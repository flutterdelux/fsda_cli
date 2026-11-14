import 'package:fsda_cli/infrastructure/text_modifiers/string_extension.dart';
import 'package:test/test.dart';

void main() {
  group('StringCasingExtension Tests', () {
    test('pascalCase should convert snake_case to PascalCase correctly', () {
      expect('auth_management'.pascalCase, 'AuthManagement');
      expect('user_profile_data'.pascalCase, 'UserProfileData');
      expect('single'.pascalCase, 'Single');
      expect(''.pascalCase, '');
    });

    test('camelCase should convert snake_case to camelCase correctly', () {
      expect('auth_management'.camelCase, 'authManagement');
      expect('user_profile_data'.camelCase, 'userProfileData');
      expect('single'.camelCase, 'single');
      expect(''.camelCase, '');
    });

    test('capitalCase should convert snake_case to Capital Case correctly', () {
      expect('auth_management'.capitalCase, 'Auth management');
      expect('user_profile_data'.capitalCase, 'User profile data');
      expect('single'.capitalCase, 'Single');
      expect(''.capitalCase, '');
    });

    test('titleCase should convert snake_case to Title Case correctly', () {
      expect('auth_management'.titleCase, 'Auth Management');
      expect('user_profile_data'.titleCase, 'User Profile Data');
      expect('single'.titleCase, 'Single');
      expect(''.titleCase, '');
    });

    test('kebabCase should convert snake_case to kebab-case correctly', () {
      expect('auth_management'.kebabCase, 'auth-management');
      expect('user_profile_data'.kebabCase, 'user-profile-data');
      expect('single'.kebabCase, 'single');
      expect(''.kebabCase, '');
    });

    test(
      'sentenceCase should convert snake_case to sentence case correctly',
      () {
        expect('auth_management'.sentenceCase, 'auth management');
        expect('user_profile_data'.sentenceCase, 'user profile data');
        expect('single'.sentenceCase, 'single');
        expect(''.sentenceCase, '');
      },
    );
  });
}
