import 'package:interact/interact.dart';

enum Capability { firebase, backgroundModes, googleMaps }

class CliPrompts {
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
