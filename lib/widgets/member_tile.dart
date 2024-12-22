import 'package:civic_project/models/member.dart';
import 'package:civic_project/pages/member_page.dart';
import 'package:flutter/material.dart';

class MemberTile extends StatelessWidget {
  final Member m;
  const MemberTile(this.m, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => MemberPage(m)));
      },
      title: Text(m.name),
      subtitle: Text(
          '${m.partyName} ${m.memberType} from ${m.state}${(m.memberType == 'Representative') ? '\'s district ${m.district ?? 'at-large'}' : ''}'),
      trailing: const Icon(Icons.arrow_forward_ios),
    );
  }
}
