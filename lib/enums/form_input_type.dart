enum FormInputType {
  text('text'),
  number('number'),
  selector('selector'),
  textArea('text_area'),
  qty('qty'),
  dropdown('dropdown'),
  dropdownEnum('dropdown_enum'),
  image('image'),
  switcher('switch'),
  password('password'),
  selectorList('selector_list');

  final String code;

  const FormInputType(this.code);

  static FormInputType? tryParse(String raw) {
    return switch (raw.trim()) {
      'text' => FormInputType.text,
      'number' => FormInputType.number,
      'text_area' => FormInputType.textArea,
      'selector' => FormInputType.selector,
      'selector_list' => FormInputType.selectorList,
      'qty' => FormInputType.qty,
      'dropdown' => FormInputType.dropdown,
      'dropdown_enum' => FormInputType.dropdownEnum,
      'image' => FormInputType.image,
      'switch' => FormInputType.switcher,
      'password' => FormInputType.password,
      _ => null,
    };
  }
}
