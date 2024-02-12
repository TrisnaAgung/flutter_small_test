import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:vector_math/vector_math_64.dart' as vc;
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:flutter_small_test/list_object.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AugmentedReality(),
    );
  }
}

class AugmentedReality extends StatefulWidget {
  const AugmentedReality({super.key});

  @override
  State<AugmentedReality> createState() => _AugmentedRealityState();
}

class _AugmentedRealityState extends State<AugmentedReality> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;

  List<ARNode> nodes = [];
  List<ARAnchor> anchors = [];

  String? objectSelected;

  @override
  void dispose() {
    super.dispose();
    arSessionManager!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Augmented Reality'),
            actions: [
              IconButton(
                  onPressed: onRemoveEverything, icon: const Icon(Icons.delete))
            ],
          ),
          body: Stack(children: [
            ARView(
              onARViewCreated: onARViewCreated,
              planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
            ),
            Align(
              alignment: FractionalOffset.bottomCenter,
              child: ListObject(
                onTap: (value) async {
                  objectSelected = value;
                },
              ),
            ),
          ])),
    );
  }

  Future<void> onRemoveEverything() async {
    for (var anchor in anchors) {
      arAnchorManager!.removeAnchor(anchor);
    }
    anchors = [];
  }

  void onARViewCreated(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager arLocationManager) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;
    this.arAnchorManager = arAnchorManager;

    this.arSessionManager!.onInitialize(
          showFeaturePoints: false,
          showPlanes: true,
          showWorldOrigin: true,
          handlePans: true,
          handleRotation: true,
        );
    this.arObjectManager!.onInitialize();

    this.arSessionManager!.onPlaneOrPointTap = onPlaneOrPointTapped;
    this.arObjectManager!.onPanStart = onPanStarted;
    this.arObjectManager!.onPanChange = onPanChanged;
    this.arObjectManager!.onPanEnd = onPanEnded;
    this.arObjectManager!.onRotationStart = onRotationStarted;
    this.arObjectManager!.onRotationChange = onRotationChanged;
    this.arObjectManager!.onRotationEnd = onRotationEnded;
  }

  Future<void> onPlaneOrPointTapped(
      List<ARHitTestResult> hitTestResults) async {
    if (objectSelected != null) {
      var singleHitTestResult = hitTestResults.firstWhere(
          (hitTestResult) => hitTestResult.type == ARHitTestResultType.plane);
      var newAnchor =
          ARPlaneAnchor(transformation: singleHitTestResult.worldTransform);
      bool? didAddAnchor = await arAnchorManager!.addAnchor(newAnchor);
      if (didAddAnchor!) {
        anchors.add(newAnchor);
        var newNode = ARNode(
            type: NodeType.localGLTF2,
            uri: objectSelected!,
            scale: vc.Vector3(0.2, 0.2, 0.2),
            position: vc.Vector3(0.0, 0.0, 0.0),
            rotation: vc.Vector4(1.0, 0.0, 0.0, 0.0));
        bool? didAddNodeToAnchor =
            await arObjectManager!.addNode(newNode, planeAnchor: newAnchor);
        if (didAddNodeToAnchor!) {
          nodes.add(newNode);
        } else {
          arSessionManager!.onError("Adding Node to Anchor failed");
        }
      } else {
        arSessionManager!.onError("Adding Anchor failed");
      }
    } else {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) =>
            const AlertDialog(content: Text('Select an object!')),
      );
    }
  }

  onPanStarted(String nodeName) {}

  onPanChanged(String nodeName) {}

  onPanEnded(String nodeName, Matrix4 newTransform) {
    final pannedNode = nodes.firstWhere((element) => element.name == nodeName);
    pannedNode.transform = newTransform;
  }

  onRotationStarted(String nodeName) {}

  onRotationChanged(String nodeName) {}

  onRotationEnded(String nodeName, Matrix4 newTransform) {
    final rotatedNode = nodes.firstWhere((element) => element.name == nodeName);
    rotatedNode.transform = newTransform;
  }
}
