import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_file.freezed.dart';

@freezed
abstract class NetworkFile with _$NetworkFile {
  const factory NetworkFile({required Uint8List bytes, required String name}) =
      _NetworkFile;
}
