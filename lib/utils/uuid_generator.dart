import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Generates a 24-character uppercase UUID suitable for use as a PBX object identifier.
String generatePbxUuid() {
  final raw = _uuid.v4().replaceAll('-', '').toUpperCase();
  return raw.substring(0, 24);
}
