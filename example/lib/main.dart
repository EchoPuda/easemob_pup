import 'package:easemob_plu_example/page/ChatPrivate.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:easemob_plu/easemob_plu.dart' as easemob;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    _initEasemob();
  }

  /// 初始化环信
  Future<void> _initEasemob() async {
    var result = await easemob.initEaseMobPlu(
      autoInvitation: true,
      debugMode: true,
      autoLogin: true,
    );
    print(result);
    if (result == "success") {
      _loginEasemob();
    }

  }

  /// 登录环信
  Future<void> _loginEasemob() async {
    var result = await easemob.login("zjm0000", "123456");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => new HomeState();

}

class HomeState extends State<Home> {

  List<Widget> _listConversationItem = new List();

  Map<String, Widget> _mapConversation = new Map();
  Map<String, int> _mapUnreadCount = new Map();
  Map<String, int> _mapTime = new Map();

  @override
  void initState() {
    super.initState();
    //登录监听
    easemob.responseFromLogin.listen((data) {
      print("登录回调: $data");
      _listConversationItem.clear();
      if (data == "success") {
        //成功才能进行其他操作
        _getConversation();
        _addMessageListener();
      }
    });
    // 连接异常监听
    easemob.responseFromDisConnect.listen((data) {
      print(data);
    });
    // 获取所有会话监听
    easemob.responseFromConversationGet.listen((conversation) {
      List<Widget> mapConversation = new List();
      Iterable iterable = conversation.keys;
      int i = 0;
      List<int> lastTime = new List();
      iterable.forEach((key){
        print("id: " + conversation[key].conversationId);
        easemob.TYPE type = conversation[key].type;
        String lastText = _delBodyType(type,conversation[key].body);
        int time = conversation[key].lastMsgTime;
        String timeText = _delTimeStamp(time);
        int unReadCount = conversation[key].unReadCount;
        _mapUnreadCount[key] = unReadCount;
        Widget conversationItem = new InkWell(
          onTap: (){_gotoChat(conversation[key].conversationId);},
          child: new ConversationItem(
            name: conversation[key].conversationId,
            lastText: lastText,
            time: timeText,
            unreadCount: _mapUnreadCount[key],
          ),
        );
        _mapConversation[key] = conversationItem;
        if (i == 0) {
          lastTime.add(time);
          mapConversation.add(
            _mapConversation[key],
          );
        } else{
          int index = lastTime.length;
          for (int j = 0; j < lastTime.length; j++) {
            if (lastTime[j] < time) {
              index = j;
              break;
            }
          }
          if (index == lastTime.length) {
            mapConversation.add(_mapConversation[key]);
            lastTime.add(time);
          } else{
            mapConversation.insert(index, _mapConversation[key]);
            lastTime.insert(index, time);
          }
        }
        i++;
      });
      setState(() {
        _listConversationItem = mapConversation;
      });
    });
    // 消息接收监听
    easemob.responseFromMsgListener.listen((data) {
      print("新消息");
      _listConversationItem.clear();
      List<Widget> mapConversation = new List();
      Map<String, int> unReadCount = new Map();
      String unReadUsername = "";
      String username;
      for (int i = 0; i < data.list.length; i++) {
        String msgId = data.list[i].msgId;
        easemob.ChatType chatType = data.list[i].chatType;
        if (chatType == easemob.ChatType.Chat) {
          username = data.list[i].fromUser;
        } else {
          username = data.list[i].toUser;
        }
        print(username);
        int newTimeStamp = data.list[i].time;
        easemob.TYPE type = data.list[i].type;
        String body = data.list[i].body;
        String text = _delBodyType(type,body);
        print(text);
        String time = _delTimeStamp(newTimeStamp);
        if (unReadUsername == username){
          unReadCount[username]++;
        } else {
          if (!unReadCount.containsKey(username)) {
            unReadCount[username] = 1;
          }
        }
        _mapTime[username] = newTimeStamp;
        if (_mapConversation.containsKey(username)) {
          _mapConversation.remove(username);
          Widget newConversationItem = new InkWell(
            onTap: (){_gotoChat(username);},
            child: new ConversationItem(
              name: username,
              lastText: text,
              time: time,
              unreadCount: unReadCount[username] + _mapUnreadCount[username],
            ),
          );
          _mapUnreadCount[username] = unReadCount[username] + _mapUnreadCount[username];
          _mapConversation[username] = newConversationItem;
          print(_mapConversation);
        } else {

          Widget newConversationItem = new InkWell(
              onTap: (){_gotoChat(username);},
              child: new ConversationItem(
                name: username,
                lastText: text,
                time: time,
                unreadCount: unReadCount[username],
              )
          );
          _mapConversation[username] = newConversationItem;

        }
        unReadUsername = username;
      }
      //最新消息置顶
      mapConversation.add(_mapConversation[username]);
      for (int i = _mapConversation.values.toList().length - 1; i >= 0; i--) {
        if (_mapConversation.keys.toList()[i] != username) {
          mapConversation.add(_mapConversation.values.toList()[i]);
        }
      }
      setState(() {
        _listConversationItem = mapConversation;
      });
    });
  }

