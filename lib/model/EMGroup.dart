
/// 环信群组信息
/// @author puppet
class EMGroup {
  final String groupId;
  final String groupOwner;
  final String groupName;
  final String groupDescription;
  final List<dynamic> adminList;
  final int groupCount;
  final List<dynamic> members;
  final int groupMaxCount;
  final bool isMsgBlocked;

  EMGroup.fromMap(Map map)
      : groupId = map["groupId"],
        groupOwner = map["groupOwner"],
        groupName = map["groupName"],
        groupDescription = map["groupDescription"],
        adminList = map["adminList"],
        groupCount = map["groupCount"],
        members = map["members"],
        groupMaxCount = map["groupMaxCount"],
        isMsgBlocked = map["isMsgBlocked"];

}