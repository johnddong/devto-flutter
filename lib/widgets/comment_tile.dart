import 'package:flutter/material.dart';
import 'package:devto_blog/models/comment.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({super.key, required this.comment, this.depth = 0});

  final Comment comment;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final user = comment.user;

    return Padding(
      padding: EdgeInsets.only(left: depth == 0 ? 0 : 16, top: 12),

      child: Container(
        decoration: depth == 0
            ? null
            : BoxDecoration(
                border: Border(
                  left: BorderSide(color: theme.outlineVariant, width: 2),
                ),
              ),
        padding: depth == 0 ? EdgeInsets.zero : EdgeInsets.only(left: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // author row (or "[hidden]" placeholder)
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundImage: user != null
                      ? NetworkImage(user.profileImage)
                      : null,
                  child: user == null ? Icon(Icons.person_off_outlined) : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    user?.name ?? '[hidden]',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: user == null ? theme.onSurfaceVariant : null,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            // comment body (HTML)
            HtmlWidget(comment.bodyHtml, renderMode: RenderMode.column),
            // recursive into replies
            for (final child in comment.children)
              CommentTile(comment: child, depth: depth + 1),
          ],
        ),
      ),
    );
  }
}
