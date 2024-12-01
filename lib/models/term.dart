class Term {
  final int startYear;
  final int? endYear;
  final String chamber;
  Term(this.startYear, this.endYear, this.chamber);
  factory Term.fromJSON(Map<String, dynamic> json) {
    return Term(json['startYear'] as int, json['endYear'] as int?,
        json['chamber'] as String);
  }
  @override
  String toString() {
    return '$startYear-${endYear ?? 'present'} in the $chamber';
  }
}
