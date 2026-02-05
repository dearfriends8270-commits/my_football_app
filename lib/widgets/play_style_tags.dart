import 'package:flutter/material.dart';

class PlayStyleTags extends StatelessWidget {
  final List<String> tags;

  const PlayStyleTags({
    super.key,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Play Style',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: tags.map((tag) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: tags.last == tag ? 0 : 8,
                ),
                child: _StyleTag(tag: tag),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _StyleTag extends StatelessWidget {
  final String tag;

  const _StyleTag({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFB8C9D9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          tag,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E4A6E),
          ),
        ),
      ),
    );
  }
}
