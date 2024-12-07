import 'package:civic_project/models/bill_action.dart';

class BillSummary {
  final BillAction action;
  final String html;
  final DateTime updateDate;
  final String versionCode;
  BillSummary(this.action, this.html, this.updateDate, this.versionCode);

  factory BillSummary.fromJSON(Map<String, dynamic> json) {
    return BillSummary(
        BillAction(DateTime.parse(json['actionDate'] as String),
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
