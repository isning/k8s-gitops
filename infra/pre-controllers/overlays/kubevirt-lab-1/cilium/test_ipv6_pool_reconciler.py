import importlib.util
import pathlib
import unittest
from unittest.mock import patch
from urllib.error import HTTPError


SCRIPT = pathlib.Path(__file__).with_name("ipv6-pool-reconciler.py")
SPEC = importlib.util.spec_from_file_location("ipv6_pool_reconciler", SCRIPT)
assert SPEC is not None and SPEC.loader is not None
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class PoolAddressTest(unittest.TestCase):
    def test_preserves_current_node_prefix(self):
        result = MODULE.desired_pool_cidr(
            ["192.168.1.101", "2409:8a04:a022:4c30:8c64:72bc:1b03:f3fd"],
            "caf0",
        )
        self.assertEqual(str(result), "2409:8a04:a022:4c30:caf0::/112")

    def test_rejects_multiple_public_prefixes(self):
        with self.assertRaisesRegex(RuntimeError, "expected one"):
            MODULE.desired_pool_cidr(
                ["2409:8a04:a022:4c30::1", "2409:8a04:a023:1111::1"],
                "caf0",
            )

    def test_rejects_no_global_address(self):
        with self.assertRaises(RuntimeError):
            MODULE.desired_pool_cidr(["fe80::1", "fd00::1"], "caf0")


class HostSourceTest(unittest.TestCase):
    source = "2409:8a04:a01b:6d70::1234"

    def address_line(self, flags="01", prefix="40", interface="ovsbr1"):
        raw = MODULE.ipaddress.IPv6Address(self.source).packed.hex()
        return f"{raw} 05 {prefix} 00 {flags} {interface}\n"

    def test_accepts_preferred_temporary_address(self):
        self.assertEqual(MODULE.validate_source(self.source, "ovsbr1", self.address_line()), self.source)

    def test_rejects_deprecated_tentative_failed_or_optimistic(self):
        for flags in ["21", "40", "08", "04"]:
            with self.subTest(flags=flags), self.assertRaises(RuntimeError):
                MODULE.validate_source(self.source, "ovsbr1", self.address_line(flags=flags))

    def test_rejects_wrong_interface_or_prefix_length(self):
        for line in [self.address_line(interface="tailscale0"), self.address_line(prefix="80")]:
            with self.assertRaises(RuntimeError):
                MODULE.validate_source(self.source, "ovsbr1", line)

    def test_rejects_non_global_source(self):
        with self.assertRaises(RuntimeError):
            MODULE.validate_source("fd00::1", "ovsbr1", "")

    def test_uses_host_route_without_reading_node_api_or_sending_packets(self):
        with patch.object(MODULE.socket, "socket") as factory, \
             patch("builtins.open", unittest.mock.mock_open(read_data=self.address_line())), \
             patch.dict(MODULE.os.environ, {"IPV6_INTERFACE": "ovsbr1", "IPV6_ROUTE_TARGET": "2001:4860:4860::8888"}), \
             patch.object(MODULE, "request") as api:
            probe = factory.return_value.__enter__.return_value
            probe.getsockname.return_value = (self.source, 12345, 0, 0)
            self.assertEqual(MODULE.host_ipv6_source(), self.source)
            probe.send.assert_not_called()
            probe.sendto.assert_not_called()
            api.assert_not_called()

    def test_discovery_failure_never_mutates_pool(self):
        with patch("sys.argv", ["reconcile.py"]), \
             patch.dict(MODULE.os.environ, {"POOL_NAME": "default-public-ipv6-pool"}), \
             patch.object(MODULE, "host_ipv6_source", side_effect=OSError("no IPv6 route")), \
             patch.object(MODULE, "request") as api, self.assertRaises(OSError):
            MODULE.main()
        api.assert_not_called()

    def test_prefix_rotation_follows_new_kernel_source(self):
        old = self.source
        new = "2409:8a04:a023:1111::1234"
        for source in [old, new]:
            row = f"{MODULE.ipaddress.IPv6Address(source).packed.hex()} 05 40 00 01 ovsbr1"
            selected = MODULE.validate_source(source, "ovsbr1", row)
            desired = MODULE.desired_pool_cidr([selected], "caf0")
            self.assertEqual(desired.supernet(new_prefix=64), MODULE.ipaddress.IPv6Network((source, 64), strict=False))


