import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment.dart';
import '../utils/constants.dart';

class CommentService {
  final FirebaseFirestore _firestore;

  CommentService(this._firestore);

  Stream<List<Comment>> getComments(String postId) {
    return _firestore.collection(Constants.firestoreCollectionComments)
        .where('postId', isEqualTo: postId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((document) => Comment(
          id: document.id,
          postId: document.data()['postId'],
          authorId: document.data()['authorId'],
          content: document.data()['content'],
        )).toList(),
    );
  }

  Future<void> addComment(Comment comment) {
    return _firestore.collection(Constants.firestoreCollectionComments).add({
      'postId': comment.postId,
      'authorId': comment.authorId,
      'content': comment.content,
    });
  }
}
