import 'package:devto_blog/models/article.dart';
import 'package:devto_blog/models/user_profile.dart';
import 'package:devto_blog/services/devto_api.dart';
import 'package:devto_blog/widgets/article_item.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Modal bottom sheet: full author profile from `GET /api/users/:id`.
class UserProfileSheet extends StatefulWidget {
  const UserProfileSheet({
    super.key,
    required this.userId,
    required this.username,
  });

  final int userId;
  final String username;

  static Future<void> open(BuildContext context, int userId, String username) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.30,
          minChildSize: 0.30,
          maxChildSize: 0.93,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: UserProfileSheet(userId: userId, username: username),
            );
          },
        );
      },
    );
  }

  @override
  State<UserProfileSheet> createState() => _UserProfileSheetState();
}

class _UserProfileSheetState extends State<UserProfileSheet> {
  // fetch user profile by id
  late final Future<UserProfile> _future = DevToApi().fetchUserProfileById(
    widget.userId,
  );

  // fetch articles by username
  late final Future<List<Article>> _articles = DevToApi()
      .fetchArticlesByUsername(username: widget.username, perPage: 3);

  Future<void> _openProfileOnWeb(UserProfile p) async {
    final uri = Uri.https('dev.to', p.username);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: FutureBuilder<UserProfile>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          // show error message
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Couldn’t load profile',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: scheme.error),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          }

          final p = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundImage: NetworkImage(p.profileImage),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '@${p.username}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          if (p.location != null &&
                              p.location!.trim().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.place_outlined,
                                  size: 20,
                                  color: scheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    p.location!,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.cake_outlined,
                      size: 20,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Joined ${p.joinedAt}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (p.summary.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    p.summary,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (p.twitterUsername != null &&
                    p.twitterUsername!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _LinkRow(
                    icon: Icons.tag,
                    label: '@${p.twitterUsername}',
                    sublabel: 'Twitter / X',
                  ),
                ],
                if (p.githubUsername != null &&
                    p.githubUsername!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _LinkRow(
                    icon: Icons.code,
                    label: p.githubUsername!,
                    sublabel: 'GitHub',
                  ),
                ],
                if (p.websiteUrl != null &&
                    p.websiteUrl!.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _LinkRow(
                    icon: Icons.link,
                    label: p.websiteUrl!,
                    sublabel: 'Website',
                  ),
                ],
                const SizedBox(height: 20),
                // list of articles
                FutureBuilder<List<Article>>(
                  future: _articles,
                  builder: (context, snapshot) {
                    // show spinner
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        for (final article in snapshot.data!)
                          ArticleItem(article: article),
                      ],
                    );
                  },
                ),

                FilledButton.icon(
                  onPressed: () => _openProfileOnWeb(p),
                  icon: const Icon(Icons.open_in_new, size: 20),
                  label: const Text('View on DEV'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.icon,
    required this.label,
    required this.sublabel,
  });

  final IconData icon;
  final String label;
  final String sublabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: scheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sublabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
