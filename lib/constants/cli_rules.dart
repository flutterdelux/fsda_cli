abstract final class CliRules {
  static const workspaceNamePattern = r'^[a-zA-Z][a-zA-Z0-9_-]*$';
  static String get workspaceNameRule => '''
Naming rules:
1. Must start with a letter (a-z)
2. Can only contain letters, numbers, underscores (_), or dashes (-)

Tips: If you want to use dash/underscore, type directly: fsda create Toko-Sepatu_01
Example: fsda create TokoSepatu_01 or fsda create Toko-Sepatu-01
''';

  static const appNamePattern = _snakeCasePattern;
  static String get appNameRule => '''$_snakeCaseRule
Tips: If you want to use underscore, type directly: fsda gen-app toko_sepatu
Example: fsda gen-app tokosepatu or fsda gen-app toko_sepatu
''';

  static const packageNamePattern = _snakeCasePattern;
  static String get packageNameRule => '''$_snakeCaseRule
Tips: If you want to use underscore, type directly: fsda add-pckg toko_sepatu_01
Example: fsda add-pckg tokosepatu_01 or fsda add-pckg toko_sepatu_01
''';

  static const moduleNamePattern = _snakeCasePattern;
  static String get moduleNameRule => '''$_snakeCaseRule
Tips: If you want to use underscore, type directly: fsda gen-module app_auth
Example: fsda gen-module app_auth or fsda gen-module auth
''';

  static const featureNamePattern = _snakeCasePattern;
  static String get featureNameRule => '''$_snakeCaseRule
Tips: If you want to use underscore, type directly: fsda gen-feature wallet -m finance
Example: fsda gen-feature wallet -m finance
''';

  static const sliceNamePattern = _snakeCasePattern;
  static String get sliceNameRule => '''$_snakeCaseRule
Tips: If you want to use underscore, type directly: fsda slice-m wallet -f transfer -m finance -d updateWallet
Example: fsda slice-m wallet -f transfer -m finance -d updateWallet
''';

  static const methodNamePattern = _camelCasePattern;
  static String get methodNameRule => '''$_camelCaseRule
Tips: Use camelCase for multiple words, type directly: fsda slice-m wallet -f transfer -m finance -d markAll
Example: fsda slice-m wallet -f transfer -m finance -d post
''';

  static const artifactPrefixPattern = _artifactPrefixPattern;
  static String get artifactPrefixRule => '''
Naming rules:
1. Must start with a letter (a-z or A-Z)
2. Can contain letters, numbers, underscores (_)

Tips: Common examples are `wallet` or `wallet_create`.
Example: fsda dto Wallet -m finance -f wallet --props "String:id"
''';

  static const modelPrefixPattern = _modelPrefixPattern;
  static String get modelPrefixRule => '''
Naming rules:
1. Must start with an uppercase letter (A-Z)
2. Use PascalCase
3. Do not include Dto/Entity suffix

Tips: Use base model prefix only (e.g., `Category`, not `CategoryDto`).
Example: fsda slice-r detail -f category -m catalog -d getCategoryDetail --model Category
''';

  static const pageNamePattern = _snakeCasePattern;
  static String get pageNameRule => '''$_snakeCaseRule
Tips: If you want to use underscore, type directly: fsda compose-main submit_transfer -f transfer -m finance -a fsda_demo -p submit_transfer_page
Example: fsda compose-main submit_transfer -f transfer -m finance -a fsda_demo -p submit_transfer_page
''';
}

const _snakeCasePattern = r'^[a-z][a-z0-9_]*$';
const _snakeCaseRule = '''
Naming rules:
1. Must start with a letter (a-z)
2. Must be lowercase (a-z)
3. Can only contain letters, numbers, underscores (_)
''';

const _camelCasePattern = r'^[a-z][a-zA-Z0-9]*$';
const _camelCaseRule = '''
Naming rules:
1. Must start with a letter (a-z)
2. Use camelCase for multiple words (e.g., myFeature)
3. Can only contain letters and numbers (a-z, 0-9)
''';

const _artifactPrefixPattern = r'^[A-Za-z][A-Za-z0-9_]*$';
const _modelPrefixPattern = r'^[A-Z][A-Za-z0-9]*$';
