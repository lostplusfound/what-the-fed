import 'dart:convert' as convert;
import 'package:civic_project/models/bill_action.dart';
import 'package:civic_project/models/bill.dart';
import 'package:civic_project/models/bill_summary.dart';
import 'package:civic_project/models/congressional_record.dart';
import 'package:civic_project/models/member.dart';
import 'package:civic_project/models/text_version.dart';
import 'package:http/http.dart' as http;

class CongressApiService {
  static const String _authority = 'api.congress.gov';
  static const String _apiKey = 'PIKgrk96nEcgeCb2KldJcc9mxqQzinDubhVvpcvO';
  CongressApiService._();
  static int currentCongress() {
    int currentYear = DateTime.now().year;
    return congressFromYear(currentYear);
  }

  static int congressFromYear(int year) {
    return ((year - 1789) / 2).floor() + 1;
  }

  static Future<List<CongressionalRecord>> fetchLatestCongressionalRecords(
      {int offset = 0, int limit = 10}) async {
    var url = Uri.https(_authority, '/v3/congressional-record', {
      'api_key': _apiKey,
      'offset': offset.toString(),
      'limit': limit.toString(),
      'format': 'json'
    });
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      var issuesJSON = jsonResponse['Results']['Issues'] as List;
      return issuesJSON.map((e) => CongressionalRecord.fromJSON(e)).toList();
    }
    return [];
  }

  static Future<List<CongressionalRecord>> fetchCongressionalRecordsByDate(
      {int offset = 0, int limit = 10, int? year, int? month, int? day}) async {
    var queryParams = {
      'api_key': _apiKey,
      'offset': offset.toString(),
      'limit': limit.toString(),
      'format': 'json'
    };
    if (year != null) queryParams['y'] = year.toString();
    if (month != null) queryParams['m'] = month.toString();
    if (day != null) queryParams['d'] = day.toString();
    var url = Uri.https(_authority, '/v3/congressional-record', queryParams);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      var issuesJSON = jsonResponse['Results']['Issues'] as List;
      return issuesJSON.map((e) => CongressionalRecord.fromJSON(e)).toList();
    }
    return [];
  }

  static Future<List<BillAction>> fetchActionsForBill(Bill b,
      {int offset = 0, int limit = 10}) async {
    var url = Uri.https(_authority,
        '/v3/bill/${b.congress}/${b.type.toLowerCase()}/${b.number}/actions', {
      'api_key': _apiKey,
      'offset': offset.toString(),
      'limit': limit.toString(),
      'format': 'json'
    });
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      var actionsJSON = jsonResponse['actions'] as List;
      return actionsJSON.map((e) => BillAction.fromJSON(e)).toList();
    }
    return [];
  }

  static Future<Bill> fetchBillByCongressTypeAndNumber(
      int congress, String type, String number) async {
    var url = Uri.https(
        _authority,
        '/v3/bill/$congress/${type.toLowerCase()}/$number',
        {'api_key': _apiKey, 'format': 'json'});
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      return Bill.fromJSON(jsonResponse['bill']);
    }
    return Bill.empty;
  }

  static Future<List<Bill>> fetchBills({int offset = 0, int limit = 10}) async {
    var url = Uri.https(_authority, '/v3/bill', {
      'api_key': _apiKey,
      'offset': offset.toString(),
      'limit': limit.toString(),
      'format': 'json'
    });
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      var billsJSON = jsonResponse['bills'] as List;
      return billsJSON.map((json) => Bill.fromJSON(json)).toList();
    }
    return [];
  }

  static Future<List<Bill>> fetchBillsCosponsoredByMember(Member m,
      {int offset = 0, int limit = 10}) async {
    var url = Uri.https(
        _authority, '/v3/member/${m.bioGuideId}/cosponsored-legislation', {
      'api_key': _apiKey,
      'format': 'json',
      'offset': offset.toString(),
      'limit': limit.toString()
    });
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      var billsJSON = jsonResponse['cosponsoredLegislation'] as List;
      return billsJSON
          .where((bill) => bill['title'] != null)
          .map((bill) => Bill.fromJSON(bill))
          .toList();
    }
    return [];
  }

  static Future<List<Bill>> fetchBillsSponsoredByMember(Member m,
      {int offset = 0, int limit = 10}) async {
    var url = Uri.https(
        _authority, '/v3/member/${m.bioGuideId}/sponsored-legislation', {
      'api_key': _apiKey,
      'format': 'json',
      'offset': offset.toString(),
      'limit': limit.toString()
    });
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      var billsJSON = jsonResponse['sponsoredLegislation'] as List;
      return billsJSON
          .where((bill) => bill['title'] != null)
          .map((bill) => Bill.fromJSON(bill))
          .toList();
    }
    return [];
  }

  static Future<List<TextVersion>> fetchBillTextVersions(Bill b,
      {int limit = 5}) async {
    var url = Uri.https(
        _authority,
        '/v3/bill/${b.congress}/${b.type.toLowerCase()}/${b.number}/text',
        {'api_key': _apiKey, 'limit': limit.toString(), 'format': 'json'});
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      var textVersionsJSON = jsonResponse['textVersions'] as List;
      return textVersionsJSON
          .where((textVersionJSON) => textVersionJSON['formats'].length > 0)
          .map((e) => TextVersion.fromJSON(e))
          .toList();
    }
    return [];
  }

  static Future<List<Member>> fetchCosponsorsOfBill(Bill b) async {
    var url = Uri.https(
        _authority,
        '/v3/bill/${b.congress}/${b.type.toLowerCase()}/${b.number}/cosponsors',
        {'api_key': _apiKey, 'format': 'json'});
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      var cosponsorsJSON = jsonResponse['cosponsors'] as List;
      var cosponsorFutures = cosponsorsJSON
          .map((cosponsor) => fetchMemberFromId(cosponsor['bioguideId']))
          .toList();
      return await Future.wait(cosponsorFutures);
    }
    return [];
  }

  static Future<Member> fetchMemberFromId(String bioGuideId) async {
    var url = Uri.https(_authority, '/v3/member/$bioGuideId',
        {'api_key': _apiKey, 'format': 'json'});
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      return Member.fromDetailedInfoJSON(jsonResponse['member']);
    }
    return Member.empty;
  }

  static Future<List<Member>> fetchMembers(
      {int offset = 0, int limit = 250, bool currentMember = true}) async {
    var url = Uri.https(_authority, '/v3/member', {
      'api_key': _apiKey,
      'offset': offset.toString(),
      'limit': limit.toString(),
      'currentMember': currentMember.toString(),
      'format': 'json'
    });
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      var membersJSON = jsonResponse['members'] as List;
      return membersJSON
          .map((memberJSON) => Member.fromJSON(memberJSON))
          .toList();
    }
    return [];
  }

  static Future<List<Member>> fetchMembersByStateCode(String stateCode,
      {bool currentMember = true, limit = 250}) async {
    var url = Uri.https(_authority, '/v3/member/$stateCode', {
      'api_key': _apiKey,
      'format': 'json',
      'currentMember': currentMember.toString(),
      'limit': limit.toString()
    });
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      var membersJSON = jsonResponse['members'] as List;
      return membersJSON.map((member) => Member.fromJSON(member)).toList();
    }
    return [];
  }

  static Future<List<Member>> fetchMembersByStateCodeDistrict(
      String stateCode, int district,
      {bool currentMember = true}) async {
    var url = Uri.https(_authority, '/v3/member/$stateCode/$district', {
      'api_key': _apiKey,
      'format': 'json',
      'currentMember': currentMember.toString(),
    });
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      var membersJSON = jsonResponse['members'] as List;
      return membersJSON.map((e) => Member.fromJSON(e)).toList();
    }
    return [];
  }

  static Future<String> fetchPolicyAreaOfBill(Bill b,
      {int offset = 0, int limit = 250}) async {
    var url = Uri.https(_authority,
        '/v3/bill/${b.congress}/${b.type.toLowerCase()}/${b.number}/subjects', {
      'api_key': _apiKey,
      'offset': offset.toString(),
      'limit': limit.toString(),
      'format': 'json'
    });
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      return jsonResponse['subjects']['policyArea']['name'] as String;
    }
    return '';
  }

  static Future<List<Bill>> fetchRelatedBills(Bill b,
      {int offset = 0, int limit = 250}) async {
    var url = Uri.https(
        _authority,
        '/v3/bill/${b.congress}/${b.type.toLowerCase()}/${b.number}/relatedbills',
        {
          'api_key': _apiKey,
          'offset': offset.toString(),
          'limit': limit.toString(),
          'format': 'json'
        });
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      var relatedBillsJSON = jsonResponse['relatedBills'] as List;
      return relatedBillsJSON.map((e) => Bill.fromJSON(e)).toList();
    }
    return [];
  }

  static Future<Member> fetchSponsorOfBill(Bill b) async {
    var url = Uri.https(
        _authority,
        '/v3/bill/${b.congress}/${b.type.toLowerCase()}/${b.number}',
        {'api_key': _apiKey, 'format': 'json'});
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      var sponsorJSON =
          jsonResponse['bill']['sponsors'][0] as Map<String, dynamic>;
      var bioGuideId = sponsorJSON['bioguideId'];
      return fetchMemberFromId(bioGuideId);
    }
    return Member("", "", null, "", "", "", "", []);
  }

  static Future<List<String>> fetchSubjectsOfBill(Bill b,
      {int offset = 0, int limit = 250}) async {
    var url = Uri.https(_authority,
        '/v3/bill/${b.congress}/${b.type.toLowerCase()}/${b.number}/subjects', {
      'api_key': _apiKey,
      'offset': offset.toString(),
      'limit': limit.toString(),
      'format': 'json'
    });
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      var subjectsJSON =
          jsonResponse['subjects']['legislativeSubjects'] as List;
      return subjectsJSON.map((e) => e['name'] as String).toList();
    }
    return [];
  }

  static Future<List<BillSummary>> fetchSummariesForBill(Bill b,
      {int offset = 0, int limit = 5}) async {
    var url = Uri.https(
        _authority,
        '/v3/bill/${b.congress}/${b.type.toLowerCase()}/${b.number}/summaries',
        {'api_key': _apiKey, 'limit': limit.toString(), 'format': 'json'});
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      var summariesJSON = jsonResponse['summaries'] as List;
      return summariesJSON.map((e) => BillSummary.fromJSON(e)).toList();
    }
    return [];
  }
}
