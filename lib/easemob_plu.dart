import 'dart:async';

import 'package:easemob_plu/model/AdminOperation.dart';
import 'package:easemob_plu/model/AutoGroupAccept.dart';
import 'package:easemob_plu/model/CharRoom.dart';
import 'package:easemob_plu/model/ContactInvited.dart';
import 'package:easemob_plu/model/EMConversation.dart';
import 'package:easemob_plu/model/EMGroup.dart';
import 'package:easemob_plu/model/EMMessage.dart';
import 'package:easemob_plu/model/GroupInvitationDel.dart';
import 'package:easemob_plu/model/GroupMsg.dart';
import 'package:easemob_plu/model/JoinRequestDel.dart';
import 'package:easemob_plu/model/ListEMMessage.dart';
import 'package:easemob_plu/model/MemberOperation.dart';
import 'package:easemob_plu/model/OwnerChanged.dart';
import 'package:easemob_plu/model/UserRequestGroup.dart';
import 'package:flutter/services.dart';

import 'model/Contact.dart';
import 'model/GroupReceived.dart';

class EasemobPlu {

}

enum TYPE {
  TXT, IMAGE, VIDEO, LOCATION, VOICE, FILE, CMD, EMO
}

enum ChatType {
  Chat, GroupChat, ChatRoom
}

final MethodChannel _channel =
    const MethodChannel("easemob_plu")..setMethodCallHandler(_handler);

/// 初始化环信SDK
Future<String> initEaseMobPlu({
  //是否需要好友验证，不需要为true
  bool autoInvitation : true,
  //Zion给上传消息附件到环信服务器，如果false，需要自己处理附件消息的上传和下载
  bool autoTransferMessageAttachments : true,
  //是否自动下载附件类消息的缩略图等，这里与上面参数相关联
  bool autoDownloadThumbnail : true,
  //debug模式，打包时关闭，避免消耗
  bool debugMode : false,
  //首次登陆成功后，自动登录
  bool autoLogin : true,
}) async {
  String result = await _channel.invokeMethod("initEaseMob", {
    "autoInvitation" : autoInvitation,
    "autoTransferMessageAttachments" : autoTransferMessageAttachments,
    "autoDownloadThumbnail" : autoDownloadThumbnail,
    "debugMode" : debugMode,
    "autoLogin" : autoLogin,
  });
  return result;
}

/// 登录
/// 环信用户名，密码
Future login(String userName,String password) async {
  String result = await _channel.invokeMethod("EMLogin",{
    "userName" : userName,
    "password" : password,
  });
  return result;
}

/// 退出登录
Future logout() async {
  String result = await _channel.invokeMethod("EMLogout");
  return result;
}

/// 发送文本消息
Future sendTextMessage(
    //对方用户或群聊的id
    String toChatUsername,
    //内容
    String content,
    //是否是群聊，默认是单聊0，群聊为1，聊天室为2
    { int chatType : 0,}
) async {
  String result = await _channel.invokeMethod("sendTextMessage",{
    "content" : content,
    "toChatUsername" : toChatUsername,
    "chatType" : chatType,
  });
  return result;
}

/// 发送语音消息
Future sendVoiceMessage(
    String toChatUsername,
    //语音文件路径
    String filePath,
    //录音时间
    int length,
    //是否是群聊，默认是单聊0，群聊为1，聊天室为2
    { int chatType : 0,}
    ) async {
  String result = await _channel.invokeMethod("sendVoiceMessage",{
    "filePath" : filePath,
    "toChatUsername" : toChatUsername,
    "length" : length,
    "chatType" : chatType,
  });
  return result;
}

/// 发送图片消息
Future sendImageMessage(
    String toChatUsername,
    //图片本地路径
    String imagePath,
    {
      //false默认不发送原图
      bool originally : false,
      //是否是群聊，默认是单聊0，群聊为1，聊天室为2
      int chatType : 0,}
    ) async {
  String result = await _channel.invokeMethod("sendImageMessage",{
    "imagePath" : imagePath,
    "toChatUsername" : toChatUsername,
    "originally" : originally,
    "chatType" : chatType,
  });
  return result;
}

