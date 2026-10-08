"""Host-independent structural tests, not a substitute for compiling Swift/iOS."""
from pathlib import Path
import importlib.util
import plistlib
import re
import sqlite3
import tempfile
import unittest
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location("generator", ROOT / "scripts/generate_project.py")
generator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(generator)


def parse_openstep(text):
    tokens = re.findall(r'"(?:\\.|[^"\\])*"|//[^\n]*|/\*.*?\*/|[{}()=;,]|[^\s{}()=;,]+', text, re.S)
    tokens = [token for token in tokens if not token.startswith(("//", "/*"))]
    index = 0
    def consume(expected):
        nonlocal index
        if tokens[index] != expected:
            raise ValueError(f"Expected {expected}, got {tokens[index]}")
        index += 1
    def value():
        nonlocal index
        token = tokens[index]
        if token == "{":
            index += 1; result = {}
            while tokens[index] != "}":
                key = value(); consume("="); result[key] = value(); consume(";")
            index += 1; return result
        if token == "(":
            index += 1; result = []
            while tokens[index] != ")":
                result.append(value()); consume(",")
            index += 1; return result
        index += 1
        if token.startswith('"'):
            return re.sub(r'\\(.)', r'\1', token[1:-1])
        return int(token) if token.isdecimal() else token
    result = value()
    if index != len(tokens):
        raise ValueError("Trailing project tokens")
    return result


class ProjectTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.model = parse_openstep((ROOT / "MyKeyboard.xcodeproj/project.pbxproj").read_text(encoding="utf-8"))
        cls.objects = cls.model["objects"]

    def test_generated_settings_are_current(self):
        for path, content in generator.outputs().items():
            self.assertEqual((ROOT / path).read_bytes(), content, path)
        self.assertEqual(self.model, generator.project_model())

    def test_all_object_references_resolve(self):
        def inspect(value):
            if isinstance(value, dict):
                for child in value.values(): inspect(child)
            elif isinstance(value, list):
                for child in value: inspect(child)
            elif isinstance(value, str) and re.fullmatch(r"[A-F0-9]{24}", value):
                self.assertIn(value, self.objects)
        inspect(self.model)

    def test_files_exist_and_target_boundaries_are_correct(self):
        for obj in self.objects.values():
            if obj["isa"] == "PBXFileReference" and obj["sourceTree"] == "<group>":
                self.assertTrue((ROOT / obj["path"]).is_file(), obj["path"])
        paths_by_target = {}
        for obj in self.objects.values():
            if obj["isa"] != "PBXNativeTarget": continue
            paths = []
            for phase_id in obj["buildPhases"]:
                phase = self.objects[phase_id]
                if phase["isa"] == "PBXSourcesBuildPhase":
                    paths = [self.objects[self.objects[build]["fileRef"]]["path"] for build in phase["files"]]
            paths_by_target[obj["name"]] = paths
        self.assertFalse(any(path.startswith("App/") for path in paths_by_target["MyKeyboardExtension"]))
        self.assertFalse(any(path.startswith("KeyboardExtension/") for path in paths_by_target["MyKeyboard"]))
        self.assertTrue(any("KeyboardViewController.swift" in path for path in paths_by_target["MyKeyboardExtension"]))
        self.assertTrue(any("ClipboardStoreTests.swift" in path for path in paths_by_target["StorageTests"]))

    def test_extension_is_embedded_and_dependency_is_pinned(self):
        app = self.objects[generator.uid("target:MyKeyboard")]
        embed = [self.objects[p] for p in app["buildPhases"] if self.objects[p]["isa"] == "PBXCopyFilesBuildPhase"]
        self.assertEqual(len(embed), 1)
        self.assertEqual(embed[0]["dstSubfolderSpec"], 13)
        file = self.objects[embed[0]["files"][0]]["fileRef"]
        self.assertEqual(self.objects[file]["path"], "MyKeyboardExtension.appex")
        remote = self.objects[generator.uid("converter-package")]
        self.assertEqual(remote["requirement"]["revision"], "8278b6b76e534f1a08e4db2a11602f499d754327")
        scheme = ET.parse(ROOT / "MyKeyboard.xcodeproj/xcshareddata/xcschemes/MyKeyboard.xcscheme")
        self.assertEqual(scheme.find(".//TestableReference/BuildableReference").get("BlueprintName"), "StorageTests")

    def test_plists_privacy_and_group_agree(self):
        read = lambda path: plistlib.loads((ROOT / path).read_bytes())
        app = read("Config/MyKeyboard-Info.plist"); extension = read("Config/MyKeyboardExtension-Info.plist")
        self.assertEqual(app["SharedAppGroup"], extension["SharedAppGroup"])
        self.assertEqual(read("Config/MyKeyboard.entitlements"), read("Config/MyKeyboardExtension.entitlements"))
        self.assertEqual(extension["NSExtension"]["NSExtensionPointIdentifier"], "com.apple.keyboard-service")
        self.assertFalse(extension["EnableExperimentalHostReplacement"])
        privacy = read("Resources/PrivacyInfo.xcprivacy")
        self.assertFalse(privacy["NSPrivacyTracking"])
        self.assertEqual(privacy["NSPrivacyCollectedDataTypes"], [])

    def test_product_sources_do_not_contain_network_clients(self):
        for folder in ["Core", "App", "KeyboardExtension", "Storage", "Shared", "DesignSystem"]:
            for path in (ROOT / folder).rglob("*.swift"):
                source = path.read_text(encoding="utf-8")
                self.assertNotRegex(source, r"URLSession|NSURLConnection|import\s+(Network|CloudKit)", str(path))


