// ── Language model ────────────────────────────────────────────────────────────

class Language {
  final String code;
  final String label;
  final String flagAsset;

  const Language({
    required this.code,
    required this.label,
    required this.flagAsset,
  });
}

const Languages = [
  Language(
    code: 'sw',
    label: 'swahili',
    flagAsset: 'assets/images/flag_es.png',
  ),
  Language(
    code: 'en',
    label: 'English US',
    flagAsset: 'assets/images/flag_en.png',
  ),
];
