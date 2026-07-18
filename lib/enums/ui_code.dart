enum UiCode {
  main('main', ' Main Content'),
  dialog('dialog', 'Alert Dialog'),
  form('form', 'Form'),
  lsh('lsh', 'List Horizontal'),
  lsv('lsv', 'List Vertical'),
  pag('pag', 'Pagination'),
  pmi('pmi', 'Popup Menu Item'),
  sec('sec', 'Section');

  final String code;
  final String description;

  const UiCode(this.code, this.description);

  factory UiCode.fromValue(String? code) {
    return values.firstWhere(
      (e) => e.code == code,
      orElse: () => throw ArgumentError(
        'Unsupported UI code: $code. Supported code(s): ${values.map((e) => '- ${e.code}\n').join('\n')}',
      ),
    );
  }
}
