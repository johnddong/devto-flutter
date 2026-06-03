import 'package:devto_blog/models/article.dart';
import 'package:devto_blog/widgets/sheets/user_profile_sheet.dart';
import 'package:flutter/material.dart';

class ArticleAuthorRow extends StatelessWidget {
  const ArticleAuthorRow({super.key, required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => UserProfileSheet.open(
            context,
            article.user.userId,
            article.user.username,
          ),
          behavior: HitTestBehavior.opaque,
          child: CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(article.user.profileImage),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.user.name,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                '${article.readablePublishDate} • ${article.readingTimeMinutes} min read',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        // stats row
        _Stats(
          reactions: article.publicReactionsCount,
          comments: article.commentsCount,
        ),
      ],
    );
  }
}

// stats
class _Stats extends StatelessWidget {
  const _Stats({required this.reactions, required this.comments});

  final int reactions;
  final int comments;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.favorite, size: 16, color: Colors.redAccent),
        const SizedBox(width: 4),
        Text('$reactions'),
        const SizedBox(width: 16),
        const Icon(Icons.mode_comment_outlined, size: 16),
        const SizedBox(width: 4),
        Text('$comments'),
      ],
    );
  }
}
