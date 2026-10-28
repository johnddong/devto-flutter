import 'package:devto_blog/models/comment.dart';
import 'package:devto_blog/services/devto_api.dart';
import 'package:devto_blog/widgets/comment_tile.dart';
import 'package:flutter/material.dart';

class CommentsSheet extends StatefulWidget {
  const CommentsSheet({
    super.key,
    required this.articleId,
    required this.commentsCount,
    required this.scrollController,
  });

  final int articleId;
  final int commentsCount;
  final ScrollController scrollController;

  static Future<void> open(
    BuildContext context, {
    required int articleId,
    required int commentsCount,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.93,
          builder: (context, scrollController) {
            return CommentsSheet(
              articleId: articleId,
              commentsCount: commentsCount,
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  late final Future<List<Comment>> _comments = DevToApi().fetchCommentsById(
    widget.articleId,
  );
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Comment>>(
      future: _comments,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Failed to load comments',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }
        final comments = snapshot.data ?? [];
        return ListView.builder(
          controller: widget.scrollController,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          itemCount: comments.isEmpty ? 2 : comments.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Comments (${widget.commentsCount})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
            if (comments.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('No comments yet'),
              );
            }
            return CommentTile(comment: comments[index - 1]);
          },
        );
      },
    );
  }
}
