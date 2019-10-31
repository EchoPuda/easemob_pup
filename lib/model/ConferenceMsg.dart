
/// 会议详情
/// @author puppet
class ConferenceMsg {
  String confId;
  String password;
  String extension;
  String conferenceType;
  int memberNum;
  List<String> speakers;

  ConferenceMsg.fromMap(Map map)
      : confId = map["confId"],
        password = map["password"],
        extension = map["extension"],
        conferenceType = map["conferenceType"],
        memberNum = map["memberNum"],
        speakers = _getSpeakers(map["speakers"]);

}

List<String> _getSpeakers(List list) {
  List<String> listS = new List();
  list.forEach((e){
    listS.add(e);
  });
  return listS;
}