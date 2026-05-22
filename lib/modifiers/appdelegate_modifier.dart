import 'dart:io';
import 'package:path/path.dart' as p;

class AppDelegateModifier {
  final String projectRoot;

  AppDelegateModifier(this.projectRoot);

  String get _delegatePath =>
      p.join(projectRoot, 'ios', 'Runner', 'AppDelegate.swift');

  List<String> addFirebase() {
    final results = <String>[];
    try {
      final file = File(_delegatePath);
      var content = file.readAsStringSync();
      var modified = false;

      // 1. Add missing imports before @UIApplicationMain / @main
      final missingImports = ['FirebaseCore', 'FirebaseMessaging', 'UserNotifications']
          .where((i) => !content.contains('import $i'))
          .toList();

      if (missingImports.isNotEmpty) {
        final marker = _annotationMarker(content);
        if (marker != null) {
          final idx = content.indexOf(marker);
          final block = missingImports.map((i) => 'import $i').join('\n') + '\n';
          content =
              content.substring(0, idx) + block + '\n' + content.substring(idx);
          modified = true;
          results.add(
              '✅ Updated AppDelegate.swift — added imports: ${missingImports.join(', ')}');
        }
      } else {
        results.add('⚠️  AppDelegate.swift — Firebase imports already exist, skipped');
      }

      // 2. Add MessagingDelegate to class signature
      if (!content.contains('MessagingDelegate')) {
        const oldSig = 'FlutterAppDelegate {';
        const newSig = 'FlutterAppDelegate, MessagingDelegate {';
        if (content.contains(oldSig)) {
          content = content.replaceFirst(oldSig, newSig);
          modified = true;
          results.add('✅ Updated AppDelegate.swift — added MessagingDelegate');
        }
      } else {
        results.add(
            '⚠️  AppDelegate.swift — MessagingDelegate already exists, skipped');
      }

      // 3. Add Firebase setup inside didFinishLaunching (before GeneratedPluginRegistrant).
      //    Anchor includes the 4-space indent so replaceFirst consumes those spaces
      //    and the setup lines start at the same 4-space indent — avoiding the
      //    8-space bug that results from the original indent being left in place.
      const registrant = '    GeneratedPluginRegistrant.register(with: self)';
      if (!content.contains('FirebaseApp.configure()')) {
        if (content.contains(registrant)) {
          const setup = '    FirebaseApp.configure()\n'
              '    UNUserNotificationCenter.current().delegate = self\n'
              '    Messaging.messaging().delegate = self\n'
              '    UNUserNotificationCenter.current().requestAuthorization(\n'
              '      options: [.alert, .sound, .badge]\n'
              '    ) { _, _ in }\n'
              '    application.registerForRemoteNotifications()\n';
          content = content.replaceFirst(registrant, '$setup$registrant');
          modified = true;
          results.add('✅ Updated AppDelegate.swift — added Firebase setup');
        }
      } else {
        results.add(
            '⚠️  AppDelegate.swift — FirebaseApp.configure() already exists, skipped');
      }

      // 4. Add Firebase delegate methods after didFinishLaunching
      final methodsToAdd = <String>[];
      if (!content.contains('didRegisterForRemoteNotificationsWithDeviceToken')) {
        methodsToAdd.add(_deviceTokenMethod);
      }
      if (!content
          .contains('func messaging(_ messaging: Messaging, didReceiveRegistrationToken')) {
        methodsToAdd.add(_messagingTokenMethod);
      }
      if (!content.contains('func userNotificationCenter')) {
        methodsToAdd.add(_notificationCenterMethod);
      }

      if (methodsToAdd.isNotEmpty) {
        final block = '\n\n' + methodsToAdd.join('\n\n') + '\n';
        content = _insertAfterDidFinishLaunching(content, block);
        modified = true;
        results.add(
            '✅ Updated AppDelegate.swift — added Firebase delegate methods');
      } else {
        results.add(
            '⚠️  AppDelegate.swift — Firebase methods already exist, skipped');
      }

      if (modified) file.writeAsStringSync(content);
    } catch (e) {
      results.add('❌ Failed to update AppDelegate.swift: $e');
    }
    return results;
  }

