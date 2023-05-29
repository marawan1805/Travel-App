import 'package:flutter/material.dart';

class AvatarButton extends StatelessWidget {
  final GestureTapCallback onTap;
  final String imageURL;

  const AvatarButton({required this.onTap, required this.imageURL});

  @override
  Widget build(BuildContext context) {
    double size = 100;

    return new InkResponse(
        onTap: onTap,
        child: new Container(
          width: size,
          height: size,
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            minRadius: size,
            maxRadius: size,
            backgroundImage: NetworkImage(imageURL),
          ),
        ));
  }
}
