import importlib.util
import pathlib
import unittest


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


if __name__ == "__main__":
    unittest.main()
