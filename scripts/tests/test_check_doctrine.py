#!/usr/bin/env python3
"""Tests for scripts/check-doctrine.py. Run: python3 -m unittest discover -s scripts/tests"""
import json
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPTS = Path(__file__).resolve().parent.parent
GATE = SCRIPTS / "check-doctrine.py"

BALANCED = (
    "Charity is honoured as Zakat in Islam, as almsgiving in the Christian Gospels, as dana in "
    "Buddhism and as seva in Sikhism.\n"
)
ONE_SIDED = "This aligns with the Islamic principle of Zakat.\n"


def page(title, body):
    return f'---\ntitle: "{title}"\norder: 1\n---\n\n# {title}\n\n{body}'


class DoctrineGate(unittest.TestCase):
    def setUp(self):
        self.root = Path(tempfile.mkdtemp())
        (self.root / "scripts").mkdir()
        # The real rules, without the list of dedicated pages this small tree does not have.
        config = json.loads((SCRIPTS / "doctrine-gate.json").read_text(encoding="utf-8"))
        config["dedicated"] = {}
        (self.root / "scripts/doctrine-gate.json").write_text(json.dumps(config),
                                                              encoding="utf-8")
        self.write("content/1-foundations/unity.md", "All existence is one divine light.\n")
        self.write("content/4-way-of-life/old.md", ONE_SIDED)
        self.run_gate("--accept-core", "--waive-imbalance")

    def tearDown(self):
        shutil.rmtree(self.root)

    def write(self, rel, body):
        path = self.root / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(page(path.stem, body), encoding="utf-8")

    def run_gate(self, *flags):
        done = subprocess.run([sys.executable, str(GATE), "--root", str(self.root), *flags],
                              capture_output=True, text=True)
        return done.returncode, done.stdout

    def test_recorded_state_passes(self):
        code, out = self.run_gate()
        self.assertEqual(code, 0, out)

    def test_new_page_leaning_on_one_tradition_fails(self):
        self.write("content/4-way-of-life/new.md", ONE_SIDED)
        code, out = self.run_gate()
        self.assertEqual(code, 1)
        self.assertIn("new.md: out of balance: names Islam and no other tradition", out)

    def test_new_balanced_page_passes(self):
        self.write("content/4-way-of-life/new.md", BALANCED)
        code, out = self.run_gate()
        self.assertEqual(code, 0, out)

    def test_page_naming_no_tradition_passes(self):
        self.write("content/4-way-of-life/new.md", "Be grateful each morning.\n")
        code, out = self.run_gate()
        self.assertEqual(code, 0, out)

    def test_editing_a_waived_page_voids_the_waiver(self):
        self.write("content/4-way-of-life/old.md", ONE_SIDED + "\nA second paragraph.\n")
        code, out = self.run_gate()
        self.assertEqual(code, 1)
        self.assertIn("old.md: this page changed and is still out of balance", out)

    def test_balancing_a_waived_page_asks_for_the_waiver_to_go(self):
        self.write("content/4-way-of-life/old.md", BALANCED)
        code, out = self.run_gate()
        self.assertEqual(code, 1)
        self.assertIn("old.md: the recorded imbalance is cleared", out)

    def test_page_dominated_by_one_tradition_fails(self):
        self.write("content/4-way-of-life/new.md",
                   "Islam, the Qur'an, Tawhid, Ummah and Zakat, and also Buddhism.\n")
        code, out = self.run_gate()
        self.assertEqual(code, 1)
        self.assertIn("Islam carries 83%", out)

    def test_link_targets_are_not_counted(self):
        self.write("content/4-way-of-life/new.md", "See [the figures](muhammad.md).\n")
        code, out = self.run_gate()
        self.assertEqual(code, 0, out)

    def test_contrary_language_fails(self):
        for body, rule in (
            ("This is the one true religion.\n", "exclusive-truth"),
            ("Our path is superior to all other religions.\n", "ranking-comparison"),
            ("The scripture is inerrant.\n", "scriptural-literalism"),
            ("Followers should reject modern medicine.\n", "against-medicine"),
            ("The wicked face eternal damnation.\n", "eternal-punishment"),
        ):
            with self.subTest(rule=rule):
                self.write("content/4-way-of-life/new.md", body)
                code, out = self.run_gate()
                self.assertEqual(code, 1)
                self.assertIn(f"[{rule}]", out)

    def test_changed_core_page_fails(self):
        self.write("content/1-foundations/unity.md", "All existence is many things.\n")
        code, out = self.run_gate()
        self.assertEqual(code, 1)
        self.assertIn("unity.md: a core page changed", out)

    def test_new_and_removed_core_pages_fail(self):
        self.write("content/1-foundations/extra.md", "A new belief.\n")
        (self.root / "content/1-foundations/unity.md").unlink()
        code, out = self.run_gate()
        self.assertEqual(code, 1)
        self.assertIn("extra.md: a new core page", out)
        self.assertIn("unity.md: a core page was removed or renamed", out)

    def test_whitespace_only_change_to_core_passes(self):
        path = self.root / "content/1-foundations/unity.md"
        path.write_text(path.read_text(encoding="utf-8") + "\n\n", encoding="utf-8")
        code, out = self.run_gate()
        self.assertEqual(code, 0, out)


if __name__ == "__main__":
    unittest.main()
