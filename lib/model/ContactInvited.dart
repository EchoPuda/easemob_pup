
/// 好友邀请
/// @author puppet
class ContactInvited {
  final String username;
  final String reason;

  ContactInvited.fromMap(Map map)
      : username = map["username"],
        reason = map["reason"];

}