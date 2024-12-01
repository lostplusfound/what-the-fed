import 'package:civic_project/models/action.dart';

class BillSummary {
  final Action action;
  final String html;
  final DateTime updateDate;
  final String versionCode;
  BillSummary(this.action, this.html, this.updateDate, this.versionCode);

  factory BillSummary.fromJSON(Map<String, dynamic> json) {
    return BillSummary(
        Action(DateTime.parse(json['actionDate'] as String),
            json['actionDesc'] as String),
        json['text'] as String,
        DateTime.parse(json['updateDate'] as String),
        json['versionCode'] as String);
  }

  @override
  String toString() {
    return '$action Text: $html Update date: $updateDate Version code: $versionCode';
  }
}
