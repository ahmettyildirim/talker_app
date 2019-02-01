
import 'package:flutter/material.dart';
import 'package:talker_app/common/constants.dart';
import 'package:talker_app/common/functions/data_repository.dart';
import 'package:talker_app/common/models/user_model.dart';

class UserListTab extends StatefulWidget {
  const UserListTab({Key key, this.scaffoldKey})
      : super(key: key);
  final GlobalKey<ScaffoldState> scaffoldKey;
  @override
 UserListTabState createState() =>UserListTabState();
}

class UserListTabState extends State<UserListTab> {
  var listMessage;
  Widget buildListMessage() {
    return StreamBuilder(
        stream: DataRepository.instance.getAllUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor)));
          } else {
            listMessage = snapshot.data.documents;
            return ListView(
                padding: const EdgeInsets.all(0.0),
              children: listMessage.map<Widget>((dynamic item) {
                return _UserListItem(
                  userModel: UserModel.fromSnapshot(item),
                 
                );
              }).toList(),
            );
          }
        },
    );
  }
  @override
  Widget build(BuildContext context) {
    Widget body;
   
      body = Scaffold(
          body: buildListMessage());
    return body;
  }
}

class _UserListItem extends StatelessWidget {
  const _UserListItem({
    Key key,
    @required this.userModel,
    
  }) : super(key: key);

  final UserModel userModel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return  Container(
          decoration: BoxDecoration(
              color: theme.canvasColor,
              border: Border(bottom: BorderSide(color: theme.dividerColor))),
          child: ListData(
              title: userModel.displayName,
              subtitle:  userModel.email,
              image: userModel.photoUrl.isEmpty ? DecorationImage(
                  image: ExactAssetImage('assets/user.png'),
                  fit: BoxFit.cover,
                ): DecorationImage(
                  image: NetworkImage(userModel.photoUrl),
                  fit: BoxFit.cover,
                )
            ),
    );
  }
}

class ListData extends StatelessWidget {
  final EdgeInsets margin;
  final double width;
  final String title;
  final String subtitle;
  final DecorationImage image;
  ListData({this.margin, this.subtitle, this.title, this.width, this.image});
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return (new Container(
      alignment: Alignment.center,
      margin: margin,
      width: width,
      decoration: new BoxDecoration(
        color: theme.selectedRowColor,
        border: new Border(
          top: new BorderSide(
              width: 1.0, color: const Color.fromRGBO(204, 204, 204, 0.3)),
          bottom: new BorderSide(
              width: 1.0, color: const Color.fromRGBO(204, 204, 204, 0.3)),
        ),
      ),
      child: new Row(
        children: <Widget>[
          new Container(
              margin: new EdgeInsets.only(
                  left: 20.0, top: 10.0, bottom: 10.0, right: 20.0),
              width: 60.0,
              height: 60.0,
              decoration:
                  new BoxDecoration(shape: BoxShape.circle, image: image)),
          new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(
                title,
                style:
                    new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
              ),
              new Padding(
                padding: new EdgeInsets.only(top: 5.0),
                child: new Text(
                  subtitle,
                  style: new TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w300),
                ),
              )
            ],
          )
        ],
      ),
    ));
  }
}
