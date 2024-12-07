class BillAction {
  DateTime actionDate;
  String text;
  BillAction(this.actionDate, this.text);
  factory BillAction.fromJSON(Map<String, dynamic> json) {
    return BillAction(
        DateTime.parse(json['actionDate'] as String), json['text'] as String);
  }

  @override
  String toString() {
    return 'Date: $actionDate Text: $text';
  }
}
