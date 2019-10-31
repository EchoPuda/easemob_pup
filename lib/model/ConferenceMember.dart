
/// 会议成员
/// @author puppet
class ConferenceMember {
  String memberName;
  String memberId;
  String extension;

  ConferenceMember.formMap(Map map)
      : memberName = map["memberName"],
        memberId = map["memberId"],
        extension = map["extension"];
}