import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:civic_project/models/bill.dart';
import 'package:civic_project/models/congressional_record.dart';
import 'package:civic_project/models/text_version.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

class AIService {
  static const String _apiKey = 'AIzaSyAGKu27oCNRq4F16UV_ToA5rtbzB63bVDI';
  static const String pdfMimeType = 'application/pdf';

  static Future<Content> urlToContent(Uri url, String mimeType) async {
    if (kIsWeb) url = Uri.parse('https://corsproxy.io/?${url.toString()}');
    var response = await http.get(url);
    return Content.data(mimeType, response.bodyBytes);
  }

  static Future<GenerateContentResponse> generateResponse(String prompt,
      [String systemInstructions = '']) async {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash-8b',
      apiKey: _apiKey,
      systemInstruction: Content.system(systemInstructions),
    );
    final content = [Content.text(prompt)];
    return model.generateContent(content);
  }

  static Future<ChatSession> startChatSession(
      {List<Content>? history, String systemInstructions = ''}) async {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(systemInstructions),
    );
    return model.startChat(history: history);
  }
}

void main() async {
  Bill bill = await Bill.fromCongressTypeAndNumber(118, 'hr', '815');
  TextVersion latest = await bill.latestTextVersion;
  CongressionalRecord record = await CongressionalRecord.latestRecord();
  ChatSession chat = await AIService.startChatSession(
      history: [
        await AIService.urlToContent(
            record.entireIssueUrl, AIService.pdfMimeType)
      ],
      systemInstructions:
          'Respond only to questions relating to politics. Use the PDF as a supplemental source. Try to be specific.');
  GenerateContentResponse response = await chat.sendMessage(Content.text(
      'Summarize everything that happened in Congress'));
  print(response.text);
}
