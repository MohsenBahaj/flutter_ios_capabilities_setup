import 'dart:io';
import 'package:path/path.dart' as p;

/// Creates `ios/Runner/Runner.entitlements` with the APS push environment key.
class EntitlementsCreator {
  final String projectRoot;

  /// Creates an instance targeting the Flutter project at [projectRoot].
  EntitlementsCreator(this.projectRoot);

  String get _entitlementsPath =>
      p.join(projectRoot, 'ios', 'Runner', 'Runner.entitlements');

  static const _content = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
\t<key>aps-environment</key>
\t<string>development</string>
</dict>
</plist>
''';

  /// Creates `Runner.entitlements` with `aps-environment` set to `development`.
  /// Does nothing if the file already exists.
  String create() {
    final file = File(_entitlementsPath);
    if (file.existsSync()) {
      return '⚠️  Runner.entitlements already exists, skipped';
    }
    try {
      file.writeAsStringSync(_content);
      return '✅ Created Runner.entitlements';
    } catch (e) {
      return '❌ Failed to create Runner.entitlements: $e\n'
          'Please open an issue: https://github.com/MohsenBahaj/flutter_ios_capabilities_setup/issues';
    }
  }
}
