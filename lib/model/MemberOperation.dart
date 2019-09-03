
/// 环信群组信息
/// @author puppet
class MemberOperation {
  final String groupId;
  final String member;

  MemberOperation.fromMap(Map map)
      : groupId = map["groupId"],
        member = map["member"];
}