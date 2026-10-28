/// Response item from `GET https://dev.to/api/comments?a_id=:id`.

import 'package:devto_blog/models/article.dart';

class Comment {
  Comment({
    required this.idCode,
    required this.createdAt,
    required this.bodyHtml,
    required this.user,
    required this.children,
  });

  final String idCode;
  final DateTime createdAt;
  final String bodyHtml;
  final User? user;
  final List<Comment> children;

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      idCode: json['id_code'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      bodyHtml: json['body_html'] as String? ?? '',
      // user is optional, check if it's not empty
      user: (json['user'] as Map<String, dynamic>?)?.isNotEmpty == true
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      children: (json['children'] as List<dynamic>? ?? [])
          .map((c) => Comment.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}
