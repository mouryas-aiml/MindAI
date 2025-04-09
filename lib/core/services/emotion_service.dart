import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../../config/app_config.dart';
import '../models/emotion_model.dart';
import 'package:record/record.dart';

class EmotionService {
  final String _azureFaceKey;
  final String _azureFaceEndpoint;
  final String _openAiKey;
  final String _openAiEndpoint;

  EmotionService({
    required String azureFaceKey,
    required String azureFaceEndpoint,
    required String openAiKey,
    required String openAiEndpoint,
  })  : _azureFaceKey = azureFaceKey,
        _azureFaceEndpoint = azureFaceEndpoint,
        _openAiKey = openAiKey,
        _openAiEndpoint = openAiEndpoint;

  // Analyze facial emotions using Azure Face API
  Future<Map<String, dynamic>> analyzeFacialEmotion(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final response = await http.post(
        Uri.parse('$_azureFaceEndpoint/face/v1.0/detect'),
        headers: {
          'Content-Type': 'application/octet-stream',
          'Ocp-Apim-Subscription-Key': _azureFaceKey,
        },
        body: bytes,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isEmpty) {
          throw Exception('No face detected in the image');
        }

        final face = data[0];
        final emotions = face['faceAttributes']['emotion'];
        
        // Find the dominant emotion
        String dominantEmotion = '';
        double maxConfidence = 0;
        emotions.forEach((emotion, confidence) {
          if (confidence > maxConfidence) {
            maxConfidence = confidence;
            dominantEmotion = emotion;
          }
        });

        return {
          'dominantEmotion': dominantEmotion,
          'confidence': maxConfidence,
          'allEmotions': emotions,
          'faceId': face['faceId'],
        };
      } else {
        throw Exception('Failed to analyze facial emotion: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error in facial emotion analysis: $e');
    }
  }

  // Analyze voice emotions using OpenAI Whisper
  Future<Map<String, dynamic>> analyzeVoiceEmotion(File audioFile) async {
    try {
      final bytes = await audioFile.readAsBytes();
      final response = await http.post(
        Uri.parse('${AppConfig.openAiEndpoint}/audio/transcriptions'),
        headers: {
          'Authorization': 'Bearer $_openAiKey',
          'Content-Type': 'multipart/form-data',
        },
        body: {
          'file': bytes,
          'model': 'whisper-1',
          'response_format': 'json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final transcription = data['text'];

        // Use GPT-4 to analyze the emotional content of the transcription
        final emotionResponse = await http.post(
          Uri.parse('${AppConfig.openAiEndpoint}/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_openAiKey',
          },
          body: jsonEncode({
            'model': 'gpt-4',
            'messages': [
              {
                'role': 'system',
                'content': 'Analyze the emotional content of the following speech transcription. Return a JSON object with the following structure: {"primaryEmotion": "string", "intensity": number (0-1), "secondaryEmotions": ["string"], "sentiment": "positive|negative|neutral", "confidence": number (0-1)}'
              },
              {
                'role': 'user',
                'content': transcription,
              }
            ],
            'temperature': 0.3,
            'max_tokens': 200,
          }),
        );

        if (emotionResponse.statusCode == 200) {
          final emotionData = jsonDecode(emotionResponse.body);
          final analysis = jsonDecode(emotionData['choices'][0]['message']['content']);
          
          return {
            'transcription': transcription,
            'emotionAnalysis': analysis,
          };
        } else {
          throw Exception('Failed to analyze voice emotion: ${emotionResponse.statusCode}');
        }
      } else {
        throw Exception('Failed to transcribe audio: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error in voice emotion analysis: $e');
    }
  }

  // Capture image from camera
  Future<File?> captureImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Error capturing image: $e');
    }
  }

  // Record audio
  Future<String> recordAudio() async {
    try {
      final recorder = Record();
      final hasPermission = await recorder.hasPermission();
      
      if (!hasPermission) {
        throw Exception('Microphone permission not granted');
      }

      final tempDir = path.join(Directory.systemTemp.path, 'mindai_audio');
      await Directory(tempDir).create(recursive: true);
      final filePath = path.join(tempDir, '${DateTime.now().millisecondsSinceEpoch}.m4a');

      await recorder.start(
        path: filePath,
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        samplingRate: 44100,
      );

      // Record for 10 seconds
      await Future.delayed(const Duration(seconds: 10));
      await recorder.stop();

      return filePath;
    } catch (e) {
      throw Exception('Failed to record audio: ${e.toString()}');
    }
  }

  // Analyze emotion from image
  Future<Map<String, dynamic>> analyzeEmotionFromImage(String imagePath) async {
    try {
      final url = Uri.parse('$_azureFaceEndpoint/face/v1.0/detect');
      final headers = {
        'Ocp-Apim-Subscription-Key': _azureFaceKey,
        'Content-Type': 'application/octet-stream',
      };

      final request = http.MultipartRequest('POST', url)
        ..headers.addAll(headers)
        ..files.add(await http.MultipartFile.fromPath('image', imagePath));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody);

      if (response.statusCode != 200) {
        throw Exception('Failed to analyze image: ${data['error']?['message'] ?? 'Unknown error'}');
      }

      if (data.isEmpty) {
        throw Exception('No face detected in the image');
      }

      final faceAttributes = data[0]['faceAttributes'];
      final emotions = faceAttributes['emotion'];
      
      // Find the emotion with highest confidence
      String dominantEmotion = '';
      double maxConfidence = 0;
      emotions.forEach((emotion, confidence) {
        if (confidence > maxConfidence) {
          maxConfidence = confidence;
          dominantEmotion = emotion;
        }
      });

      return {
        'emotion': dominantEmotion,
        'confidence': maxConfidence,
        'rawEmotions': emotions,
      };
    } catch (e) {
      throw Exception('Failed to analyze emotion from image: ${e.toString()}');
    }
  }

  // Analyze emotion from audio
  Future<Map<String, dynamic>> analyzeEmotionFromAudio(String audioPath) async {
    try {
      // First, transcribe the audio using OpenAI Whisper
      final transcriptionUrl = Uri.parse('$_openAiEndpoint/v1/audio/transcriptions');
      final transcriptionHeaders = {
        'Authorization': 'Bearer $_openAiKey',
        'Content-Type': 'multipart/form-data',
      };

      final transcriptionRequest = http.MultipartRequest('POST', transcriptionUrl)
        ..headers.addAll(transcriptionHeaders)
        ..files.add(await http.MultipartFile.fromPath('file', audioPath))
        ..fields['model'] = 'whisper-1';

      final transcriptionResponse = await transcriptionRequest.send();
      final transcriptionData = json.decode(await transcriptionResponse.stream.bytesToString());

      if (transcriptionResponse.statusCode != 200) {
        throw Exception('Failed to transcribe audio: ${transcriptionData['error']?['message'] ?? 'Unknown error'}');
      }

      final text = transcriptionData['text'];

      // Then, analyze the emotion from the transcribed text
      final analysisUrl = Uri.parse('$_openAiEndpoint/v1/chat/completions');
      final analysisHeaders = {
        'Authorization': 'Bearer $_openAiKey',
        'Content-Type': 'application/json',
      };

      final analysisBody = {
        'model': 'gpt-4',
        'messages': [
          {
            'role': 'system',
            'content': 'Analyze the emotional content of the following text and return a JSON object with the following structure: {"emotion": "primary emotion", "confidence": 0.0-1.0, "secondary_emotions": ["emotion1", "emotion2"]}',
          },
          {
            'role': 'user',
            'content': text,
          },
        ],
        'temperature': 0.7,
        'max_tokens': 150,
      };

      final analysisResponse = await http.post(
        analysisUrl,
        headers: analysisHeaders,
        body: json.encode(analysisBody),
      );

      final analysisData = json.decode(analysisResponse.body);

      if (analysisResponse.statusCode != 200) {
        throw Exception('Failed to analyze text: ${analysisData['error']?['message'] ?? 'Unknown error'}');
      }

      final content = analysisData['choices'][0]['message']['content'];
      return json.decode(content);
    } catch (e) {
      throw Exception('Failed to analyze emotion from audio: ${e.toString()}');
    }
  }

  // Take photo for emotion analysis
  Future<String> takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) {
        throw Exception('No image selected');
      }

      return image.path;
    } catch (e) {
      throw Exception('Failed to take photo: ${e.toString()}');
    }
  }

  // Save emotion data
  Future<void> saveEmotionData(EmotionModel emotion) async {
    try {
      // TODO: Implement saving emotion data to your backend
      // This could be Firebase, your own API, etc.
    } catch (e) {
      throw Exception('Failed to save emotion data: ${e.toString()}');
    }
  }

  // Get emotion history
  Future<List<EmotionModel>> getEmotionHistory(String userId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      // TODO: Implement fetching emotion history from your backend
      // This could be Firebase, your own API, etc.
      return [];
    } catch (e) {
      throw Exception('Failed to get emotion history: ${e.toString()}');
    }
  }
} 