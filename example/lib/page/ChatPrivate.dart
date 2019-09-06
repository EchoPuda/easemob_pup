import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easemob_plu/easemob_plu.dart' as easemob;
import 'package:image_picker/image_picker.dart';

/// 私聊
/// @author puppet
class ChatPrivate extends StatefulWidget {
  ChatPrivate({Key key,@required this.username}) : super(key: key);
  final String username;

  @override
  State<StatefulWidget> createState() => new ChatPrivateState();

}

class ChatPrivateState extends State<ChatPrivate> {

  List<String> _listMsgId = new List();
  List<Widget> _listMsgItem = new List();
  List<Widget> _listMsg = new List();
  TextEditingController _controller;
  ScrollController _scrollController = new ScrollController();

  bool _showSend = false;
  String _editText = "";
  bool _showBottom = false;
  FocusNode _focusNode = FocusNode();
  int _listLength = 0;

  /// 注册消息监听
  Future<void> _addMessageListener() async {
    var result = await easemob.addMessageListener();
  }

  /// 移除消息监听
  Future<void> _removeMsgListener() async {
    var result = await easemob.removeMessageListener();
  }

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _showBottom = false;
        });
      }
    });

    _getAllMessages();
    _addMessageListener();
    // 消息接收监听
    easemob.responseFromMsgListener.listen((data) async {
      print("新消息");
      String fromUser;
      List<Widget> listMsg = new List();
      for (int i = 0; i < data.list.length; i++) {
        String msgId = data.list[i].msgId;
//        easemob.ChatType chatType = data.list[i].chatType;
//        if (chatType == easemob.ChatType.Chat) {
//          username = data.list[i].fromUser;
//        } else {
//          username = data.list[i].toUser;
//        }
        fromUser = data.list[i].fromUser;
        print(fromUser);
        int newTimeStamp = data.list[i].time;
        easemob.TYPE type = data.list[i].type;

        String body;
        if (type == easemob.TYPE.IMAGE) {
          body = await data.list[i].body;
        } else {
          body = data.list[i].body;
        }
        listMsg.add(new MessageTime(time: _delTimeStamp(newTimeStamp),));
        print(body);
        if (fromUser != widget.username) {
          listMsg.add(new MessageShowMe(
            body: body,
            type: type,
          ));
        } else {
          listMsg.add(new MessageShowFrom(
            body: body,
            type: type,
          ));
        }
      }
      listMsg.insertAll(0, _listMsg);
      _listMsg = listMsg;
      print(listMsg);
      setState(() {
        _listMsgItem = listMsg;
        _listLength = listMsg.length;
      });
      scrollToEnd();
    });
    //消息发送后监听
    easemob.responseFromMsgSendStateListener.listen((data){
      print("监听：" + data);
    });
  }

  void scrollToEnd() {
    double scrollOffset = _scrollController.position.maxScrollExtent + 100;
    print("offset:" + "$scrollOffset");
    _scrollController.animateTo(scrollOffset, duration: Duration(milliseconds: 500), curve: Curves.ease);
  }

  Future<void> _getAllMessages() async {
    var result = await easemob.getAllMessages(widget.username);
    List<Widget> listMsg = new List();
    for (int i = 0; i < result.list.length; i++) {
      int time = result.list[i].time;
      print("time:" + result.list[i].time.toString());
      print("msgId:" + result.list[i].msgId);
      print("fromUser:" + result.list[i].fromUser);
      print("type:" + result.list[i].type.toString());
      print("body:" + result.list[i].body);
      String timeText = _delTimeStamp(time);
      String msgId = result.list[i].msgId;
      _listMsgId.add(msgId);
      String fromUser = result.list[i].fromUser;
      easemob.TYPE type = result.list[i].type;
      String body = result.list[i].body;
      listMsg.add(new MessageTime(time: timeText,));
      _listMsg.add(new MessageTime(time: timeText,));
      if (fromUser != widget.username) {
        Widget msgShow = new MessageShowMe(
          body: body,
          type: type,
        );
        listMsg.add(msgShow);
        _listMsg.add(msgShow);
      } else {
        Widget msgShow = new MessageShowFrom(
          body: body,
          type: type,
        );
        listMsg.add(msgShow);
        _listMsg.add(msgShow);
      }
    }
    setState(() {
      _listMsgItem = listMsg;
      _listLength = listMsg.length;
    });
    _scrollController.animateTo(listMsg.length * 50.0, duration: Duration(milliseconds: 500), curve: Curves.ease);

  }

  String _delTimeStamp(int timeStamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timeStamp);

    return (dateTime.hour < 10 ? "0" + dateTime.hour.toString() : dateTime.hour.toString()) + ":"
        + (dateTime.minute < 10 ? "0" + dateTime.minute.toString() : dateTime.minute.toString());
  }

  ///输入框监听
  void _onChangeText(String value) {
    if (value.isNotEmpty) {
      setState(() {
        _showSend = true;
        _editText = value;
      });
    } else {
      setState(() {
        _showSend = false;
        _editText = "";
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _removeMsgListener();
    _controller?.dispose();
    _scrollController?.dispose();
    _getMsgAsRead(widget.username);
  }

  Future<void> _getMsgAsRead(String username) async {
    var result = await easemob.getMsgAsRead(username: username);
  }

  ///发送文本
  void _sendTextMsg() async {
    if (_editText != "") {
      String text = _editText;
      List<Widget> listMsg = new List();
      int dateNow = new DateTime.now().millisecondsSinceEpoch;
      listMsg.add(new MessageTime(time: _delTimeStamp(dateNow),));
      listMsg.add(new MessageShowMe(
        body: _editText,
        type: easemob.TYPE.TXT,
      ));
      listMsg.insertAll(0, _listMsg);
      _listMsg = listMsg;
      setState(() {
        _listMsgItem = listMsg;
        _listLength = _listMsgItem.length;
        _editText = "";
      });
      scrollToEnd();
      String result = await easemob.sendTextMessage(widget.username, text);
      print("结果："+ result);
    }
  }

  ///发送图片
  void _sendImageMsg(String path) async {
    print(path);

    scrollToEnd();
    String result = await easemob.sendImageMessage(widget.username, path);
    print(result);
    if (result == "success") {
      await easemob.getThumbPath(path);
    }
  }

  Future _chooseImageMsg() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }
    List<Widget> listMsg = new List();
    int dateNow = new DateTime.now().millisecondsSinceEpoch;
    listMsg.add(new MessageTime(time: _delTimeStamp(dateNow),));
    listMsg.add(new MessageShowMe(
      body: image.path,
      type: easemob.TYPE.IMAGE,
    ));
    listMsg.insertAll(0, _listMsg);
    _listMsg = listMsg;
    setState(() {
      _listMsgItem = listMsg;
      _listLength = listMsg.length;
    });
    _sendImageMsg(image.path);
  }

  Future _shootImageMsg() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (image == null) {
      return;
    }
    List<Widget> listMsg = new List();
    int dateNow = new DateTime.now().millisecondsSinceEpoch;
    listMsg.add(new MessageTime(time: _delTimeStamp(dateNow),));
    listMsg.add(new MessageShowMe(
      body: image.path,
      type: easemob.TYPE.IMAGE,
    ));
    listMsg.insertAll(0, _listMsg);
    _listMsg = listMsg;
    setState(() {
      _listMsgItem = listMsg;
      _listLength = listMsg.length;
    });
    _sendImageMsg(image.path);
  }

  ///键盘下菜单事件
  void _showBottomMenu() {
    setState(() {
      _showBottom = !_showBottom;
      if (_showBottom) {
        _focusNode.unfocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _controller = new TextEditingController.fromValue(TextEditingValue(
        text: _editText,
        selection: new TextSelection.fromPosition(TextPosition(
            affinity: TextAffinity.downstream,
            offset: _editText.length,
        )),
    ));
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.username}"),
      ),
      body: new Container(
        width: double.maxFinite,
        height: double.maxFinite,
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                color: Color(0xFFF6F6F6),
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: _listLength,
                  controller: _scrollController,
                  itemBuilder: (BuildContext context, int position) {
                    return _listMsgItem[position];
                  },
                ),
              ),
            ),
            new Container(
              color: Color(0xffD8D8D8),
              height: 1.0,
              width: double.maxFinite,
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0,right: 10.0,bottom: 15.0,top: 10.0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Image.asset("asset/image/chat_icon_keyboard.png",width: 28.0,),
                      Expanded(
                        flex: 1,
                        child: Container(
                          color: Colors.white,
                          width: double.maxFinite,
                          margin: EdgeInsets.symmetric(horizontal: 10.0),
                          padding: EdgeInsets.only(left: 10.0),
                          child: TextField(
                            controller: _controller,
                            minLines: 1,
                            maxLines: 10,
                            focusNode: _focusNode,
                            onEditingComplete: _sendTextMsg,
                            onChanged: _onChangeText,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              counterText: "",
                            ),
                          ),
                        ),
                      ),
                      Image.asset("asset/image/chat_icon_expression.png",width: 28.0,),
                      SizedBox(width: 10.0,),
                      _showSend
                          ? InkWell(
                        onTap: _sendTextMsg,
                        child: new Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.0,vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                          child: Center(
                            child: Text(
                              "发送",
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                          : GestureDetector(
                        onTap: () {_showBottomMenu();},
                        child: Image.asset("asset/image/chat_icon_add.png",width: 28.0,),
                      ),
                    ],
                  ),
                  Offstage(
                    offstage: !_showBottom,
                    child: Container(
                      width: double.maxFinite,
                      height: 300.0,
                      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                      child: GridView.count(
                        physics: new NeverScrollableScrollPhysics(),
                        crossAxisCount: 4,
                        mainAxisSpacing: 10.0,
                        children: <Widget>[
                          InkWell(
                            onTap: () {_chooseImageMsg();},
                            child: Column(
                              children: <Widget>[
                                new Container(
                                  width: 60.0,
                                  height: 60.0,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "图片",
                                      style: TextStyle(
                                          fontSize: 18.0
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5.0,
                                ),
                                Text(
                                  "照片",
                                  style: TextStyle(
                                      fontSize: 13.0
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {_shootImageMsg();},
                            child: Column(
                              children: <Widget>[
                                new Container(
                                  width: 60.0,
                                  height: 60.0,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "拍照",
                                      style: TextStyle(
                                          fontSize: 18.0
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5.0,
                                ),
                                Text(
                                  "拍照",
                                  style: TextStyle(
                                      fontSize: 13.0
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }

}

class MessageTime extends StatelessWidget {
  MessageTime({Key key, this.time}) : super(key: key);
  final String time;

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: EdgeInsets.only(top: 15),
      child: Center(
        child: Text(
          time,
          style: TextStyle(
            fontSize: 9.0,
            color: Color(0xFF999999),
          ),
        ),
      ),
    );
  }

}

///自己的消息体
class MessageShowMe extends StatefulWidget {
  MessageShowMe({Key key,@required this.body,this.type : easemob.TYPE.TXT}) : super(key: key);
  final String body;
  final easemob.TYPE type;

  @override
  State<StatefulWidget> createState() => new MessageShowMeState();

}

class MessageShowMeState extends State<MessageShowMe> {

  ///三角形大小
  double triangleSize = 10.0;

  @override
  Widget build(BuildContext context) {

    Widget bodyMsgTxt = new Stack(
      alignment: Alignment.topRight,
      children: <Widget>[
        new Container(
          child: new Container(
            margin: EdgeInsets.only(right: triangleSize),
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Color(0xFF6BA9F8),
            ),
            child: Text(
              widget.body,
              style: TextStyle(
                fontSize: 16.0,
                color: Color(0xFF464545),
              ),
            ),
          ),
        ),
        new Positioned(
          top: 10.0,
          right: 0,
          child: Icon(Icons.arrow_right,size: 20.0,color: Color(0xFF6BA9F8),),
        ),
      ],
    );

    Widget bodyMsgImage = new Stack(
      alignment: Alignment.topRight,
      children: <Widget>[
        new Container(
          child: Image.file(File(widget.body), width: 100.0,),
        )
      ],
    );

    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.only(left: 68),
      margin: EdgeInsets.symmetric(vertical: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: widget.type == easemob.TYPE.IMAGE ? bodyMsgImage : bodyMsgTxt,
          ),
          new Container(
            margin: EdgeInsets.only(left: 5.0, right: 10.0),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3.0),
              color: Colors.white,
            ),
            child: Icon(Icons.person_outline,size: 42,),
          )
        ],
      ),
    );
  }

}

///对方的消息体
class MessageShowFrom extends StatefulWidget {
  MessageShowFrom({Key key,@required this.body,this.type : easemob.TYPE.TXT}) : super(key: key);
  final String body;
  final easemob.TYPE type;

  @override
  State<StatefulWidget> createState() => new MessageShowFromState();

}

class MessageShowFromState extends State<MessageShowFrom> {

  ///三角形大小
  double triangleSize = 10.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    Widget bodyMsgTxt = new Stack(
      alignment: Alignment.topLeft,
      children: <Widget>[
        new Container(
          child: new Container(
            margin: EdgeInsets.only(left: triangleSize),
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Color(0xFFFFFFFF),
            ),
            child: Text(
              widget.body,
              style: TextStyle(
                fontSize: 16.0,
                color: Color(0xFF464545),
              ),
            ),
          ),
        ),
        new Positioned(
          top: 10.0,
          left: 0,
          child: Icon(Icons.arrow_left,size: 18.0,color: Color(0xFFFFFFFFFF),),
        ),
      ],
    );

    Widget bodyMsgImage = new Stack(
      alignment: Alignment.topLeft,
      children: <Widget>[
        new Container(
          child: Image.file(
            File(widget.body),
            width: 50.0,
          ),
        ),
      ],
    );

    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.only(right: 68),
      margin: EdgeInsets.symmetric(vertical: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            margin: EdgeInsets.only(left: 10.0, right: 5.0),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3.0),
              color: Colors.white,
            ),
            child: Icon(Icons.person_outline,size: 42,),
          ),
          Expanded(
            flex: 1,
            child: widget.type == easemob.TYPE.IMAGE ? bodyMsgImage : bodyMsgTxt,
          ),
        ],
      ),
    );
  }

}