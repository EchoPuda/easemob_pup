package com.ewhale.easemob_plu.handler;

import android.view.View;

import com.ewhale.easemob_plu.R;
import com.ewhale.easemob_plu.utils.EaseImageUtils;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMFileMessageBody;
import com.hyphenate.chat.EMImageMessageBody;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.chat.EMTextMessageBody;
import com.hyphenate.chat.EMVoiceMessageBody;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

/**
 * 监听管理
 * @author Puppet
 */
public class EasemobResponseHandler {

    private static MethodChannel channel = null;

    public static void setMethodChannel(MethodChannel channel) {
        EasemobResponseHandler.channel = channel;
    }

    public static void emDisConnectListener(String connectState){
        channel.invokeMethod("emDisConnectListener", connectState);
    }

    public static void onMsgSendState(String states){
        channel.invokeMethod("msgSendState", states);
    }

    public static void onLoginListener(String state) {
        channel.invokeMethod("loginListener",state);
    }

    public static void onConversationGet(HashMap<String, HashMap<String, Object>> map) {
        channel.invokeMethod("conversationGetListener",map);
    }

    public static void onMessageReceived(List<EMMessage> messages){
        ArrayList<Map<String, Object>> msgList = new ArrayList<>();
        String thumbPath = "";
        for (int i = 0; i < messages.size(); i++) {
            Map<String, Object> map = new HashMap<>();
            EMMessage.ChatType chatType = messages.get(i).getChatType();
            if (chatType == EMMessage.ChatType.Chat) {
                map.put("chatType",0);
            } else if (chatType == EMMessage.ChatType.GroupChat) {
                map.put("chatType",1);
            } else {
                map.put("chatType",2);
            }
            EMMessage.Type type = messages.get(i).getType();
            switch (type) {
                case TXT:
                    map.put("type","TXT");
                    EMTextMessageBody textBody = (EMTextMessageBody) messages.get(i).getBody();
                    map.put("body",textBody.getMessage());
                    break;
                case IMAGE:
                    map.put("type","IMAGE");
                    EMImageMessageBody imgBody = (EMImageMessageBody) messages.get(i).getBody();
                    while ("".equals(thumbPath)) {
                        if (imgBody.thumbnailDownloadStatus() == EMFileMessageBody.EMDownloadStatus.DOWNLOADING ||
                                imgBody.thumbnailDownloadStatus() == EMFileMessageBody.EMDownloadStatus.PENDING) {

                        } else if(imgBody.thumbnailDownloadStatus() == EMFileMessageBody.EMDownloadStatus.FAILED){

                        } else {

                            thumbPath = imgBody.thumbnailLocalPath();
                            if (!new File(thumbPath).exists()) {
                                // to make it compatible with thumbnail received in previous version
                                thumbPath = EaseImageUtils.getThumbnailImagePath(imgBody.getLocalUrl());
                            }
                        }
                    }
                    String imagePath = EaseImageUtils.getImagePath(imgBody.getRemoteUrl());
                    map.put("body",thumbPath);
                    map.put("image",imagePath);
                    break;
                case VOICE:
                    map.put("type","VOICE");
                    EMVoiceMessageBody voiceBody = (EMVoiceMessageBody) messages.get(i).getBody();
                    map.put("body",voiceBody.getLocalUrl());
                    break;
                case CMD:
                    map.put("type","CMD");
                    break;
                case FILE:
                    map.put("type","FILE");
                    break;
                case VIDEO:
                    map.put("type","VIDEO");
                    break;
                case LOCATION:
                    map.put("type","LOCATION");
                    break;
                default:
                    break;
            }
            String msgId = messages.get(i).getMsgId();
            map.put("msgId",msgId);
            String fromUser = messages.get(i).getFrom();
            map.put("fromUser",fromUser);
            String toUser = messages.get(i).getTo();
            map.put("toUser",toUser);
            msgList.add(map);
            map.put("time",messages.get(i).getMsgTime());
            channel.invokeMethod("emMsgListener", msgList);
        }

    }

    public static void onContactListener(String username, int type){
        Map<String, Object> map = new HashMap<>();
        map.put("username", username);
        map.put("type", type);
        channel.invokeMethod("contactListener", map);
    }