/// 保存图片缩略图
Future getThumbPath(
    //图片本地路径
    String imagePath,
    ) async {
  String result = await _channel.invokeMethod("getThumbPath",{
    "localImagePath" : imagePath,
  });
  return result;
}

/// 注册接收消息监听
Future addMessageListener() async {
  String result = await _channel.invokeMethod("addMessageListener");
  return result;
}

/// 移除接收消息监听
Future removeMessageListener() async {
  String result = await _channel.invokeMethod("removeMessageListener");
  return result;
}

/// 获取聊天记录
Future<ListEMMessage> getAllMessages(String username) async {
  var result = await _channel.invokeMethod("getAllMessages",{
    "username" : username,
  });
  print(result);
  return ListEMMessage.fromList(result);
}

/// 获取更多聊天记录
Future<ListEMMessage> getAllMessagesMore(String username, String startMsgId) async {
  var result = await _channel.invokeMethod("getAllMessagesMore",{
    "username" : username,
    "startMsgId" : startMsgId,
  });
  return ListEMMessage.fromList(result);
}

/// 获取未读消息数量
Future<int> getUnreadMsgCount(String username) async {
  int result = await _channel.invokeMethod("getUnreadMsgCount",{
    "username" : username,
  });
  return result;
}

/// 未读消息数清零
/// username为用户id或群聊id : 指定会话消息未读数清零
/// username为空 : 所有未读消息数清零
Future getMsgAsRead({String username : ""}) async {
  String result = await _channel.invokeMethod("getMsgAsRead",{
    "username" : username,
  });
  return result;
}

/// 获取消息总数
Future<int> getAllMsgCount(String username) async {
  int result = await _channel.invokeMethod("getAllMsgCount",{
    "username" : username,
  });
  return result;
}

/// 获取所有会话
Future getAllConversations() async {
  var result = await _channel.invokeMethod("getAllConversations");
  return result;
}

/// 删除会话
/// 删除某个user会话，如果需要保留聊天记录，传false
Future deleteConversation(String username, {bool isDelHistory : true}) async {
  String result = await _channel.invokeMethod("deleteConversation",{
    "username" : username,
    "isDelHistory" : isDelHistory,
  });
  return result;
}

/// 获取好友列表
/// 获取环信服务器上所有的，对应好友详情，分组等，需要到自己服务器上获取
Future<List<String>> getAllContactsFromServer() async {
  List<String> result = await _channel.invokeMethod("getAllContactsFromServer");
  return result;
}

/// 添加好友
Future addContact(
    //添加的好友的username
    String toAddUsername,
    //添加好友验证信息
    String reason,
    ) async {
  String result = await _channel.invokeMethod("addContact",{
    "toAddUsername" : toAddUsername,
    "reason" : reason,
  });
  return result;
}

/// 删除好友
Future deleteContact(String username) async {
  String result = await _channel.invokeMethod("deleteContact",{
    "username" : username,
  });
  return result;
}

/// 同意好友请求 (先设置手动同意好友请求才能使用)
Future acceptInvitation(String username) async {
  String result = await _channel.invokeMethod("acceptInvitation",{
    "username" : username,
  });
  return result;
}

/// 拒绝好友请求 (先设置手动同意好友请求才能使用)
Future declineInvitation(String username) async {
  String result = await _channel.invokeMethod("declineInvitation",{
    "username" : username,
  });
  return result;
}

