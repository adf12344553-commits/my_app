// lib/ai_assistant_screen.dart – Phase 5.5 (Conversation History, Smart Actions)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'app_state.dart';
import 'ai_service.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isListening = false;
  bool _isLoading = false;
  String _spokenText = '';

  // 🔥 Conversation history
  List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _tts.setLanguage('en-IN');
    // Add initial welcome message
    _messages.add({
      'role': 'assistant',
      'content':
          '👋 Hello! I\'m your AI Business Assistant. Ask me anything about your business.'
    });
  }

  Future<void> _initSpeech() async {
    await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' && _spokenText.isNotEmpty) {
          _processQuery(_spokenText);
        }
      },
      onError: (error) => setState(() {
        _messages
            .add({'role': 'assistant', 'content': '⚠️ Speech error: $error'});
        _isListening = false;
        _scrollToBottom();
      }),
    );
  }

  void _startListening() async {
    if (!_speech.isAvailable) {
      _messages.add({
        'role': 'assistant',
        'content': '⚠️ Speech not available. Please type your question.'
      });
      _scrollToBottom();
      return;
    }
    setState(() {
      _isListening = true;
      _spokenText = '';
    });
    await _speech.listen(
      onResult: (result) {
        setState(() {
          _spokenText = result.recognizedWords;
        });
      },
      listenFor: const Duration(seconds: 10),
    );
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
    if (_spokenText.isNotEmpty) {
      _processQuery(_spokenText);
    }
  }

  Future<void> _processQuery(String query) async {
    if (query.trim().isEmpty) return;

    // Add user message
    setState(() {
      _messages.add({'role': 'user', 'content': query});
      _isLoading = true;
      _scrollToBottom();
    });

    try {
      final appState = context.read<AppState>();
      final result = await AIService.processQuery(query, appState);

      setState(() {
        _messages.add({'role': 'assistant', 'content': result});
        _isLoading = false;
        _textController.clear();
        _scrollToBottom();
      });

      // Speak the response
      await _tts.speak(result);
    } catch (e) {
      setState(() {
        _messages.add({'role': 'assistant', 'content': '❌ Error: $e'});
        _isLoading = false;
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSubmit(String query) async {
    if (query.trim().isEmpty) return;
    await _processQuery(query.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AI Business Assistant'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
        actions: [
          // Mic button
          IconButton(
            icon: Icon(_isListening ? Icons.stop : Icons.mic,
                color: Colors.white),
            onPressed: _isListening ? _stopListening : _startListening,
          ),
          // Clear history button
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add({
                  'role': 'assistant',
                  'content': '👋 Conversation cleared. Ask me anything!'
                });
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔥 Conversation History
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                              color: Colors.purple, strokeWidth: 2),
                          SizedBox(width: 12),
                          Text('Thinking...'),
                        ],
                      ),
                    ),
                  );
                }
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Colors.purple.shade100
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isUser
                            ? Colors.purple.shade300
                            : Colors.grey.shade400,
                        width: 0.5,
                      ),
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    child: Text(
                      msg['content'] ?? '',
                      style: TextStyle(
                        color: isUser ? Colors.purple.shade900 : Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Ask anything...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.purple.shade700),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    onSubmitted: _handleSubmit,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.purple.shade700,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: () => _handleSubmit(_textController.text),
                  ),
                ),
              ],
            ),
          ),

          // Quick chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.grey.shade50,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _quickChip('📊 Summary', 'Give me a business summary'),
                  _quickChip('🚨 Overdue', 'Show overdue debtors'),
                  _quickChip('📦 Products', 'List my products'),
                  _quickChip('👥 Customers', 'How many customers?'),
                  _quickChip('📅 Today', 'Today\'s orders'),
                  _quickChip('💡 Suggestions', 'What should I do today?'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickChip(String label, String query) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ActionChip(
        label: Text(label),
        onPressed: () => _handleSubmit(query),
        backgroundColor: Colors.purple.shade50,
        side: BorderSide(color: Colors.purple.shade200),
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
