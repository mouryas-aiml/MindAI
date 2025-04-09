import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/chat_service.dart';
import '../../../core/services/emotion_service.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isRecording = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        content: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _messageController.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final chatService = Provider.of<ChatService>(context, listen: false);
      final response = await chatService.sendMessage(message, _messages);
      
      if (mounted) {
        setState(() {
          _messages.add(response);
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _startVoiceRecording() async {
    setState(() => _isRecording = true);
    
    try {
      final emotionService = Provider.of<EmotionService>(context, listen: false);
      final audioFile = await emotionService.recordAudio();
      
      if (audioFile != null && mounted) {
        final analysis = await emotionService.analyzeVoiceEmotion(audioFile);
        
        setState(() {
          _messages.add(ChatMessage(
            content: analysis['transcription'],
            isUser: true,
            timestamp: DateTime.now(),
            metadata: {
              'emotionAnalysis': analysis['emotionAnalysis'],
              'type': 'voice',
            },
          ));
          _isLoading = true;
        });

        final chatService = Provider.of<ChatService>(context, listen: false);
        final response = await chatService.sendMessage(
          analysis['transcription'],
          _messages,
        );

        if (mounted) {
          setState(() {
            _messages.add(response);
            _isLoading = false;
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRecording = false);
      }
    }
  }

  Future<void> _analyzeVoiceEmotion(String audioPath) async {
    try {
      final audioFile = File(audioPath);
      final result = await emotionService.analyzeVoiceEmotion(audioFile);
      // ... rest of the code ...
    } catch (e) {
      // ... error handling ...
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Therapist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () async {
              try {
                final emotionService = Provider.of<EmotionService>(context, listen: false);
                final imageFile = await emotionService.captureImage();
                
                if (imageFile != null && mounted) {
                  final analysis = await emotionService.analyzeFacialEmotion(imageFile);
                  
                  setState(() {
                    _messages.add(ChatMessage(
                      content: 'I notice you look ${analysis['dominantEmotion']}',
                      isUser: false,
                      timestamp: DateTime.now(),
                      metadata: {
                        'emotionAnalysis': analysis,
                        'type': 'facial',
                      },
                    ));
                    _scrollToBottom();
                  });
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message.isUser;
                final hasEmotionData = message.metadata != null &&
                    (message.metadata!['type'] == 'voice' ||
                        message.metadata!['type'] == 'facial');

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: 51)
                          : Theme.of(context).colorScheme.surface.withValues(alpha: 51),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.content,
                          style: TextStyle(
                            color: isUser
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        if (hasEmotionData) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Emotion: ${message.metadata!['emotionAnalysis']['primaryEmotion']}',
                            style: TextStyle(
                              color: isUser
                                  ? Colors.white70
                                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 51),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: _isRecording ? Colors.red : null,
                  ),
                  onPressed: _isRecording ? null : _startVoiceRecording,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 