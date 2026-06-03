import 'package:devto_blog/models/article.dart';
import 'package:devto_blog/widgets/app_logo.dart';
import 'package:devto_blog/widgets/article_item.dart';
import 'package:devto_blog/widgets/article_item_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:devto_blog/services/devto_api.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const AppLogo(size: 32),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Relevant'),
              Tab(text: 'Latest'),
              Tab(text: 'Top'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ArticleFeed(),
            _ArticleFeed(state: 'fresh'),
            _ArticleFeed(top: 7),
          ],
        ),
      ),
    );
  }
}

// ── feed widget with its own pagination state ─────────────────────────────

class _ArticleFeed extends StatefulWidget {
  const _ArticleFeed({this.state, this.top});

  final String? state;
  final int? top;

  @override
  State<_ArticleFeed> createState() => _ArticleFeedState();
}

class _ArticleFeedState extends State<_ArticleFeed>
    with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();
  final _articles = <Article>[];
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;

  static const _perPage = 10;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchMore();
    _scrollController.addListener(_onScroll);
    // test fetch articles by username
    final articles = DevToApi().fetchArticlesByUsername(username: 'itsugo');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 300 && !_isLoading && _hasMore) {
      _fetchMore();
    }
  }

  Future<void> _fetchMore() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await DevToApi().fetchArticles(
        page: _page,
        perPage: _perPage,
        state: widget.state,
        top: widget.top,
      );
      setState(() {
        _articles.addAll(results);
        _page++;
        _hasMore = results.length >= _perPage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _articles.clear();
      _page = 1;
      _hasMore = true;
      _error = null;
    });
    await _fetchMore();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // required for AutomaticKeepAliveClientMixin

    // initial loading
    if (_articles.isEmpty && _isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, __) => const ArticleItemShimmer(),
      );
    }

    // initial error
    if (_articles.isEmpty && _error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: _fetchMore, child: const Text('Retry')),
          ],
        ),
      );
    }

    // empty
    if (_articles.isEmpty) {
      return const Center(child: Text('No articles found'));
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _articles.length + 1, // +1 footer
        itemBuilder: (context, index) {
          // footer
          if (index == _articles.length) {
            if (_isLoading) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (_error != null) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Text(
                      'Failed to load more',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    TextButton(
                      onPressed: _fetchMore,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (!_hasMore) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'You\'ve reached the end',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }

          return ArticleItem(article: _articles[index]);
        },
      ),
    );
  }
}
