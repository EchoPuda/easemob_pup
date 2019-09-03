
/// 加群申请处理
/// @author puppet
class JoinRequestDel {
  final String groupId;
  final String groupName;
  final String admin;

  JoinRequestDel.fromMap(Map map)
      : groupId = map["groupId"],
        groupName = map["groupName"],
        admin = map["admin"];

}