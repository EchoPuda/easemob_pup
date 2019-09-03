
/// 群组邀请
/// @author puppet
class GroupReceived {
  final String groupId;
  final String groupName;
  final String inviter;
  final String reason;

  GroupReceived.fromMap(Map map)
      : groupId = map["groupId"],
        groupName = map["groupName"],
        inviter = map["inviter"],
        reason = map["reason"];

}