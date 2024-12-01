import 'package:civic_project/services/congress_api_service.dart';

import 'bill.dart';
import 'term.dart';

class Member {
  static final Member empty = Member("", "", null, "", "", "", "", []);
  final String bioGuideId;
  final String? imageUrl;
  final int? district;
  final String state;
  final String name;
  final String partyName;
  final String chamber;
  final List<Term> terms;

  Member(this.bioGuideId, this.imageUrl, this.district, this.state, this.name,
      this.partyName, this.chamber, this.terms);

  factory Member.fromDetailedInfoJSON(Map<String, dynamic> json) {
    var listOfTermsJSON = json['terms'] as List;
    List<Term> terms =
        listOfTermsJSON.map((termJSON) => Term.fromJSON(termJSON)).toList();
    String currentChamber = terms[0].chamber;
    int? currentDistrict = listOfTermsJSON[0]['district'];
    String currentState = listOfTermsJSON[0]['stateName'];
    String currentParty = json['partyHistory'][0]['partyName'];
    return Member(
        json['bioguideId'] as String,
        json['depiction']['imageUrl'] as String,
        currentDistrict,
        currentState,
        json['invertedOrderName'] as String,
        currentParty,
        currentChamber,
        terms);
  }

  factory Member.fromJSON(Map<String, dynamic> json) {
    var listOfTermsJSON = json['terms']['item'] as List;
    List<Term> terms =
        listOfTermsJSON.map((termJSON) => Term.fromJSON(termJSON)).toList();
    String currentChamber = terms[0].chamber;
    return Member(
        json['bioguideId'] as String,
        json['depiction'] != null
            ? json['depiction']['imageUrl'] as String
            : null,
        json['district'] as int?,
        json['state'] as String,
        json['name'] as String,
        json['partyName'] as String,
        currentChamber,
        terms);
  }

  Future<List<Bill>> cosponsoredLegislation({int offset = 0, int limit = 10}) async {
    return await CongressApiService.fetchBillsCosponsoredByMember(this, offset: offset, limit: limit);
  }

  Future<List<Bill>> sponsoredLegislation(
      {int offset = 0, int limit = 10}) async {
    return await CongressApiService.fetchBillsSponsoredByMember(this,
        offset: offset, limit: limit);
  }

  @override
  String toString() {
    return '$name, $partyName, $chamber from $state\'s district $district\nTerms: $terms\nbioGuideId: $bioGuideId imageUrl: $imageUrl';
  }

  static Future<Member> currentMemberFromStateCodeDistrict(
      String stateCode, int district) async {
    List<Member> members =
        await CongressApiService.fetchMembersByStateCodeDistrict(
            stateCode, district,
            currentMember: true);
    return members[0];
  }

  static Future<Member> memberFromId(String bioguideId) async {
    return await CongressApiService.fetchMemberFromId(bioguideId);
  }

  static Future<List<Member>> members(
      {int offset = 0, int limit = 250, bool currentMember = true}) async {
    return await CongressApiService.fetchMembers(
        offset: offset, limit: limit, currentMember: currentMember);
  }

  static Future<List<Member>> membersFromStateCode(String stateCode,
      {bool currentMember = true}) async {
    return await CongressApiService.fetchMembersByStateCode(stateCode,
        currentMember: currentMember);
  }

  static Future<List<Member>> membersFromStateCodeDistrict(
      String stateCode, int district,
      {bool currentMember = true}) async {
    return await CongressApiService.fetchMembersByStateCodeDistrict(
        stateCode, district,
        currentMember: currentMember);
  }
}
