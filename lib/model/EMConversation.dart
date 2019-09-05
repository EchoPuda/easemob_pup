
import 'package:easemob_plu/easemob_plu.dart';

/// 会话
/// @author puppet
///
class EMConversation {
  ///会话类型
  final ChatType chatType;
  ///消息的类型
  final TYPE type;
  ///消息本体
  final String body;
  ///会话ID
  final String conversationId;
  ///会话的未读数
  final int unReadCount;
  ///时间戳
  final int lastMsgTime;

  EMConversation.fromMap(Map map)
      : chatType = getChatType(map["chatType"]),
        type = getType(map["type"]),
        body = map["body"],
        conversationId = map["conversationId"],
        unReadCount = map["unReadCount"],
        lastMsgTime = map["lastMsgTime"];

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
ChatType getChatType(String chatType) {
  switch(chatType) {
    case "Chat":
      return ChatType.Chat;
    case "GroupChat":
      return ChatType.GroupChat;
    case "ChatRoom":
      return ChatType.ChatRoom;
    default:
      return ChatType.ChatRoom;
  }
}