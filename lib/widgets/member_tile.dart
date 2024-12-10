import 'package:civic_project/models/member.dart';
import 'package:civic_project/pages/member_page.dart';
import 'package:civic_project/services/cors_proxy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MemberTile extends StatelessWidget {
  final Member m;
  const MemberTile(this.m, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(
          (kIsWeb) ? CorsProxy.proxyUrlString(m.imageUrl!) : m.imageUrl!),
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => MemberPage(m)));
      },
      title: Text(m.name),
      subtitle:
          Text('Chamber: ${m.chamber} State: ${m.state} Party: ${m.partyName}'),
      trailing: Icon(Icons.arrow_forward_ios),
    );
  }
}
