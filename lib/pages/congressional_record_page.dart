import 'dart:typed_data';

import 'package:civic_project/models/congressional_record.dart';
import 'package:civic_project/widgets/ai_chat.dart';
import 'package:civic_project/widgets/pdf.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

class CongressionalRecordPage extends StatefulWidget {
  final CongressionalRecord record;

  const CongressionalRecordPage({super.key, required this.record});

  @override
  State<CongressionalRecordPage> createState() =>
      _CongressionalRecordPageState();
}

class _CongressionalRecordPageState extends State<CongressionalRecordPage> {
  final List<bool> _isPanelExpanded = [false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
              'Congressional Record of ${widget.record.publishDate.month}/${widget.record.publishDate.day}/${widget.record.publishDate.year}'),
        ),
        body: SingleChildScrollView(
            child: ExpansionPanelList(
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _isPanelExpanded[index] = isExpanded;
                  });
                },
                children: [
              ExpansionPanel(
                isExpanded: _isPanelExpanded[0],
                headerBuilder: (context, isExpanded) =>
                    ListTile(title: Text('AI Summary')),
                body: Container(
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: _buildAiChatTile()),
              ),
              ExpansionPanel(
                  isExpanded: _isPanelExpanded[1],
                  headerBuilder: (context, isExpanded) =>
                      ListTile(title: Text('Full PDF')),
                  body: Container(
                      height: MediaQuery.of(context).size.height * 0.75,
                      child: Pdf(
                        uri: widget.record.entireIssueUrl,
                      ))),
            ])));
  }

  Widget _buildAiChatTile() {
    return AiChat(
      url: widget.record.entireIssueUrl,
      initialQuery: 'Summarize everything Congress did',
    );
  }
}
