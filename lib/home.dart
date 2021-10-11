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
    LatLng(35.829712, 10.640552),
    LatLng(35.833536, 10.640169),
    LatLng(35.835353, 10.636464),
    LatLng(35.836059, 10.635675),
    LatLng(35.837019, 10.634611),
    LatLng(35.838154, 10.63307),
    LatLng(35.838988, 10.63171),
    LatLng(35.839576, 10.630134),
    LatLng(35.839942, 10.629649),
    LatLng(35.840249, 10.62894),
    LatLng(35.840251, 10.628401),
    LatLng(35.84012, 10.627054),
    LatLng(35.840042, 10.625409),
    LatLng(35.84003, 10.623829),
    LatLng(35.84007, 10.622763),
    LatLng(35.840192, 10.622491),
    LatLng(35.840174, 10.622341),
    LatLng(35.840007, 10.6222),
    LatLng(35.839835, 10.622385),
    LatLng(35.839596, 10.622725)
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
        AnimationController(duration: Duration(seconds: 25), vsync: this);
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
        AnimationController(duration: Duration(seconds: 5), vsync: this);

    animation = Tween<double>(begin: 0.0, end: interpolator.totalDistance)
        .animate(controller)
      ..addListener(() {
        InterpolatedResult interpolatedResult =
            interpolator.interpolate(controller.value, animation!.value, true);

        if (interpolatedResult.point != null) {
          print(interpolatedResult.point);
          print(interpolatedResult.angle);
          _controller.move(interpolatedResult.point!, 16);
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
                onTap: (cords) {
                  myPoints.add(cords);
                }),
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
