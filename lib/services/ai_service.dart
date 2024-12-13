import 'package:flutter/foundation.dart' show kIsWeb;
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
