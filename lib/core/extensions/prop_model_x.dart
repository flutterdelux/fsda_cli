import '../../domain/models/prop_model.dart';

extension PropModelX on PropModel {
  PropModel get noConverter => PropModel(
    type: type,
    name: name,
    defaultValue: defaultValue,
    converter: '',
  );
}
