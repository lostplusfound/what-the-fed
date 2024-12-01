import 'package:civic_project/services/congress_api_service.dart';
import 'package:http/http.dart' as http;

class CongressionalRecord {
  final String congress;
  final int id;
  final String issue;
  final Uri entireIssueUrl;
  final DateTime publishDate;
  final String session;
  final String volume;

  CongressionalRecord(this.congress, this.id, this.issue, this.entireIssueUrl,
      this.publishDate, this.session, this.volume);

  factory CongressionalRecord.fromJSON(Map<String, dynamic> json) {
    Map<String, dynamic> links = json['Links'];
    return CongressionalRecord(
        json['Congress'] as String,
        json['Id'] as int,
        json['Issue'] as String,
        Uri.parse(links['FullRecord']['PDF'][0]['Url'] as String),
        DateTime.parse(json['PublishDate'] as String),
        json['Session'] as String,
        json['Volume'] as String);
  }

  static Future<CongressionalRecord> latestRecord() async {
    List<CongressionalRecord> records =
        await CongressApiService.fetchLatestCongressionalRecords(limit: 1);
    return records[0];
  }

  static Future<List<CongressionalRecord>> latestRecords(
      {int offset = 0, int limit = 10}) async {
    return await CongressApiService.fetchLatestCongressionalRecords(
        offset: offset, limit: limit);
  }

  @override
  String toString() {
    return 'Published: $publishDate Entire Issue: $entireIssueUrl';
  }
}
