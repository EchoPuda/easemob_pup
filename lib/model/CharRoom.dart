
/// 聊天室详情
/// @author puppet
class ChatRoom {
  final String roomName;
  final String id;
  final String description;
  final String owner;
  final String announcement;
  final int memberCount;

  ChatRoom.fromMap(Map map)
      : roomName = map["roomName"],
        id = map["id"],
        description = map["description"],
        owner = map["owner"],
        announcement = map["announcement"],
        memberCount = map["memberCount"];

}