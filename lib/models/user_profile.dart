/// Response from `GET https://dev.to/api/users/:id` (Forem user JSON).
class UserProfile {
  const UserProfile({
    required this.typeOf,
    required this.id,
    required this.username,
    required this.name,
    required this.summary,
    required this.joinedAt,
    required this.profileImage,
    this.twitterUsername,
    this.githubUsername,
    this.location,
    this.websiteUrl,
  });

  final String typeOf;
  final int id;
  final String username;
  final String name;
  final String summary;
  final String joinedAt;
  final String profileImage;
  final String? twitterUsername;
  final String? githubUsername;
  final String? location;
  final String? websiteUrl;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      typeOf: json['type_of'] as String,
      id: json['id'] as int,
      username: json['username'] as String,
      name: json['name'] as String,
      summary: json['summary'] as String? ?? '',
      joinedAt: json['joined_at'] as String,
      profileImage: json['profile_image'] as String,
      twitterUsername: json['twitter_username'] as String?,
      githubUsername: json['github_username'] as String?,
      location: json['location'] as String?,
      websiteUrl: json['website_url'] as String?,
    );
  }
}