  List<String> addGoogleMaps(String apiKey) {
    final results = <String>[];
    try {
      final file = File(_delegatePath);
      var content = file.readAsStringSync();
      var modified = false;

      // 1. Add import GoogleMaps
      if (!content.contains('import GoogleMaps')) {
        final marker = _annotationMarker(content);
        if (marker != null) {
          final idx = content.indexOf(marker);
          content =
              content.substring(0, idx) + 'import GoogleMaps\n\n' + content.substring(idx);
          modified = true;
          results.add('✅ Updated AppDelegate.swift — added import GoogleMaps');
        }
      } else {
        results.add(
            '⚠️  AppDelegate.swift — import GoogleMaps already exists, skipped');
      }

      // 2. Add GMSServices.provideAPIKey as first line of didFinishLaunching
      if (!content.contains('GMSServices.provideAPIKey(')) {
        final bodyStart = _didFinishLaunchingBodyStart(content);
        if (bodyStart != -1) {
          final newlineAfterBrace = content.indexOf('\n', bodyStart);
          if (newlineAfterBrace != -1) {
            content = content.substring(0, newlineAfterBrace + 1) +
                '    GMSServices.provideAPIKey("$apiKey")\n' +
                content.substring(newlineAfterBrace + 1);
            modified = true;
            results.add(
                '✅ Updated AppDelegate.swift — added GMSServices.provideAPIKey');
          }
        }
      } else {
        results.add(
            '⚠️  AppDelegate.swift — GMSServices.provideAPIKey already exists, skipped');
      }

      if (modified) file.writeAsStringSync(content);
    } catch (e) {
      results.add('❌ Failed to update AppDelegate.swift: $e');
    }
    return results;
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  String? _annotationMarker(String content) {
    if (content.contains('@UIApplicationMain')) return '@UIApplicationMain';
    if (content.contains('@main')) return '@main';
    if (content.contains('@objc class AppDelegate')) {
      return '@objc class AppDelegate';
    }
    return null;
  }

  // Returns index of the end of ") -> Bool {" in didFinishLaunching signature.
  int _didFinishLaunchingBodyStart(String content) {
    const sigMarker = 'didFinishLaunchingWithOptions launchOptions';
    final sigIdx = content.indexOf(sigMarker);
    if (sigIdx == -1) return -1;
    const bodyMarker = ') -> Bool {';
    final bodyIdx = content.indexOf(bodyMarker, sigIdx);
    if (bodyIdx == -1) return -1;
    return bodyIdx + bodyMarker.length;
  }

  // Inserts [toInsert] after the closing brace of didFinishLaunching.
  String _insertAfterDidFinishLaunching(String content, String toInsert) {
    const registrant = 'GeneratedPluginRegistrant.register(with: self)';
    final anchorIdx = content.indexOf(registrant);
    if (anchorIdx == -1) return content;

    // The method closing brace is the first "\n  }" (2-space indent) after
    // the GeneratedPluginRegistrant line.
    const methodClose = '\n  }';
    final closeIdx = content.indexOf(methodClose, anchorIdx);
    if (closeIdx == -1) return content;

    final insertAt = closeIdx + methodClose.length;
    return content.substring(0, insertAt) + toInsert + content.substring(insertAt);
  }

  // ── Firebase method templates ─────────────────────────────────────────────

  static const _deviceTokenMethod =
      '  override func application(\n'
      '    _ application: UIApplication,\n'
      '    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data\n'
      '  ) {\n'
      '    Messaging.messaging().apnsToken = deviceToken\n'
      '    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)\n'
      '  }';

  static const _messagingTokenMethod =
      '  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {\n'
      '    if let token = fcmToken {\n'
      '      print("FCM Token: \\(token)")\n'
      '    }\n'
      '  }';

  static const _notificationCenterMethod =
      '  override func userNotificationCenter(\n'
      '    _ center: UNUserNotificationCenter,\n'
      '    willPresent notification: UNNotification,\n'
      '    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void\n'
      '  ) {\n'
      '    completionHandler([.alert, .sound, .badge])\n'
      '  }';
}
