
/// 用户入群申请
/// @author puppet
class UserRequestGroup {
  final String groupId;
  final String groupName;
  final String applicant;
  final String reason;

  UserRequestGroup.fromMap(Map map)
      : groupId = map["groupId"],
        groupName = map["groupName"],
        applicant = map["applicant"],
        reason = map["reason"];

}