    public static void onContactInvitedListener(String username, String reason){
        Map<String, String> map = new HashMap<>();
        map.put("username", username);
        map.put("reason", reason);
        channel.invokeMethod("contactInvitedListener", map);
    }

    public static void onInvitationReceived(String groupId, String groupName, String inviter, String reason){
        Map<String, String> map = new HashMap<>();
        map.put("groupId",groupId);
        map.put("groupName",groupName);
        map.put("inviter",inviter);
        map.put("reason",reason);
        channel.invokeMethod("onInvitationReceived", map);
    }

    public static void onRequestToJoinReceived(String groupId, String groupName, String applicant, String reason){
        Map<String, String> map = new HashMap<>();
        map.put("groupId",groupId);
        map.put("groupName",groupName);
        map.put("applicant",applicant);
        map.put("reason",reason);
        channel.invokeMethod("onRequestToJoinReceived", map);
    }

    public static void onRequestToJoinAccepted(String groupId, String groupName, String accepter){
        Map<String, String> map = new HashMap<>();
        map.put("groupId",groupId);
        map.put("groupName",groupName);
        map.put("admin",accepter);
        channel.invokeMethod("onRequestToJoinAccepted", map);
    }

    public static void onRequestToJoinDeclined(String groupId, String groupName, String decliner){
        Map<String, String> map = new HashMap<>();
        map.put("groupId",groupId);
        map.put("groupName",groupName);
        map.put("admin",decliner);
        channel.invokeMethod("onRequestToJoinDeclined", map);
    }

    public static void onInvitationAccepted(String groupId, String invitee, String reason){
        Map<String, String> map = new HashMap<>();
        map.put("groupId",groupId);
        map.put("invitee",invitee);
        map.put("reason",reason);
        channel.invokeMethod("onInvitationAccepted", map);
    }

    public static void onInvitationDeclined(String groupId, String invitee, String reason){
        Map<String, String> map = new HashMap<>();
        map.put("groupId",groupId);
        map.put("invitee",invitee);
        map.put("reason",reason);
        channel.invokeMethod("onInvitationDeclined", map);
    }

    public static void onUserRemoved(String groupId, String groupName){
        Map<String, String> map = new HashMap<>();
        map.put("groupId",groupId);
        map.put("groupName",groupName);
        channel.invokeMethod("onUserRemoved", map);
    }

    public static void onGroupDestroyed(String groupId, String groupName){
        Map<String, String> map = new HashMap<>();
        map.put("groupId",groupId);
        map.put("groupName",groupName);
        channel.invokeMethod("onGroupDestroyed", map);
    }

    public static void onAutoAcceptInvitationFromGroup(String groupId, String inviter, String inviteMessage){
        Map<String, String> map = new HashMap<>();
        map.put("groupId",groupId);
        map.put("inviter",inviter);
        map.put("inviteMessage",inviteMessage);
        channel.invokeMethod("onAutoAcceptInvitationFromGroup", map);
    }

    public static void onOwnerChanged(String groupId, String newOwner, String oldOwner){
        Map<String, String> map = new HashMap<>();
        map.put("groupId",groupId);
        map.put("newOwner",newOwner);
        map.put("oldOwner",oldOwner);
        channel.invokeMethod("onOwnerChanged", map);
    }

    public static void onMemberJoined(String groupId, String member){
        Map<String, String> map = new HashMap<>();
        map.put("groupId",groupId);
        map.put("member",member);
        channel.invokeMethod("onMemberJoined", map);
    }

    public static void onMemberExited(String groupId, String member){
        Map<String, String> map = new HashMap<>();
        map.put("groupId",groupId);
        map.put("member",member);
        channel.invokeMethod("onMemberExited", map);
    }

    public static void onAdminAdded(String groupId, String administrator){
        Map<String, String> map = new HashMap<>();
        map.put("groupId",groupId);
        map.put("administrator",administrator);
        channel.invokeMethod("onAdminAdded", map);
    }

    public static void onAdminRemoved(String groupId, String administrator){
        Map<String, String> map = new HashMap<>();
        map.put("groupId",groupId);
        map.put("administrator",administrator);
        channel.invokeMethod("onAdminRemoved", map);
    }

    public static void onCallReceive(String username, String type){
        channel.invokeMethod("onCallReceive", username);
    }

    public static void onCallStateChange(int callState){
        channel.invokeMethod("onCallStateChange", callState);
    }

}
