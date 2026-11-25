import '../../core/constants/rules.dart';
import '../../domain/params/app_param.dart';
import '../../domain/params/gen_app_param.dart';
import '../../infrastructure/text_modifiers/string_extension.dart';

abstract final class GenAppResolverKeys {
  /// `org`
  static const org = 'org';

  /// `title`
  static const title = 'title';

  /// `org-name`
  static const orgName = 'org-name';
}

abstract final class GenAppResolver {
  static GenAppParam resolve({
    required Map<String, dynamic> data,
    required AppParam app,
  }) {
    // ============ org ============
    final rawOrg = data[GenAppResolverKeys.org] ?? Rules.orgDefault;
    if (rawOrg is! String) {
      throw const FormatException(
        'Organization identifier must be String type.',
      );
    }

    final org = rawOrg.trim();
    if (org.isEmpty) {
      throw const FormatException('Organization identifier cannot be empty.');
    }

    if (!Rules.orgRegExp.hasMatch(org)) {
      throw FormatException(
        'Invalid organization identifier format: "$org".\n'
        '${Rules.orgDescription}',
      );
    }

    // ============ title (optional) ============
    final rawTitle = data[GenAppResolverKeys.title];
    if (rawTitle != null && rawTitle is! String) {
      throw const FormatException('App title must be String type.');
    }
    final trimmedTitle = (rawTitle as String?)?.trim() ?? '';
    final appTitle = trimmedTitle.isNotEmpty
        ? trimmedTitle
        : app.appName.titleCase;

    // ============ org-name (optional) ============
    final rawOrgName = data[GenAppResolverKeys.orgName];
    if (rawOrgName != null && rawOrgName is! String) {
      throw const FormatException('Organization name must be String type.');
    }
    final trimmedOrgName = (rawOrgName as String?)?.trim() ?? '';
    final orgName = trimmedOrgName.isNotEmpty
        ? trimmedOrgName
        : org.split('.').last;

    return GenAppParam.fromApp(
      app: app,
      appTitle: appTitle,
      org: org,
      orgName: orgName,
    );
  }
}
