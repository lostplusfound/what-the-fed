class Action {
  DateTime actionDate;
  String text;
  Action(this.actionDate, this.text);
  factory Action.fromJSON(Map<String, dynamic> json) {
    return Action(
        DateTime.parse(json['actionDate'] as String), json['text'] as String);
  }

  @override
  String toString() {
    return 'Date: $actionDate Text: $text';
  }
}
