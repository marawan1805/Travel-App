// import 'package:flutter/material.dart';
// import '../models/user.dart';

// class ImageSwap extends StatefulWidget {
//   final User user;
//   const ImageSwap(this.user);

//   @override
//   State<ImageSwap> createState() => _ImageSwapState();
// }

// class _ImageSwapState extends State<ImageSwap> {
//   final imageUrlController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 10,
//       child: Container(
//         padding: const EdgeInsets.all(10),
//         margin: const EdgeInsets.all(10),
//         child: Column(children: [
//           TextField(
//             decoration: const InputDecoration(
//               labelText: 'Enter image URL',
//             ),
//             controller: imageUrlController,
//             onSubmitted: (_) => setState(() {}),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if(imageUrlController.text != ""){
//                 widget.user.imageURL = imageUrlController.text;
//               }
//               Navigator.of(context).pop();
//             },
//             child: const Text('Confirm'),
//           ),
//           changeImage(imageUrlController)
//         ]),
//       ),
//     );
//   }

//   Center changeImage(TextEditingController urlController) {
//     double size = 75;
//     return Center(
//       child: CircleAvatar(
//         minRadius: size,
//         maxRadius: size,
//         backgroundImage: NetworkImage(urlController.text == ""
//             ? widget.user.imageURL
//             : urlController.text),
//       ),
//     );
//   }
// }
