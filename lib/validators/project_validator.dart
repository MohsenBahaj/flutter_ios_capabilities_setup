import 'dart:io';
import 'package:path/path.dart' as p;

class ProjectValidator {
  final String projectRoot;

  ProjectValidator(this.projectRoot);

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
