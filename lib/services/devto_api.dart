import 'package:devto_blog/models/article.dart';
import 'package:devto_blog/models/user_profile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DevToApi {
  static const _host = 'dev.to';

  /// In-memory detail cache (session). Avoids refetch and repeat shimmer when
  /// reopening an article.
  static final Map<int, Article> _articleDetailById = {};
  static const _maxCachedArticles = 100;

  static bool _hasDetailBody(Article a) =>
      a.bodyMarkdown != null && a.bodyMarkdown!.isNotEmpty;

  /// Full article from session cache, if already loaded (for [FutureBuilder.initialData]).
  static Article? cachedDetailIfReady(int id) {
    final cached = _articleDetailById[id];
    if (cached != null && _hasDetailBody(cached)) return cached;
    return null;
  }

  static void _cacheArticle(Article article) {
    final id = article.id;
    if (!_articleDetailById.containsKey(id) &&
        _articleDetailById.length >= _maxCachedArticles) {
      _articleDetailById.remove(_articleDetailById.keys.first);
    }
    _articleDetailById[id] = article;
  }

  // get articles
  Future<List<Article>> fetchArticles({
    int page = 1,
    int perPage = 10,
    String? state,
    int? top,
  }) async {
    final params = <String, String>{
      'page': '$page',
      'per_page': '$perPage',
      'state': ?state,
      'top': ?(top?.toString()),
    };
    final response = await http.get(Uri.https(_host, 'api/articles', params));

    if (response.statusCode != 200) {
      throw Exception('Failed to load articles: ${response.statusCode}');
    }

    final List<dynamic> data = json.decode(response.body);

    final List<Article> articles = data
        .map((article) => Article.fromJson(article as Map<String, dynamic>))
        .toList();

    return articles;
  }

  // get article by id
  Future<Article> fetchArticleById(int id) async {
    final cached = _articleDetailById[id];
    if (cached != null && _hasDetailBody(cached)) {
      return Future.value(cached);
    }

    final response = await http.get(Uri.https(_host, 'api/articles/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load article by id: ${response.statusCode}');
    }

    final Map<String, dynamic> data = json.decode(response.body);

    final Article article = Article.fromJson(data);
    if (_hasDetailBody(article)) {
      _cacheArticle(article);
    }

    return article;
  }

  // get user profile by id
  Future<UserProfile> fetchUserProfileById(int id) async {
    final response = await http.get(Uri.https(_host, 'api/users/$id'));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load user profile by id: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> data = json.decode(response.body);

    final UserProfile userProfile = UserProfile.fromJson(data);

    return userProfile;
  }

  // get articles by username
  Future<List<Article>> fetchArticlesByUsername({
    required String username,
    int page = 1,
    int perPage = 10,
  }) async {
    final params = <String, String>{
      'page': '$page',
      'per_page': '$perPage',
      'username': username,
    };

    final response = await http.get(Uri.https(_host, 'api/articles', params));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load articles by username: ${response.statusCode}',
      );
    }

    final List<dynamic> data = json.decode(response.body);

    final List<Article> articles = data
        .map((article) => Article.fromJson(article as Map<String, dynamic>))
        .toList();

    return articles;
  }
}
