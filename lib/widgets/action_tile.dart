import 'package:flutter/material.dart';
import 'package:civic_project/models/bill_action.dart';

class ActionTile extends StatelessWidget {
  final BillAction action;
  const ActionTile({required this.action, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(action.text),
      subtitle: Text(
          '${action.actionDate.month}/${action.actionDate.day}/${action.actionDate.year}'),
    );
  }
}
