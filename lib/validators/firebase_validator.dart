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
}
