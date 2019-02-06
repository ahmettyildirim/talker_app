import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:talker_app/common/models/user_model.dart';

class GoogleMapLocation extends StatefulWidget {
  final double latitude;
  final double longitude;
  GoogleMapLocation({this.latitude,this.longitude});
  _GoogleMapLocationState createState() => _GoogleMapLocationState();
}

class _GoogleMapLocationState extends State<GoogleMapLocation> {
  GoogleMapController mapController;
  bool mapToogle = true;
  Marker currentMarker;
  

  void initMarker() {
    mapController
        .addMarker(MarkerOptions(
            position: LatLng(widget.latitude,
                widget.longitude),
            draggable: true,
            rotation: 4.0))
        .then((result) {
      currentMarker = result;
    });
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("",
        ),
        centerTitle: true,
        elevation: 6.0,
      ),
      body: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height - 80.0,
                width: double.infinity,
                child: mapToogle
                    ? GoogleMap(
                        onMapCreated: _onMapCreated,
                        
                        initialCameraPosition: CameraPosition(
                            target: LatLng(
                                UserModelRepository.instance.currentUser.currentLocation.latitude,
                                UserModelRepository.instance.currentUser.currentLocation.longitude,
                                ),
                            zoom: 35.0,
                            bearing: 90,
                            tilt:45),
                        myLocationEnabled: true,
                        rotateGesturesEnabled: true,
                        scrollGesturesEnabled: true,
                        tiltGesturesEnabled: true,
                        zoomGesturesEnabled: true,
                        compassEnabled: true,
                      )
                    : Center(
                        child: Text(
                          'Loading.. Please wait',
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ),
              ),
             
            ],
          )
        ],
      ),
    );
  }
  Future sleep2seconds() {
    return new Future.delayed(const Duration(seconds: 2), () => "1");
  }

  void _onMapCreated(GoogleMapController controller)async {
    setState(() {
      mapController = controller;
    });
    await sleep2seconds();
    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
                            target: LatLng(
                                widget.latitude,
                                widget.longitude),
                            zoom: 35.0,
                            bearing: 90,
                            tilt:45)
    ));
    
    initMarker();
  }
}
// @override

// Widget build(BuildContext context) {
//   return Padding(
//     padding: EdgeInsets.all(15.0),
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: <Widget>[
//         Center(
//           child: SizedBox(
//             width: double.infinity,
//             height: 500.0,
//             child: GoogleMap(
//               initialCameraPosition:  const CameraPosition(
//                 bearing: 270.0,
//                 target: LatLng(40.974201, 29.063621),
//                 tilt: 30.0,
//                 zoom: 5.0,
//               ),
//               onMapCreated: _onMapCreated,
//             ),
//           ),
//         ),
//         RaisedButton(
//           child: const Text('Go to London'),
//           onPressed: mapController == null ? null : () {
//             mapController.animateCamera(CameraUpdate.newCameraPosition(
//               const CameraPosition(
//                 bearing: 0.0,
//                 target: LatLng(40.974201, 29.063621),
//                 tilt: 10.0,
//                 zoom: 15.0,
//               ),
//             ));
//           },
//         ),
//       ],
//     ),
//   );
// }
// void _onMapCreated(GoogleMapController controller) {
//   setState(() { mapController = controller; });
// }
// }
