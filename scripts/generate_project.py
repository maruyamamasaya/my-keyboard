"""Deterministic, dependency-free Xcode project generator. Xcode validation is still required."""
from pathlib import Path
import argparse
import hashlib
import plistlib
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
REVISION = "8278b6b76e534f1a08e4db2a11602f499d754327"
CONVERTER_URL = "https://github.com/azooKey/AzooKeyKanaKanjiConverter"


def uid(key):
    return hashlib.sha256(key.encode()).hexdigest()[:24].upper()


def serialize(value, depth=0):
    indent = "\t" * depth
    if isinstance(value, dict):
        return "{\n" + "".join(f'{indent}\t{serialize(k)} = {serialize(v, depth + 1)};\n' for k, v in value.items()) + indent + "}"
    if isinstance(value, list):
        return "(\n" + "".join(f'{indent}\t{serialize(v, depth + 1)},\n' for v in value) + indent + ")"
    if isinstance(value, int):
        return str(value)
    return '"' + str(value).replace("\\", "\\\\").replace('"', '\\"') + '"'


def project_model():
    objects = {}

    def add(key, isa, **fields):
        identifier = uid(key)
        objects[identifier] = dict(isa=isa, **fields)
        return identifier

    files = {}
    def file(path):
        if path not in files:
            suffix = Path(path).suffix
            kind = {".swift": "sourcecode.swift", ".xcconfig": "text.xcconfig", ".plist": "text.plist.xml", ".entitlements": "text.plist.entitlements"}.get(suffix, "text")
            files[path] = add("file:" + path, "PBXFileReference", lastKnownFileType=kind, path=path, sourceTree="<group>")
        return files[path]

    shared = sorted(str(p.relative_to(ROOT)).replace("\\", "/") for folder in ["Shared", "Storage"] for p in (ROOT / folder).rglob("*.swift"))
    design = sorted(str(p.relative_to(ROOT)).replace("\\", "/") for p in (ROOT / "DesignSystem").rglob("*.swift"))
    resources = ["Resources/PrivacyInfo.xcprivacy", "Resources/ThirdPartyNotices.txt", "Storage/Clipboard/schema.sql"]
    xcconfig = file("Config/Project.xcconfig")
    local_package = add("local-package", "XCLocalSwiftPackageReference", relativePath=".")
    remote_package = add("converter-package", "XCRemoteSwiftPackageReference", repositoryURL=CONVERTER_URL, requirement={"kind": "revision", "revision": REVISION})
    products = []
    targets = []

    def configs(key, settings):
        references = []
        for name in ["Debug", "Release"]:
            values = dict(settings)
            values["SWIFT_OPTIMIZATION_LEVEL"] = "-Onone" if name == "Debug" else "-O"
            values["SWIFT_ACTIVE_COMPILATION_CONDITIONS"] = "$(inherited) DEBUG" if name == "Debug" else "$(inherited)"
            values["DEBUG_INFORMATION_FORMAT"] = "dwarf" if name == "Debug" else "dwarf-with-dsym"
            references.append(add(f"config:{key}:{name}", "XCBuildConfiguration", baseConfigurationReference=xcconfig, buildSettings=values, name=name))
        return add("configs:" + key, "XCConfigurationList", buildConfigurations=references, defaultConfigurationIsVisible=0, defaultConfigurationName="Release")

    specifications = [
        ("MyKeyboard", "App", "com.apple.product-type.application", "MyKeyboard.app", "wrapper.application", "$(APP_BUNDLE_IDENTIFIER)"),
        ("MyKeyboardExtension", "KeyboardExtension", "com.apple.product-type.app-extension", "MyKeyboardExtension.appex", "wrapper.app-extension", "$(APP_BUNDLE_IDENTIFIER).keyboard"),
        ("StorageTests", "Tests/Integration", "com.apple.product-type.bundle.unit-test", "StorageTests.xctest", "wrapper.cfbundle", "$(APP_BUNDLE_IDENTIFIER).storage-tests"),
    ]
    target_ids = {name: uid("target:" + name) for name, *_ in specifications}
    for name, folder, product_type, product_name, file_type, bundle_id in specifications:
        source_paths = sorted(str(p.relative_to(ROOT)).replace("\\", "/") for p in (ROOT / folder).rglob("*.swift")) + shared
        if name != "StorageTests":
            source_paths += design
        source_build = [add(f"source:{name}:{p}", "PBXBuildFile", fileRef=file(p)) for p in source_paths]
        source_phase = add("sources:" + name, "PBXSourcesBuildPhase", buildActionMask=2147483647, files=source_build, runOnlyForDeploymentPostprocessing=0)
        resource_build = [add(f"resource:{name}:{p}", "PBXBuildFile", fileRef=file(p)) for p in resources]
        resource_phase = add("resources:" + name, "PBXResourcesBuildPhase", buildActionMask=2147483647, files=resource_build, runOnlyForDeploymentPostprocessing=0)
        dependencies = [add("core-product:" + name, "XCSwiftPackageProductDependency", productName="KeyboardCore")]
        if name == "MyKeyboardExtension":
            dependencies.append(add("converter-product", "XCSwiftPackageProductDependency", package=remote_package, productName="KanaKanjiConverterModuleWithDefaultDictionary"))
        framework_build = [add(f"framework:{name}:{dependency}", "PBXBuildFile", productRef=dependency) for dependency in dependencies]
        framework_phase = add("frameworks:" + name, "PBXFrameworksBuildPhase", buildActionMask=2147483647, files=framework_build, runOnlyForDeploymentPostprocessing=0)
        product = add("product:" + name, "PBXFileReference", explicitFileType=file_type, includeInIndex=0, path=product_name, sourceTree="BUILT_PRODUCTS_DIR")
        products.append(product)
        settings = {
            "PRODUCT_NAME": "$(TARGET_NAME)", "PRODUCT_BUNDLE_IDENTIFIER": bundle_id,
            "SDKROOT": "iphoneos", "SUPPORTED_PLATFORMS": "iphoneos iphonesimulator", "TARGETED_DEVICE_FAMILY": "1",
            "MARKETING_VERSION": "0.1.0", "CURRENT_PROJECT_VERSION": "1", "CLANG_ENABLE_MODULES": "YES",
            "LD_RUNPATH_SEARCH_PATHS": ["$(inherited)", "@executable_path/Frameworks", "@executable_path/../../Frameworks"],
            "OTHER_LDFLAGS": ["$(inherited)", "-lsqlite3"],
        }
        if name == "StorageTests":
            settings["GENERATE_INFOPLIST_FILE"] = "YES"
        else:
            settings["INFOPLIST_FILE"] = f"Config/{name}-Info.plist"
            settings["CODE_SIGN_ENTITLEMENTS"] = f"Config/{name}.entitlements"
            file(settings["INFOPLIST_FILE"]); file(settings["CODE_SIGN_ENTITLEMENTS"])
        if name != "MyKeyboard":
            settings["APPLICATION_EXTENSION_API_ONLY"] = "YES"
            settings["SKIP_INSTALL"] = "YES"
        phases = [source_phase, framework_phase, resource_phase]
        target_dependencies = []
        if name == "MyKeyboard":
            extension_product = uid("product:MyKeyboardExtension")
            embed = add("embed-extension", "PBXBuildFile", fileRef=extension_product, settings={"ATTRIBUTES": ["RemoveHeadersOnCopy"]})
            phases.append(add("embed-phase", "PBXCopyFilesBuildPhase", buildActionMask=2147483647, dstPath="", dstSubfolderSpec=13, files=[embed], name="Embed App Extensions", runOnlyForDeploymentPostprocessing=0))
            proxy = add("extension-proxy", "PBXContainerItemProxy", containerPortal=uid("project"), proxyType=1, remoteGlobalIDString=target_ids["MyKeyboardExtension"], remoteInfo="MyKeyboardExtension")
            target_dependencies.append(add("extension-dependency", "PBXTargetDependency", target=target_ids["MyKeyboardExtension"], targetProxy=proxy))
        target = add("target:" + name, "PBXNativeTarget", buildConfigurationList=configs(name, settings), buildPhases=phases, buildRules=[], dependencies=target_dependencies, name=name, packageProductDependencies=dependencies, productName=name, productReference=product, productType=product_type)
        targets.append(target)
    product_group = add("products-group", "PBXGroup", children=products, name="Products", sourceTree="<group>")
    main_group = add("main-group", "PBXGroup", children=list(files.values()) + [product_group], sourceTree="<group>")
    project = add("project", "PBXProject", attributes={"BuildIndependentTargetsInParallel": "YES", "LastUpgradeCheck": "1630"}, buildConfigurationList=configs("project", {"CLANG_ENABLE_MODULES": "YES"}), compatibilityVersion="Xcode 14.0", developmentRegion="ja", hasScannedForEncodings=0, knownRegions=["ja", "en", "Base"], mainGroup=main_group, packageReferences=[local_package, remote_package], productRefGroup=product_group, projectDirPath="", projectRoot="", targets=targets)
    return {"archiveVersion": 1, "classes": {}, "objectVersion": 56, "objects": objects, "rootObject": project}


