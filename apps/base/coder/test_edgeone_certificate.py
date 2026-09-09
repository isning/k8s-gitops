import importlib.util
import pathlib
import types
import unittest
from datetime import datetime, timedelta, timezone
from unittest import mock


SCRIPT = pathlib.Path(__file__).with_name("edgeone-certificate.py")
SPEC = importlib.util.spec_from_file_location("edgeone_certificate", SCRIPT)
assert SPEC is not None and SPEC.loader is not None
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class ChallengeValidationTest(unittest.TestCase):
    def test_accepts_expected_delegation(self):
        MODULE.validate_challenge(
            "_acme-challenge.coder.isning.moe",
            "CNAME",
            "validation.example.eo.dnse0.com",
        )

    def test_rejects_record_outside_managed_zone(self):
        with self.assertRaisesRegex(RuntimeError, "unsafe challenge name"):
            MODULE.validate_challenge(
                "_acme-challenge.example.com",
                "CNAME",
                "validation.example.eo.dnse0.com",
            )

    def test_rejects_non_cname_record(self):
        with self.assertRaisesRegex(RuntimeError, "unsupported challenge record type"):
            MODULE.validate_challenge(
                "_acme-challenge.coder.isning.moe",
                "TXT",
                "unexpected",
            )


class DnsEndpointTest(unittest.TestCase):
    @mock.patch.object(MODULE, "kubernetes_request")
    @mock.patch.object(MODULE, "get_dns_endpoint", return_value=None)
    def test_creates_unproxied_cloudflare_cname(self, _get, request):
        MODULE.reconcile_dns_endpoint(
            "coder-edgeone-acme",
            "_acme-challenge.coder.isning.moe.",
            "CNAME",
            "validation.example.eo.dnse0.com",
        )

        path, method, body = request.call_args.args
        self.assertEqual(path, MODULE.dns_endpoint_path())
        self.assertEqual(method, "POST")
        endpoint = body["spec"]["endpoints"][0]
        self.assertEqual(endpoint["dnsName"], "_acme-challenge.coder.isning.moe")
        self.assertEqual(endpoint["targets"], ["validation.example.eo.dnse0.com"])
        self.assertEqual(endpoint["providerSpecific"][0]["value"], "false")
        self.assertIn(MODULE.ORDER_CREATED_AT_ANNOTATION, body["metadata"]["annotations"])


class CertificateStateTest(unittest.TestCase):
    @mock.patch.object(MODULE, "check_certificate")
    def test_requires_common_name_and_expiry(self, check):
        check.return_value = types.SimpleNamespace(
            CommonName="*.coder.isning.moe",
            ExpireTime="2026-12-01T00:00:00Z",
        )
        self.assertTrue(MODULE.certificate_is_verified(object(), "zone", "*.coder.isning.moe"))

    def test_rejects_certificate_for_another_domain(self):
        response = types.SimpleNamespace(
            CommonName="other.isning.moe",
            ExpireTime="2026-12-01T00:00:00Z",
        )
        self.assertFalse(MODULE.certificate_response_is_verified(response, "*.coder.isning.moe"))


class OrderResumeTest(unittest.TestCase):
    def test_recent_order_is_resumed(self):
        now = datetime(2026, 9, 9, tzinfo=timezone.utc)
        endpoint = {
            "metadata": {
                "annotations": {
                    MODULE.ORDER_CREATED_AT_ANNOTATION: (now - timedelta(hours=24)).isoformat(),
                }
            }
        }
        self.assertTrue(MODULE.order_is_fresh(endpoint, now))

    def test_old_order_is_replaced(self):
        now = datetime(2026, 9, 9, tzinfo=timezone.utc)
        endpoint = {
            "metadata": {
                "annotations": {
                    MODULE.ORDER_CREATED_AT_ANNOTATION: (now - timedelta(hours=49)).isoformat(),
                }
            }
        }
        self.assertFalse(MODULE.order_is_fresh(endpoint, now))


if __name__ == "__main__":
    unittest.main()
