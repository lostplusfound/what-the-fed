import 'package:civic_project/models/congressional_record.dart';
import 'package:civic_project/pages/congressional_record_page.dart';
import 'package:flutter/material.dart';

class CongressionalRecordPreview extends StatelessWidget {
  final CongressionalRecord record;
  const CongressionalRecordPreview({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  CongressionalRecordPage(record: record)));
        },
        title: Text(
            'Congressional Record of ${record.publishDate.month}/${record.publishDate.day}/${record.publishDate.year}'),
        subtitle: Text('Volume ${record.volume}, Issue ${record.issue}'),
        trailing: Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
