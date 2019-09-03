
/// 环信群组信息
/// @author puppet
class AdminOperation {
  final String groupId;
  final String administrator;

  AdminOperation.fromMap(Map map)
      : groupId = map["groupId"],
        administrator = map["administrator"];
}