  Future<void> _getMsgAsRead(String username) async {
    var result = await easemob.getMsgAsRead(username: username);
  }

  void _gotoChat(String username) {
    //离开页面要移除消息监听
    _removeMsgListener();
    _getMsgAsRead(username);
    Navigator.push(context,new MaterialPageRoute(
      builder: (BuildContext context) {
        return ChatPrivate(
          username: username,
        );
      },
    )).then((value){
      setState(() {
        _getMsgAsRead(username);
        _mapUnreadCount[username] = 0;
        //重新获取数据和添加监听
        _getConversation();
        _addMessageListener();
      });
    });
  }

  /// 处理时间戳
  String _delTimeStamp(int timeStamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timeStamp);
    return (dateTime.hour < 10 ? "0" + dateTime.hour.toString() : dateTime.hour.toString()) + ":"
        + (dateTime.minute < 10 ? "0" + dateTime.minute.toString() : dateTime.minute.toString());
  }

  /// 处理消息类型
  String _delBodyType(easemob.TYPE type,String body) {
    switch(type) {
      case easemob.TYPE.TXT:
        return body;
      case easemob.TYPE.IMAGE:
        return "[图片]";
      case easemob.TYPE.VOICE:
        return "[语音]";
      case easemob.TYPE.VIDEO:
        return "[视频]";
      case easemob.TYPE.CMD:
        return body;
      case easemob.TYPE.FILE:
        return "[文件]";
      case easemob.TYPE.LOCATION:
        return "[定位]";
      default:
        return body;
    }
  }

  /// 获取所有会话（在内存中的）
  Future<void> _getConversation() async {
    var result = await easemob.getAllConversations();
  }

  /// 注册消息监听
  Future<void> _addMessageListener() async {
    var result = await easemob.addMessageListener();
  }

  /// 移除消息监听
  Future<void> _removeMsgListener() async {
    var result = await easemob.removeMessageListener();
  }

  @override
  void dispose() async {
    ///退出时移除消息的监听
    await easemob.removeMessageListener();
    await easemob.logout();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('消息'),
      ),
      body: new Container(
        width: double.maxFinite,
        height: double.maxFinite,
        child: Column(
          children: <Widget>[
            new Container(
              margin: EdgeInsets.symmetric(horizontal: 27.0,vertical: 10.0),
              padding: EdgeInsets.symmetric(vertical: 10.0),
              decoration: BoxDecoration(
                color: Color(0xABEFEFEF),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  "搜索",
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Color(0xFF999999),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.0,),
            new Expanded(
              flex: 1,
              child: ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: _listConversationItem,
              ),
            )
          ],
        ),
      ),
    );
  }

}

class ConversationItem extends StatefulWidget {

  ConversationItem({
    Key key,
    this.image,
    @required this.name,
    @required this.lastText,
    @required this.time,
    @required this.unreadCount,
  }) : super(key: key);
  ///头像
  final String image;
  ///昵称ID
  final String name;
  ///最后一条消息
  final String lastText;
  ///最后更新的时间
  final String time;
  ///未读消息数
  final int unreadCount;

  @override
  State<StatefulWidget> createState() => new ConversationItemState();

}

class ConversationItemState extends State<ConversationItem> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          new Container(
            width: double.maxFinite,
            child: Row(
              children: <Widget>[
                new Container(
                  width: 64,
                  height: 64,
                  margin: EdgeInsets.only(left: 15.0,right: 15.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFD8D8D8), width: 0.5),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Center(
                            child: Icon(Icons.person_outline,size: 48,color: Colors.blue,),
                          )
                      ),
                      Positioned(
                          right: 0,
                          top: 0,
                          child: Offstage(
                            offstage: widget.unreadCount == 0,
                            child: new Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle
                              ),
                              child: Center(
                                child: Text(
                                  "${widget.unreadCount}",
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.white
                                  ),
                                ),
                              ),
                            ),
                          )
                      )
                    ],
                  ),
                ),
                new Expanded(
                    flex: 1,
                    child: Stack(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(right: 25),
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                widget.name,
                                style: TextStyle(
                                  fontSize: 17.0,
                                  color: Color(0xFF464545),
                                ),
                              ),
                              SizedBox(height: 5.0,),
                              Text(
                                widget.lastText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Color(0xFF999999),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                            bottom: 0,
                            child: new Container(
                              height: 0.5,
                              width: double.maxFinite,
                              color: Color(0xffD8D8D8),
                            )
                        ),
                      ],
                    )
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 33.0,
            child: new Text(
              widget.time,
              style: TextStyle(
                fontSize: 9.0,
                color: Color(0xFF999999),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
