import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String authorInitials;
  final String authorName;
  final String timeAgo;
  final String title;
  final String content;
  final List<String> tags;
  final VoidCallback? onReadMore;

  const PostCard({
    super.key,
    required this.authorInitials,
    required this.authorName,
    required this.timeAgo,
    required this.title,
    required this.content,
    this.tags = const [],
    this.onReadMore,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    authorInitials,
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Text(authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(timeAgo, style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700, height: 1.5),
                children: [
                  TextSpan(text: content),
                  if (onReadMore != null)
                    TextSpan(
                      text: ' Read more',
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                      recognizer: TapGestureRecognizer()..onTap = onReadMore,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              children: tags.map((tag) => Chip(
                label: Text(tag),
                backgroundColor: Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide.none,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
