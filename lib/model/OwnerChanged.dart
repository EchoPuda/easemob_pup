
/// 群主变化
/// @author puppet
class OwnerChanged {
  final String groupId;
  final String newOwner;
  final String oldOwner;

  OwnerChanged.fromMap(Map map)
      : groupId = map["groupId"],
        newOwner = map["newOwner"],
        oldOwner = map["oldOwner"];

}