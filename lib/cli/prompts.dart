import 'package:interact/interact.dart';

/// Represents an iOS capability that can be configured by this tool.
enum Capability { firebase, backgroundModes, googleMaps }

/// Provides interactive CLI prompts for selecting iOS capabilities and options.
class CliPrompts {
  /// Prompts the user to choose which capabilities to configure and returns
  /// the selected [Capability] values.
  List<Capability> selectCapabilities() {
    final options = [
      'Firebase & Push Notifications',
      'Background Modes',
      'Google Maps',
    ];

    print('');
    print('  📋 Instructions:');
    print('     SPACE  = select / deselect');
    print('     ENTER  = confirm selection');
    print('     ↑ ↓    = navigate');
    print('');

    final selected = MultiSelect(
      prompt: 'Select capabilities to configure',
      options: options,
    ).interact();

    return selected.map((i) => Capability.values[i]).toList();
  }

  /// Prompts the user to select which background modes to enable and returns
  /// the corresponding plist string values.
  List<String> selectBackgroundModes() {
    final options = [
      'fetch',
      'remote-notification',
      'location',
      'audio',
      'processing',
    ];

    final selected = MultiSelect(
      prompt: 'Select Background Modes',
      options: options,
    ).interact();

    return selected.map((i) => options[i]).toList();
  }

  /// Prompts the user to enter their Google Maps API key and returns the value.
  String promptGoogleMapsKey() {
    return Input(
      prompt: 'Enter your Google Maps API Key',
      validator: (value) {
        if (value.trim().isEmpty) {
          throw ValidationError('API key cannot be empty');
        }
        return true;
      },
    ).interact();
  }
}
