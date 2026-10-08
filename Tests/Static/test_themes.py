"""Validate shipped palette contrast and design-system target ownership; Swift remains unexecuted."""
from pathlib import Path
import re
import unittest
from test_repository import generator

ROOT = Path(__file__).resolve().parents[2]

def luminance(hex_color):
    channels = [int(hex_color[i:i+2], 16) / 255 for i in (1, 3, 5)]
    linear = [v / 12.92 if v <= .04045 else ((v + .055) / 1.055) ** 2.4 for v in channels]
    return sum(v * weight for v, weight in zip(linear, (.2126, .7152, .0722)))

def contrast(a, b):
    a, b = luminance(a), luminance(b)
    return (max(a, b) + .05) / (min(a, b) + .05)

class ThemeStructureTests(unittest.TestCase):
    def test_shipped_palettes_are_legible(self):
        source = (ROOT / "Core/Theme/ThemeTokens.swift").read_text(encoding="utf-8")
        palettes = re.findall(r'\.init\(background: "(#[A-F0-9]{6})", key: "(#[A-F0-9]{6})", text: "(#[A-F0-9]{6})", accent: "(#[A-F0-9]{6})"', source)
        self.assertEqual(len(palettes), 5)
        for background, key, text, accent in palettes:
            with self.subTest(background=background):
                self.assertGreaterEqual(contrast(key, text), 4.5)
                self.assertGreaterEqual(contrast(background, text), 4.5)
                self.assertGreaterEqual(contrast(background, accent), 4.5)

    def test_design_sources_belong_to_products_and_ui_tests(self):
        objects = generator.project_model()["objects"]
        expected = {p.relative_to(ROOT).as_posix() for p in (ROOT / "DesignSystem").rglob("*.swift")}
        self.assertTrue(expected)
        for name in ("MyKeyboard", "MyKeyboardExtension", "StorageTests"):
            phase = objects[generator.uid("sources:" + name)]
            paths = {objects[objects[build]["fileRef"]]["path"] for build in phase["files"]}
            self.assertEqual(paths & expected, expected)
            self.assertIn("Storage/Preferences/ThemeStore.swift", paths)

    def test_appearance_has_no_input_dependencies(self):
        for folder in ("Core/Theme", "DesignSystem"):
            for file in (ROOT / folder).rglob("*.swift"):
                self.assertNotRegex(file.read_text(encoding="utf-8"), r'AzooKeyConversion|UITextDocumentProxy|Composition\(')
        self.assertNotIn("DesignSystem", (ROOT / "Package.swift").read_text(encoding="utf-8"))

if __name__ == "__main__":
    unittest.main()