/// 创建群组
/// @param groupName 群组名称
/// @param desc 群组简介
/// @param allMembers 群组初始成员，如果只有自己传空数组即可
/// @param reason 邀请成员加入的reason
/// @param option 群组类型选项，可以设置群组最大用户数(默认200)及群组类型@see {@link EMGroupStyle}
///               option.inviteNeedConfirm表示邀请对方进群是否需要对方同意。
///               option.extField创建群时可以为群组设定扩展字段，方便个性化订制。
/// @return 创建好的group
/// @throws HyphenateException
Future createNewGroup(
    String groupName,
    String desc,
    List<String> allMembers,
    {
      String reason : "",
      // 0 公开群，任何人可加入（默认）  1 公开群，群主邀请直接加入，不然得申请
      // 2 私有群，只有群主可以邀请人  3 私有群，群成员也能邀请人进群
      int groupType : 0,
      // 邀请对方进群是否需要对方同意，默认需要
      bool inviteNeedConfirm : true,
    }) async {
  String result = await _channel.invokeMethod("createGroup", {
    "groupName" : groupName,
    "desc" : desc,
    "allMembers" : allMembers,
    "reason" : reason,
    "groupType" : groupType,
    "inviteNeedConfirm" : inviteNeedConfirm,
  });
  return result;
}

/// 增加群组管理员，需要owner权限
Future addGroupAdmin(String groupId, String admin) async {
  String result = await _channel.invokeMethod("addGroupAdmin",{
    "groupId" : groupId,
    "admin" : admin,
  });
  return result;
}

/// 删除群组管理员，需要owner权限
Future removeGroupAdmin(String groupId, String admin) async {
  String result = await _channel.invokeMethod("removeGroupAdmin",{
    "groupId" : groupId,
    "admin" : admin,
  });
  return result;
}

/// 群组所有权给他人
Future changeOwner(String groupId, String newOwner) async {
  String result = await _channel.invokeMethod("changeOwner",{
    "groupId" : groupId,
    "newOwner" : newOwner,
  });
  return result;
}

/// 群组加人(群主)
Future addUsersToGroup(String groupId, List<String> newmember) async {
  String result = await _channel.invokeMethod("addUsersToGroup",{
    "groupId" : groupId,
    "newmember" : newmember,
  });
  return result;
}

/// 群组踢人
Future removeUserFromGroup(String groupId, String username) async {
  String result = await _channel.invokeMethod("removeUserFromGroup",{
    "groupId" : groupId,
    "username" : username,
  });
  return result;
}

/// 私有群里，如果开放了群成员邀请，群成员邀请调用下面方法
Future inviteUser(String groupId, List<String> newmember) async {
  String result = await _channel.invokeMethod("inviteUser",{
    "groupId" : groupId,
    "newmember" : newmember,
  });
  return result;
}

/// 加入某个群组（只能用于加入公开群）
Future joinGroup(
    String groupId,
    //根据创建群组的设置，判断是否需要申请验证
    bool needApply,
    {
      //若需要申请，填写原因
      String reason : "",
    }
    ) async {
  String result = await _channel.invokeMethod("joinGroup",{
    "groupId" : groupId,
    "needApply" : needApply,
    "reason" : reason,
  });
  return result;
}

/// 退出群组
Future leaveGroup(String groupId) async {
  String result = await _channel.invokeMethod("leaveGroup",{
    "groupId" : groupId,
  });
  return result;
}

/// 退出群组
Future destroyGroup(String groupId) async {
  String result = await _channel.invokeMethod("destroyGroup",{
    "groupId" : groupId,
  });
  return result;
}

/// 获取完整的群成员列表
Future<List<String>> fetchGroupMembers(String groupId) async {
  List<String> result = await _channel.invokeMethod("fetchGroupMembers",{
    "groupId" : groupId,
  });
  return result;
}

/// 获取群组列表
/// 从服务器获取自己加入的和创建的群组列表，此api获取的群组sdk会自动保存到内存和db。
Future<List<EMGroup>> getJoinedGroupsFromServer() async {
  // TODO 需调整
  var result = await _channel.invokeMethod("getJoinedGroupsFromServer");
  List<EMGroup> listMap = new List();
  for (int i = 0; i < result.length(); i++) {
    listMap.add(EMGroup.fromMap(result[i]));
  }
  return listMap;
}

