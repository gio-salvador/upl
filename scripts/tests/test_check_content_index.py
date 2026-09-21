#!/usr/bin/env python3
"""Tests for scripts/check-content-index.py. Run: python3 -m unittest discover -s scripts/tests"""
import json
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

GATE = Path(__file__).resolve().parent.parent / "check-content-index.py"
KARMA = "content/2-doctrine/karma.md"
SHARED = ("Each thought and each intention weaves the fabric of the soul and shapes the conditions "
          "it will meet on the long road towards enlightenment.\n")


def page(title, body):
    return f'---\ntitle: "{title}"\norder: 1\n---\n\n# {title}\n\n{body}'


class ContentIndexGate(unittest.TestCase):
    def setUp(self):
        self.root = Path(tempfile.mkdtemp())
        (self.root / "scripts").mkdir()
        (self.root / "docs").mkdir()
        self.write(KARMA, page("Karma", "Karma is the law of moral cause and effect.\n"))
        self.index = {
            "concepts": {"karma": {"label": "Karma", "owner": KARMA, "terms": ["karma"]}},
            "findings": [],
            "pages": {},
        }
        self.save()
        self.run_gate("--record")

    def tearDown(self):
        shutil.rmtree(self.root)

    def write(self, path, text):
        target = self.root / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(text, encoding="utf-8")

    def save(self):
        (self.root / "scripts/content-index.json").write_text(json.dumps(self.index), encoding="utf-8")

    def reload(self):
        self.index = json.loads((self.root / "scripts/content-index.json").read_text(encoding="utf-8"))

    def run_gate(self, *args):
        return subprocess.run([sys.executable, str(GATE), "--root", str(self.root), *args],
                              capture_output=True, text=True)

    def test_recorded_tree_passes(self):
        self.assertEqual(self.run_gate().returncode, 0)

    def test_new_page_fails_until_recorded(self):
        self.write("content/2-doctrine/dharma.md", page("Dharma", "Dharma is the path of duty.\n"))
        result = self.run_gate()
        self.assertEqual(result.returncode, 1)
        self.assertIn("not in scripts/content-index.json", result.stdout)
        self.assertEqual(self.run_gate("--record").returncode, 0)

    def test_changed_page_fails_until_recorded(self):
        self.write(KARMA, page("Karma", "Karma is the law of cause and effect, and more.\n"))
        result = self.run_gate()
        self.assertEqual(result.returncode, 1)
        self.assertIn("changed since the index was last recorded", result.stdout)

    def test_owner_must_name_its_concept(self):
        self.write(KARMA, page("Cause and effect", "Every action has its fruit.\n"))
        result = self.run_gate("--record")
        self.assertIn("never names the concept", result.stdout)

    def test_same_title_needs_a_finding(self):
        other = "content/3-practice/karma.md"
        self.write(other, page("Karma", "Living with karma in mind.\n"))
        result = self.run_gate("--record")
        self.assertIn("same title", result.stdout)
        self.reload()
        self.index["findings"].append({"id": "X1", "type": "ambiguous", "status": "open",
                                       "pages": [KARMA, other], "note": "Same title."})
        self.save()
        self.assertEqual(self.run_gate("--record").returncode, 0)

    def test_shared_wording_needs_a_finding(self):
        self.write(KARMA, page("Karma", "Karma. " + SHARED))
        self.write("content/2-doctrine/soul.md", page("Soul", SHARED))
        result = self.run_gate("--record")
        self.assertEqual(result.returncode, 1)
        self.assertIn("runs of identical wording", result.stdout)

    def test_deprecated_page_needs_a_replacement_and_no_inbound_links(self):
        old = "content/2-doctrine/old-karma.md"
        self.write(old, page("The old law", "Superseded.\n"))
        self.write("content/2-doctrine/README.md", page("Doctrine", "See [the old law](old-karma.md).\n"))
        self.run_gate("--record")
        self.reload()
        self.index["pages"][old]["status"] = "deprecated"
        self.save()
        result = self.run_gate("--render")
        self.assertIn("must name a current page in replaced_by", result.stdout)
        self.assertIn("links to deprecated page", result.stdout)

    def map_setup(self, cells, body="Karma is the law of moral cause and effect, as Hinduism teaches.\n"):
        self.write(KARMA, page("Karma", body))
        self.write("scripts/doctrine-gate.json", json.dumps({"traditions": {"Hinduism": ["hindu\\w*"], "Buddhism": ["buddh\\w*"]}}))
        self.write("docs/sources.md", "| Id | Source |\n| --- | --- |\n| S01 | A text |\n")
        self.reload()
        self.index["concepts"]["karma"]["held_by"] = cells
        self.save()
        return self.run_gate("--record")

    def test_convergence_map_passes_when_sourced(self):
        result = self.map_setup({"Hinduism": {"relation": "origin", "sources": ["S01"]}})
        self.assertEqual(result.returncode, 0, result.stdout)
        view = (self.root / "docs/cross-reference.md").read_text(encoding="utf-8")
        self.assertIn("## Convergence map", view)

    def test_convergence_cell_needs_a_known_source_and_a_note(self):
        result = self.map_setup({"Hinduism": {"relation": "origin", "sources": ["S09"]},
                                 "Buddhism": {"relation": "resembles", "sources": ["S01"]}})
        self.assertIn("source S09 is not in docs/sources.md", result.stdout)
        self.assertIn("needs a note saying how it differs", result.stdout)

    def test_inherited_teaching_names_its_origin(self):
        result = self.map_setup({"Hinduism": {"relation": "origin", "sources": ["S01"]},
                                 "Buddhism": {"relation": "inherits", "sources": ["S01"], "from": "Taoism"}})
        self.assertIn("names in \"from\" a tradition that holds it", result.stdout)

    def test_tradition_named_on_the_page_needs_a_cell(self):
        result = self.map_setup({"Hinduism": {"relation": "origin", "sources": ["S01"]}},
                                body="Karma, as Hinduism and Buddhism teach.\n")
        self.assertIn("names Buddhism, which has no cell", result.stdout)

    def test_stale_view_fails(self):
        (self.root / "docs/cross-reference.md").write_text("stale\n", encoding="utf-8")
        result = self.run_gate()
        self.assertEqual(result.returncode, 1)
        self.assertIn("out of date", result.stdout)

    def test_accepted_finding_needs_a_reason(self):
        self.index["findings"].append({"id": "X1", "type": "redundant", "status": "accepted",
                                       "pages": [KARMA], "note": "Kept."})
        self.reload_pages_and_save()
        self.assertIn("needs a reason", self.run_gate("--render").stdout)

    def reload_pages_and_save(self):
        findings = self.index["findings"]
        self.reload()
        self.index["findings"] = findings
        self.save()


if __name__ == "__main__":
    unittest.main()
