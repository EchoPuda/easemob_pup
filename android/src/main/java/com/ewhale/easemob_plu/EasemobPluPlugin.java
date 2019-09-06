package com.ewhale.easemob_plu;

import com.ewhale.easemob_plu.handler.EasemobHandler;
import com.ewhale.easemob_plu.handler.EasemobRequestHandler;
import com.ewhale.easemob_plu.handler.EasemobResponseHandler;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * EasemobPluPlugin
 * @author Puppet
 */
public class EasemobPluPlugin implements MethodCallHandler {

  Registrar registrar;
  MethodChannel channel;

  private EasemobPluPlugin(Registrar registrar, MethodChannel channel) {
    this.registrar = registrar;
    this.channel = channel;
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "easemob_plu");
    EasemobHandler.setRegistrar(registrar);
    EasemobRequestHandler.setRegistrar(registrar);
    EasemobResponseHandler.setMethodChannel(channel);
    channel.setMethodCallHandler(new EasemobPluPlugin(registrar, channel));
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("initEaseMob")) {
      EasemobHandler.initEaseMob(call,result);
    } else if (call.method.equals("EMLogin")) {
      EasemobHandler.login(call,result);
    } else if (call.method.equals("EMLogout")) {
      EasemobHandler.logout(call,result);
    } else if (call.method.equals("sendTextMessage")) {
      EasemobHandler.sendTextMessage(call,result);
    } else if (call.method.equals("sendVoiceMessage")) {
      EasemobHandler.sendVoiceMessage(call,result);
    } else if (call.method.equals("sendImageMessage")) {
      EasemobHandler.sendImageMessage(call,result);
    } else if (call.method.equals("addMessageListener")) {
      EasemobHandler.addMessageListener(call,result);
    } else if (call.method.equals("removeMessageListener")) {
      EasemobHandler.removeMessageListener(call,result);
    } else if (call.method.equals("getAllMessages")) {
      EasemobHandler.getAllMessages(call,result);
    } else if (call.method.equals("getAllMessagesMore")) {
      EasemobHandler.getAllMessagesMore(call,result);
    } else if (call.method.equals("getUnreadMsgCount")) {
      EasemobHandler.getUnreadMsgCount(call,result);
    } else if (call.method.equals("getMsgAsRead")) {
      EasemobHandler.getMsgAsRead(call,result);
    } else if (call.method.equals("getAllMsgCount")) {
      EasemobHandler.getAllMsgCount(call,result);
    } else if (call.method.equals("getAllConversations")) {
      EasemobHandler.getAllConversations(call,result);
    } else if (call.method.equals("deleteConversation")) {
      EasemobHandler.deleteConversation(call,result);
    } else if (call.method.equals("getAllContactsFromServer")) {
      EasemobHandler.getAllContactsFromServer(call,result);
    } else if (call.method.equals("addContact")) {
      EasemobHandler.addContact(call,result);
    } else if (call.method.equals("deleteContact")) {
      EasemobHandler.deleteContact(call,result);
    } else if (call.method.equals("acceptInvitation")) {
      EasemobHandler.acceptInvitation(call,result);
    } else if (call.method.equals("declineInvitation")) {
      EasemobHandler.declineInvitation(call,result);
    } else if (call.method.equals("createGroup")) {
        EasemobHandler.createGroup(call,result);
    } else if (call.method.equals("addGroupAdmin")) {
        EasemobHandler.addGroupAdmin(call,result);
    } else if (call.method.equals("removeGroupAdmin")) {
        EasemobHandler.removeGroupAdmin(call,result);
    } else if (call.method.equals("changeOwner")) {
        EasemobHandler.changeOwner(call,result);
    } else if (call.method.equals("addUsersToGroup")) {
        EasemobHandler.addUsersToGroup(call,result);
    } else if (call.method.equals("removeUserFromGroup")) {
        EasemobHandler.removeUserFromGroup(call,result);
    } else if (call.method.equals("inviteUser")) {
        EasemobHandler.inviteUser(call,result);
    } else if (call.method.equals("joinGroup")) {
        EasemobHandler.joinGroup(call,result);
    } else if (call.method.equals("leaveGroup")) {
        EasemobHandler.leaveGroup(call,result);
    } else if (call.method.equals("destroyGroup")) {
        EasemobHandler.destroyGroup(call,result);
    } else if (call.method.equals("fetchGroupMembers")) {
        EasemobHandler.fetchGroupMembers(call,result);
    } else if (call.method.equals("getJoinedGroupsFromServer")) {
        EasemobHandler.getJoinedGroupsFromServer(call,result);
    } else if (call.method.equals("changeGroupName")) {
        EasemobHandler.changeGroupName(call,result);
    } else if (call.method.equals("changeGroupDescription")) {
        EasemobHandler.changeGroupDescription(call,result);
    } else if (call.method.equals("getGroupFromServer")) {
        EasemobHandler.getGroupFromServer(call,result);
    } else if (call.method.equals("addGroupChangeListener")) {
        EasemobHandler.addGroupChangeListener(call,result);
    } else if (call.method.equals("addCallStateChangeListener")) {
        EasemobHandler.addCallStateChangeListener(call,result);
    } else if (call.method.equals("makeVoiceCall")) {
        EasemobHandler.makeVoiceCall(call, result);
    } else if (call.method.equals("answerCall")) {
        EasemobHandler.answerCall(call, result);
    } else if (call.method.equals("rejectCall")) {
        EasemobHandler.rejectCall(call, result);
    } else if (call.method.equals("endCall")) {
        EasemobHandler.endCall(call, result);
    } else if (call.method.equals("getThumbPath")) {
        EasemobHandler.getThumbPath(call, result);
    } else if (call.method.equals("joinChatRoom")) {
        EasemobHandler.joinChatRoom(call, result);
    } else if (call.method.equals("leaveChatRoom")) {
        EasemobHandler.leaveChatRoom(call, result);
    } else if (call.method.equals("getChatRoomDetail")) {
        EasemobHandler.getChatRoomDetail(call, result);
    } else {
      result.notImplemented();
    }
  }
}