/// 修改群组名称
Future changeGroupName(String groupId, String changedGroupName) async {
  String result = await _channel.invokeMethod("changeGroupName",{
    "groupId" : groupId,
    "changedGroupName" : changedGroupName,
  });
  return result;
}

/// 修改群组描述
Future changeGroupDescription(String groupId, String description) async {
  String result = await _channel.invokeMethod("changeGroupDescription",{
    "groupId" : groupId,
    "description" : description,
  });
  return result;
}

/// 群组信息
Future<EMGroup> getGroupFromServer(String groupId) async {
  var result = await _channel.invokeMethod("getGroupFromServer",{
    "groupId" : groupId,
  });
  return EMGroup.fromMap(result);
}

/// 注册群组事件监听
Future addGroupChangeListener() async {
  var result = await _channel.invokeMethod("addGroupChangeListener");
  return result;
}

/// 注册通话状态监听
Future addCallStateChangeListener() async {
  var result = await _channel.invokeMethod("addCallStateChangeListener");
  return result;
}

/// 拨打语音通话
Future makeVoiceCall(String username) async {
  var result = await _channel.invokeMethod("makeVoiceCall",{
    "username" : username,
  });
  return result;
}

/// 接听通话
Future answerCall() async {
  var result = await _channel.invokeMethod("answerCall");
  return result;
}

/// 拒绝接听
Future rejectCall() async {
  var result = await _channel.invokeMethod("rejectCall");
  return result;
}

/// 挂断通话
Future endCall() async {
  var result = await _channel.invokeMethod("endCall");
  return result;
}

/// 加入聊天室
Future<String> joinChatRoom(String roomId) async {
  var result = await _channel.invokeMethod("joinChatRoom",{
    "roomId" : roomId,
  });
  return result;
}

/// 离开聊天室
Future<String> leaveChatRoom(String roomId) async {
  var result = await _channel.invokeMethod("leaveChatRoom",{
    "roomId" : roomId,
  });
  return result;
}

/// 获取聊天室详情
Future<ChatRoom> getChatRoomDetail(String roomId) async {
  var result = await _channel.invokeMethod("getChatRoomDetail",{
    "roomId" : roomId,
  });
  return ChatRoom.fromMap(result);
}


/// 连接失败状态回调
/// 登录成功自动注册了监听
/// 1.账号被移除
/// 2.账号在其他设备登录
/// 3.连接不到聊天服务器
/// 4.当前网络不可用，请检查网络设置
StreamController<String> _disconnectController = new StreamController.broadcast();

Stream<String> get responseFromDisConnect => _disconnectController.stream;

/// 消息发送状态,发送后调用监听
StreamController<String> _msgSendStateController = new StreamController.broadcast();

Stream<String> get responseFromMsgSendStateListener => _msgSendStateController.stream;

/// 登录监听
StreamController<String> _loginController = new StreamController.broadcast();

Stream<String> get responseFromLogin => _loginController.stream;

/// 接收消息(仅提示是否有消息)
StreamController<ListEMMessage> _msgListenerController = new StreamController.broadcast();

Stream<ListEMMessage> get responseFromMsgListener => _msgListenerController.stream;

/// 获取会话监听（获取所有会话后使用）
StreamController<Map<String, EMConversation>> _onConversationGetController = new StreamController.broadcast();

Stream<Map<String, EMConversation>> get responseFromConversationGet => _onConversationGetController.stream;

/// 监听好友状态事件
/// 登录成功自动注册了监听
StreamController<Contact> _contactListenerController = new StreamController.broadcast();

Stream<Contact> get responseFromContactListener => _contactListenerController.stream;

/// 监听好友邀请事件
/// 登录成功自动注册了监听
StreamController<ContactInvited> _contactInvitedListenerController = new StreamController.broadcast();

