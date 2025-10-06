import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/firebase_service.dart';
import '../models/community_user_model.dart';

/// Remote datasource for community operations using Firestore
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

/// Firestore implementation of CommunityRemoteDataSource
class CommunityRemoteDataSourceImpl implements CommunityRemoteDataSource {
  final FirebaseService _firebaseService;

  CommunityRemoteDataSourceImpl(this._firebaseService);

  @override
  Future<List<CommunityUserModel>> getUsers({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final querySnapshot = await _firebaseService.firestore
          .collection('community_users')
          .orderBy('joinedAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => CommunityUserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  @override
  Future<CommunityUserModel?> getUserById(String userId) async {
    try {
      final docSnapshot = await _firebaseService.firestore
          .collection('community_users')
          .doc(userId)
          .get();

      if (!docSnapshot.exists) return null;

      return CommunityUserModel.fromJson(docSnapshot.data()!);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  @override
  Future<List<CommunityUserModel>> searchUsers(String query) async {
    try {
      final querySnapshot = await _firebaseService.firestore
          .collection('community_users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '$query\uf8ff')
          .limit(20)
          .get();

      return querySnapshot.docs
          .map((doc) => CommunityUserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  @override
  Future<List<CommunityUserModel>> getOnlineUsers() async {
    try {
      final querySnapshot = await _firebaseService.firestore
          .collection('community_users')
          .where('isOnline', isEqualTo: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => CommunityUserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get online users: $e');
    }
  }

  @override
  Future<CommunityUserModel> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firebaseService.firestore
          .collection('community_users')
          .doc(userId)
          .update(updates);

      // Return updated user
      final updatedDoc = await _firebaseService.firestore
          .collection('community_users')
          .doc(userId)
          .get();

      return CommunityUserModel.fromJson(updatedDoc.data()!);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  @override
  Future<void> followUser(String followerId, String followedId) async {
    try {
      final batch = _firebaseService.firestore.batch();

      // Add to follower's following
      final followerRef = _firebaseService.firestore
          .collection('community_users')
          .doc(followerId)
          .collection('following')
          .doc(followedId);

      batch.set(followerRef, {
        'followedId': followedId,
        'followedAt': FieldValue.serverTimestamp(),
      });

      // Add to followed's followers
      final followedRef = _firebaseService.firestore
          .collection('community_users')
          .doc(followedId)
          .collection('followers')
          .doc(followerId);

      batch.set(followedRef, {
        'followerId': followerId,
        'followedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to follow user: $e');
    }
  }

  @override
  Future<void> unfollowUser(String followerId, String followedId) async {
    try {
      final batch = _firebaseService.firestore.batch();

      // Remove from follower's following
      final followerRef = _firebaseService.firestore
          .collection('community_users')
          .doc(followerId)
          .collection('following')
          .doc(followedId);

      batch.delete(followerRef);

      // Remove from followed's followers
      final followedRef = _firebaseService.firestore
          .collection('community_users')
          .doc(followedId)
          .collection('followers')
          .doc(followerId);

      batch.delete(followedRef);

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to unfollow user: $e');
    }
  }

  @override
  Future<List<CommunityUserModel>> getFollowers(String userId) async {
    try {
      final querySnapshot = await _firebaseService.firestore
          .collection('community_users')
          .doc(userId)
          .collection('followers')
          .get();

      final followerIds = querySnapshot.docs.map((doc) => doc.id).toList();

      if (followerIds.isEmpty) return [];

      final usersQuery = await _firebaseService.firestore
          .collection('community_users')
          .where(FieldPath.documentId, whereIn: followerIds)
          .get();

      return usersQuery.docs
          .map((doc) => CommunityUserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get followers: $e');
    }
  }

  @override
  Future<List<CommunityUserModel>> getFollowing(String userId) async {
    try {
      final querySnapshot = await _firebaseService.firestore
          .collection('community_users')
          .doc(userId)
          .collection('following')
          .get();

      final followingIds = querySnapshot.docs.map((doc) => doc.id).toList();

      if (followingIds.isEmpty) return [];

      final usersQuery = await _firebaseService.firestore
          .collection('community_users')
          .where(FieldPath.documentId, whereIn: followingIds)
          .get();

      return usersQuery.docs
          .map((doc) => CommunityUserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get following: $e');
    }
  }

  @override
  Future<bool> isFollowing(String followerId, String followedId) async {
    try {
      final docSnapshot = await _firebaseService.firestore
          .collection('community_users')
          .doc(followerId)
          .collection('following')
          .doc(followedId)
          .get();

      return docSnapshot.exists;
    } catch (e) {
      throw Exception('Failed to check following status: $e');
    }
  }

  @override
  Future<void> shareProgress(
    String userId,
    Map<String, dynamic> progressData,
  ) async {
    try {
      await _firebaseService.firestore.collection('progress_shares').add({
        'userId': userId,
        'progressData': progressData,
        'sharedAt': FieldValue.serverTimestamp(),
        'likes': 0,
        'comments': 0,
      });
    } catch (e) {
      throw Exception('Failed to share progress: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getProgressFeed(
    String userId, {
    int limit = 20,
  }) async {
    try {
      // Get following list first
      final followingSnapshot = await _firebaseService.firestore
          .collection('community_users')
          .doc(userId)
          .collection('following')
          .get();

      final followingIds = followingSnapshot.docs.map((doc) => doc.id).toList();
      followingIds.add(userId); // Include own progress

      if (followingIds.isEmpty) return [];

      final querySnapshot = await _firebaseService.firestore
          .collection('progress_shares')
          .where('userId', whereIn: followingIds)
          .orderBy('sharedAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to get progress feed: $e');
    }
  }

  @override
  Future<void> likePost(String postId, String userId) async {
    try {
      final batch = _firebaseService.firestore.batch();

      // Add like to post
      final likeRef = _firebaseService.firestore
          .collection('progress_shares')
          .doc(postId)
          .collection('likes')
          .doc(userId);

      batch.set(likeRef, {
        'userId': userId,
        'likedAt': FieldValue.serverTimestamp(),
      });

      // Increment likes count
      final postRef = _firebaseService.firestore
          .collection('progress_shares')
          .doc(postId);

      batch.update(postRef, {'likes': FieldValue.increment(1)});

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to like post: $e');
    }
  }

  @override
  Future<void> unlikePost(String postId, String userId) async {
    try {
      final batch = _firebaseService.firestore.batch();

      // Remove like from post
      final likeRef = _firebaseService.firestore
          .collection('progress_shares')
          .doc(postId)
          .collection('likes')
          .doc(userId);

      batch.delete(likeRef);

      // Decrement likes count
      final postRef = _firebaseService.firestore
          .collection('progress_shares')
          .doc(postId);

      batch.update(postRef, {'likes': FieldValue.increment(-1)});

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to unlike post: $e');
    }
  }

  @override
  Future<List<dynamic>> getComments(
    String postId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      Query query = _firebaseService.firestore
          .collection('progress_shares')
          .doc(postId)
          .collection('comments')
          .orderBy('createdAt', descending: false)
          .limit(limit);

      // Note: Firestore doesn't have offset, so we'll skip it for now
      // In a real implementation, you'd use startAfter with a document snapshot
      final querySnapshot = await query.get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to get comments: $e');
    }
  }

  @override
  Future<dynamic> createComment(dynamic comment) async {
    try {
      final commentData = comment as Map<String, dynamic>;
      final docRef = await _firebaseService.firestore
          .collection('progress_shares')
          .doc(commentData['postId'])
          .collection('comments')
          .add({
            ...commentData,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Increment comments count
      await _firebaseService.firestore
          .collection('progress_shares')
          .doc(commentData['postId'])
          .update({'comments': FieldValue.increment(1)});

      return {
        'id': docRef.id,
        ...commentData,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      };
    } catch (e) {
      throw Exception('Failed to create comment: $e');
    }
  }

  @override
  Future<dynamic> updateComment(
    String commentId,
    Map<String, dynamic> updates,
  ) async {
    try {
      // Note: This is a simplified implementation
      // In a real app, you'd need to find which post the comment belongs to
      // For now, we'll assume we have the postId in the updates
      final postId = updates['postId'];
      if (postId == null) {
        throw Exception('postId is required for comment update');
      }

      await _firebaseService.firestore
          .collection('progress_shares')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .update({...updates, 'updatedAt': FieldValue.serverTimestamp()});

      return {'id': commentId, ...updates, 'updatedAt': DateTime.now()};
    } catch (e) {
      throw Exception('Failed to update comment: $e');
    }
  }

  @override
  Future<void> deleteComment(String commentId) async {
    try {
      // Note: This is a simplified implementation
      // In a real app, you'd need to find which post the comment belongs to
      // For now, we'll assume we can delete by commentId alone
      final querySnapshot = await _firebaseService.firestore
          .collectionGroup('comments')
          .where(FieldPath.documentId, isEqualTo: commentId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Comment not found');
      }

      final commentDoc = querySnapshot.docs.first;
      final postId = commentDoc.reference.parent.parent?.id;

      if (postId == null) {
        throw Exception('Could not determine post for comment');
      }

      await _firebaseService.firestore
          .collection('progress_shares')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();

      // Decrement comments count
      await _firebaseService.firestore
          .collection('progress_shares')
          .doc(postId)
          .update({'comments': FieldValue.increment(-1)});
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }

  @override
  Future<void> likeComment(String commentId, String userId) async {
    try {
      // Find the comment and its post
      final querySnapshot = await _firebaseService.firestore
          .collectionGroup('comments')
          .where(FieldPath.documentId, isEqualTo: commentId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Comment not found');
      }

      final commentDoc = querySnapshot.docs.first;
      final postId = commentDoc.reference.parent.parent?.id;

      if (postId == null) {
        throw Exception('Could not determine post for comment');
      }

      final batch = _firebaseService.firestore.batch();

      // Add like to comment
      final likeRef = _firebaseService.firestore
          .collection('progress_shares')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('likes')
          .doc(userId);

      batch.set(likeRef, {
        'userId': userId,
        'likedAt': FieldValue.serverTimestamp(),
      });

      // Increment likes count
      final commentRef = _firebaseService.firestore
          .collection('progress_shares')
          .doc(postId)
          .collection('comments')
          .doc(commentId);

      batch.update(commentRef, {'likesCount': FieldValue.increment(1)});

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to like comment: $e');
    }
  }

  @override
  Future<void> unlikeComment(String commentId, String userId) async {
    try {
      // Find the comment and its post
      final querySnapshot = await _firebaseService.firestore
          .collectionGroup('comments')
          .where(FieldPath.documentId, isEqualTo: commentId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Comment not found');
      }

      final commentDoc = querySnapshot.docs.first;
      final postId = commentDoc.reference.parent.parent?.id;

      if (postId == null) {
        throw Exception('Could not determine post for comment');
      }

      final batch = _firebaseService.firestore.batch();

      // Remove like from comment
      final likeRef = _firebaseService.firestore
          .collection('progress_shares')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('likes')
          .doc(userId);

      batch.delete(likeRef);

      // Decrement likes count
      final commentRef = _firebaseService.firestore
          .collection('progress_shares')
          .doc(postId)
          .collection('comments')
          .doc(commentId);

      batch.update(commentRef, {'likesCount': FieldValue.increment(-1)});

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to unlike comment: $e');
    }
  }
}
