import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/services/authentication_service.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String selectedItem = "Choose Category";

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
    final AuthenticationService authService =
        Provider.of<AuthenticationService>(context, listen: false);
    
     List<String> items = ["Choose Category","Restaurant", "Beach", "Bar", "Local Market", "Hotel", "Museum", "Park", "Landmark", "Other"];
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
            DropdownButton<String>(
              
              onChanged: (_value) {  // update the selectedItem value
                setState(() {
                  print(selectedItem);
                  selectedItem = _value!;
                  print(selectedItem);
                });
              },
              value: selectedItem,
              items: items
                  .map<DropdownMenuItem<String>>((String _value) => DropdownMenuItem<String>(
                  value: _value, // add this property an pass the _value to it
                  child: Text(_value,)
              )).toList(),
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
            FutureBuilder<User>(
              future: authService.getCurrentUser(),
              builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Show loading spinner while waiting for data
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}'); // Handle error case
                } else {
                  User author = snapshot.data!;
                  // Now you can use your User data here
                  return ElevatedButton(
                    onPressed: () async {
                      if (titleController.text.isEmpty ||
                          descriptionController.text.isEmpty ||
                          pickedFiles.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please fill in all fields.')),
                        );
                        return;
                      }
                      if(selectedItem == 'Choose Category'){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please select a category.')),
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
                        authorId: author.id,
                        authorDisplayName: author.displayName,
                        rating: 0.0,
                        ratings: {},
                        category:
                            selectedItem, // Assign the selected category
                        location: '',
                      );
                      context.read<PostService>().addPost(post);
                      Navigator.pop(context);
                    },
                    child: Text('Submit'),
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
