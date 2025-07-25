import 'package:civic_project/env/env.dart';
import 'package:civic_project/services/cors_proxy.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

class AiChat extends StatefulWidget {
  final String? initialQuery;
  final Uri? url;
  const AiChat({super.key, this.url, this.initialQuery});

  @override
  State<AiChat> createState() => _AiChatState();
}

class _AiChatState extends State<AiChat> {
  static final String _apiKey = Env.geminiKey;
  static const String systemInstruction =
      '''Only answer questions relating to politics and the initial prompt. Refuse to answer off-topic questions and remind the user to stay on-topic. 
              Try to be specific and thorough. 
              Use any provided documents if necessary or possible and your general knowledge when answering questions.''';
  late final GenerativeModel _model;
  late final ChatSession _ai;
  final List<ChatMessage> _messages = [];
  final List<ChatUser> typingUsers = [];
  final ChatUser _user = ChatUser(id: '0');
  final ChatUser _gemini = ChatUser(id: '1', firstName: 'Gemini');
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
        systemInstruction: Content.system(systemInstruction));

    if (widget.url != null) {
      _loadPdf();
    } else {
      _ai = _model.startChat(history: []);
      if (widget.initialQuery != null) {
        _sendMessage(ChatMessage(
            user: _user,
            createdAt: DateTime.now(),
            text: widget.initialQuery!));
      }
      loading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: (loading)
            ? const SizedBox(height: 4.0, child: CircularProgressIndicator())
            : DashChat(
                currentUser: _user,
                onSend: _sendMessage,
                messages: _messages,
                messageOptions: const MessageOptions(),
                inputOptions: const InputOptions(sendOnEnter: true),
                typingUsers: typingUsers,
              ));
  }

  Future<void> _loadPdf() async {
    var response = await http
        .get((kIsWeb) ? CorsProxy.proxyUrl(widget.url!) : widget.url!);
    if (!mounted) return;
    setState(() {
      _ai = _model.startChat(
          history: [Content.data('application/pdf', response.bodyBytes)]);
      if (widget.initialQuery != null) {
        _sendMessage(ChatMessage(
            user: _user,
            createdAt: DateTime.now(),
            text: widget.initialQuery!));
      }
      loading = false;
    });
  }

  void _sendMessage(ChatMessage chatMessage) async {
    try {
      if (!mounted) return;
      setState(() {
        _messages.insert(0, chatMessage);
        typingUsers.add(_gemini);
      });
      String query = chatMessage.text;
      Stream<GenerateContentResponse> responseStream =
          _ai.sendMessageStream(Content.text(query));
      ChatMessage responseMessage = ChatMessage(
          user: _gemini, createdAt: DateTime.now(), text: '', isMarkdown: true);
      _messages.insert(0, responseMessage);
      responseStream.forEach((part) {
        if (!mounted) return;
        setState(() {
          typingUsers.remove(_gemini);
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
