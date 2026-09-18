enum InputCode {
  text('text', 'Text Field'),
  dropdown('dropdown', 'Dropdown Field (Custom)'),
  dropdownEnum('dropdown-enum', 'Dropdown Field (Enum)'),
  password('password', 'Password Field');

  final String code;
  final String description;

  const InputCode(this.code, this.description);
}
