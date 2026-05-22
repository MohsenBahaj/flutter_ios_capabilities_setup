import 'dart:io';
import 'package:path/path.dart' as p;

class EntitlementsCreator {
  final String projectRoot;

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

  String create() {
    final file = File(_entitlementsPath);
    if (file.existsSync()) {
      return '⚠️  Runner.entitlements already exists, skipped';
    }
    try {
      file.writeAsStringSync(_content);
      return '✅ Created Runner.entitlements';
    } catch (e) {
      return '❌ Failed to create Runner.entitlements: $e';
    }
  }
}