def scheme():
    root = ET.Element("Scheme", LastUpgradeVersion="1630", version="1.7")
    build = ET.SubElement(root, "BuildAction", parallelizeBuildables="YES", buildImplicitDependencies="YES")
    entries = ET.SubElement(build, "BuildActionEntries")
    def reference(parent, name, product):
        ET.SubElement(parent, "BuildableReference", BuildableIdentifier="primary", BlueprintIdentifier=uid("target:" + name), BuildableName=product, BlueprintName=name, ReferencedContainer="container:MyKeyboard.xcodeproj")
    for name, product in [("MyKeyboard", "MyKeyboard.app"), ("StorageTests", "StorageTests.xctest")]:
        entry = ET.SubElement(entries, "BuildActionEntry", buildForTesting="YES", buildForRunning="YES" if name == "MyKeyboard" else "NO", buildForProfiling="YES" if name == "MyKeyboard" else "NO", buildForArchiving="YES" if name == "MyKeyboard" else "NO", buildForAnalyzing="YES")
        reference(entry, name, product)
    test = ET.SubElement(root, "TestAction", buildConfiguration="Debug", selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB", selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB", shouldUseLaunchSchemeArgsEnv="YES")
    testables = ET.SubElement(test, "Testables")
    reference(ET.SubElement(testables, "TestableReference", skipped="NO"), "StorageTests", "StorageTests.xctest")
    launch = ET.SubElement(root, "LaunchAction", buildConfiguration="Debug", selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB", selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB", launchStyle="0", useCustomWorkingDirectory="NO", ignoresPersistentStateOnLaunch="NO", debugDocumentVersioning="YES", allowLocationSimulation="NO")
    reference(ET.SubElement(launch, "BuildableProductRunnable", runnableDebuggingMode="0"), "MyKeyboard", "MyKeyboard.app")
    ET.SubElement(root, "ProfileAction", buildConfiguration="Release", shouldUseLaunchSchemeArgsEnv="YES", savedToolIdentifier="", useCustomWorkingDirectory="NO", debugDocumentVersioning="YES")
    ET.SubElement(root, "AnalyzeAction", buildConfiguration="Debug")
    ET.SubElement(root, "ArchiveAction", buildConfiguration="Release", revealArchiveInOrganizer="YES")
    ET.indent(root)
    return ET.tostring(root, encoding="utf-8", xml_declaration=True)


