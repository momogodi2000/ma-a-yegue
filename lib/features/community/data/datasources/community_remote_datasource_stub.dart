import '../../../../core/services/firebase_service.dart';
import '../models/community_user_model.dart';

/// Remote datasource for community operations (HYBRID - SIMPLIFIED STUB)
///
/// ⚠️ IMPORTANT: This is a simplified stub version
/// Community features (forums, social, following) are disabled until
/// full SQLite implementation is completed.
///
/// For now, this class returns empty data to allow compilation.
/// Full implementation will store all community data in SQLite.
abstract class CommunityRemoteDataSource {
  // User operations
  Future<List<CommunityUserModel>> getUsers({int limit = 20, int offset = 0});
  Future<CommunityUserModel?> getUserById(String userId);
  Future<List<CommunityUserModel>> searchUsers(String query);
  Future<List<CommunityUserModel>> getOnlineUsers();
  Future<CommunityUserModel> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  );

  // Following operations
  Future<void> followUser(String followerId, String followedId);
  Future<void> unfollowUser(String followerId, String followedId);
  Future<List<CommunityUserModel>> getFollowers(String userId);
  Future<List<CommunityUserModel>> getFollowing(String userId);
  Future<bool> isFollowing(String followerId, String followedId);

  // Progress sharing operations
  Future<void> shareProgress(String userId, Map<String, dynamic> progressData);
  Future<List<Map<String, dynamic>>> getProgressFeed(
    String userId, {
    int limit = 20,
  });

  // Post operations
  Future<void> likePost(String postId, String userId);
  Future<void> unlikePost(String postId, String userId);

  // Comment operations
  Future<List<dynamic>> getComments(
    String postId, {
    int limit = 20,
    int offset = 0,
  });
  Future<dynamic> createComment(dynamic comment);
  Future<dynamic> updateComment(String commentId, Map<String, dynamic> updates);
  Future<void> deleteComment(String commentId);
  Future<void> likeComment(String commentId, String userId);
  Future<void> unlikeComment(String commentId, String userId);
}

/// Stub implementation - returns empty data
/// TODO: Implement full SQLite-based community features
class CommunityRemoteDataSourceImpl implements CommunityRemoteDataSource {
  CommunityRemoteDataSourceImpl(FirebaseService firebaseService);

  @override
  Future<List<CommunityUserModel>> getUsers({
    int limit = 20,
    int offset = 0,
  }) async {
    return [];
  }

  @override
  Future<CommunityUserModel?> getUserById(String userId) async {
    return null;
  }

  @override
  Future<List<CommunityUserModel>> searchUsers(String query) async {
    return [];
  }

  @override
  Future<List<CommunityUserModel>> getOnlineUsers() async {
    return [];
  }

  @override
  Future<CommunityUserModel> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    throw UnimplementedError('Community features temporarily disabled');
  }

  @override
  Future<void> followUser(String followerId, String followedId) async {
    // Silently ignore
  }

  @override
  Future<void> unfollowUser(String followerId, String followedId) async {
    // Silently ignore
  }

  @override
  Future<List<CommunityUserModel>> getFollowers(String userId) async {
    return [];
  }

  @override
  Future<List<CommunityUserModel>> getFollowing(String userId) async {
    return [];
  }

  @override
  Future<bool> isFollowing(String followerId, String followedId) async {
    return false;
  }

  @override
  Future<void> shareProgress(
    String userId,
    Map<String, dynamic> progressData,
  ) async {
    // Silently ignore
  }

  @override
  Future<List<Map<String, dynamic>>> getProgressFeed(
    String userId, {
    int limit = 20,
  }) async {
    return [];
  }

  @override
  Future<void> likePost(String postId, String userId) async {
    // Silently ignore
  }

  @override
  Future<void> unlikePost(String postId, String userId) async {
    // Silently ignore
  }

  @override
  Future<List<dynamic>> getComments(
    String postId, {
    int limit = 20,
    int offset = 0,
  }) async {
    return [];
  }

  @override
  Future<dynamic> createComment(dynamic comment) async {
    throw UnimplementedError('Community features temporarily disabled');
  }

  @override
  Future<dynamic> updateComment(
    String commentId,
    Map<String, dynamic> updates,
  ) async {
    throw UnimplementedError('Community features temporarily disabled');
  }

  @override
  Future<void> deleteComment(String commentId) async {
    // Silently ignore
  }

  @override
  Future<void> likeComment(String commentId, String userId) async {
    // Silently ignore
  }

  @override
  Future<void> unlikeComment(String commentId, String userId) async {
    // Silently ignore
  }
}
