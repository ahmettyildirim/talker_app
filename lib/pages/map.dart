import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:talker_app/common/models/user_model.dart';

class GoogleMapExample extends StatefulWidget {
  _GoogleMapExampleState createState() => _GoogleMapExampleState();
}

class _GoogleMapExampleState extends State<GoogleMapExample> {
  GoogleMapController mapController;
  bool mapToogle = false;
  UserModel _currentUser = UserModelRepository.instance.currentUser;
  bool useCurrentLocation = true;
  Marker currentMarker;
  @override
  void initState() {
    super.initState();
    setState(() {
     useCurrentLocation=!_currentUser.useCustomLocation; 
    });
    if (_currentUser.currentLocation == null) {
      Geolocator().getCurrentPosition().then((onValue) {
        setState(() {
          _currentUser.currentLocation =  UserLocation(onValue.latitude, onValue.longitude);
          mapToogle = true;
        });
      });
    } else {
      setState(() {
        mapToogle = true;
      });
    }
  }
  

  void initMarker() {
    mapController
        .addMarker(MarkerOptions(
            position: LatLng(_currentUser.currentLocation.latitude,
                _currentUser.currentLocation.longitude),
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
        title: Text(
          "Location Operations",
          style: TextStyle(color: Colors.indigo),
        ),
        centerTitle: true,
        elevation: 6.0,
      ),
      body: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 50),
                height: MediaQuery.of(context).size.height - 130.0,
                width: double.infinity,
                child: mapToogle
                    ? GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                            target: LatLng(
                                _currentUser.currentLocation.latitude,
                                _currentUser.currentLocation.longitude),
                            zoom: 15.0),
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
              Positioned(
                top: 5.0,
                left: 10.0,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("Use my current location",
                        style: TextStyle(color: Colors.indigo)),
                    Switch(
                        value: useCurrentLocation,
                        onChanged: (value) {
                          setState(() {
                            useCurrentLocation = value;
                          });
                        }),
                        FlatButton(
                          child: Text("Save new Position"),
                          onPressed: (){
                            var myMarker = mapController.markers.first;
                            _currentUser.currentLocation =UserLocation(currentMarker.options.position.latitude, currentMarker.options.position.longitude);
                            _currentUser.useCustomLocation = true;
                          },
                          )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
      initMarker();
    });
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
