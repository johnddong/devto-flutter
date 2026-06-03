/// Response from `GET https://dev.to/api/articles/:id` (shape matches Forem article JSON).

class Article {
  const Article({
    required this.typeOf,
    required this.id,
    required this.title,
    required this.description,
    required this.readablePublishDate,
    required this.slug,
    required this.path,
    required this.url,
    required this.commentsCount,
    required this.publicReactionsCount,
    required this.positiveReactionsCount,
    required this.collectionId,
    required this.publishedTimestamp,
    required this.publishedAt,
    required this.createdAt,
    required this.editedAt,
    required this.crosspostedAt,
    required this.lastCommentAt,
    required this.language,
    required this.subforemId,
    required this.readingTimeMinutes,
    required this.coverImage,
    required this.socialImage,
    required this.canonicalUrl,
    required this.tagList,
    required this.tags,
    this.bodyHtml,
    this.bodyMarkdown,
    required this.user,
    required this.organization,
    required this.flareTag,
  });

  final String typeOf;
  final int id;
  final String title;
  final String description;
  final String readablePublishDate;
  final String slug;
  final String path;
  final String url;
  final int commentsCount;
  final int publicReactionsCount;
  final int positiveReactionsCount;
  final int? collectionId;
  final DateTime publishedTimestamp;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime? editedAt;
  final DateTime? crosspostedAt;
  final DateTime? lastCommentAt;
  final String language;
  final int subforemId;
  final int readingTimeMinutes;
  final String? coverImage;
  final String? socialImage;
  final String canonicalUrl;
  final List<String> tagList;
  final String tags;
  final String? bodyHtml;
  final String? bodyMarkdown;
  final User user;
  final Organization? organization;
  final FlareTag? flareTag;

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      typeOf: json['type_of'] as String,
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      readablePublishDate: json['readable_publish_date'] as String? ?? '',
      slug: json['slug'] as String,
      path: json['path'] as String,
      url: json['url'] as String,
      commentsCount: json['comments_count'] as int? ?? 0,
      publicReactionsCount: json['public_reactions_count'] as int? ?? 0,
      positiveReactionsCount: json['positive_reactions_count'] as int? ?? 0,
      collectionId: json['collection_id'] as int?,
      publishedTimestamp: DateTime.parse(json['published_timestamp'] as String),
      publishedAt: _parseDate(json['published_at']),
      createdAt: DateTime.parse(json['created_at'] as String),
      editedAt: _parseDate(json['edited_at']),
      crosspostedAt: _parseDate(json['crossposted_at']),
      lastCommentAt: _parseDate(json['last_comment_at']),
      language: json['language'] as String? ?? 'en',
      subforemId: json['subforem_id'] as int? ?? 0,
      readingTimeMinutes: json['reading_time_minutes'] as int? ?? 0,
      coverImage: json['cover_image'] as String?,
      socialImage: json['social_image'] as String?,
      canonicalUrl: json['canonical_url'] as String? ?? '',
      tagList: _parseTagList(json['tag_list']),
      tags: json['tags'] is List
          ? (json['tags'] as List<dynamic>).join(', ')
          : (json['tags'] as String? ?? ''),
      bodyHtml: json['body_html'] as String?,
      bodyMarkdown: json['body_markdown'] as String?,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      organization: json['organization'] == null
          ? null
          : Organization.fromJson(json['organization'] as Map<String, dynamic>),
      flareTag: json['flare_tag'] == null
          ? null
          : FlareTag.fromJson(json['flare_tag'] as Map<String, dynamic>),
    );
  }

  static List<String> _parseTagList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e as String).toList();
    if (value is String) {
      return value.isEmpty
          ? []
          : value.split(',').map((t) => t.trim()).toList();
    }
    return [];
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value as String);
  }
}

class User {
  final String name;
  final String username;
  final String? twitterUsername;
  final String? githubUsername;
  final int userId;
  final String? websiteUrl;
  final String profileImage;
  final String profileImage90;

  const User({
    required this.name,
    required this.username,
    required this.twitterUsername,
    required this.githubUsername,
    required this.userId,
    required this.websiteUrl,
    required this.profileImage,
    required this.profileImage90,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String,
      username: json['username'] as String,
      twitterUsername: json['twitter_username'] as String?,
      githubUsername: json['github_username'] as String?,
      userId: json['user_id'] as int,
      websiteUrl: json['website_url'] as String?,
      profileImage: json['profile_image'] as String,
      profileImage90: json['profile_image_90'] as String,
    );
  }
}

class Organization {
  final String name;
  final String username;
  final String slug;
  final String profileImage;
  final String profileImage90;

  const Organization({
    required this.name,
    required this.username,
    required this.slug,
    required this.profileImage,
    required this.profileImage90,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      name: json['name'] as String,
      username: json['username'] as String,
      slug: json['slug'] as String,
      profileImage: json['profile_image'] as String,
      profileImage90: json['profile_image_90'] as String,
    );
  }
}

class FlareTag {
  final String name;
  final String bgColorHex;
  final String textColorHex;

  const FlareTag({
    required this.name,
    required this.bgColorHex,
    required this.textColorHex,
  });

  factory FlareTag.fromJson(Map<String, dynamic> json) {
    return FlareTag(
      name: json['name'] as String,
      bgColorHex: json['bg_color_hex'] as String,
      textColorHex: json['text_color_hex'] as String,
    );
  }
}
