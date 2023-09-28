import 'package:catering_core/core.dart';
import 'package:flutter/material.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key, this.loc});
  final LatLng? loc;
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Future determinePosition() async {
    if (widget.loc != null) return;
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return;
    }
    final loc = await Geolocator.getCurrentPosition();
    setLocation(LatLng(loc.latitude, loc.longitude));
  }

  final mapController = MapController();

  List<Marker> markers = [
    Marker(
      point: const LatLng(-8.660055582969436, 116.52222799437303),
      builder: (context) => Icon(
        Icons.location_on,
        color: Colors.red[400],
        size: context.rsize(.1),
      ),
    )
  ];
  void setLocation(LatLng point) => setState(() {
        markers = [
          Marker(
            point: point,
            builder: (context) => Icon(
              Icons.location_on,
              color: Colors.red[400],
              size: context.rsize(.1),
            ),
          )
        ];
        mapController.move(point, 14);
      });
  @override
  void initState() {
    determinePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => determinePosition(),
        child: const Icon(Icons.gps_fixed),
      ),
      bottomNavigationBar: markers.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(16),
              child: MainButton(
                onPressed: () => context.pop(markers.first.point),
                child: const Left("Pilih"),
              ),
            ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
            maxZoom: 18,
            onTap: (tapPosition, point) => setLocation(point),
            center: markers.first.point),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),
          MarkerLayer(
            markers: markers,
          )
        ],
      ),
    );
  }
}
