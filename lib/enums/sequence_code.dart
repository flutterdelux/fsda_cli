enum SequenceCode {
  m('M', 'Mutation'),
  mp('Mp', 'Mutation + Param'),
  mr('Mr', 'Mutation + Return'),
  mrp('Mrp', 'Mutation + Return + Param'),
  r('R', 'Retrieval'),
  rp('Rp', 'Retrieval + Param'),
  rpag('Rpag', 'Retrieval + Pagination'),
  rs('Rs', 'Retrieval + Stream'),
  rsp('Rsp', 'Retrieval + Stream + Param'),
  rof('Rof', 'Retrieval + Offline First');

  final String code;
  final String description;

  const SequenceCode(this.code, this.description);

  factory SequenceCode.fromValue(String? code) {
    return values.firstWhere(
      (e) => e.code == code,
      orElse: () => throw ArgumentError(
        'Unsupported sequence code: $code. Supported code(s): ${values.map((e) => '- ${e.code}\n').join('\n')}',
      ),
    );
  }

  bool get isMutation => code.startsWith('M');
  bool get isRetrieval => code.startsWith('R');
}
