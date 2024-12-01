import 'package:civic_project/pages/daily_record_page.dart';
import 'package:civic_project/pages/legislation_page.dart';
import 'package:civic_project/pages/members_page.dart';
import 'package:flutter/material.dart';

class CongressPage extends StatefulWidget {
  const CongressPage({super.key});

  @override
  State<CongressPage> createState() => _CongressPageState();
}

class _CongressPageState extends State<CongressPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Center(
              child: Text('Congress'),
            ),
            bottom: TabBar(tabs: [
              Tab(
                text: 'Daily Record',
              ),
              Tab(
                text: 'Legislation',
              ),
              Tab(
                text: 'Members',
              )
            ]),
          ),
          body: TabBarView(children: [
            DailyRecordPage(),
            LegislationPage(),
            MembersPage(),
          ]),
        ));
  }
}
