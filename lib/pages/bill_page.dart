import 'package:civic_project/models/bill.dart';
import 'package:flutter/material.dart';

class BillPage extends StatefulWidget {
  final Bill _bill;
  const BillPage(this._bill, {super.key});

  @override
  State<BillPage> createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget._bill.type} ${widget._bill.number}'),
      ),
      body: Column(
        children: [Text(widget._bill.title)],
      ),
    );
  }
}
