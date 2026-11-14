abstract final class DefaultValue {
  static String fromType(String type) {
    return switch (type) {
      'String' => '',
      'int' => '0',
      'double' => '0.0',
      'bool' => 'false',
      'num' => '0',
      'DateTime' => 'DateTime.now()',
      'Duration' => 'Duration(seconds: 1)',
      'Uri' => "Uri.parse('https:www.google.com')",
      'List' => '[]',
      'Map' => '{}',
      'Set' => '{}',
      'Symbol' => '',
      'Function' => '() {}',
      'Future<void>' => '() async {}',
      'VoidCallback' => '() {}',
      'dynamic' => '',
      'void' => 'null',
      'Object' => '',
      'Failure' => 'CoreFailure.serverError',
      'Uint8List' => "[]",
      'Int8List' => "[]",
      'Uint32List' => "[]",
      'Int32List' => "[]",
      'File' => "File('')",
      'Directory' => "Directory('')",
      _ => '',
    };
  }
}
