
/// 群组邀请处理
/// @author puppet
class GroupInvitationDel {
  final String groupId;
  final String invitee;
  final String reason;

  GroupInvitationDel.fromMap(Map map)
      : groupId = map["groupId"],
        invitee = map["invitee"],
        reason = map["reason"];

}