
/// 自动加入到群组
/// @author puppet
class AutoGroupAccept {
  final String groupId;
  final String inviter;
  final String inviteMessage;

  AutoGroupAccept.fromMap(Map map)
      : groupId = map["groupId"],
        inviter = map["inviter"],
        inviteMessage = map["inviteMessage"];

}