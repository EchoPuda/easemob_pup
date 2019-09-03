
/// 群基础信息
/// @author puppet
class GroupMsg {
  final String groupId;
  final String groupName;

  GroupMsg.fromMap(Map map)
      : groupId = map["groupId"],
        groupName = map["groupName"];

}