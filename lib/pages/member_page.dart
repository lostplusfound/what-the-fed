import 'package:civic_project/models/member.dart';
import 'package:flutter/material.dart';

class MemberPage extends StatelessWidget {
  final Member _m;

  const MemberPage(this._m, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(_m.name),),);
  }
}
