
/// 
/// @author puppet
class ImageMsg {
  final String messageId;
  final String image;
  final String body;

  ImageMsg.fromMap(Map map)
      : messageId = map["messageId"],
        image = map["image"],
        body = map["body"];
}