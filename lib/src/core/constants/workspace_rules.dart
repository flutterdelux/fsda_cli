abstract final class WorkspaceRules {
  static final RegExp snakeCaseRegex = RegExp(r'^[a-z]+(_[a-z0-9]+)*$');

  static const String namingRuleDescription =
      'Workspace name must strictly use snake_case format '
      '(lowercase letters separated by underscores, e.g., my_awesome_workspace).';
}
