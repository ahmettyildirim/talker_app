import 'package:flutter/material.dart';
// import 'package:location/location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:talker_app/common/models/user_model.dart';

class ContactPage extends StatefulWidget {
  @override
  ContactPageState createState() => new ContactPageState();
}

class ContactPageState extends State<ContactPage>
    with TickerProviderStateMixin {
  MapController mapController;
  static LatLng myLocation;
  bool useCurrentLocation = true;
  @override
  void initState() {
    super.initState();
    setState(() {
      myLocation = new LatLng(UserModelRepository.instance.currentUser.currentLocation.latitude,
          UserModelRepository.instance.currentUser.currentLocation.longitude);
      mapController = MapController();
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double heigh = screenSize.height;
    TextStyle whiteStyle = new TextStyle(fontSize: 20.0, color: Colors.white);
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
                child: true
                    ? FlutterMap(
                        mapController: mapController,
                        options: new MapOptions(
                            center: myLocation,
                            zoom: 15.0,
                            minZoom: 3.0,
                            onTap: _handleTap),
                        layers: [
                          new TileLayerOptions(
                              urlTemplate:
                                  "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                              subdomains: ['a', 'b', 'c']),
                          new MarkerLayerOptions(
                            markers: [
                              new Marker(
                                width: 80.0,
                                height: 80.0,
                                point: new LatLng(
                                    myLocation.latitude, myLocation.longitude),
                                builder: (ctx) => new Container(
                                        child: IconButton(
                                      icon: Icon(Icons.location_on),
                                      onPressed: () {},
                                      color: Colors.red,
                                      iconSize: 40.0,
                                    )),
                              ),
                            ],
                          ),
                        ],
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
                        value: !UserModelRepository.instance.currentUser.useCustomLocation,
                        onChanged: (value) {
                          setState(() {
                            UserModelRepository.instance.currentUser.useCustomLocation = !value;
                            if (value) {
                              UserModelRepository.instance
                                  .setUserLocation();
                              
                            }
                          });
                        }),
                    FlatButton(
                      child: Text("Save new Position"),
                      onPressed: () {
                        UserModelRepository.instance.currentUser.currentLocation = UserLocation(
                            myLocation.latitude, myLocation.longitude);
                        UserModelRepository.instance.currentUser.useCustomLocation = true;
                        UserModelRepository.instance
                            .unsubscribeLocationChanges();
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

  _handleTap(LatLng point) {
    setState(() {
      myLocation = point;
    });
  }
}
