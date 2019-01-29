import 'package:flutter/material.dart';
import 'package:talker_app/pages/chat.dart';
import 'package:talker_app/widgets/bottom_navigation.dart';
import 'package:talker_app/widgets/room_list.dart';
import 'package:talker_app/widgets/user_list.dart';

class TabNavigatorRoutes {
  static const String root = '/';
  static const String detail = '/detail';
}

class TabNavigator extends StatelessWidget {
  TabNavigator({this.navigatorKey, this.tabItem});
  final GlobalKey<NavigatorState> navigatorKey;
  final TabItem tabItem;

  void _push(BuildContext context, {int materialIndex: 500}) {
    var routeBuilders = _routeBuilders(context, materialIndex: materialIndex);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => routeBuilders[TabNavigatorRoutes.detail](context),
      ),
    );
  }

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context,
      {int materialIndex: 500}) {
    return {
      TabNavigatorRoutes.root: (context) {
        switch (tabItem) {
          case TabItem.allRooms:
            return RoomListTab(tabItem: tabItem,  scaffoldKey: GlobalKey<ScaffoldState>());
            break;
          case TabItem.myRooms:
            return RoomListTab(tabItem: tabItem,  scaffoldKey: GlobalKey<ScaffoldState>(),onlyMyRoom: true,);  
            break;
          case TabItem.friends:
            return UserListTab(tabItem: tabItem,  scaffoldKey: GlobalKey<ScaffoldState>());  
            break;
          default:
        }
      },
      TabNavigatorRoutes.detail: (context) => Chat(roomId:"")
    };
  }

  @override
  Widget build(BuildContext context) {
    var routeBuilders = _routeBuilders(context);

    return Navigator(
        key: navigatorKey,
        initialRoute: TabNavigatorRoutes.root,
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) => routeBuilders[routeSettings.name](context),
          );
        });
  }
}
