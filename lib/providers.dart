import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart';

class MarkerProvider extends ChangeNotifier {
  double markerAngle = 0.0;
  LatLng? markerPoint;

  updateMarker(double angle, LatLng position) {
    markerAngle = angle;
    markerPoint = position;
    notifyListeners();
  }
}
