const functions = require("firebase-functions");

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendPostNotification = functions.firestore
    .document('posts/{postId}')
    .onCreate((snapshot, context) => {
      const post = snapshot.data();
      const payload = {
        notification: {
          title: 'New Post!',
          body: `Check out the new post: ${post.title}`,
          clickAction: 'FLUTTER_NOTIFICATION_CLICK', // Must be present for onResume or onLaunch callbacks to be called on Android
        },
        data: {
          route: `post/${context.params.postId}`,
        },
      };

      return admin.messaging().sendToTopic('posts', payload);
    });

    exports.sendCommentNotification = functions.firestore
    .document('comments/{commentId}')
    .onCreate(async (snapshot, context) => {
      const comment = snapshot.data();
      const postSnapshot = await admin.firestore().doc(`posts/${comment.postId}`).get();
      const post = postSnapshot.data();

      const payload = {
        notification: {
          title: 'New Comment!',
          body: `${comment.authorDisplayName} commented on your post: ${post.title}`,
          clickAction: 'FLUTTER_NOTIFICATION_CLICK', // Must be present for onResume or onLaunch callbacks to be called on Android
        },
        data: {
          route: `post/${comment.postId}`,
        },
      };

      // Fetch tokens of the post author.
      const tokenSnapshot = await admin.firestore().collection('users').doc(post.authorId).collection('tokens').get();
      const tokens = tokenSnapshot.docs.map(doc => doc.id); // tokens are stored in the document ID

      if (tokens.length > 0) {
        return admin.messaging().sendToDevice(tokens, payload);
      } else {
        console.log(`No tokens for user: ${post.authorId}`);
        return null;
      }
    });
