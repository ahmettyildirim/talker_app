
import 'package:flutter/material.dart';

enum TabItem { allRooms, myRooms, friends, }

class TabHelper {
  static TabItem item({int index}) {
    switch (index) {
      case 0:
        return TabItem.allRooms;
      case 1:
        return TabItem.myRooms;
      case 2:
        return TabItem.friends;
    }
    return TabItem.allRooms;
  }

  static String description(TabItem tabItem) {
    switch (tabItem) {
      case TabItem.allRooms:
        return 'All Rooms';
      case TabItem.myRooms:
        return 'Active Rooms';
      case TabItem.friends:
        return 'Friends';
    }
    return '';
  }
  static IconData icon(TabItem tabItem) {
    return Icons.layers;
  }

  static MaterialColor color(TabItem tabItem) {
    switch (tabItem) {
      case TabItem.allRooms:
        return Colors.red;
      case TabItem.myRooms:
        return Colors.green;
      case TabItem.friends:
        return Colors.blue;
    }
    return Colors.grey;
  }
}

class BottomNavigation extends StatelessWidget {
  BottomNavigation({this.currentTab, this.onSelectTab});
  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectTab;


  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [
        _buildItem(tabItem: TabItem.allRooms),
        _buildItem(tabItem: TabItem.myRooms),
        _buildItem(tabItem: TabItem.friends),
      ],
      onTap: (index) => onSelectTab(
        TabHelper.item(index: index),
      ),
    );
  }

  BottomNavigationBarItem _buildItem({TabItem tabItem}) {

    String text = TabHelper.description(tabItem);
    IconData icon = TabHelper.icon(tabItem);
    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        color: _colorTabMatching(item: tabItem),
      ),
      title: Text(
        text,
        style: TextStyle(
          color: _colorTabMatching(item: tabItem),
        ),
      ),
    );
  }

  Color _colorTabMatching({TabItem item}) {
    return currentTab == item ? TabHelper.color(item) : Colors.grey;
  }
}