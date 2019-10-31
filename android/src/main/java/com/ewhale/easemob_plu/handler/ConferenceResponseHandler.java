package com.ewhale.easemob_plu.handler;

import com.hyphenate.EMConferenceListener;
import com.hyphenate.chat.EMConferenceMember;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

/**
 * @author Puppet
 */
public class ConferenceResponseHandler {

    private static MethodChannel channel = null;

    public static void setMethodChannel(MethodChannel channel) {
        ConferenceResponseHandler.channel = channel;
    }

    /**
     * 成员加入监听
     */
    public static void onMemberJoined(EMConferenceMember member){
        Map<String, Object> map = new HashMap<>();
        map.put("memberName",member.memberName);
        map.put("memberId",member.memberId);
        map.put("extension",member.extension);
        channel.invokeMethod("onMemberJoined", map);
    }

    /**
     * 成员退出监听
     */
    public static void onMemberExited(EMConferenceMember member){
        Map<String, Object> map = new HashMap<>();
        map.put("memberName",member.memberName);
        map.put("memberId",member.memberId);
        map.put("extension",member.extension);
        channel.invokeMethod("onMemberExited", map);
    }

    /**
     * 会议状态监听
     */
    public static void onConferenceState(EMConferenceListener.ConferenceState state){
        String confState = "";
        switch (state) {
            case STATE_NORMAL:
                confState = "STATE_NORMAL";
                break;
            case STATE_CUSTOM_MSG:
                confState = "STATE_CUSTOM_MSG";
                break;
            case STATE_AUDIO_TALKERS:
                confState = "STATE_AUDIO_TALKERS";
                break;
            case STATE_STATISTICS:
                confState = "STATE_STATISTICS";
                break;
            case STATE_POOR_QUALITY:
                confState = "STATE_POOR_QUALITY";
                break;
            case STATE_RECONNECTION:
                confState = "STATE_RECONNECTION";
                break;
            case STATE_DISCONNECTION:
                confState = "STATE_DISCONNECTION";
                break;
            case STATE_OPEN_MIC_FAIL:
                confState = "STATE_OPEN_MIC_FAIL";
                break;
            case STATE_P2P_PEER_EXIT:
                confState = "STATE_P2P_PEER_EXIT";
                break;
            case STATE_PUBLISH_SETUP:
                confState = "STATE_PUBLISH_SETUP";
                break;
            case STATE_SUBSCRIBE_SETUP:
                confState = "STATE_SUBSCRIBE_SETUP";
                break;
            case STATE_OPEN_CAMERA_FAIL:
                confState = "STATE_OPEN_CAMERA_FAIL";
                break;
            case STATE_TAKE_CAMERA_PICTURE:
                confState = "STATE_TAKE_CAMERA_PICTURE";
                break;
            default:
                confState = "error";
                break;
        }
        channel.invokeMethod("onConferenceState", confState);
    }

    /**
     * 当前说话者监听
     */
    public static void onSpeakers(List<String> speakers){
        ArrayList<String> list = new ArrayList<>(speakers);
        channel.invokeMethod("onSpeakersChange", list);
    }

    /**
     * 监听群语音邀请
     */
    public static void onReceiveInvite(String confId, String password, String extension){
        Map<String, Object> map = new HashMap<>();
        map.put("confId",confId);
        map.put("password",password);
        map.put("extension",extension);
        channel.invokeMethod("onReceiveConferenceInvite", map);
    }

}
