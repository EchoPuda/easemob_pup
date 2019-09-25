import 'package:flutter/material.dart';
import 'package:easemob_plu/easemob_plu.dart' as easemob;

/// 通话页面
/// @author puppet
class CallingPage extends StatefulWidget {

  CallingPage({Key key,this.username}) : super(key: key);
  final String username;

  @override
  State<StatefulWidget> createState() => new CallingPageState();

}

class CallingPageState extends State<CallingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    "邀请你语音通话",
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
                    "00:00",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 25,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Container(
                            width: 66,
                            height: 66,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFD94A4A),
                            ),
                            child: Icon(Icons.call_end,color: Colors.white,size: 40,),
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
                          Container(
                            width: 66,
                            height: 66,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF0CB20A),
                            ),
                            child: Icon(Icons.call_end,color: Colors.white,size: 40,),
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
                  ),
                ],
              ),
            ),
          ],
        )
      ),
    );
  }


}