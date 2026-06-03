import 'package:devto_blog/screens/article_detail.dart';
import 'package:devto_blog/widgets/article_author_row.dart';
import 'package:devto_blog/widgets/article_tags_row.dart';
import 'package:flutter/material.dart';
import 'package:devto_blog/models/article.dart';

class ArticleItem extends StatelessWidget {
  const ArticleItem({super.key, required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArticleDetailScreen(article: article),
          ),
        ),
        child: Column(
          children: [
            // cover image
            if (article.coverImage != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(article.coverImage!, fit: BoxFit.cover),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // author & stats row
                  ArticleAuthorRow(article: article),
                  SizedBox(height: 12),
                  // title
                  _Title(title: article.title),
                  SizedBox(height: 6),
                  // description
                  if (article.description.isNotEmpty)
                    Text(
                      article.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  SizedBox(height: 8),
                  // tags
                  if (article.tagList.isNotEmpty)
                    ArticleTagsRow(tags: article.tagList),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* private sub-widgets */
// title
class _Title extends StatelessWidget {
  const _Title({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }
}

// tags
