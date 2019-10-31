package com.ewhale.easemob_plu.handler;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.media.AudioManager;
import android.preference.PreferenceManager;

import com.hyphenate.EMConferenceListener;
import com.hyphenate.EMValueCallBack;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMConference;
import com.hyphenate.chat.EMConferenceManager;
import com.hyphenate.chat.EMConferenceMember;
import com.hyphenate.chat.EMConferenceStream;
import com.hyphenate.chat.EMStreamParam;
import com.hyphenate.chat.EMStreamStatistics;
import com.hyphenate.util.EMLog;
import com.hyphenate.util.EasyUtils;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

/**
 * 多人音視頻相關
 * @author Puppet
 */
public class ConferenceHandler {
    private static PluginRegistry.Registrar registrar = null;
    private static final String TAG = "conference---:";

    public static void setRegistrar(PluginRegistry.Registrar registrar) {
        ConferenceHandler.registrar = registrar;
        normalParam.setStreamType(EMConferenceStream.StreamType.NORMAL);
        normalParam.setVideoOff(true);
        normalParam.setAudioOff(false);
        audioManager = (AudioManager) registrar.activity().getSystemService(Context.AUDIO_SERVICE);
    }

    private static SharedPreferences mSharedPreferences;

    private static EMConference conference;
    private static EMStreamParam normalParam = new EMStreamParam();
    private static List<EMConferenceStream> streamList = new ArrayList<>();
    private static AudioManager audioManager;

    /**
     * 作为创建者创建并加入会议
     */
    public static void createAndJoinConference(MethodCall call, MethodChannel.Result result) {
        boolean record = mSharedPreferences.getBoolean("shared_key_setting_record_on_server", false);
        boolean merge = mSharedPreferences.getBoolean("shared_key_setting_merge_stream", false);

        String password = call.argument("password");

        EMClient.getInstance().conferenceManager().createAndJoinConference(EMConferenceManager.EMConferenceType.LargeCommunication,
                password, record, merge, new EMValueCallBack<EMConference>() {
                    @Override
                    public void onSuccess(EMConference value) {
                        EMLog.e(TAG, "create and join conference success");
                        conference = value;
                        startAudioTalkingMonitor();
                        registrar.activity().runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                result.success(value.getConferenceId() + ":" + value.getPassword() + ":" + value.getExtension());
                            }
                        });
                    }