class DatabaseSchemaTests(unittest.TestCase):
    def setUp(self):
        self.db = sqlite3.connect(":memory:")
        self.db.executescript((ROOT / "Storage/Clipboard/schema.sql").read_text(encoding="utf-8"))
    def tearDown(self): self.db.close()
    def insert(self, id, text, pinned=0):
        self.db.execute("INSERT INTO clipboard VALUES(?,?,?,?,?)", (id, text, 100, 100, pinned))
    def test_duplicate_and_pin_constraints(self):
        self.insert("1", "共有")
        with self.assertRaises(sqlite3.IntegrityError): self.insert("2", "共有")
        with self.assertRaises(sqlite3.IntegrityError): self.insert("3", "別", 2)
        self.assertEqual(self.db.execute("PRAGMA user_version").fetchone()[0], 1)
    def test_literal_search_and_pin_order(self):
        self.insert("1", "100%_")
        self.insert("2", "普通", 1)
        result = self.db.execute("SELECT text FROM clipboard WHERE instr(text,?)>0", ("%_",)).fetchall()
        self.assertEqual(result, [("100%_",)])
        self.assertEqual(self.db.execute("SELECT id FROM clipboard ORDER BY pinned DESC,last_used_at DESC").fetchone()[0], "2")
    def test_transaction_rollback_preserves_original(self):
        self.insert("1", "残す"); self.db.commit()
        self.db.execute("BEGIN IMMEDIATE")
        self.db.execute("DELETE FROM clipboard")
        self.db.rollback()
        self.assertEqual(self.db.execute("SELECT text FROM clipboard").fetchall(), [("残す",)])
    def test_read_only_connection_rejects_write(self):
        scratch = ROOT / ".build" / "static-tests"
        scratch.resolve().relative_to(ROOT.resolve())
        scratch.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(dir=scratch) as directory:
            Path(directory).resolve().relative_to(scratch.resolve())
            file = Path(directory) / "test.sqlite"
            writer = sqlite3.connect(file)
            writer.executescript((ROOT / "Storage/Clipboard/schema.sql").read_text(encoding="utf-8")); writer.close()
            reader = sqlite3.connect(file.as_uri() + "?mode=ro", uri=True)
            try:
                with self.assertRaises(sqlite3.OperationalError): reader.execute("DELETE FROM clipboard")
            finally: reader.close()


if __name__ == "__main__": unittest.main()
