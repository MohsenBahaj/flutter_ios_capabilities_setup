import 'dart:io';

import 'package:flutter_ios_capabilities_setup/cli/prompts.dart';
import 'package:flutter_ios_capabilities_setup/modifiers/appdelegate_modifier.dart';
import 'package:flutter_ios_capabilities_setup/modifiers/entitlements_creator.dart';
import 'package:flutter_ios_capabilities_setup/modifiers/info_plist_modifier.dart';
import 'package:flutter_ios_capabilities_setup/modifiers/pbxproj_modifier.dart';
import 'package:flutter_ios_capabilities_setup/validators/firebase_validator.dart';
import 'package:flutter_ios_capabilities_setup/validators/project_validator.dart';

void main() {
  final divider = '━' * 40;

  print('');
  print('🔧 Flutter iOS Configurator');
  print(
      '   by Mohsen Bahaj — https://github.com/MohsenBahaj/flutter_ios_capabilities_setup ');
  print('');
  print(divider);
  print('');

  final projectRoot = Directory.current.path;

  // Validate Flutter project structure
  if (!ProjectValidator(projectRoot).validate()) {
    print('❌ Not a Flutter project or missing iOS files.');
    print('Please run this tool from the root of your Flutter project.');
    exit(1);
  }

  final prompts = CliPrompts();
  final capabilities = prompts.selectCapabilities();

  if (capabilities.isEmpty) {
    print('\nNo capabilities selected. Exiting.');
    exit(0);
  }

  print('');
  final results = <String>[];

  // ── Firebase & Push Notifications ────────────────────────────────────────
  if (capabilities.contains(Capability.firebase)) {
    final fbValidator = FirebaseValidator(projectRoot);

    if (!fbValidator.fileExists()) {
      print('❌ GoogleService-Info.plist not found!\n');
      print('Please:');
      print('1. Go to Firebase Console → Your Project → iOS App');
      print('2. Download GoogleService-Info.plist');
      print('3. Place it at: ios/Runner/GoogleService-Info.plist');
      print('4. Run this tool again\n');
      print('Stopping...');
      exit(1);
    }

    if (!fbValidator.isValid()) {
      print('❌ GoogleService-Info.plist appears to be invalid or incomplete.');
      print('Make sure you downloaded the correct file from Firebase Console.');
      exit(1);
    }

    results.add(EntitlementsCreator(projectRoot).create());
    results.addAll(InfoPlistModifier(projectRoot)
        .addBackgroundModes(['fetch', 'remote-notification']));
    results.addAll(AppDelegateModifier(projectRoot).addFirebase());
    final pbx = PbxprojModifier(projectRoot);
    results.add(pbx.addFirebase());
    results.add(pbx.updateDeploymentTarget());
  }

  // ── Background Modes (standalone) ────────────────────────────────────────
  if (capabilities.contains(Capability.backgroundModes)) {
    final selectedModes = prompts.selectBackgroundModes();
    if (selectedModes.isEmpty) {
      results.add('⚠️  Background Modes — no modes selected, skipped');
    } else {
      results.addAll(
          InfoPlistModifier(projectRoot).addBackgroundModes(selectedModes));
    }
  }

  // ── Google Maps ───────────────────────────────────────────────────────────
  if (capabilities.contains(Capability.googleMaps)) {
    final apiKey = prompts.promptGoogleMapsKey();
    results.addAll(AppDelegateModifier(projectRoot).addGoogleMaps(apiKey));
    results.add(InfoPlistModifier(projectRoot).addNSLocation());
  }

  // Print step results
  for (final result in results) {
    print(result);
  }

  // Final summary
  print('\n$divider');
  print('✅ iOS configuration complete!\n');
  print('');
  print('⭐ If this tool helped you, star the repo:');
  print('   https://github.com/MohsenBahaj/flutter_ios_capabilities_setup ');
  print('');
  print('🐛 Found a bug? Open an issue:');
  print(
      '   https://github.com/MohsenBahaj/flutter_ios_capabilities_setup /issues');
  print(divider);
}
