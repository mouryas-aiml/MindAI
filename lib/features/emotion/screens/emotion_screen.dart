import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/services/emotion_service.dart';
import 'dart:io';

class EmotionScreen extends StatefulWidget {
  const EmotionScreen({super.key});

  @override
  State<EmotionScreen> createState() => _EmotionScreenState();
}

class _EmotionScreenState extends State<EmotionScreen> {
  final List<Map<String, dynamic>> _moodHistory = [];
  bool _isLoading = false;

  Future<void> _analyzeCurrentEmotion() async {
    setState(() => _isLoading = true);

    try {
      final emotionService = Provider.of<EmotionService>(context, listen: false);
      final imageFile = await emotionService.captureImage();
      
      if (imageFile != null && mounted) {
        final analysis = await emotionService.analyzeFacialEmotion(imageFile);
        
        setState(() {
          _moodHistory.add({
            'timestamp': DateTime.now(),
            'emotion': analysis['dominantEmotion'],
            'confidence': analysis['confidence'],
            'type': 'facial',
          });
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _analyzeVoiceEmotion() async {
    setState(() => _isLoading = true);

    try {
      final emotionService = Provider.of<EmotionService>(context, listen: false);
      final audioFile = await emotionService.recordAudio();
      
      if (audioFile != null && mounted) {
        final analysis = await emotionService.analyzeVoiceEmotion(audioFile);
        
        setState(() {
          _moodHistory.add({
            'timestamp': DateTime.now(),
            'emotion': analysis['emotionAnalysis']['primaryEmotion'],
            'confidence': analysis['emotionAnalysis']['confidence'],
            'type': 'voice',
          });
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _analyzeEmotion(String imagePath) async {
    try {
      final imageFile = File(imagePath);
      final result = await _emotionService.analyzeFacialEmotion(imageFile);
      // ... rest of the code ...
    } catch (e) {
      // ... error handling ...
    }
  }

  Widget _buildEmotionChart() {
    if (_moodHistory.isEmpty) {
      return const Center(
        child: Text('No mood data available yet'),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Text(
                  '${date.hour}:${date.minute}',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: _moodHistory.map((mood) {
              return FlSpot(
                mood['timestamp'].millisecondsSinceEpoch.toDouble(),
                mood['confidence'],
              );
            }).toList(),
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emotion Analysis'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Mood',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _analyzeCurrentEmotion,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Analyze Face'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _analyzeVoiceEmotion,
                          icon: const Icon(Icons.mic),
                          label: const Text('Analyze Voice'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mood History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: _buildEmotionChart(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Emotions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_moodHistory.isEmpty)
                      const Center(
                        child: Text('No recent emotions recorded'),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _moodHistory.length,
                        itemBuilder: (context, index) {
                          final mood = _moodHistory[_moodHistory.length - 1 - index];
                          return ListTile(
                            leading: Icon(
                              mood['type'] == 'facial'
                                  ? Icons.face
                                  : Icons.record_voice_over,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: Text(mood['emotion']),
                            subtitle: Text(
                              '${mood['timestamp'].hour}:${mood['timestamp'].minute}',
                            ),
                            trailing: Text(
                              '${(mood['confidence'] * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 