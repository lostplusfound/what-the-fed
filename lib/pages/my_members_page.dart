import 'package:civic_project/models/member.dart';
import 'package:civic_project/services/geocodio.dart';
import 'package:civic_project/widgets/member_tile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyMembersPage extends StatefulWidget {
  const MyMembersPage({super.key});

  @override
  State<MyMembersPage> createState() => _MyMembersPageState();
}

class _MyMembersPageState extends State<MyMembersPage> {
  final TextEditingController _controller = TextEditingController();
  final SharedPreferencesAsync prefs = SharedPreferencesAsync();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('My Members')),
      ),
      body: Column(
        children: [
          TextButton(
              onPressed: () {
                prefs.clear();
                setState(() {});
              },
              child: Text('Change Address')),
          FutureBuilder(
            future: _getMyMembers(),
            builder:
                (BuildContext context, AsyncSnapshot<List<Member>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.hasData) {
                return Column(
                    children: snapshot.data!
                        .map((member) => MemberTile(member))
                        .toList());
              }
              return Center(child: Text('No data available'));
            },
          ),
        ],
      ),
    );
  }

  Future<void> _promptSetLocation() async {
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Enter your address'),
              content: TextField(
                controller: _controller,
              ),
              actions: [
                TextButton(
                    onPressed: Navigator.of(context).pop, child: Text('Set'))
              ],
            ));
    ({String state, int district})? result =
        await Geocodio.getStateAndDistrict(_controller.text);
    if (result == null) return;
    await prefs.setString('State', result.state);
    await prefs.setInt('District', result.district);
  }

  Future<List<Member>> _getMyMembers() async {
    String? state = await prefs.getString('State');
    int? district = await prefs.getInt('District');
    while (state == null || district == null) {
      await _promptSetLocation();
      state = await prefs.getString('State');
      district = await prefs.getInt('District');
    }
    final List<Member> stateMembers =
        await Member.membersFromStateCode(state, currentMember: true);
    return stateMembers
        .where((m) => (m.memberType == 'Senator' || m.district == district))
        .toList();
  }
}
