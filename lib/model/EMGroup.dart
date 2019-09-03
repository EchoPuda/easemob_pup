
/// 环信群组信息
/// @author puppet
class EMGroup {
  final String groupId;
  final String groupOwner;
  final String groupName;
  final String groupDescription;
  final List<String> adminList;
  final int groupCount;
  final List<String> members;
  final int groupMaxCount;

  EMGroup.fromMap(Map map)
      : groupId = map["groupId"],
        groupOwner = map["groupOwner"],
        groupName = map["groupName"],
        groupDescription = map["groupDescription"],
        adminList = map["adminList"],
        groupCount = map["groupCount"],
        members = map["members"],
        groupMaxCount = map["groupMaxCount"];

}