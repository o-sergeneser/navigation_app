// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_routes/google_maps_routes.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mtk;
import 'package:my_simple_navigation/constants/constants.dart';
import 'package:my_simple_navigation/utils/permission_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  String _darkMapStyle = "";
  StreamSubscription<Position>? _positionStream;
  final CameraPosition _cameraPos = CameraPosition(
    target: LatLng(48.14918762944394, 11.580469375826612),
    zoom: 16,
  );
  List<Marker> markerList = [];
  final Marker _destinationMarker = Marker(
      markerId: MarkerId("destination"),
      position: LatLng(48.1510805637, 11.5789536609));
  Position? _currentPosition;
  List<Polyline> myRouteList = [];
  MapsRoutes route = MapsRoutes();
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  Marker? myLocationMarker;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      markerList.add(_destinationMarker);
      setCustomIconForUserLocation();
      _loadMapStyles().then((_) {
        if (mounted) setState(() {});
      });
      checkPermissionAndListenLocation();
    });
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_positionStream != null) _positionStream!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.grey[850],
        onPressed: () {
          getNewRouteFromAPI();
        },
        label: Text(
          "Get Route",
          style: TextStyle(color: Colors.grey[300]),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        centerTitle: true,
        title: Text("My Simple Navigation",
            style: TextStyle(color: Colors.grey[300])),
      ),
      body: PermissionProvider.locationPermission != PermissionStatus.granted ||
              _darkMapStyle.isEmpty
          ? Container(
              color: Colors.grey[700],
              child: Center(child: CircularProgressIndicator()))
          : GoogleMap(
              style: _darkMapStyle,
              polylines: Set<Polyline>.from(myRouteList),
              initialCameraPosition: _cameraPos,
              markers: Set<Marker>.from(markerList),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
    );
  }

  void setCustomIconForUserLocation() {
    Future<Uint8List> getBytesFromAsset(String path, int width) async {
      ByteData data = await rootBundle.load(path);
      Codec codec = await instantiateImageCodec(data.buffer.asUint8List(),
          targetWidth: width);
      FrameInfo fi = await codec.getNextFrame();
      return (await fi.image.toByteData(format: ImageByteFormat.png))!
          .buffer
          .asUint8List();
    }

    getBytesFromAsset('assets/user_location.png', 64).then((onValue) {
      markerIcon = BitmapDescriptor.fromBytes(onValue);
    });
  }

  void navigationProcess() {
    List<mtk.LatLng> myLatLngList = [];
    for (var data in route.routes.first.points) {
      myLatLngList.add(mtk.LatLng(data.latitude, data.longitude));
    }
    mtk.LatLng myPosition =
        mtk.LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    // we check if our location is on route or not
    int x = mtk.PolygonUtil.locationIndexOnPath(myPosition, myLatLngList, true,
        tolerance: 12);
    /* x: -1 if point does not lie on or near the polyline. 0 if point is between
            poly[0] and poly[1] (inclusive), 1 if between poly[1] and poly[2]... */
    if (x == -1) {
      getNewRouteFromAPI();
    } else {
      myLatLngList[x] = myPosition;
      myLatLngList.removeRange(0, x);
      myRouteList.first.points.clear();
      myRouteList.first.points
          .addAll(myLatLngList.map((e) => LatLng(e.latitude, e.longitude)));
    }
    if (mounted) setState(() {});
  }

  void getNewRouteFromAPI() async {
    if (route.routes.isNotEmpty) route.routes.clear();
    if (myRouteList.isNotEmpty) myRouteList.clear();
    log("GETTING NEW ROUTE !!");
    await route.drawRoute([
      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      LatLng(_destinationMarker.position.latitude,
          _destinationMarker.position.longitude)
    ], 'route', Color.fromARGB(255, 33, 155, 255), Constants.googleApiKey,
        travelMode: TravelModes.driving);
    myRouteList.add(route.routes.first);
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (PermissionProvider.permissionDialogRoute != null &&
          PermissionProvider.permissionDialogRoute!.isActive) {
        Navigator.of(context)
            .removeRoute(PermissionProvider.permissionDialogRoute!);
      }
      Future.delayed(Duration(milliseconds: 250), () async {
        checkPermissionAndListenLocation();
      });
    }
  }

  Future<void> _loadMapStyles() async {
    _darkMapStyle = await rootBundle.loadString(Constants.darkMapStyleJson);
  }

  void checkPermissionAndListenLocation() {
    PermissionProvider.handleLocationPermission(context).then((_) {
      if (_positionStream == null &&
          PermissionProvider.locationPermission == PermissionStatus.granted) {
        startListeningLocation();
      }
      if (mounted) setState(() {});
    });
  }

  void startListeningLocation() {
    _positionStream = Geolocator.getPositionStream(
            locationSettings: LocationSettings(accuracy: LocationAccuracy.high))
        .listen((Position? position) {
      if (position != null) {
        log('${position.latitude.toString()}, ${position.longitude.toString()}');
        showMyLocationOnMap(position);
        if (myRouteList.isNotEmpty) {
          navigationProcess();
        }
      }
    });
  }

  void showMyLocationOnMap(Position position) {
    _currentPosition = position;
    markerList.removeWhere((e) => e.markerId == MarkerId("myLocation"));
    myLocationMarker = Marker(
        markerId: MarkerId("myLocation"),
        position:
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        icon: markerIcon,
        rotation: _currentPosition!.heading);
    if (markerIcon != BitmapDescriptor.defaultMarker) {
      markerList.add(myLocationMarker!);
    }
    if (mounted) setState(() {});
  }
}
