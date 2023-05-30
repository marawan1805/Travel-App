import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../services/authentication_service.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  XFile? pickedFile;
  String? imageURL;
  bool isUploading = false;

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? newFile = await picker.pickImage(source: ImageSource.gallery);

    if (newFile != null) {
      setState(() {
        pickedFile = newFile;
      });
      await uploadImage(); // Note the await here
    } else {
      print('No image selected');
    }
  }

  Future<void> uploadImage() async {
    setState(() {
      isUploading = true;
    });

    final File file = File(pickedFile!.path);
    final String fileName = Uuid().v4();
    final Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('user_profile_images/$fileName');

    try {
      final UploadTask uploadTask = firebaseStorageRef.putFile(file);
      await uploadTask.whenComplete(() {});
      imageURL = await firebaseStorageRef.getDownloadURL();
    } catch (e) {
      print('Upload failed: $e');
    }

    setState(() {
      isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AuthenticationService authService =
        Provider.of<AuthenticationService>(context, listen: false);

    return FutureBuilder<User>(
        future: authService.getCurrentUser(),
        builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Show loading spinner while waiting for data
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}'); // Handle error case
          } else {
            User user = snapshot.data!;
            return Scaffold(
              appBar: AppBar(
                title: Text("Edit Profile"),
              ),
              body: ListView(
                children: <Widget>[
                  if (pickedFile != null)
                    Image.file(
                      File(pickedFile!.path),
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  ElevatedButton(
                    onPressed: isUploading ? null : pickImage,
                    child: Text("Change Profile Image"),
                  ),
                  ElevatedButton(
                    onPressed: isUploading || imageURL == null
                        ? null
                        : () async {
                            // Update imageURL for user in your database
                            await authService.updateUserImage(
                                user.id, imageURL!);

                            // You need to pop after the update so you go back to the Profile screen
                            Navigator.pop(context);
                          },
                    child: Text("Save"),
                  ),
                ],
              ),
            );
          }
        });
  }
}