Stream<ContactInvited> get responseFromContactInvitedListener => _contactInvitedListenerController.stream;

/// 接收到群组加入邀请
StreamController<GroupReceived> _onInvitationReceivedController = new StreamController.broadcast();

Stream<GroupReceived> get responseFromInvitationReceived => _onInvitationReceivedController.stream;

/// 用户申请加入群
StreamController<UserRequestGroup> _onRequestToJoinReceivedController = new StreamController.broadcast();

Stream<UserRequestGroup> get responseFromRequestToJoinReceived => _onRequestToJoinReceivedController.stream;

/// 加群申请被同意
StreamController<JoinRequestDel> _onRequestToJoinAcceptedController = new StreamController.broadcast();

Stream<JoinRequestDel> get responseFromRequestToJoinAccepted => _onRequestToJoinAcceptedController.stream;

/// 加群申请被拒绝
StreamController<JoinRequestDel> _onRequestToJoinDeclinedController = new StreamController.broadcast();

Stream<JoinRequestDel> get responseFromRequestToJoinDeclined => _onRequestToJoinDeclinedController.stream;

/// 群组邀请被同意
StreamController<GroupInvitationDel> _onInvitationAcceptedController = new StreamController.broadcast();

Stream<GroupInvitationDel> get responseFromInvitationAccepted => _onInvitationAcceptedController.stream;

/// 群组邀请被拒绝
StreamController<GroupInvitationDel> _onInvitationDeclinedController = new StreamController.broadcast();

Stream<GroupInvitationDel> get responseFromInvitationDeclined => _onInvitationDeclinedController.stream;

/// 用户被踢出群的通知
StreamController<GroupMsg> _onUserRemovedController = new StreamController.broadcast();

Stream<GroupMsg> get responseFromUserRemoved => _onUserRemovedController.stream;

/// 群解散的通知
StreamController<GroupMsg> _onGroupDestroyedController = new StreamController.broadcast();

Stream<GroupMsg> get responseFromGroupDestroyed=> _onGroupDestroyedController.stream;

/// 接收邀请时自动加入到群组的通知
StreamController<AutoGroupAccept> _onAutoAcceptInvitationFromGroupController = new StreamController.broadcast();

Stream<AutoGroupAccept> get responseFromAutoAcceptInvitationFromGroup => _onAutoAcceptInvitationFromGroupController.stream;

/// 群所有者变动通知
StreamController<OwnerChanged> _onOwnerChangedController = new StreamController.broadcast();

Stream<OwnerChanged> get responseFromOwnerChanged => _onOwnerChangedController.stream;

/// 群组加入新成员通知
StreamController<MemberOperation> _onMemberJoinedController = new StreamController.broadcast();

Stream<MemberOperation> get responseFromMemberJoined => _onMemberJoinedController.stream;

/// 群成员退出通知
StreamController<MemberOperation> _onMemberExitedController = new StreamController.broadcast();

Stream<MemberOperation> get responseMemberExited => _onMemberExitedController.stream;

/// 增加管理员的通知
StreamController<AdminOperation> _onAdminAddedController = new StreamController.broadcast();

Stream<AdminOperation> get responseFromAdminAdded => _onAdminAddedController.stream;

/// 管理员移除的通知
StreamController<AdminOperation> _onAdminRemovedController = new StreamController.broadcast();

Stream<AdminOperation> get responseFromAdminRemoved => _onAdminRemovedController.stream;

/// 通话呼入监听
/// return 拨入用户用户名
StreamController<String> _onCallReceiverController = new StreamController.broadcast();

Stream<String> get responseFromCallReceiver => _onCallReceiverController.stream;

/// 通话状态监听
/// 0 电话接通成功
/// 1 正在连接对方
/// 2 双方已经建立连接
/// 3 网络恢复正常
/// -1 电话断了   只有断了之后才能关闭通话界面（保证通话所占用的资源都释放完）
/// -2 网络不稳定
StreamController<int> _onCallStateChangeController = new StreamController.broadcast();

