
/// 好友事件
/// @author puppet
class Contact {
  final String username;
  /// 0 ：增加了联系人
  /// 1 ：被删除
  /// 2 ：好友请求被同意
  /// 3 ：好友请求被拒绝
  final int type;

  Contact.fromMap(Map map)
      : username = map["username"],
        type = map["type"];

}