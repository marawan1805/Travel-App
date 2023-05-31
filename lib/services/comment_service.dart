import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment.dart';
import '../utils/constants.dart';
  import 'package:http/http.dart' as http;
import 'dart:convert';

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


Future<void> addComment(Comment comment) async {
  // Fetch the post data from Firestore
  DocumentSnapshot postSnapshot = await _firestore.collection(Constants.firestoreCollectionPosts).doc(comment.postId).get();

  if (!postSnapshot.exists) {
    throw Exception('Post not found');
  }

  // Extract the authorId from the post data
  String postAuthorId = postSnapshot['authorId'];

  // First, add the comment to Firestore
  await _firestore.collection(Constants.firestoreCollectionComments).add({
    'postId': comment.postId,
    'authorId': comment.authorId,
    'authorDisplayName': comment.authorDisplayName,
    'content': comment.content,
    'dateTime': comment.dateTime,
  });

  // Then, send a request to the Java server to notify about the comment
  String postTitle = 'someone commented on your post.'; // You need to fetch the post title
  var response = await http.post(
      Uri.parse('http://172.20.10.2:3000/notifyComment'),
      body: jsonEncode({
        'postTitle': postTitle,
        'commentContent': comment.content,
        'postAuthorId': postAuthorId  // Here's the new field
      }),
      headers: {
        'Content-Type': 'application/json'
      }
  );

  if (response.statusCode != 200) {
      print('Failed to send notification: ${response.body}');
  }
}


}
