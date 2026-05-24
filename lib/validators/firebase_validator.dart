import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

/// Validates the presence and content of `GoogleService-Info.plist`.
class FirebaseValidator {
  final String projectRoot;

  /// Creates an instance targeting the Flutter project at [projectRoot].
  FirebaseValidator(this.projectRoot);

  String get _googleServicePath =>
      p.join(projectRoot, 'ios', 'Runner', 'GoogleService-Info.plist');

  /// Returns `true` if `GoogleService-Info.plist` exists at the expected path.
  bool fileExists() => File(_googleServicePath).existsSync();

  /// Returns `true` if the plist contains the required Firebase keys
  /// (`GOOGLE_APP_ID`, `BUNDLE_ID`, `PROJECT_ID`).
  bool isValid() {
    try {
      final content = File(_googleServicePath).readAsStringSync();
      final doc = XmlDocument.parse(content);
      final keys = doc.findAllElements('key').map((e) => e.innerText).toSet();
      return keys.contains('GOOGLE_APP_ID') &&
          keys.contains('BUNDLE_ID') &&
          keys.contains('PROJECT_ID');
    } catch (_) {
      return false;
    }
  }

  /// Returns a warning message if the Bundle ID in `GoogleService-Info.plist`
  /// does not match `PRODUCT_BUNDLE_IDENTIFIER` in `project.pbxproj`, or
  /// `null` if they match or either value cannot be read.
  String? checkBundleIdMatch(String projectRoot) {
    try {
      // 1. Read BUNDLE_ID from plist.
      final plistContent = File(_googleServicePath).readAsStringSync();
      final doc = XmlDocument.parse(plistContent);
      String? plistBundleId;
      for (final key in doc.findAllElements('key')) {
        if (key.innerText == 'BUNDLE_ID') {
          final next = key.nextElementSibling;
          if (next != null) plistBundleId = next.innerText;
          break;
        }
      }
      if (plistBundleId == null) return null;

      // 2. Read PRODUCT_BUNDLE_IDENTIFIER from pbxproj.
      final pbxprojPath =
          p.join(projectRoot, 'ios', 'Runner.xcodeproj', 'project.pbxproj');
      final pbxContent = File(pbxprojPath).readAsStringSync();
      final pattern = RegExp(r'PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);');
      String? pbxBundleId;
      for (final match in pattern.allMatches(pbxContent)) {
        final value = match.group(1)!.trim();
        if (!value.contains('RunnerTests')) {
          pbxBundleId = value;
          break;
        }
      }
      if (pbxBundleId == null) return null;

      // 3. Compare.
      if (plistBundleId == pbxBundleId) return null;

      return '⚠️  Bundle ID mismatch detected:\n'
          '    GoogleService-Info.plist : $plistBundleId\n'
          '    project.pbxproj          : $pbxBundleId\n'
          '\n'
          '    Your app will likely crash at launch — Firebase cannot initialize\n'
          '    with a mismatched Bundle ID.\n'
          '\n'
          '    To fix, run:\n'
          '      flutter pub add -d change_app_package_name\n'
          '      dart run change_app_package_name:main $plistBundleId --ios\n'
          '\n'
          '    See: https://pub.dev/packages/change_app_package_name\n'
          '\n'
          '    Continue anyway? (y/N): ';
    } catch (_) {
      return null;
    }
  }
}
