
/// 
/// @author puppet
class ConferenceInviteMsg {
  String confId;
  String password;
  String extension;

  ConferenceInviteMsg.formMap(Map map)
      : confId = map["confId"],
        password = map["password"],
        extension = map["extension"];
}