Stream<int> get responseFromCallStateChange => _onCallStateChangeController.stream;

///事件处理
Future<dynamic> _handler(MethodCall methodCall) {
  if ("emDisConnectListener" == methodCall.method) {
    _disconnectController.add(methodCall.arguments);
  } else if ("msgSendState" == methodCall.method) {
    _msgSendStateController.add(methodCall.arguments);
  } else if ("loginListener" == methodCall.method) {
    _loginController.add(methodCall.arguments);
  } else if ("emMsgListener" == methodCall.method) {
    _msgListenerController.add(ListEMMessage.fromList(methodCall.arguments));
  } else if ("contactListener" == methodCall.method) {
    _contactListenerController.add(Contact.fromMap(methodCall.arguments));
  } else if ("conversationGetListener" == methodCall.method) {
    Map<String, EMConversation> mapConversation = new Map();
    Iterable iterable = methodCall.arguments.keys;
    iterable.forEach((key){
      mapConversation[key] = EMConversation.fromMap(methodCall.arguments[key]);
    });
    _onConversationGetController.add(mapConversation);
  } else if ("contactInvitedListener" == methodCall.method) {
    _contactInvitedListenerController.add(ContactInvited.fromMap(methodCall.arguments));
  } else if ("onInvitationReceived" == methodCall.method) {
    _onInvitationReceivedController.add(GroupReceived.fromMap(methodCall.arguments));
  } else if ("onRequestToJoinReceived" == methodCall.method) {
    _onRequestToJoinReceivedController.add(UserRequestGroup.fromMap(methodCall.arguments));
  } else if ("onRequestToJoinAccepted" == methodCall.method) {
    _onRequestToJoinAcceptedController.add(JoinRequestDel.fromMap(methodCall.arguments));
  } else if ("onRequestToJoinDeclined" == methodCall.method) {
    _onRequestToJoinDeclinedController.add(JoinRequestDel.fromMap(methodCall.arguments));
  } else if ("onInvitationAccepted" == methodCall.method) {
    _onInvitationAcceptedController.add(GroupInvitationDel.fromMap(methodCall.arguments));
  } else if ("onInvitationDeclined" == methodCall.method) {
    _onInvitationDeclinedController.add(GroupInvitationDel.fromMap(methodCall.arguments));
  } else if ("onUserRemoved" == methodCall.method) {
    _onUserRemovedController.add(GroupMsg.fromMap(methodCall.arguments));
  } else if ("onGroupDestroyed" == methodCall.method) {
    _onGroupDestroyedController.add(GroupMsg.fromMap(methodCall.arguments));
  } else if ("onAutoAcceptInvitationFromGroup" == methodCall.method) {
    _onAutoAcceptInvitationFromGroupController.add(AutoGroupAccept.fromMap(methodCall.arguments));
  } else if ("onOwnerChanged" == methodCall.method) {
    _onOwnerChangedController.add(OwnerChanged.fromMap(methodCall.arguments));
  } else if ("onMemberJoined" == methodCall.method) {
    _onMemberJoinedController.add(MemberOperation.fromMap(methodCall.arguments));
  } else if ("onMemberExited" == methodCall.method) {
    _onMemberJoinedController.add(MemberOperation.fromMap(methodCall.arguments));
  } else if ("onAdminAdded" == methodCall.method) {
    _onAdminAddedController.add(AdminOperation.fromMap(methodCall.arguments));
  } else if ("onAdminRemoved" == methodCall.method) {
    _onAdminRemovedController.add(AdminOperation.fromMap(methodCall.arguments));
  } else if ("onCallReceive" == methodCall.method) {
    _onCallReceiverController.add(methodCall.arguments);
  } else if ("onCallStateChange" == methodCall.method) {
    _onCallStateChangeController.add(methodCall.arguments);
  }
  return Future.value(true);
}