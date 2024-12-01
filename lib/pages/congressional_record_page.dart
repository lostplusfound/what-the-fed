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
  late Uri _url;
  late final Uint8List pdfBytes;
  AiChat? _aiChat;
  bool _loading = true;
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
                  body: (_loading)
                      ? SizedBox(
                          height: 4.0, child: CircularProgressIndicator())
                      : Builder(builder: (context) {
                          return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.75,
                              child: _aiChat);
                        })),
              ExpansionPanel(
                  isExpanded: _isPanelExpanded[1],
                  headerBuilder: (context, isExpanded) =>
                      ListTile(title: Text('Full PDF')),
                  body: Builder(builder: (context) {
                    return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.75,
                        child: Pdf(
                          uri: _url,
                        ));
                  })),
            ])));
  }

  @override
  void initState() {
    super.initState();
    _url = widget.record.entireIssueUrl;
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    if (kIsWeb) _url = Uri.parse('https://corsproxy.io/?${_url.toString()}');
    var response = await http.get(_url);
    pdfBytes = response.bodyBytes;
    setState(() {
      _loading = false;
      _aiChat = AiChat(
        history: [Content.data('application/pdf', pdfBytes)],
        systemInstruction:
            Content.system('''Respond only to questions about politics. 
              Try to be specific and thorough. 
              Use any provided documents if necessary or possible and your general knowledge when answering questions.'''),
        initialQuery: 'Summarize everything Congress did',
      );
    });
  }
}
