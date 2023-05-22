import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment.dart';
import '../utils/constants.dart';

class CommentService {
  final FirebaseFirestore _firestore;

  CommentService(this._firestore);

  Stream<List<Comment>> getComments(String postId) {
    return _firestore
        .collection(Constants.firestoreCollectionComments)
        .where('postId', isEqualTo: postId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((document) {
              final data = document.data();
              return Comment(
                id: document.id,
                postId: data['postId'],
                authorId: data['authorId'],
                authorDisplayName: data['authorDisplayName'] ??
                    'Anonymous', // Provide a default value for authorDisplayName
                content: data['content'],
                dateTime: data.containsKey('dateTime')
                    ? data['dateTime'].toDate()
                    : DateTime.now(),
              );
            }).toList());
  }

  Future<void> addComment(Comment comment) {
    return _firestore.collection(Constants.firestoreCollectionComments).add({
      'postId': comment.postId,
      'authorId': comment.authorId,
      'authorDisplayName': comment
          .authorDisplayName, // Save the 'authorDisplayName' field in Firestore
      'content': comment.content,
      'dateTime': comment.dateTime,
    });
  }
}
