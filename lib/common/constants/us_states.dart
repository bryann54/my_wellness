class UsState {
  final String code;
  final String name;

  const UsState({required this.code, required this.name});

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsState &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

class UsStates {
  static const List<UsState> all = [
    UsState(code: 'AL', name: 'Alabama'),
    UsState(code: 'AK', name: 'Alaska'),
    UsState(code: 'AZ', name: 'Arizona'),
    UsState(code: 'AR', name: 'Arkansas'),
    UsState(code: 'CA', name: 'California'),
    UsState(code: 'CO', name: 'Colorado'),
    UsState(code: 'CT', name: 'Connecticut'),
    UsState(code: 'DE', name: 'Delaware'),
    UsState(code: 'FL', name: 'Florida'),
    UsState(code: 'GA', name: 'Georgia'),
    UsState(code: 'HI', name: 'Hawaii'),
    UsState(code: 'ID', name: 'Idaho'),
    UsState(code: 'IL', name: 'Illinois'),
    UsState(code: 'IN', name: 'Indiana'),
    UsState(code: 'IA', name: 'Iowa'),
    UsState(code: 'KS', name: 'Kansas'),
    UsState(code: 'KY', name: 'Kentucky'),
    UsState(code: 'LA', name: 'Louisiana'),
    UsState(code: 'ME', name: 'Maine'),
    UsState(code: 'MD', name: 'Maryland'),
    UsState(code: 'MA', name: 'Massachusetts'),
    UsState(code: 'MI', name: 'Michigan'),
    UsState(code: 'MN', name: 'Minnesota'),
    UsState(code: 'MS', name: 'Mississippi'),
    UsState(code: 'MO', name: 'Missouri'),
    UsState(code: 'MT', name: 'Montana'),
    UsState(code: 'NE', name: 'Nebraska'),
    UsState(code: 'NV', name: 'Nevada'),
    UsState(code: 'NH', name: 'New Hampshire'),
    UsState(code: 'NJ', name: 'New Jersey'),
    UsState(code: 'NM', name: 'New Mexico'),
    UsState(code: 'NY', name: 'New York'),
    UsState(code: 'NC', name: 'North Carolina'),
    UsState(code: 'ND', name: 'North Dakota'),
    UsState(code: 'OH', name: 'Ohio'),
    UsState(code: 'OK', name: 'Oklahoma'),
    UsState(code: 'OR', name: 'Oregon'),
    UsState(code: 'PA', name: 'Pennsylvania'),
    UsState(code: 'RI', name: 'Rhode Island'),
    UsState(code: 'SC', name: 'South Carolina'),
    UsState(code: 'SD', name: 'South Dakota'),
    UsState(code: 'TN', name: 'Tennessee'),
    UsState(code: 'TX', name: 'Texas'),
    UsState(code: 'UT', name: 'Utah'),
    UsState(code: 'VT', name: 'Vermont'),
    UsState(code: 'VA', name: 'Virginia'),
    UsState(code: 'WA', name: 'Washington'),
    UsState(code: 'WV', name: 'West Virginia'),
    UsState(code: 'WI', name: 'Wisconsin'),
    UsState(code: 'WY', name: 'Wyoming'),
    UsState(code: 'DC', name: 'District of Columbia'),
  ];
  static String decode(String? code) {
    if (code == null || code.isEmpty) return code ?? '';
    return all
        .firstWhere(
          (s) => s.code.toUpperCase() == code.toUpperCase(),
          orElse: () => UsState(code: code, name: code),
        )
        .name;
  }
}
