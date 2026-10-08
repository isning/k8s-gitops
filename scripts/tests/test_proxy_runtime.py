"""Offline checks for API isolation and last-good subscription recovery."""
import contextlib
import io
import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import yaml

ROOT = Path(__file__).resolve().parents[2]
CONFIG = ROOT / 'infra/controllers/general/base/egress/proxy-engine'


class RuntimeTests(unittest.TestCase):
    def setUp(self):
        script = yaml.safe_load((CONFIG / 'sub-converter-script-config.yaml').read_text())['data']['update_sub.py']
        self.module = {}
        with patch.dict(os.environ, {'SUB_URLS': 'https://subscription.invalid/test'}):
            exec(compile(script.split('started = time.time()')[0], 'update_sub.py', 'exec'), self.module)
        cache = ROOT / '.cache/ccsn-migration/test-runtime'
        cache.mkdir(parents=True, exist_ok=True)
        self.tmp = tempfile.TemporaryDirectory(dir=cache)
        self.addCleanup(self.tmp.cleanup)
        for key in ('OUTPUT_PATH', 'LAST_GOOD_PATH', 'RUNTIME_PATH', 'MAIN_PATH', 'RUNTIME_MAIN_PATH', 'LOCK_PATH'):
            self.module[key] = str(Path(self.tmp.name) / key)
        self.main = json.loads(yaml.safe_load((CONFIG / 'singbox-main.yaml').read_text())['data']['main.json'])
        Path(self.module['MAIN_PATH']).write_text(json.dumps(self.main))

    def test_api_guard_covers_loopback_dual_stack_and_every_dns_resolution(self):
        with patch.dict(os.environ, {'POD_IPS': '10.42.0.1,fd00::1'}):
            self.module['write_runtime_config']({'outbounds': [{'tag': 'test'}]})
        runtime = json.loads(Path(self.module['RUNTIME_MAIN_PATH']).read_text())
        rules = runtime['route']['rules']
        guard = rules[0]
        self.assertEqual(guard['action'], 'reject')
        self.assertTrue({'127.0.0.0/8', '::1/128', '10.42.0.1/32', 'fd00::1/128'}.issubset(guard['ip_cidr']))
        self.assertEqual(guard['port'], [9090])
        for i, rule in enumerate(rules):
            if rule.get('action') == 'resolve':
                self.assertEqual(rules[i + 1], guard)

    def test_public_profiles_route_direct_before_subscription_default(self):
        rules = self.main['route']['rules']
        for inbound in ('public-egress-http-ipv4', 'public-egress-http-ipv6'):
            self.assertTrue(any(inbound in r.get('inbound', []) and r.get('outbound') == 'direct' for r in rules))

    def test_fallback_keeps_shared_last_good_snapshot(self):
        good = {'outbounds': [{'type': 'direct', 'tag': 'saved'}]}
        self.module['publish_config'](good)
        recovered = self.module['load_last_good_if_exists']()
        self.assertEqual(recovered, good)
        self.module['write_runtime_config'](recovered)
        self.assertEqual(json.loads(Path(self.module['LAST_GOOD_PATH']).read_text()), good)
        self.assertEqual(json.loads(Path(self.module['RUNTIME_PATH']).read_text()), good)

    def test_invalid_cache_is_rejected(self):
        Path(self.module['LAST_GOOD_PATH']).write_text('{"outbounds": []}')
        with self.assertRaises(self.module['FetchNodesError']):
            self.module['load_last_good_if_exists']()


if __name__ == '__main__':
    unittest.main()
