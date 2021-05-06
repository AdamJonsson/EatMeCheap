import 'dart:async';

import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

void main() => runApp(MaterialApp(home: ImageDetectionPage()));

class ImageDetectionPage extends StatefulWidget {
  @override
  _ImageDetectionPageState createState() => _ImageDetectionPageState();
}

class _ImageDetectionPageState extends State<ImageDetectionPage> {
  ARKitController arkitController;
  Timer timer;
  bool anchorWasFound = false;
  List<String> addedAnchors = [];

  @override
  void dispose() {
    timer?.cancel();
    arkitController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Image Detection Sample')),
        body: Container(
          child: Stack(
            fit: StackFit.expand,
            children: [
              ARKitSceneView(
                detectionImagesGroupName: 'Products',
                maximumNumberOfTrackedImages: 2,
                onARKitViewCreated: onARKitViewCreated,
              ),
              anchorWasFound
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Point the camera at the earth image from the article about Earth on Wikipedia.',
                        style: Theme.of(context)
                            .textTheme
                            .headline5
                            .copyWith(color: Colors.white),
                      ),
                    ),
            ],
          ),
        ),
      );

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    this.arkitController.onAddNodeForAnchor = onAnchorWasFound;
    this.arkitController.onUpdateNodeForAnchor = (ARKitAnchor anchor) {
      print(anchor.identifier);
    };
  }

  void onAnchorWasFound(ARKitAnchor anchor) {
    if (anchor is ARKitImageAnchor) {
      print(anchor.identifier);
      if (addedAnchors.contains(anchor.identifier)) return;
      addedAnchors.add(anchor.identifier);
      setState(() => anchorWasFound = true);

      final material = ARKitMaterial(
        lightingModelName: ARKitLightingModel.lambert,
        diffuse: ARKitMaterialProperty(image: 'lib/assets/discount-label.png'),
      );
      final sphere = ARKitPlane(
        materials: [material],
        width: 0.1,
        height: 0.1,
      );

      final earthPosition = anchor.transform.getColumn(3);
      final node = ARKitNode(
        geometry: sphere,
        position:
            vector.Vector3(earthPosition.x, earthPosition.y, earthPosition.z),
        eulerAngles: vector.Vector3.zero(),
      );
      arkitController.add(node);
      arkitController.removeAnchor(anchor.identifier);

      // timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      //   final old = node.eulerAngles;
      //   final eulerAngles = vector.Vector3(old.x + 0.01, old.y, old.z);
      //   node.eulerAngles = eulerAngles;
      // });
    }
  }
}
