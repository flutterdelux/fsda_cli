abstract final class Rules {
  static final _snakeCaseRegExp = RegExp(r'^[a-z]+(_[a-z0-9]+)*$');
  static final _pascalCaseRegExp = RegExp(r'^[A-Z][a-zA-Z0-9]*$');

  static final appNameRegExp = _snakeCaseRegExp;
  static const appNameDescription =
      'App name must be in strict snake_case (e.g., ruviti, ruviti_app).';

  // === Rule untuk --org (Reverse Domain) ===
  // Memastikan format seperti 'com.example' atau 'id.co.ruviti'
  // - Harus lowercase (a-z)
  // - Setiap segmen dipisahkan oleh titik (.)
  // - Setiap segmen harus diawali huruf, angka boleh setelahnya (misal: com.company2)
  static final orgRegExp = RegExp(r'^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$');
  static const orgDescription =
      'Organization (--org) must be in lowercase reverse-domain format separated by dots. '
      'Each segment must start with a letter (e.g., com.example, id.co.ruviti).';
  static const orgDefault = 'com.example';

  static final workspaceRegExp = _snakeCaseRegExp;
  static const workspaceDescription =
      'Workspace name must strictly use snake_case format '
      '(lowercase letters separated by underscores, e.g., my_awesome_workspace).';

  static final moduleRegExp = _snakeCaseRegExp;
  static const moduleDescription =
      'Module name must strictly use snake_case format '
      '(lowercase letters separated by underscores, e.g., authentication, user_profile).';

  static final featureRegExp = _snakeCaseRegExp;
  static const featureDescription =
      'Feature name must be in strict snake_case (e.g., user_profile, payment).';

  static final enumRegExp = _snakeCaseRegExp;
  static const enumDescription =
      'Enum name must be in strict snake_case (e.g., payment_method, role).';

  static final enumValueRegExp = _snakeCaseRegExp;
  static const enumValueDescription =
      'Enum value must be in strict snake_case (e.g., todo, in_progress).';

  static final modelRegExp = _snakeCaseRegExp;
  static const modelDescription =
      'Model name must be in strict snake_case (e.g., payment_entity, payment_setting_dto, task_response).';

  static final propNameRegExp = _snakeCaseRegExp;
  static const propNameDescription =
      'Property name must be in strict snake_case (e.g., name, task_status, created_at).';

  static final propConverterRegExp = _pascalCaseRegExp;
  static const propConverterDescription =
      'Converter class must be in strict PascalCase (e.g., TaskStatusConverter, UtcDateTimeConverter).';

  static final usecaseRegExp = _snakeCaseRegExp;
  static const usecaseDescription =
      'Use case class must be in strict snake_case (e.g., task_list_use_case, task_update_use_case).';

  static final methodRegExp = _snakeCaseRegExp;
  static const methodDescription =
      'Use case class must be in strict snake_case (e.g., get_task_list, update_task).';

  static final cacheKeyRegExp = _snakeCaseRegExp;
  static const cacheKeyDescription =
      'Cache key must be in strict snake_case (e.g., auth_token, theme_mode).';

  static final sliceRegExp = _snakeCaseRegExp;
  static const sliceDescription =
      'Slice name must be in strict snake_case (e.g., update, create, status_update).';

  static final fieldNameRegExp = _snakeCaseRegExp;
  static const fieldNameDescription =
      'Field name must be in strict snake_case (e.g., name, description, status).';

  static final modelTypeRegExp = _snakeCaseRegExp;
  static const modelTypeDescription =
      'Object type must be in strict snake_case (e.g., tas_entity, note_create_param).';

  static final failureNameRegExp = _snakeCaseRegExp;
  static const failureNameDescription =
      'Failure name must be in strict snake_case (e.g., invalid_payment_method, email_is_required).';

  static final composeTargetRegExp = _snakeCaseRegExp;
  static const composeTargetDescription =
      'Failure name must be in strict snake_case (e.g., product_detail_page, product_delete_button).';
}