                    @Override
                    public void onError(int error, String errorMsg) {
                        EMLog.e(TAG, "Create and join conference failed error " + error + ", msg " + errorMsg);
                        registrar.activity().runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                result.success("error");
                            }
                        });
                    }
                });
    }

    /**
     * 作为成员直接根据 confId 和 password 加入会议
     */
    public static void joinConference(MethodCall call, MethodChannel.Result result) {
        String confId = call.argument("confId");
        String password = call.argument("password");
        EMClient.getInstance().conferenceManager().joinConference(confId, password, new EMValueCallBack<EMConference>() {
            @Override
            public void onSuccess(EMConference value) {
                conference = value;
                startAudioTalkingMonitor();
                registrar.activity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        result.success("success");
                    }
                });
            }

            @Override
            public void onError(int error, String errorMsg) {
                EMLog.e(TAG, "Create and join conference failed error " + error + ", msg " + errorMsg);
                registrar.activity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        result.success("error");
                    }
                });
            }
        });
    }

    /**
     * 退出会议
     */
    public static void exitConference(MethodCall call, MethodChannel.Result result) {
        stopAudioTalkingMonitor();
        conference = null;

        EMClient.getInstance().conferenceManager().exitConference(new EMValueCallBack() {
            @Override
            public void onSuccess(Object value) {
                EMLog.e(TAG, "leave conference success");
            }

            @Override
            public void onError(int error, String errorMsg) {
                EMLog.e(TAG, "exit conference failed " + error + ", " + errorMsg);
            }
        });
    }

    /**
     * 语音开
     */
    public static void openVoiceTransfer(MethodCall call, MethodChannel.Result result) {
        EMClient.getInstance().conferenceManager().openVoiceTransfer();
    }

    /**
     * 语音關
     */
    public static void closeVoiceTransfer(MethodCall call, MethodChannel.Result result) {
        EMClient.getInstance().conferenceManager().closeVoiceTransfer();
    }

    /**
     * 打开扬声器
     * 主要是通过扬声器的开关以及设置音频播放模式来实现
     * 1、MODE_NORMAL：是正常模式，一般用于外放音频
     * 2、MODE_IN_CALL：
     * 3、MODE_IN_COMMUNICATION：这个和 CALL 都表示通讯模式，不过 CALL 在华为上不好使，故使用 COMMUNICATION
     * 4、MODE_RINGTONE：铃声模式
     */
    public static void openSpeaker(MethodCall call, MethodChannel.Result result) {
        // 检查是否已经开启扬声器
        if (!audioManager.isSpeakerphoneOn()) {
            // 打开扬声器
            audioManager.setSpeakerphoneOn(true);
        }
        // 开启了扬声器之后，因为是进行通话，声音的模式也要设置成通讯模式
        audioManager.setMode(AudioManager.MODE_IN_COMMUNICATION);
        result.success("success");
    }

    /**
     * 关闭扬声器，即开启听筒播放模式
     */
    public static void closeSpeaker(MethodCall call, MethodChannel.Result result) {
        // 检查是否已经开启扬声器
        if (audioManager.isSpeakerphoneOn()) {
            // 关闭扬声器
            audioManager.setSpeakerphoneOn(false);
        }
        // 设置声音模式为通讯模式
        audioManager.setMode(AudioManager.MODE_IN_COMMUNICATION);
        result.success("success");
    }

    /**
     * 获取会议信息
     */
    public static void getConferenceMsg(MethodCall call, MethodChannel.Result result) {
        Map<String, Object> map = new HashMap<>();
        if (conference == null || conference.getConferenceId() == null) {
            map.put("confId","");
            map.put("password","");
            map.put("extension","");
        } else  {
            map.put("confId",conference.getConferenceId());
            map.put("password",conference.getPassword());
            map.put("extension",conference.getExtension());
        }

        if (conference.getConferenceType() == EMConferenceManager.EMConferenceType.LargeCommunication) {
            map.put("conferenceType","largeCommunication");
        } else if (conference.getConferenceType() == EMConferenceManager.EMConferenceType.SmallCommunication) {
            map.put("conferenceType","smallCommunication");
        } else {
            map.put("conferenceType","LiveStream");
        }
        map.put("memberNum",conference.getMemberNum());
        ArrayList<String> list = new ArrayList<String>();
        if (conference.getSpeakers() != null) {
            list.addAll(Arrays.asList(conference.getSpeakers()));
        }
        map.put("speakers",list);
        result.success(map);
    }


    private static void addSelfToList() {
        EMConferenceStream localStream = new EMConferenceStream();
        localStream.setUsername(EMClient.getInstance().getCurrentUser());
        localStream.setStreamId("local-stream");
        streamList.add(localStream);
    }

    /**
     * 打开麦克风监听
     */
    private static void startAudioTalkingMonitor() {
        EMClient.getInstance().conferenceManager().startMonitorSpeaker(300);
    }

    /**
     * 关闭麦克风监听
     */
    private static void stopAudioTalkingMonitor() {
        EMClient.getInstance().conferenceManager().stopMonitorSpeaker();
    }


    ///------------------------------监听事件
    /**
     * 添加会议监听
     */
    public static void addConferenceListener(MethodCall call, MethodChannel.Result result) {
        EMClient.getInstance().conferenceManager().addConferenceListener(new EMConferenceListener() {
            @Override
            public void onMemberJoined(EMConferenceMember member) {
                ConferenceResponseHandler.onMemberJoined(member);
            }

            @Override
            public void onMemberExited(EMConferenceMember member) {
                ConferenceResponseHandler.onMemberExited(member);
            }

            @Override
            public void onStreamAdded(EMConferenceStream stream) {

            }

            @Override
            public void onStreamRemoved(EMConferenceStream stream) {

            }

            @Override
            public void onStreamUpdate(EMConferenceStream stream) {

            }

            @Override
            public void onPassiveLeave(int error, String message) {

            }

            @Override
            public void onConferenceState(ConferenceState state) {
                ConferenceResponseHandler.onConferenceState(state);
            }

            @Override
            public void onStreamStatistics(EMStreamStatistics statistics) {

            }

            @Override
            public void onStreamSetup(String streamId) {

            }

            @Override
            public void onSpeakers(List<String> speakers) {
                ConferenceResponseHandler.onSpeakers(speakers);
            }

            @Override
            public void onReceiveInvite(String confId, String password, String extension) {
                ConferenceResponseHandler.onReceiveInvite(confId,password,extension);
            }

            @Override
            public void onRoleChanged(EMConferenceManager.EMConferenceRole role) {

            }
        });
    }


}
