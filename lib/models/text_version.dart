class TextVersion {
  final DateTime? date;
  final Uri htmlUrl;
  final Uri pdfUrl;
  final Uri xmlUrl;
  final String type;
  TextVersion(this.date, this.htmlUrl, this.pdfUrl, this.xmlUrl, this.type);
  factory TextVersion.fromJSON(Map<String, dynamic> json) {
    return TextVersion(
        json['date'] != null ? DateTime.parse(json['date'] as String) : null,
        Uri.parse(json['formats'][0]['url'] as String),
        Uri.parse(json['formats'][1]['url'] as String),
        Uri.parse(json['formats'][2]['url'] as String),
        json['type'] as String);
  }
  
  @override
  String toString() {
    return 'Date: $date Html Url: $htmlUrl Pdf Url: $pdfUrl Xml Url: $xmlUrl Type: $type';
  }
}
