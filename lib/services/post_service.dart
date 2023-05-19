import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';
import '../utils/constants.dart';

class PostService {
  final FirebaseFirestore _firestore;

  PostService(this._firestore);

  Stream<List<Post>> getPosts() {
  return _firestore.collection(Constants.firestoreCollectionPosts)
      .snapshots()
      .map((snapshot) {
        print('Fetched ${snapshot.docs.length} documents from posts collection');
        return snapshot.docs.map((document) {
          try {
            return Post(
              id: document.id,
              title: document.data()['title'],
              description: document.data()['description'],
              images: List<String>.from(document.data()['images']),
              authorId: document.data()['authorId'],
              rating: document.data()['rating'].toDouble(),
            );
          } catch (e) {
            print('Error in converting document to Post: $e');
            throw e;
          }
        }).toList();
      })
      .handleError((error) {
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
    return _firestore.collection(Constants.firestoreCollectionPosts).doc(post.id).update({
      'title': post.title,
      'description': post.description,
      'images': post.images,
      'rating': post.rating,
    });
  }
}
