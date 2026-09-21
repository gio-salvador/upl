#!/usr/bin/env python3
"""Tests for scripts/check-sources.py. Run: python3 -m unittest discover -s scripts/tests"""
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

GATE = Path(__file__).resolve().parent.parent / "check-sources.py"
HEAD = "| Id | Source | Kind | Supports | Used in | Looked at |\n| --- | --- | --- | --- | --- | --- |\n"
ROW = "| S01 | [A study](https://example.org/study) | primary | Belief eases pain | [notes.md](notes.md) | 2026-09-21 |\n"
BOOKS = "\n| Id | Entry as listed | Standing |\n| --- | --- | --- |\n| R01 | \"A Book\" by An Author | Not checked |\n"
REFERENCES = '---\ntitle: "References"\norder: 4\n---\n\n# References\n\n- "A Book" by An Author\n'


class SourceGate(unittest.TestCase):
    def setUp(self):
        self.root = Path(tempfile.mkdtemp())
        self.write("docs/sources.md", "# Source register\n\n" + HEAD + ROW + BOOKS)
        self.write("docs/notes.md", "# Notes\n\nBelief eases pain (S01).\n")
        self.write("content/5-context/references.md", REFERENCES)

    def tearDown(self):
        shutil.rmtree(self.root)

    def write(self, path, text):
        target = self.root / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(text, encoding="utf-8")

    def run_gate(self, *args):
        return subprocess.run([sys.executable, str(GATE), "--root", str(self.root), "--today", "2026-09-22", *args],
                              capture_output=True, text=True)

    def test_clean_tree_passes(self):
        result = self.run_gate()
        self.assertEqual(result.returncode, 0, result.stdout)

    def test_loose_link_in_a_teaching_fails(self):
        self.write("content/3-practice/prayer.md", "# Prayer\n\nSee [a site](https://example.com/prayer).\n")
        result = self.run_gate()
        self.assertEqual(result.returncode, 1)
        self.assertIn("is not in docs/sources.md", result.stdout)

    def test_link_inside_code_is_not_a_source(self):
        self.write("content/3-practice/prayer.md", "# Prayer\n\nBuilt with `SITE=https://example.com`.\n")
        self.assertEqual(self.run_gate().returncode, 0)

    def test_unknown_id_fails(self):
        self.write("docs/notes.md", "# Notes\n\nBelief eases pain (S01), and more (S09).\n")
        result = self.run_gate()
        self.assertEqual(result.returncode, 1)
        self.assertIn("cites S09", result.stdout)

    def test_source_cited_nowhere_fails(self):
        self.write("docs/notes.md", "# Notes\n\nNothing cited.\n")
        result = self.run_gate()
        self.assertEqual(result.returncode, 1)
        self.assertIn("S01 is cited nowhere", result.stdout)

    def test_incomplete_row_fails(self):
        self.write("docs/sources.md", "# Source register\n\n" + HEAD
                   + "| S01 | [A study](https://example.org/study) | primary | | [notes.md](notes.md) | last week |\n" + BOOKS)
        result = self.run_gate()
        self.assertEqual(result.returncode, 1)
        self.assertIn("empty Supports cell", result.stdout)
        self.assertIn("YYYY-MM-DD", result.stdout)

    def test_used_in_must_exist(self):
        self.write("docs/sources.md", "# Source register\n\n" + HEAD + ROW.replace("notes.md](notes.md)", "gone.md](gone.md)") + BOOKS)
        result = self.run_gate()
        self.assertIn("gone.md, which does not exist", result.stdout)

    def test_new_reference_needs_a_row(self):
        self.write("content/5-context/references.md", REFERENCES + '- "Another Book" by Someone Else\n')
        result = self.run_gate()
        self.assertEqual(result.returncode, 1)
        self.assertIn("has no row in docs/sources.md", result.stdout)

    def test_removed_reference_needs_the_row_updated(self):
        self.write("content/5-context/references.md", REFERENCES.replace('- "A Book" by An Author\n', ""))
        result = self.run_gate()
        self.assertEqual(result.returncode, 1)
        self.assertIn("no longer in content/5-context/references.md", result.stdout)

    def test_old_source_is_a_note_not_a_failure(self):
        self.write("docs/sources.md", "# Source register\n\n" + HEAD + ROW.replace("2026-09-21", "2024-01-01") + BOOKS)
        result = self.run_gate()
        self.assertEqual(result.returncode, 0, result.stdout)
        self.assertIn("read it again", result.stdout)


if __name__ == "__main__":
    unittest.main()
