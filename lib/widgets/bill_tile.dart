import 'package:civic_project/pages/bill_page.dart';
import 'package:flutter/material.dart';
import 'package:civic_project/models/bill.dart';

class BillTile extends StatelessWidget {
  final Bill _bill;
  const BillTile(this._bill, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
      child: ListTile(
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => BillPage(_bill)));
        },
        title: Text('${_bill.type} ${_bill.number}: ${_bill.title}'),
        subtitle: _bill.latestAction != null
            ? Text(
                'Latest action: (${_bill.latestAction!.actionDate.month}/${_bill.latestAction!.actionDate.day}/${_bill.latestAction!.actionDate.year}) ${_bill.latestAction!.text}')
            : const Text('No latest action available'),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
