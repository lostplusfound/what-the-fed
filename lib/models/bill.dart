import 'package:civic_project/models/text_version.dart';
import 'package:civic_project/services/congress_api_service.dart';

import 'bill_action.dart';
import 'bill_summary.dart';
import 'member.dart';

class Bill {
  static final Bill empty = Bill(
      '', '', '', BillAction(DateTime.fromMillisecondsSinceEpoch(0), ''), 0);
  final String title;
  final String type;
  final String number;
  final BillAction latestAction;
  final int congress;
  Member? _sponsor;
  String? _policyArea;
  TextVersion? _latestTextVersion;

  BillSummary? _latestSummary;

  Bill(this.title, this.type, this.number, this.latestAction, this.congress);

  factory Bill.fromJSON(Map<String, dynamic> json) {
    return Bill(
        json['title'] as String,
        json['type'] as String,
        json['number'].toString(),
        BillAction.fromJSON(json['latestAction']),
        json['congress'] as int);
  }

  Future<BillSummary> get latestSummary async {
    if (_latestSummary == null) {
      List<BillSummary> summariesList = await summaries(limit: 250);
      _latestSummary = summariesList[summariesList.length - 1];
    }
    return _latestSummary!;
  }

  Future<TextVersion> get latestTextVersion async {
    if (_latestTextVersion == null) {
      List<TextVersion> versionsList = await textVersions(limit: 1);
      _latestTextVersion ??= versionsList[0];
    }
    return _latestTextVersion!;
  }

  Future<String> get policyArea async {
    _policyArea ??= await CongressApiService.fetchPolicyAreaOfBill(this);
    return _policyArea!;
  }

  Future<Member> get sponsor async {
    _sponsor ??= await CongressApiService.fetchSponsorOfBill(this);
    return _sponsor!;
  }

  Future<List<BillAction>> actions({int offset = 0, int limit = 10}) async {
    return await CongressApiService.fetchActionsForBill(this,
        offset: offset, limit: limit);
  }

  Future<List<Member>> cosponsors() async {
    return await CongressApiService.fetchCosponsorsOfBill(this);
  }

  Future<List<Bill>> relatedBills({int offset = 0, int limit = 250}) async {
    return await CongressApiService.fetchRelatedBills(this,
        offset: offset, limit: limit);
  }

  Future<List<String>> subjects({int offset = 0, int limit = 250}) async {
    return await CongressApiService.fetchSubjectsOfBill(this,
        offset: offset, limit: limit);
  }

  Future<List<BillSummary>> summaries({int offset = 0, int limit = 5}) async {
    return await CongressApiService.fetchSummariesForBill(this,
        offset: offset, limit: limit);
  }

  Future<List<TextVersion>> textVersions({int limit = 5}) async {
    return await CongressApiService.fetchBillTextVersions(this, limit: limit);
  }

  @override
  String toString() {
    return '$type $number: $title Congress: $congress Latest action: $latestAction';
  }

  static Future<Bill> fromCongressTypeAndNumber(
      int congress, String type, String number) async {
    return await CongressApiService.fetchBillByCongressTypeAndNumber(
        congress, type.toLowerCase(), number);
  }

  static Future<List<Bill>> latestBills(
      {int offset = 0, int limit = 250}) async {
    return await CongressApiService.fetchBills(offset: offset, limit: limit);
  }
}
