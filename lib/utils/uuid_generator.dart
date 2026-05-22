import 'package:uuid/uuid.dart';

const _uuid = Uuid();

String generatePbxUuid() {
  final raw = _uuid.v4().replaceAll('-', '').toUpperCase();
  return raw.substring(0, 24);
}
