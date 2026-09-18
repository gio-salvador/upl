#!/usr/bin/env python3
"""Tests for scripts/check-infra.py. Run: python3 -m unittest discover -s scripts/tests"""
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent.parent
GATE = REPO / "scripts" / "check-infra.py"


class InfraGate(unittest.TestCase):
    """Each test weakens a copy of the real infra/ in one way and expects the gate to say so."""

    def setUp(self):
        self.root = Path(tempfile.mkdtemp()) / "infra"
        shutil.copytree(REPO / "infra", self.root, ignore=shutil.ignore_patterns(".terraform"))
        self.addCleanup(shutil.rmtree, self.root.parent)

    def run_gate(self):
        return subprocess.run([sys.executable, str(GATE), "--root", str(self.root)], capture_output=True, text=True)

    def edit(self, name, old, new):
        path = self.root / name
        text = path.read_text(encoding="utf-8")
        self.assertIn(old, text, f"{name} no longer contains the text this test weakens")
        path.write_text(text.replace(old, new, 1), encoding="utf-8")

    def assert_fails_with(self, fragment):
        result = self.run_gate()
        self.assertEqual(result.returncode, 1, result.stdout)
        self.assertIn(fragment, result.stdout)

    def test_the_real_infra_passes(self):
        result = self.run_gate()
        self.assertEqual(result.returncode, 0, result.stdout)

    def test_a_secret_variable_that_is_not_sensitive_fails(self):
        self.edit("variables.tf", "  type        = string\n  sensitive   = true\n}", "  type        = string\n}")
        self.assert_fails_with('"cloudflare_api_token" looks like a secret')

    def test_a_default_on_a_sensitive_variable_fails(self):
        self.edit("variables.tf", "  sensitive   = true\n", '  sensitive   = true\n  default     = "x"\n')
        self.assert_fails_with("must not have a default")

    def test_a_literal_api_token_fails(self):
        self.edit("providers.tf", "api_token = var.cloudflare_api_token", 'api_token = "not-a-real-token"')
        self.assert_fails_with("api_token is set to a literal")

    def test_a_provider_version_range_fails(self):
        self.edit("providers.tf", 'version = "5.18.0"', 'version = "~> 5.18"')
        self.assert_fails_with("is a range")

    def test_a_missing_lock_file_fails(self):
        (self.root / ".terraform.lock.hcl").unlink()
        self.assert_fails_with(".terraform.lock.hcl is missing")

    def test_a_committed_state_bucket_fails(self):
        self.edit("backend.tf", '    region                      = "auto"\n',
                  '    region                      = "auto"\n    bucket                      = "state"\n')
        self.assert_fails_with("backend setting bucket is committed")

    def test_a_commented_out_setting_is_not_a_finding(self):
        self.edit("backend.tf", "terraform {", '#   bucket = "only-a-comment"\nterraform {')
        self.assertEqual(self.run_gate().returncode, 0)

    def test_weakened_dmarc_fails(self):
        self.edit("domain.tf", "p=reject; sp=reject", "p=none; sp=none")
        self.assert_fails_with("DMARC")

    def test_softened_spf_fails(self):
        self.edit("domain.tf", "v=spf1 -all", "v=spf1 ~all")
        self.assert_fails_with("SPF")

    def test_dnssec_switched_off_fails(self):
        self.edit("domain.tf", 'status  = "active"', 'status  = "disabled"')
        self.assert_fails_with("DNSSEC")

    def test_an_unsafe_default_fails(self):
        self.edit("variables.tf", "Set to false before the domain is ever used for email. No effect while site_domain is empty.\"\n  type        = bool\n  default     = true",
                  "Set to false before the domain is ever used for email. No effect while site_domain is empty.\"\n  type        = bool\n  default     = false")
        self.assert_fails_with('"site_domain_no_email" must default to true')


if __name__ == "__main__":
    unittest.main()
