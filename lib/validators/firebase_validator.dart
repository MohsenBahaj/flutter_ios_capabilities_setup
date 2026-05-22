import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

class FirebaseValidator {
  final String projectRoot;

  FirebaseValidator(this.projectRoot);

  String get _googleServicePath =>
      p.join(projectRoot, 'ios', 'Runner', 'GoogleService-Info.plist');

  bool fileExists() => File(_googleServicePath).existsSync();

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
