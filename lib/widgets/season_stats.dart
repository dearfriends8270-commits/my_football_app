import 'package:flutter/material.dart';

class SeasonStats extends StatelessWidget {
  final int goals;
  final int assists;
  final double rating;

  const SeasonStats({
    super.key,
    required this.goals,
    required this.assists,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Season Stats',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatBox(
                value: goals.toString(),
                label: 'Goals',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatBox(
                value: assists.toString(),
                label: 'Assists',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatBox(
                value: rating.toStringAsFixed(0),
                label: 'Rating',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;

  const _StatBox({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
