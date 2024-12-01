import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiChat extends StatefulWidget {
  final List<Content>? _history;
  final Content? _systemInstruction;
  final String? _initialQuery;
  const AiChat(
      {super.key,
      List<Content>? history,
      Content? systemInstruction,
      String? initialQuery})
      : _initialQuery = initialQuery,
        _systemInstruction = systemInstruction,
        _history = history;

  @override
  State<AiChat> createState() => _AiChatState();
}

class _AiChatState extends State<AiChat> {
  static const String _apiKey = 'AIzaSyAGKu27oCNRq4F16UV_ToA5rtbzB63bVDI';
  late final GenerativeModel _model;
  late final ChatSession _ai;
  final List<ChatMessage> _messages = [];
  final ChatUser _user = ChatUser(id: '0');
  final ChatUser _gemini = ChatUser(id: '1');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: DashChat(
      currentUser: _user,
      onSend: _sendMessage,
      messages: _messages,
      messageOptions: MessageOptions(),
      inputOptions: InputOptions(sendOnEnter: true),
    ));
  }

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        systemInstruction: widget._systemInstruction);
    _ai = _model.startChat(history: widget._history);
    if (widget._initialQuery != null) {
      _sendMessage(ChatMessage(
          user: _user, createdAt: DateTime.now(), text: widget._initialQuery!));
    }
  }

  void _sendMessage(ChatMessage chatMessage) async {
    try {
      setState(() {
        _messages.insert(0, chatMessage);
      });
      String query = chatMessage.text;
      Stream<GenerateContentResponse> responseStream =
          _ai.sendMessageStream(Content.text(query));
      ChatMessage responseMessage = ChatMessage(
          user: _gemini, createdAt: DateTime.now(), text: '', isMarkdown: true);
      _messages.insert(0, responseMessage);
      responseStream.forEach((part) {
        setState(() {
          responseMessage.text += part.text!;
        });
      });
    } catch (e) {
      _messages.insert(
          0,
          ChatMessage(
              user: _gemini, createdAt: DateTime.now(), text: e.toString()));
    }
  }
}
