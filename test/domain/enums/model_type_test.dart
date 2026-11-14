import 'package:fsda_cli/domain/enums/model_type.dart';
import 'package:test/test.dart';

void main() {
  group('ModelType Tests', () {
    test('fromValue should return correct ModelType for valid string', () {
      expect(ModelType.fromValue('entity'), ModelType.entity);
      expect(ModelType.fromValue('param'), ModelType.param);
      expect(ModelType.fromValue('dto'), ModelType.dto);
      expect(ModelType.fromValue('request'), ModelType.request);
      expect(ModelType.fromValue('response'), ModelType.response);
    });

    test('fromValue should return null for invalid string', () {
      expect(ModelType.fromValue('unknown'), isNull);
    });

    test(
      'resolveParentDirUnderFeature should return correct path for each type',
      () {
        expect(
          ModelType.entity.resolveParentDirUnderFeature(),
          'domain/entities',
        );
        expect(ModelType.param.resolveParentDirUnderFeature(), 'domain/params');
        expect(ModelType.dto.resolveParentDirUnderFeature(), 'data/dtos');
        expect(
          ModelType.request.resolveParentDirUnderFeature(),
          'data/requests',
        );
        expect(
          ModelType.response.resolveParentDirUnderFeature(),
          'data/responses',
        );
      },
    );
  });
}
