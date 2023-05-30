import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';
import '../utils/constants.dart';

class PostService {
  final FirebaseFirestore _firestore;

  PostService(this._firestore);

  Future<void> updatePostRating(
      String postId, String userId, double rating) async {
    DocumentReference postRef =
        _firestore.collection(Constants.firestoreCollectionPosts).doc(postId);
    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot postSnapshot = await transaction.get(postRef);
      if (!postSnapshot.exists) {
        throw Exception("Post does not exist!");
      }

      Map<String, dynamic> data = postSnapshot.data() as Map<String, dynamic>;
      Map<String, dynamic> ratingsData = data.containsKey('ratings')
          ? Map<String, dynamic>.from(data['ratings'])
          : {};
      Map<String, double> ratings = {};
      ratingsData.forEach((key, value) {
        ratings[key] = value is double ? value : (value as num).toDouble();
      });

      ratings[userId] = rating;

      double averageRating =
          ratings.values.reduce((a, b) => a + b) / ratings.length;

      transaction
          .update(postRef, {'ratings': ratings, 'rating': averageRating});
    });
  }

  Stream<List<Post>> getPosts() {
    return _firestore
        .collection(Constants.firestoreCollectionPosts)
        .snapshots()
        .map((snapshot) {
      print('Fetched ${snapshot.docs.length} documents from posts collection');
      return snapshot.docs.map((document) {
        try {
          Map<String, double> ratings = {};
          if (document.data()['ratings'] != null) {
            Map<String, dynamic> ratingsData = document.data()['ratings'];
            ratingsData.forEach((key, value) {
              ratings[key] = value.toDouble();
            });
          }
          return Post(
            id: document.id,
            title: document.data()['title'] ?? '',
            description: document.data()['description'] ?? '',
            images: document.data()['images'] != null
                ? List<String>.from(document.data()['images'])
                : [],
            authorId: document.data()['authorId'] ?? '',
            rating: document.data()['rating'] != null
                ? document.data()['rating'].toDouble()
                : 0.0,
            ratings: ratings,
          );
        } catch (e) {
          print('Error in converting document to Post: $e');
          throw e;
        }
      }).toList();
    }).handleError((error) {
      print('Error in fetching posts: $error');
      throw error;
    });
  }

  Future<void> addPost(Post post) {
    return _firestore.collection(Constants.firestoreCollectionPosts).add({
      'title': post.title,
      'description': post.description,
      'images': post.images,
      'authorId': post.authorId,
      'rating': post.rating,
    });
  }

  Future<void> updatePost(Post post) {
    return _firestore
        .collection(Constants.firestoreCollectionPosts)
        .doc(post.id)
        .update({
      'title': post.title,
      'description': post.description,
      'images': post.images,
      'rating': post.rating,
    });
  }

  Stream<List<Post?>> getPostsForAuthor(authorId) {
    return _firestore
        .collection(Constants.firestoreCollectionPosts)
        .snapshots()
        .map((snapshot) {
      print('Fetched ${snapshot.docs.length} documents from posts collection');
      return snapshot.docs.map((document) {
        try {
          Map<String, double> ratings = {};
          if (document.data()['ratings'] != null) {
            Map<String, dynamic> ratingsData = document.data()['ratings'];
            ratingsData.forEach((key, value) {
              ratings[key] = value.toDouble();
            });
          }
          print(authorId);
          print(document.data()['authorId']);
          if(authorId == document.data()['authorId']){
            print("ALOOOOOOOOO");
            return Post(
              id: document.id,
              title: document.data()['title'] ?? '',
              description: document.data()['description'] ?? '',
              images: document.data()['images'] != null
                  ? List<String>.from(document.data()['images'])
                  : [],
              authorId: document.data()['authorId'] ?? '',
              rating: document.data()['rating'] != null
                  ? document.data()['rating'].toDouble()
                  : 0.0,
              ratings: ratings,
            );
          }
        } catch (e) {
          print('Error in converting document to Post: $e');
          throw e;
        }
      }).toList();
    }).handleError((error) {
      print('Error in fetching posts: $error');
      throw error;
    });
  }
}
