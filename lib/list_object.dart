import 'package:flutter/material.dart';

class ListObject extends StatefulWidget {
  final Function? onTap;

  const ListObject({super.key, this.onTap});

  @override
  // ignore: library_private_types_in_public_api
  _ListObjectState createState() => _ListObjectState();
}

class _ListObjectState extends State<ListObject> {
  List<String> gifs = [
    'assets/images/fox.png',
    'assets/images/lantern.png',
    'assets/images/duck.png',
    'assets/images/bottle.png',
    'assets/images/chair.png',
  ];

  List<String> objectsFileName = [
    'Models/fox/Fox.gltf',
    'Models/lantern/Lantern.gltf',
    'Models/duck/Duck.gltf',
    'Models/bottle/WaterBottle.gltf',
    'Models/chair/SheenChair.gltf',
  ];

  String? selected;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150.0,
      child: ListView.builder(
        itemCount: gifs.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selected = gifs[index];
                widget.onTap?.call(objectsFileName[index]);
              });
            },
            child: Card(
              elevation: 4.0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: Container(
                color:
                    selected == gifs[index] ? Colors.red : Colors.transparent,
                padding:
                    selected == gifs[index] ? const EdgeInsets.all(8.0) : null,
                child: Image.asset(gifs[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}
