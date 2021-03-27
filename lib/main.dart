import 'dart:typed_data';

import 'package:flutter/material.dart';
// import 'package:arkit_plugin/arkit_node.dart';
// import 'package:arkit_plugin/arkit_plugin.dart';
// import 'package:arkit_plugin/arkit_reference_node.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class DemoAr extends StatelessWidget {
  DemoAr({Key key}) : super(key: key) {
    rootBundle.load('lib/assets/earth.jpg').then((data) {
      earthTexture = data.buffer.asUint8List();
    });

    rootBundle.load('lib/assets/moon.jpg').then((data) {
      moonTexture = data.buffer.asUint8List();
    });
  }
  ArCoreController controller;
  Uint8List earthTexture;
  Uint8List moonTexture;
  ArCoreRotatingNode earth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Augmented Reality'),
        ),
        body: Column(
          children: <Widget>[
            RotationSlider(
              degreesPerSecondInitialValue: 5.0,
              onDegreesPerSecondChange: onDegreesPerSecondChange,
            ),
            Expanded(
              child: ArCoreView(
                onArCoreViewCreated: onCoreViewCreated,
                enableTapRecognizer: true,
              ),
            ),
          ],
        ));
  }

  onCoreViewCreated(ArCoreController controller) {
    this.controller = controller;
    controller.onPlaneTap = _handleOnPlaneTap;
  }

   onDegreesPerSecondChange(double value) {
    if (earth == null) {
      return;
    }
    debugPrint("onDegreesPerSecondChange");
    if (earth.degreesPerSecond.value != value) {
      debugPrint("onDegreesPerSecondChange: $value");
      earth.degreesPerSecond.value = value;
    }
  }

  void _handleOnPlaneTap(List<ArCoreHitTestResult> hits) {
    final hit = hits.first;

    final moonMaterial =
        ArCoreMaterial(color: Colors.grey, textureBytes: moonTexture);

    final moonShape = ArCoreSphere(
      materials: [moonMaterial],
      radius: 0.03,
    );

    final moon = ArCoreNode(
      shape: moonShape,
      position: vector.Vector3(0.2, 0, 0),
      rotation: vector.Vector4(0, 0, 0, 0),
    );

    final earthMaterial = ArCoreMaterial(
        color: Color.fromARGB(120, 66, 134, 244), textureBytes: earthTexture);

    final earthShape = ArCoreSphere(
      materials: [earthMaterial],
      radius: 0.8,
    );

    // final earth = ArCoreNode(
    //     shape: earthShape,
    //     children: [moon],
    //     position: hit.pose.translation + vector.Vector3(0.0, 1.0, 0.0),//vector.Vector3(0.0, -0.5, -3.0),
    //     rotation: hit.pose.rotation
    //     );

    earth = ArCoreRotatingNode(
      shape: earthShape,
      position: hit.pose.translation + vector.Vector3(0.0, 1.0, 0.0),//vector.Vector3(0, 0, -1.5),
      rotation: hit.pose.rotation//vector.Vector4(0, 0, 0, 0),
    );


// final toucanNode = ArCoreReferenceNode(
//         name: "Toucano",
//         objectUrl:
//             "https://github.com/KhronosGroup/glTF-Sample-Models/raw/master/2.0/Duck/glTF/Duck.gltf",
//         position: hit.pose.translation,
//         rotation: hit.pose.rotation);
    // final material = ArCoreMaterial(
    //     color: Color.fromARGB(120, 66, 134, 244),
    //     textureBytes: image
    //   );
    // final sphere = ArCoreSphere(
    //   materials: [material],
    //   radius: 10,
    // );
    // final node = ArCoreNode(
    //   shape: sphere,
    //   position: vector.Vector3(0, 0, -1.5),
    // );
    controller.addArCoreNode(earth);
  }

  dispose() {
    controller.dispose();
  }
}

class RotationSlider extends StatefulWidget {
  final double degreesPerSecondInitialValue;
  final ValueChanged<double> onDegreesPerSecondChange;

  const RotationSlider(
      {Key key,
      this.degreesPerSecondInitialValue,
      this.onDegreesPerSecondChange})
      : super(key: key);

  @override
  _RotationSliderState createState() => _RotationSliderState();
}

class _RotationSliderState extends State<RotationSlider> {
  double degreesPerSecond;

  @override
  void initState() {
    degreesPerSecond = widget.degreesPerSecondInitialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text("Degrees Per Second"),
        Expanded(
          child: Slider(
            value: degreesPerSecond,
            divisions: 8,
            min: 0.15,
            max: 360.0,
            onChangeEnd: (value) {
              degreesPerSecond = value;
              widget.onDegreesPerSecondChange(degreesPerSecond);
            },
            onChanged: (double value) {
              setState(() {
                degreesPerSecond = value;
              });
            },
          ),
        ),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => DemoAr()));
    // setState(() {
    //   // This call to setState tells the Flutter framework that something has
    //   // changed in this State, which causes it to rerun the build method below
    //   // so that the display can reflect the updated values. If we changed
    //   // _counter without calling setState(), then the build method would not be
    //   // called again, and so nothing would appear to happen.
    //   _counter++;
    // });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
