// ── Language model ────────────────────────────────────────────────────────────

class Language {
  final String code;
  final String labelKey;
  final String flagAsset;

  const Language({
    required this.code,
    required this.labelKey,
    required this.flagAsset,
  });
}

const Languages = [
  Language(
    code: 'sw',
    labelKey: 'language.swahili',
    flagAsset: 'assets/images/flag_es.png',
  ),
  Language(
    code: 'en',
    labelKey: 'language.english',
    flagAsset: 'assets/images/flag_en.png',
  ),
];
