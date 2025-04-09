import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'content': content,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
    'metadata': metadata,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    content: json['content'],
    isUser: json['isUser'],
    timestamp: DateTime.parse(json['timestamp']),
    metadata: json['metadata'],
  );
}

class ChatService {
  final String _apiKey;
  final String _baseUrl = AppConfig.openAiEndpoint;

  ChatService(this._apiKey);

  Future<ChatMessage> sendMessage(String message, List<ChatMessage> chatHistory) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': _formatMessages(message, chatHistory),
          'temperature': 0.7,
          'max_tokens': 1000,
          'presence_penalty': 0.6,
          'frequency_penalty': 0.5,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['choices'][0]['message']['content'];
        
        return ChatMessage(
          content: aiResponse,
          isUser: false,
          timestamp: DateTime.now(),
          metadata: {
            'model': 'gpt-4',
            'tokens': data['usage']['total_tokens'],
          },
        );
      } else {
        throw Exception('Failed to get AI response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error in chat service: $e');
    }
  }

  List<Map<String, dynamic>> _formatMessages(String currentMessage, List<ChatMessage> chatHistory) {
    final messages = <Map<String, dynamic>>[
      {
        'role': 'system',
        'content': '''You are an empathetic and professional AI therapist. Your role is to:
1. Listen actively and show understanding
2. Ask thoughtful questions to help users explore their feelings
3. Provide gentle guidance and support
4. Maintain appropriate boundaries
5. Recognize when to suggest professional help
6. Focus on emotional well-being and personal growth
7. Use evidence-based therapeutic techniques
8. Be mindful of crisis situations and provide appropriate resources

Remember to:
- Be non-judgmental and supportive
- Use appropriate therapeutic language
- Maintain confidentiality
- Focus on the present moment
- Encourage self-reflection
- Provide practical coping strategies
- Be clear about your AI nature'''
      },
    ];

    // Add chat history
    for (var message in chatHistory) {
      messages.add({
        'role': message.isUser ? 'user' : 'assistant',
        'content': message.content,
      });
    }

    // Add current message
    messages.add({
      'role': 'user',
      'content': currentMessage,
    });

    return messages;
  }

  Future<Map<String, dynamic>> analyzeEmotion(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': 'Analyze the emotional content of the following message. Return a JSON object with the following structure: {"primaryEmotion": "string", "intensity": number (0-1), "secondaryEmotions": ["string"], "sentiment": "positive|negative|neutral", "confidence": number (0-1)}'
            },
            {
              'role': 'user',
              'content': message,
            }
          ],
          'temperature': 0.3,
          'max_tokens': 200,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final analysis = jsonDecode(data['choices'][0]['message']['content']);
        return analysis;
      } else {
        throw Exception('Failed to analyze emotion: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error in emotion analysis: $e');
    }
  }
} 