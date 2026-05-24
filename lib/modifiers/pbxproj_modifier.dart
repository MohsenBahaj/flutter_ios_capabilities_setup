import 'dart:io';
import 'package:path/path.dart' as p;
import '../utils/uuid_generator.dart';

/// Modifies `ios/Runner.xcodeproj/project.pbxproj` to register files and
/// update build settings for iOS capabilities.
class PbxprojModifier {
  final String projectRoot;

  /// Creates an instance targeting the Flutter project at [projectRoot].
  PbxprojModifier(this.projectRoot);

  String get _pbxprojPath =>
      p.join(projectRoot, 'ios', 'Runner.xcodeproj', 'project.pbxproj');

  // ── Anchor helpers ──────────────────────────────────────────────
  static const _exactGroupAnchor =
      '\t\t\t\t97C146FA1CF9000F007C117D /* Main.storyboard */,';
  static const _exactResourcesAnchor =
      '\t\t\t\t97C146FE1CF9000F007C117D /* Assets.xcassets in Resources */,';

  static final _regexGroupAnchor = RegExp(
    r'\t{4}[0-9A-F]{24} /\* Main\.storyboard \*/,',
    multiLine: true,
  );
  static final _regexResourcesAnchor = RegExp(
    r'\t{4}[0-9A-F]{24} /\* Assets\.xcassets in Resources \*/,',
    multiLine: true,
  );

  String? _findGroupAnchor(String content) {
    if (content.contains(_exactGroupAnchor)) return _exactGroupAnchor;
    final match = _regexGroupAnchor.firstMatch(content);
    if (match != null) return match.group(0);
    return null;
  }

  String? _findResourcesAnchor(String content) {
    if (content.contains(_exactResourcesAnchor)) return _exactResourcesAnchor;
    final match = _regexResourcesAnchor.firstMatch(content);
    if (match != null) return match.group(0);
    return null;
  }

  /// Registers `GoogleService-Info.plist` and `Runner.entitlements` in the
  /// Xcode project and sets `CODE_SIGN_ENTITLEMENTS` on all build configurations.
  String addFirebase() {
    try {
      final file = File(_pbxprojPath);
      var content = file.readAsStringSync();

      if (content.contains('GoogleService-Info.plist')) {
        return '⚠️  project.pbxproj — GoogleService-Info.plist already registered, skipped';
      }

      if (!content.contains('/* Begin PBXBuildFile section */') ||
          !content.contains('/* Begin PBXFileReference section */')) {
        return '❌ Could not modify project.pbxproj — unexpected file structure.\n'
            'Please open an issue: https://github.com/MohsenBahaj/flutter_ios_capabilities_setup/issues';
      }

      final groupAnchor = _findGroupAnchor(content);
      if (groupAnchor == null) {
        return '❌ Could not find Main.storyboard anchor in project.pbxproj.\n'
            'Please open an issue: https://github.com/MohsenBahaj/flutter_ios_capabilities_setup/issues';
      }

      final resourcesAnchor = _findResourcesAnchor(content);
      if (resourcesAnchor == null) {
        return '❌ Could not find Assets.xcassets anchor in project.pbxproj.\n'
            'Please open an issue: https://github.com/MohsenBahaj/flutter_ios_capabilities_setup/issues';
      }

      final uuidBuildFile = generatePbxUuid();
      final uuidFileRefGoogle = generatePbxUuid();
      final uuidFileRefEntitlements = generatePbxUuid();

      // 1. Add PBXBuildFile entry
      content = content.replaceFirst(
        '/* Begin PBXBuildFile section */',
        '/* Begin PBXBuildFile section */\n'
            '\t\t$uuidBuildFile /* GoogleService-Info.plist in Resources */ = '
            '{isa = PBXBuildFile; fileRef = $uuidFileRefGoogle /* GoogleService-Info.plist */; };',
      );

      // 2. Add PBXFileReference entries
      content = content.replaceFirst(
        '/* Begin PBXFileReference section */',
        '/* Begin PBXFileReference section */\n'
            '\t\t$uuidFileRefEntitlements /* Runner.entitlements */ = '
            '{isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; '
            'path = Runner.entitlements; sourceTree = "<group>"; };\n'
            '\t\t$uuidFileRefGoogle /* GoogleService-Info.plist */ = '
            '{isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = text.plist.xml; '
            'path = "GoogleService-Info.plist"; sourceTree = "<group>"; };',
      );

      // 3. Add files to Runner PBXGroup children (before Main.storyboard).
      //    Anchor includes 4-tab prefix + trailing comma so replaceFirst hits
      //    the children-list line and not a fileRef = ... occurrence elsewhere.
      content = content.replaceFirst(
        groupAnchor,
        '\t\t\t\t$uuidFileRefEntitlements /* Runner.entitlements */,\n'
        '\t\t\t\t$uuidFileRefGoogle /* GoogleService-Info.plist */,\n'
        '$groupAnchor',
      );

      // 4. Add to PBXResourcesBuildPhase files list (before Assets.xcassets).
      //    Same reasoning: include tabs + comma for uniqueness.
      content = content.replaceFirst(
        resourcesAnchor,
        '\t\t\t\t$uuidBuildFile /* GoogleService-Info.plist in Resources */,\n'
        '$resourcesAnchor',
      );

      // 5-7. Add CODE_SIGN_ENTITLEMENTS to all 3 Runner build configurations
      //      (Debug, Release, Profile) — only blocks that also have INFOPLIST_FILE.
      if (!content.contains(
          'CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;')) {
        content = _addCodeSignEntitlements(content);
      }

      file.writeAsStringSync(content);
      return '✅ Updated project.pbxproj — registered GoogleService-Info.plist';
    } catch (e) {
      return '❌ Failed to modify project.pbxproj: $e';
    }
  }

