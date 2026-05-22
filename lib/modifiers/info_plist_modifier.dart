import 'dart:io';
import 'package:path/path.dart' as p;

class InfoPlistModifier {
  final String projectRoot;

  InfoPlistModifier(this.projectRoot);

  String get _plistPath =>
      p.join(projectRoot, 'ios', 'Runner', 'Info.plist');

  List<String> addBackgroundModes(List<String> modes) {
    final results = <String>[];
    try {
      final file = File(_plistPath);
      var content = file.readAsStringSync();

      if (!content.contains('<key>UIBackgroundModes</key>')) {
        // Array does not exist yet — create it with all selected modes.
        final toInsert = '\t<key>UIBackgroundModes</key>\n'
            '\t<array>\n'
            '${modes.map((m) => '\t\t<string>$m</string>\n').join()}'
            '\t</array>\n';

        final updated = _insertBeforeLastDict(content, toInsert);
        if (updated == null) {
          results.add('❌ Could not find </dict> in Info.plist');
          return results;
        }

        file.writeAsStringSync(updated);
        for (final mode in modes) {
          results.add('✅ Updated Info.plist — added background mode: $mode');
        }
      } else {
        // Array already exists — locate its boundaries.
        final keyPos = content.indexOf('<key>UIBackgroundModes</key>');
        final arrayStart = content.indexOf('<array>', keyPos);
        final arrayEnd = content.indexOf('</array>', arrayStart);

        if (arrayStart == -1 || arrayEnd == -1) {
          results.add('❌ Could not find UIBackgroundModes array in Info.plist');
          return results;
        }

        final arrayContent = content.substring(arrayStart, arrayEnd);

        final missingModes = modes
            .where((m) => !arrayContent.contains('<string>$m</string>'))
            .toList();

        if (missingModes.isEmpty) {
          results.add(
              '⚠️  Info.plist — all selected background modes already configured, skipped');
          return results;
        }

        // Report each mode that is already present.
        for (final mode in modes) {
          if (!missingModes.contains(mode)) {
            results.add(
                '⚠️  Info.plist — background mode $mode already exists, skipped');
          }
        }

        // Insert missing modes immediately before </array>.
        final modesBlock =
            missingModes.map((m) => '\t\t<string>$m</string>\n').join();
        content = content.substring(0, arrayEnd) +
            modesBlock +
            content.substring(arrayEnd);

        file.writeAsStringSync(content);
        for (final mode in missingModes) {
          results.add(
              '✅ Updated Info.plist — added background mode: $mode');
        }
      }
    } catch (e) {
      results.add('❌ Failed to update Info.plist: $e');
    }
    return results;
  }

  String addNSLocation() {
    try {
      final file = File(_plistPath);
      final content = file.readAsStringSync();

      if (content.contains('<key>NSLocationWhenInUseUsageDescription</key>')) {
        return '⚠️  Info.plist — NSLocationWhenInUseUsageDescription already exists, skipped';
      }

      const toInsert =
          '\t<key>NSLocationWhenInUseUsageDescription</key>\n'
          '\t<string>This app requires location access to show maps</string>\n';

      final updated = _insertBeforeLastDict(content, toInsert);
      if (updated == null) {
        return '❌ Could not find </dict> in Info.plist';
      }

      file.writeAsStringSync(updated);
      return '✅ Updated Info.plist — added NSLocationWhenInUseUsageDescription';
    } catch (e) {
      return '❌ Failed to update Info.plist: $e';
    }
  }

  // Inserts [toInsert] immediately before the last </dict> in the file,
  // which is the closing tag of the root plist dictionary.
  // Returns null if </dict> is not found.
  String? _insertBeforeLastDict(String content, String toInsert) {
    final insertionPoint = content.lastIndexOf('</dict>');
    if (insertionPoint == -1) return null;
    return content.substring(0, insertionPoint) +
        toInsert +
        content.substring(insertionPoint);
  }
}
