import 'dart:io';
import 'package:path/path.dart' as p;

/// Validates that a directory is a valid Flutter project with an iOS target.
class ProjectValidator {
  final String projectRoot;

  /// Creates an instance targeting the directory at [projectRoot].
  ProjectValidator(this.projectRoot);

  /// Returns `true` if all expected Flutter iOS project files and directories
  /// are present under [projectRoot].
  bool validate() {
    final checks = [
      p.join(projectRoot, 'pubspec.yaml'),
      p.join(projectRoot, 'ios', 'Runner'),
      p.join(projectRoot, 'ios', 'Runner.xcodeproj', 'project.pbxproj'),
      p.join(projectRoot, 'ios', 'Runner', 'AppDelegate.swift'),
      p.join(projectRoot, 'ios', 'Runner', 'Info.plist'),
    ];

    for (final path in checks) {
      if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
        return false;
      }
    }
    return true;
  }
}
