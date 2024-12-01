import 'package:civic_project/pages/bill_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:civic_project/models/bill.dart';

class BillPreview extends StatelessWidget {
  final Bill _bill;
  const BillPreview(this._bill, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
      child: ListTile(
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => BillPage(_bill)));
        },
        title: Text('${_bill.type} ${_bill.number}'),
        subtitle: Text('${_bill.title}'),
        trailing: Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