def outputs():
    common = dict(CFBundleDevelopmentRegion="ja", CFBundleExecutable="$(EXECUTABLE_NAME)", CFBundleIdentifier="$(PRODUCT_BUNDLE_IDENTIFIER)", CFBundleInfoDictionaryVersion="6.0", CFBundleName="$(PRODUCT_NAME)", CFBundleShortVersionString="$(MARKETING_VERSION)", CFBundleVersion="$(CURRENT_PROJECT_VERSION)", SharedAppGroup="$(APP_GROUP_IDENTIFIER)")
    app = dict(common, CFBundlePackageType="APPL", CFBundleDisplayName="MyKeyboard", LSRequiresIPhoneOS=True, UILaunchScreen={}, UIApplicationSceneManifest={"UIApplicationSupportsMultipleScenes": False}, UISupportedInterfaceOrientations=["UIInterfaceOrientationPortrait", "UIInterfaceOrientationLandscapeLeft", "UIInterfaceOrientationLandscapeRight"])
    extension = dict(common, CFBundlePackageType="XPC!", CFBundleDisplayName="MyKeyboard", EnableExperimentalHostReplacement=False,
        NSExtension={"NSExtensionPointIdentifier": "com.apple.keyboard-service", "NSExtensionPrincipalClass": "$(PRODUCT_MODULE_NAME).KeyboardViewController", "NSExtensionAttributes": {"IsASCIICapable": True, "PrefersRightToLeft": False, "PrimaryLanguage": "ja-JP", "RequestsOpenAccess": True}})
    entitlements = {"com.apple.security.application-groups": ["$(APP_GROUP_IDENTIFIER)"]}
    privacy = {"NSPrivacyTracking": False, "NSPrivacyCollectedDataTypes": [], "NSPrivacyAccessedAPITypes": [
        {"NSPrivacyAccessedAPIType": "NSPrivacyAccessedAPICategoryUserDefaults", "NSPrivacyAccessedAPITypeReasons": ["1C8F.1", "CA92.1"]},
        {"NSPrivacyAccessedAPIType": "NSPrivacyAccessedAPICategorySystemBootTime", "NSPrivacyAccessedAPITypeReasons": ["35F9.1"]}
    ]}
    return {
        "MyKeyboard.xcodeproj/project.pbxproj": ("// !$*UTF8*$!\n" + serialize(project_model()) + "\n").encode(),
        "MyKeyboard.xcodeproj/xcshareddata/xcschemes/MyKeyboard.xcscheme": scheme(),
        "Config/MyKeyboard-Info.plist": plistlib.dumps(app),
        "Config/MyKeyboardExtension-Info.plist": plistlib.dumps(extension),
        "Config/MyKeyboard.entitlements": plistlib.dumps(entitlements),
        "Config/MyKeyboardExtension.entitlements": plistlib.dumps(entitlements),
        "Resources/PrivacyInfo.xcprivacy": plistlib.dumps(privacy),
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true", help="Compare generated settings without modifying files")
    args = parser.parse_args()
    stale = []
    for path, content in outputs().items():
        target = ROOT / path
        if args.check:
            if not target.exists() or target.read_bytes() != content:
                stale.append(path)
        else:
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(content)
    if stale:
        raise SystemExit("Stale project/settings: " + ", ".join(stale))
    print("PASS: generated project matches sources." if args.check else "Generated Xcode project and settings (not Xcode-validated).")


if __name__ == "__main__":
    main()
