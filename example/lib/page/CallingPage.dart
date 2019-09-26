import 'dart:async';

import 'package:flutter/material.dart';
import 'package:easemob_plu/easemob_plu.dart' as easemob;

/// 通话页面
/// @author puppet
class CallingPage extends StatefulWidget {

  CallingPage({Key key,@required this.username,this.callIn : true}) : super(key: key);
  final String username;
  final bool callIn;

  @override
  State<StatefulWidget> createState() => new CallingPageState();

}

class CallingPageState extends State<CallingPage> {

  static const duration = const Duration(seconds: 1);

  String _timeValue = "";
  Timer timer;
  bool isActive = false;
  int secondsPassed = 0;
  String statusText;
  bool isCalling = false;
  bool _mic = false;
  bool _voiceOpen = false;

  @override
  void initState() {
    super.initState();
    statusText = widget.callIn ? "邀请你进行语音通话" : "正在等待对方接收邀请";
    _addCallStateListener();
    easemob.responseFromCallStateChange.listen((result){
      switch(result) {
        case 0: {
          setState(() {
            statusText = "";
            _timeValue = "00:00";
            isCalling = true;
            isActive = true;
          });
          _resumeVoice();
          break;
        }
        case 1: {
          setState(() {
            statusText = "正在连接";
          });
          break;
        }
        case 2: {
          setState(() {
            statusText = "";
          });
          break;
        }
        case 3: {
          setState(() {
            statusText = "";
          });
          break;
        }
        case -1: {
          setState(() {
            statusText = "通话已结束";
            isActive = false;
            timer.cancel();
            Navigator.of(context).pop();
          });
          break;
        }
        case -2: {
          setState(() {
            statusText = "网络不稳定";
          });
          break;
        }
      }
    });
  }

  void handleTick() {
    if (isActive) {
      setState(() {
        secondsPassed = secondsPassed + 1; //需要更新UI
        _timeValue = _getMinutes(secondsPassed).toString().padLeft(2, "0") + ":" + _getSeconds(secondsPassed).toString().padLeft(2, "0");
      });
    }
  }

  Future<void> _addCallStateListener() async {
    var result = await easemob.addCallStateChangeListener();
  }

  int _getSeconds(int secondsPassed) {
    return secondsPassed % 60;
  }

  int _getMinutes(int secondsPassed) {
    return secondsPassed ~/ 60;
  }

  int _getHours(int secondsPassed) {
    return secondsPassed ~/ (60 * 60);
  }

  Future<void> _answerCall() async {
    var result = easemob.answerCall();
  }

  Future<void> _rejectCall() async {
    var result = easemob.rejectCall();
  }

  Future<void> _endCall() async {
    var result = easemob.endCall();
  }

  Future<void> _resumeVoice() async {
    var result = easemob.resumeVoice();
  }

  Future<void> _pauseVoice() async {
    var result = easemob.pauseVoice();
  }

  Future<void> _openSpeaker() async {
    var result = easemob.openSpeaker();
  }

  Future<void> _closeSpeaker() async {
    var result = easemob.closeSpeaker();
  }

  void _onMicChange() {
    setState(() {
      _mic = !_mic;
      if (_mic) {
        _pauseVoice();
      } else {
        _resumeVoice();
      }
    });
  }

  void _onVoiceOpen() {
    setState(() {
      _voiceOpen = !_voiceOpen;
      if (_voiceOpen) {
        _openSpeaker();
      } else {
        _closeSpeaker();
      }
    });
  }

  @override
  void dispose() async {
    super.dispose();
    await easemob.removeCallStateChangeListener();
  }

  @override
  Widget build(BuildContext context) {
    if(timer == null){
      timer = Timer.periodic(duration, (Timer t){
        handleTick();
      });
    }
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: Container(
            width: double.maxFinite,
            height: double.maxFinite,
            color: Color(0xFF15161A),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  height: 250,
                  child: Column(
                    children: <Widget>[
                      Icon(Icons.image,size: 121,),
                      SizedBox(height: 17,),
                      Text(
                        "${widget.username}",
                        style: TextStyle(
                          fontSize: 31.0,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10,),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 15.0,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20,),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20.0,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: <Widget>[
                      Text(
                        _timeValue,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 25,),
                      isCalling
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              FlatButton(
                                onPressed: () {
                                  _onMicChange();
                                },
                                child: Container(
                                  width: 66,
                                  height: 66,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white,width: 2.0),
                                    color: _mic ? Colors.white : Colors.transparent,
                                  ),
                                  child: Icon(Icons.mic_off,color: _mic ? Colors.black : Colors.white,size: 40,),
                                ),
                              ),
                              SizedBox(height: 10,),
                              Text(
                                "静音",
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              FlatButton(
                                onPressed: () {
                                  _endCall();
                                },
                                child: Container(
                                  width: 66,
                                  height: 66,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFD94A4A),
                                  ),
                                  child: Icon(Icons.call_end,color: Colors.white,size: 40,),
                                ),
                              ),
                              SizedBox(height: 10,),
                              Text(
                                "挂断",
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              FlatButton(
                                onPressed: (){
                                  _onVoiceOpen();
                                },
                                child: Container(
                                  width: 66,
                                  height: 66,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white,width: 2.0),
                                    color: _voiceOpen ? Colors.white : Colors.transparent,
                                  ),
                                  child: Icon(Icons.volume_up,color: _voiceOpen ? Colors.black : Colors.white,size: 40,),
                                ),
                              ),
                              SizedBox(height: 10,),
                              Text(
                                "免提",
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                          : widget.callIn ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              FlatButton(
                                onPressed: () {
                                  _rejectCall();
                                },
                                child: Container(
                                  width: 66,
                                  height: 66,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFD94A4A),
                                  ),
                                  child: Icon(Icons.call_end,color: Colors.white,size: 40,),
                                ),
                              ),
                              SizedBox(height: 10,),
                              Text(
                                "拒绝",
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              FlatButton(
                                onPressed: (){
                                  _answerCall();
                                },
                                child: Container(
                                  width: 66,
                                  height: 66,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF0CB20A),
                                  ),
                                  child: Icon(Icons.call_end,color: Colors.white,size: 40,),
                                ),
                              ),
                              SizedBox(height: 10,),
                              Text(
                                "接听",
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                          : Center(
                        child: Column(
                          children: <Widget>[
                            FlatButton(
                              onPressed: (){
                                _endCall();
                              },
                              child: Container(
                                width: 66,
                                height: 66,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF0CB20A),
                                ),
                                child: Icon(Icons.call_end,color: Colors.white,size: 40,),
                              ),
                            ),
                            SizedBox(height: 10,),
                            Text(
                              "取消",
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
        ),
      ),
    );
  }


}