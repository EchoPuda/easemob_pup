import 'package:easemob_plu/easemob_plu.dart';

/// 消息实体
/// @author puppet
class EMMessage {
  final ChatType chatType;
  final TYPE type;
  final String body;
  /// 类型为图片时原图地址
  final String image;
  /// 类型为语音时的语音时长（秒）
  final int soundLength;
  final String msgId;
  final String fromUser;
  final String toUser;
  final int time;
  final String error;
  final String extra;

  EMMessage.fromMap(Map map)
      : chatType = getChatType(map["chatType"]),
        type = getType(map["type"]),
        body = map["body"],
        image = map["image"],
        soundLength = map["soundLength"],
        msgId = map["msgId"],
        fromUser = map["fromUser"],
        time = map["time"],
        error = map["error"],
        extra = map["extra"],
        toUser = map["toUser"];

}

/// 消息类型：文本，图片，视频，位置，语音，文件,透传消息
TYPE getType(String type) {
  switch(type) {
    case "TXT":
      return TYPE.TXT;
    case "IMAGE":
      return TYPE.IMAGE;
    case "VIDEO":
      return TYPE.VIDEO;
    case "LOCATION":
      return TYPE.LOCATION;
    case "VOICE":
      return TYPE.VOICE;
    case "FILE":
      return TYPE.FILE;
    case "CMD":
      return TYPE.CMD;
    default:
      return TYPE.TXT;
  }
}

/// 会话类型 ： 单聊 、群聊 、聊天室
ChatType getChatType(int chatType) {
  switch(chatType) {
    case 0:
      return ChatType.Chat;
    case 1:
      return ChatType.GroupChat;
    case 2:
      return ChatType.ChatRoom;
    default:
      return ChatType.ChatRoom;
  }
}