
/// 会话
/// @author puppet
///
class EMConversation {
  final ChatType chatType;
  final TYPE type;
  final String body;
  final String conversationId;
  final int unReadCount;
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

enum TYPE {
  TXT, IMAGE, VIDEO, LOCATION, VOICE, FILE, CMD
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

enum ChatType {
  Chat, GroupChat, ChatRoom
}