  /// Raises `IPHONEOS_DEPLOYMENT_TARGET` to 15.0 in all build configurations
  /// where it is currently set below that value.
  String updateDeploymentTarget() {
    try {
      final file = File(_pbxprojPath);
      var content = file.readAsStringSync();

      final pattern = RegExp(r'IPHONEOS_DEPLOYMENT_TARGET = ([^;]+);');
      final matches = pattern.allMatches(content).toList();

      if (matches.isEmpty) {
        return '⚠️  project.pbxproj — IPHONEOS_DEPLOYMENT_TARGET not found, skipped';
      }

      final anyBelow15 = matches.any((m) {
        final v = double.tryParse(m.group(1)!.trim());
        return v != null && v < 15.0;
      });

      if (!anyBelow15) {
        return '⚠️  project.pbxproj — iOS deployment target already 15.0+, skipped';
      }

      content = content.replaceAllMapped(pattern, (m) {
        final v = double.tryParse(m.group(1)!.trim());
        return (v != null && v < 15.0)
            ? 'IPHONEOS_DEPLOYMENT_TARGET = 15.0;'
            : m.group(0)!;
      });

      file.writeAsStringSync(content);
      return '✅ Updated project.pbxproj — iOS deployment target set to 15.0';
    } catch (e) {
      return '❌ Failed to update deployment target: $e';
    }
  }

  // Inserts CODE_SIGN_ENTITLEMENTS after every CLANG_ENABLE_MODULES = YES; that
  // sits inside a buildSettings block containing INFOPLIST_FILE = Runner/Info.plist;
  String _addCodeSignEntitlements(String content) {
    const anchor = '\t\t\t\tCLANG_ENABLE_MODULES = YES;';
    const infoplist = 'INFOPLIST_FILE = Runner/Info.plist;';
    const codeSign = '\t\t\t\tCODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;';
    const blockClose = '\n\t\t\t};'; // end of buildSettings = { ... }

    final result = StringBuffer();
    var remaining = content;

    while (remaining.contains(anchor)) {
      final anchorIdx = remaining.indexOf(anchor);
      final afterAnchor = anchorIdx + anchor.length;

      // Find the buildSettings block end after this anchor.
      final blockEndIdx = remaining.indexOf(blockClose, afterAnchor);

      bool shouldAdd = false;
      if (blockEndIdx != -1) {
        final block = remaining.substring(anchorIdx, blockEndIdx);
        shouldAdd = block.contains(infoplist);
      }

      result.write(remaining.substring(0, afterAnchor));
      if (shouldAdd) result.write('\n$codeSign');
      remaining = remaining.substring(afterAnchor);
    }

    result.write(remaining);
    return result.toString();
  }
}
