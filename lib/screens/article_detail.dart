import 'package:devto_blog/models/article.dart';
import 'package:devto_blog/services/devto_api.dart';
import 'package:devto_blog/widgets/article_author_row.dart';
import 'package:devto_blog/widgets/article_tags_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleDetailScreen extends StatefulWidget {
  const ArticleDetailScreen({super.key, required this.article});

  final Article article;

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  // fetch article by id
  late final Future<Article> _article = DevToApi().fetchArticleById(
    widget.article.id,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Article>(
        initialData: DevToApi.cachedDetailIfReady(widget.article.id),
        future: _article,
        builder: (context, snapshot) {
          final article = snapshot.data ?? widget.article;
          final hasBody = article.bodyMarkdown?.isNotEmpty == true;
          final showShimmer =
              snapshot.connectionState == ConnectionState.waiting && !hasBody;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: widget.article.coverImage != null
                    ? MediaQuery.of(context).size.width * 9 / 16
                    : 0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsetsDirectional.only(
                    start: 38,
                    end: 16,
                    bottom: 16,
                  ),
                  title: Text(
                    widget.article.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: widget.article.coverImage != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              widget.article.coverImage!,
                              fit: BoxFit.cover,
                            ),
                            const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black45],
                                ),
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
              if (showShimmer)
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: _DetailShimmer(context: context),
                  ),
                )
              else if (snapshot.hasError)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Failed to load article',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: widget.article.coverImage != null
                      ? const EdgeInsets.all(16)
                      : EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 0,
                          bottom: 16,
                        ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // full title
                      Text(
                        article.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                      ),
                      const SizedBox(height: 12),
                      // author & stats row
                      ArticleAuthorRow(article: article),
                      const SizedBox(height: 12),
                      // tags row
                      ArticleTagsRow(tags: article.tagList),
                      const Divider(height: 32),
                      // body content
                      if (article.bodyMarkdown?.isNotEmpty == true)
                        MarkdownBody(
                          data: article.bodyMarkdown!,
                          onTapLink: (text, href, title) async {
                            if (href == null) return;
                            final uri = Uri.tryParse(href);
                            if (uri != null && await canLaunchUrl(uri)) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                        )
                      else
                        const Text('No content available'),
                    ]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// private sub-widgets
// detail shimmer
class _DetailShimmer extends StatelessWidget {
  const _DetailShimmer({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title
          Container(height: 24, width: double.infinity, color: Colors.white),
          const SizedBox(height: 8),
          Container(height: 24, width: 240, color: Colors.white),
          const SizedBox(height: 20),
          // author row
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 12, width: 120, color: Colors.white),
                  const SizedBox(height: 6),
                  Container(height: 10, width: 80, color: Colors.white),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // tags
          Row(
            children: [
              Container(
                height: 24,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 24,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // body lines
          ...List.generate(
            6,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                height: 14,
                width: i % 3 == 2 ? 200 : double.infinity,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
