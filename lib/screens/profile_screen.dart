import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/image_swapper.dart';
import '../widgets/post_card.dart';
import '../widgets/avatar_button.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../services/authentication_service.dart';
import '../services/post_service.dart';

class Profile extends StatefulWidget {
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    final AuthenticationService authService =
        Provider.of<AuthenticationService>(context, listen: false);

    User? user = authService.getCurrentUser();
    return Scaffold(
        appBar: AppBar(
          title: Text(user!.displayName),
        ),
        body: Container(
          margin: EdgeInsets.symmetric(vertical: 30),
          child: Center(
            child: Column(
              children: [
                AvatarButton(
                    onTap: () {
                      changeProfileImage(context, user);
                      setState(() {});
                    },
                    imageURL: user.imageURL),
                Text(user.displayName),
                Text(user.email),
                Text(user.id),
                Container(
                    height: 500,
                    child: StreamBuilder<List<Post?>>(
                        stream: context
                            .read<PostService>()
                            .getPostsForAuthor(user.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                print(snapshot.data!);
                                if (snapshot.data![index] != null) {
                                  return PostCard(
                                      post: snapshot.data![index] as Post);
                                }
                              },
                            );
                          }
                        })),
              ],
            ),
          ),
        ));
  }

  void changeProfileImage(BuildContext ctx, User user) {
    showModalBottomSheet(
        context: ctx,
        builder: (_) {
          return GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: ImageSwap(user),
          );
        });
  }
}