class PoolReconcileTest(unittest.TestCase):
    desired = MODULE.ipaddress.IPv6Network("2409:8a04:a01b:6d70:caf0::/112")
    name = "default-public-ipv6-pool"

    def pool(self, cidr=None):
        return {"metadata": {"annotations": {MODULE.OWNER_ANNOTATION: MODULE.OWNER}},
                "spec": {"allowFirstLastIPs": "No", "blocks": [{"cidr": cidr or str(self.desired)}]}}

    def test_no_write_when_unchanged(self):
        with patch.object(MODULE, "request", return_value=self.pool()) as api:
            MODULE.ensure_pool(self.name, self.desired)
            self.assertEqual(api.call_count, 1)

    def test_prefix_change_updates_only_owned_pool(self):
        with patch.object(MODULE, "request", return_value=self.pool("2409:8a04:a022:4c30:caf0::/112")) as api:
            MODULE.ensure_pool(self.name, self.desired)
            self.assertEqual(api.call_count, 2)
            self.assertEqual(api.call_args.args[1], "PATCH")
            self.assertEqual(api.call_args.args[2]["spec"]["blocks"], [{"cidr": str(self.desired)}])

    def test_rejects_unmarked_existing_pool(self):
        pool = self.pool()
        pool["metadata"]["annotations"] = {}
        with patch.object(MODULE, "request", return_value=pool) as api, self.assertRaisesRegex(RuntimeError, "unowned"):
            MODULE.ensure_pool(self.name, self.desired)
        self.assertEqual(api.call_count, 1)

    def test_creates_pool_on_fresh_cluster(self):
        missing = HTTPError("", 404, "NotFound", {}, None)
        with patch.object(MODULE, "request", side_effect=[missing, self.pool()]) as api:
            MODULE.ensure_pool(self.name, self.desired)
            self.assertEqual(api.call_args.args[1], "POST")
            self.assertEqual(api.call_args.args[2]["metadata"]["annotations"][MODULE.OWNER_ANNOTATION], MODULE.OWNER)

    def test_check_never_writes(self):
        for existing in [self.pool("2409:8a04:a022:4c30:caf0::/112"), HTTPError("", 404, "", {}, None)]:
            with patch.object(MODULE, "request", side_effect=[existing]) as api:
                MODULE.ensure_pool(self.name, self.desired, check=True)
                self.assertEqual(api.call_count, 1)

    def test_forbidden_is_not_treated_as_missing(self):
        with patch.object(MODULE, "request", side_effect=HTTPError("", 403, "", {}, None)) as api, self.assertRaises(HTTPError):
            MODULE.ensure_pool(self.name, self.desired)
        self.assertEqual(api.call_count, 1)

    def test_failed_notification_does_not_record_success(self):
        with patch.dict(MODULE.os.environ, {"EDGEONE_TERRAFORM_NAMESPACE": "prod", "EDGEONE_TERRAFORM_NAME": "coder-edgeone-control"}), \
             patch.object(MODULE, "request", side_effect=RuntimeError("API unavailable")) as api, self.assertRaises(RuntimeError):
            MODULE.notify_edgeone("/pool", self.desired)
        self.assertEqual(api.call_count, 1)

    def test_waits_for_missing_or_old_service_addresses(self):
        for addresses, expected in [([], False), (["2409:8a04:a022:4c30:caf0::1"], False),
                                    (["2409:8a04:a01b:6d70:caf1::1"], False),
                                    (["2409:8a04:a01b:6d70:caf0::1"], True)]:
            service = {"spec": {"type": "LoadBalancer", "ipFamilies": ["IPv6"]},
                       "status": {"loadBalancer": {"ingress": [{"ip": ip} for ip in addresses]}}}
            with patch.object(MODULE, "request", return_value={"items": [service]}):
                self.assertEqual(MODULE.services_use_prefix(self.desired), expected)


if __name__ == "__main__":
    unittest.main()
