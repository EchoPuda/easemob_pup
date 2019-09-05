import 'package:easemob_plu/easemob_plu.dart';
import 'package:easemob_plu/model/EMMessage.dart';

/// 
/// @author puppet
class ListEMMessage {
  final List<EMMessage> list;

  ListEMMessage.fromList(List list)
      : list = _getListMessage(list);
}

List<EMMessage> _getListMessage(List list) {
  List<EMMessage> listMsg = new List();
  list.forEach((value) {
    listMsg.add(EMMessage.fromMap(value));
  });
  return listMsg;
}

