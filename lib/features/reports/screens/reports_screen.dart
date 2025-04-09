import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedTimeRange = 'Week';
  final List<String> _timeRanges = ['Week', 'Month', 'Year'];
  
  // Mock data - replace with actual data from your backend
  final List<FlSpot> _moodData = [
    FlSpot(0, 3.5),
    FlSpot(1, 4.0),
    FlSpot(2, 3.8),
    FlSpot(3, 4.2),
    FlSpot(4, 3.9),
    FlSpot(5, 4.5),
    FlSpot(6, 4.1),
  ];

  final Map<String, int> _emotionDistribution = {
    'Happy': 45,
    'Calm': 30,
    'Anxious': 15,
    'Sad': 10,
  };

  Widget _buildMoodChart() {
    return AspectRatio(
      aspectRatio: 1.70,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 40,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    final now = DateTime.now();
                    final date = now.subtract(Duration(days: (6 - value).toInt()));
                    return Text(DateFormat('E').format(date));
                  },
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: true),
            minX: 0,
            maxX: 6,
            minY: 0,
            maxY: 5,
            lineBarsData: [
              LineChartBarData(
                spots: _moodData,
                isCurved: true,
                color: Theme.of(context).colorScheme.primary,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionDistribution() {
    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          sectionsSpace: 0,
          centerSpaceRadius: 40,
          sections: _emotionDistribution.entries.map((entry) {
            final color = _getColorForEmotion(entry.key);
            return PieChartSectionData(
              color: color,
              value: entry.value.toDouble(),
              title: '${entry.value}%',
              radius: 100,
              titleStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getColorForEmotion(String emotion) {
    switch (emotion) {
      case 'Happy':
        return Colors.green;
      case 'Calm':
        return Colors.blue;
      case 'Anxious':
        return Colors.orange;
      case 'Sad':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          DropdownButton<String>(
            value: _selectedTimeRange,
            items: _timeRanges.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedTimeRange = newValue;
                });
              }
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Mood Tracking',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildMoodChart(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Emotion Distribution',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildEmotionDistribution(),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: 16,
                        children: _emotionDistribution.keys.map((emotion) {
                          return Chip(
                            avatar: CircleAvatar(
                              backgroundColor: _getColorForEmotion(emotion),
                              radius: 8,
                            ),
                            label: Text(emotion),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Insights',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.trending_up),
                        title: const Text('Mood Trend'),
                        subtitle: const Text('Your mood has been improving over the past week'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.schedule),
                        title: const Text('Peak Times'),
                        subtitle: const Text('You tend to feel best in the morning hours'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.psychology),
                        title: const Text('Common Triggers'),
                        subtitle: const Text('Work-related stress seems to affect your mood'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 