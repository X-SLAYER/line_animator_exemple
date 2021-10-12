import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_test/line_animator.dart';
import 'package:map_test/providers.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  List<LatLng> builtPoints = [];
  List<LatLng> myPoints = [];
  ValueNotifier<LatLng> latLng = ValueNotifier<LatLng>(LatLng(0.0, 0.0));
  List<LatLng> points = [
    LatLng(36.726687, 3.06347),
    LatLng(36.634455, 3.006323),
    LatLng(36.688443, 2.849542),
    LatLng(36.682102, 2.937777),
    LatLng(36.674, 2.953073),
    LatLng(36.702357, 3.200328),
    LatLng(36.73825, 4.366245),
    LatLng(36.784522, 3.018333),
    LatLng(36.475435, 2.82872),
  ];
  bool isReversed = false;
  MapController _controller = MapController();
  late PointInterpolator interpolator;
  late AnimationController controller;
  Animation<double>? animation;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(seconds: 42), vsync: this);
    interpolator = PointInterpolator(
      originalPoints: points,
      isReversed: false,
      distanceFunc: null,
    );
    animation = Tween<double>(begin: 0.0, end: interpolator.totalDistance)
        .animate(controller);
  }

  void startAnimation() {
    interpolator = PointInterpolator(
        originalPoints: points, distanceFunc: null, isReversed: false);

    controller =
        AnimationController(duration: Duration(seconds: 35), vsync: this);

    animation = Tween<double>(begin: 0.0, end: interpolator.totalDistance)
        .animate(controller)
      ..addListener(() {
        InterpolatedResult interpolatedResult =
            interpolator.interpolate(controller.value, animation!.value, true);

        if (interpolatedResult.point != null) {
          print(interpolatedResult.point);
          print(interpolatedResult.angle);
          _controller.move(interpolatedResult.point!, 10.5);
          Provider.of<MarkerProvider>(context, listen: false).updateMarker(
              interpolatedResult.angle, interpolatedResult.point!);
        }
      })
      ..addStatusListener((status) {
        print(animation!.status);
      });

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Consumer<MarkerProvider>(
          builder: (_, marker, __) => FlutterMap(
            mapController: _controller,
            options: MapOptions(
              boundsOptions: FitBoundsOptions(padding: EdgeInsets.all(30)),
              onTap: (_, latLng) {
                print(_controller.zoom);
                log('$latLng');
              },
            ),
            layers: [
              TileLayerOptions(
                  placeholderImage: NetworkImage(
                      'https://c4.wallpaperflare.com/wallpaper/172/783/827/avatar-the-last-airbender-anime-wallpaper-preview.jpg'),
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                  tileProvider: NetworkTileProvider()),
              PolylineLayerOptions(polylines: [
                Polyline(points: points, strokeWidth: 5.0, color: Colors.green),
              ]),
              MarkerLayerOptions(markers: [
                Marker(
                  width: 180,
                  height: 180,
                  point: marker.markerPoint ?? points[0],
                  builder: (ctx) => Container(
                    child: Transform.rotate(
                      angle: marker.markerAngle,
                      child: Icon(Icons.airplanemode_active_sharp),
                    ),
                  ),
                )
              ]),
            ],
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              child: Text("plot"),
              heroTag: null,
              onPressed: () {
                print(myPoints);
              },
            ),
            SizedBox(height: 15.0),
            FloatingActionButton(
              backgroundColor: Colors.green,
              child: Text("Start"),
              heroTag: null,
              onPressed: () {
                controller.reset();
                startAnimation();
              },
            ),
            SizedBox(height: 15.0),
            FloatingActionButton(
              backgroundColor: Colors.red,
              child: Text("Stop"),
              heroTag: null,
              onPressed: () {
                controller.stop();
              },
            ),
            SizedBox(height: 15.0),
            FloatingActionButton(
              backgroundColor: Colors.yellow,
              child: Text("Reset"),
              heroTag: null,
              onPressed: () {
                controller.forward();
              },
            ),
          ],
        ));
  }

  @override
  void didUpdateWidget(MyHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }
}
