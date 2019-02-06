import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:talker_app/common/models/user_model.dart';

class Helper {
  static final Helper instance = Helper();
  Geoflutterfire _geo = Geoflutterfire();

  GeoFirePoint getCurrentGeoFirePoint() => _geo.point(
      latitude:
          UserModelRepository.instance.currentUser.currentLocation.latitude,
      longitude:
          UserModelRepository.instance.currentUser.currentLocation.longitude);
}

bool isNullEmpty(String o) => o == null || "" == o;

bool isNullEmptyOrFalse(Object o) => o == null || false == o || "" == o;

bool isNullEmptyFalseOrZero(Object o) =>
    o == null || false == o || 0 == o || "" == o;
