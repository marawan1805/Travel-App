import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  List<String> uploadedImageUrls = []; // To store uploaded image URLs
  List<XFile> pickedFiles = []; // To store picked Files

  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? newFiles = await picker.pickMultiImage(imageQuality: 1);

    if (newFiles != null) {
      setState(() {
        pickedFiles.addAll(newFiles);
      });
    } else {
      print('No image selected');
    }
  }

  void removeImageAt(int index) {
    setState(() {
      pickedFiles.removeAt(index);
    });
  }

  Future<void> uploadImage(int index) async {
    final File file = File(pickedFiles[index].path);
    final String fileName = Uuid().v4();
    final Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('uploads/$fileName');

    try {
      final UploadTask uploadTask = firebaseStorageRef.putFile(file);
      await uploadTask.whenComplete(() {});
      final String url = await firebaseStorageRef.getDownloadURL();

      uploadedImageUrls.add(url);
    } catch (e) {
      print('Upload failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title*',
              ),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description*',
              ),
            ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(
                pickedFiles.length,
                (index) => Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.file(
                      File(pickedFiles[index].path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        onPressed: () => removeImageAt(index),
                        icon: Icon(Icons.close, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: pickImages,
              child: Text('Pick Image(s)'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty ||
                    descriptionController.text.isEmpty ||
                    pickedFiles.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in all fields.')),
                  );
                  return;
                }

                for (var i = 0; i < pickedFiles.length; i++) {
                  await uploadImage(i);
                }

                final post = Post(
                  id: '',
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim(),
                  images: uploadedImageUrls,
                  authorId: '', // Add the author's user ID here
                  rating: 0.0,
                  ratings: {},
                );
                context.read<PostService>().addPost(post);
                Navigator.pop(context);
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
