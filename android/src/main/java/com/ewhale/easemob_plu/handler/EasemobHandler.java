package com.ewhale.easemob_plu.handler;

import android.app.ActivityManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;

import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import android.text.TextUtils;

import com.ewhale.easemob_plu.utils.EaseImageUtils;
import com.hyphenate.EMCallBack;
import com.hyphenate.EMConnectionListener;
import com.hyphenate.EMContactListener;
import com.hyphenate.EMError;
import com.hyphenate.EMGroupChangeListener;
import com.hyphenate.EMMessageListener;
import com.hyphenate.EMValueCallBack;
import com.hyphenate.chat.EMCallStateChangeListener;
import com.hyphenate.chat.EMChatRoom;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMCursorResult;
import com.hyphenate.chat.EMGroup;
import com.hyphenate.chat.EMGroupManager;
import com.hyphenate.chat.EMGroupOptions;
import com.hyphenate.chat.EMImageMessageBody;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.chat.EMMucSharedFile;
import com.hyphenate.chat.EMOptions;
import com.hyphenate.chat.EMTextMessageBody;
import com.hyphenate.chat.EMVoiceMessageBody;
import com.hyphenate.exceptions.EMNoActiveCallException;
import com.hyphenate.exceptions.EMServiceNotReadyException;
import com.hyphenate.exceptions.HyphenateException;
import com.hyphenate.util.NetUtils;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import io.flutter.Log;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

import static android.content.Context.ACTIVITY_SERVICE;
import static com.hyphenate.chat.EMClient.TAG;

/**
 * 请求方法处理
 * @author Puppet
 */
public class EasemobHandler {

    private static PluginRegistry.Registrar registrar = null;

    public static void setRegistrar(PluginRegistry.Registrar registrar) {
        EasemobHandler.registrar = registrar;
    }

    private static LocalBroadcastManager broadcastManager;
    private static CallReceiver callReceiver = new CallReceiver();

    /**
     * 初始化环信
     */
    public static void initEaseMob(MethodCall call, MethodChannel.Result result) {
        broadcastManager = LocalBroadcastManager.getInstance(registrar.context());
        EMOptions options = new EMOptions();
        options.setAcceptInvitationAlways((boolean) call.argument("autoInvitation"));
        options.setAutoTransferMessageAttachments((boolean) call.argument("autoTransferMessageAttachments"));
        options.setAutoDownloadThumbnail((boolean) call.argument("autoDownloadThumbnail"));
        options.setAutoLogin((boolean) call.argument("autoLogin"));

        int pid = android.os.Process.myPid();
        String processAppName = getAppName(pid);
        // 如果APP启用了远程的service，此application:onCreate会被调用2次
        // 为了防止环信SDK被初始化2次，加此判断会保证SDK被初始化1次
        // 默认的APP会在以包名为默认的process name下运行，如果查到的process name不是APP的process name就立即返回
        if (processAppName == null || !processAppName.equalsIgnoreCase(registrar.context().getPackageName())) {
            Log.e(TAG, "enter the service process!");
            //则此application:onCreate 是被service 调用的，直接返回
            return;
        }

        //初始化
        EMClient.getInstance().init(registrar.context(),options);
        EMClient.getInstance().setDebugMode((boolean) call.argument("debugMode"));
        result.success("success");
    }

    private static String getAppName(int pID) {
        String processName = null;
        ActivityManager am = (ActivityManager) registrar.context().getSystemService(ACTIVITY_SERVICE);
        List l = am.getRunningAppProcesses();
        Iterator i = l.iterator();
        PackageManager pm = registrar.context().getPackageManager();
        while (i.hasNext()) {
            ActivityManager.RunningAppProcessInfo info = (ActivityManager.RunningAppProcessInfo) (i.next());
            try {
                if (info.pid == pID) {
                    processName = info.processName;
                    return processName;
                }
            } catch (Exception e) {

            }
        }
        return processName;
    }

    /**
     * 登录
     * @param call 用户名，密码
     * @param result 成功，失败
     */
    public static void login(MethodCall call, MethodChannel.Result result) {
        EMClient.getInstance().login(call.argument("userName"), call.argument("password"), new EMCallBack() {
            @Override
            public void onSuccess() {
                EMClient.getInstance().groupManager().loadAllGroups();
                EMClient.getInstance().chatManager().loadAllConversations();
                Log.d("main", "登录聊天服务器成功！");
                registrar.activity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        EasemobResponseHandler.onLoginListener("success");
                    }
                });


                EMClient.getInstance().addConnectionListener(new MyConnectionListener());
                EMClient.getInstance().contactManager().setContactListener(new EMContactListener() {
                    @Override
                    public void onContactAdded(String username) {
                        //增加了联系人时回调此方法
                        EasemobResponseHandler.onContactListener(username,0);
                    }

                    @Override
                    public void onContactDeleted(String username) {
                        //被删除时回调此方法
                        EasemobResponseHandler.onContactListener(username,1);
                    }

                    @Override
                    public void onContactInvited(String username, String reason) {
                        //收到好友邀请
                        EasemobResponseHandler.onContactInvitedListener(username,reason);
                    }

                    @Override
                    public void onFriendRequestAccepted(String username) {
                        //好友请求被同意
                        EasemobResponseHandler.onContactListener(username,2);
                    }

                    @Override
                    public void onFriendRequestDeclined(String username) {
                        //好友请求被拒绝
                        EasemobResponseHandler.onContactListener(username,3);
                    }
                });

                IntentFilter callFilter = new IntentFilter(EMClient.getInstance().callManager().getIncomingCallBroadcastAction());
                broadcastManager.registerReceiver(callReceiver, callFilter);

            }

            @Override
            public void onError(int code, String error) {
                Log.d("main", "登录聊天服务器失败！");
                registrar.activity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        EasemobResponseHandler.onLoginListener("error");
                    }
                });
            }

            @Override
            public void onProgress(int progress, String status) {

            }
        });
    }

    private static class CallReceiver extends BroadcastReceiver {

        @Override
        public void onReceive(Context context, Intent intent) {
            // 拨打方username
            String from = intent.getStringExtra("from");
            // call type
            String type = intent.getStringExtra("type");
            //跳转到通话页面
            EasemobResponseHandler.onCallReceive(from,type);

        }
    }

    private static void unregisterBroadcastReceiver() {
        broadcastManager.unregisterReceiver(callReceiver);
    }

    /**
     * 连接状态监听
     */
    private static class MyConnectionListener implements EMConnectionListener {

        @Override
        public void onConnected() {
            Log.d("main", "连接成功！");
        }

        @Override
        public void onDisconnected(int errorCode) {
            registrar.activity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if(errorCode == EMError.USER_REMOVED){
                        // 显示帐号已经被移除
                        EasemobResponseHandler.emDisConnectListener("帐号已经被移除");
                    }else if (errorCode == EMError.USER_LOGIN_ANOTHER_DEVICE) {
                        // 显示帐号在其他设备登录
                        EasemobResponseHandler.emDisConnectListener("帐号在其他设备登录");
                    } else {
                        if (NetUtils.hasNetwork(registrar.context())){
                            //连接不到聊天服务器
                            EasemobResponseHandler.emDisConnectListener("连接不到聊天服务器");
                        } else {
                            //当前网络不可用，请检查网络设置
                            EasemobResponseHandler.emDisConnectListener("当前网络不可用，请检查网络设置");
                        }
                    }
                }
            });

        }
    }

    /**
     * 退出登录
     */
    public static void logout(MethodCall call, MethodChannel.Result result) {
        unregisterBroadcastReceiver();
        EMClient.getInstance().logout(true);
    }

    /**
     * 发送文本消息
     */
    public static void sendTextMessage(MethodCall call, MethodChannel.Result result) {
        //创建一条文本消息，content为消息文字内容，toChatUsername为对方用户或者群聊的id，后文皆是如此
        String text = call.argument("content");
        assert text != null;
        EMMessage message = EMMessage.createTxtSendMessage(text, call.argument("toChatUsername"));
        //如果是群聊1或聊天室2，设置chattype，默认是单聊0
        int chatType = (int)call.argument("chatType");
        if (chatType == 1){
            message.setChatType(EMMessage.ChatType.GroupChat);
        } else if (chatType == 2) {
            message.setChatType(EMMessage.ChatType.ChatRoom);
        }
        //发送消息
        EMClient.getInstance().chatManager().sendMessage(message);
        message.setMessageStatusCallback(new EMCallBack() {
            @Override
            public void onSuccess() {
                registrar.activity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        EasemobResponseHandler.onMsgSendState("success");
                        result.success("success");
                    }
                });
            }

            @Override
            public void onError(int code, String error) {
                registrar.activity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        EasemobResponseHandler.onMsgSendState("error");
                        result.success("error");
                    }
                });
            }

            @Override
            public void onProgress(int progress, String status) {

            }
        });
    }

    /**
     * 发送语音消息
     */
    public static void sendVoiceMessage(MethodCall call, MethodChannel.Result result) {
        //filePath为语音文件路径，length为录音时间(秒)
        String filePath = call.argument("filePath");
        int length = (int)call.argument("length");
        assert filePath != null;
        EMMessage message = EMMessage.createVoiceSendMessage(filePath, length, call.argument("toChatUsername"));
        //如果是群聊1或聊天室2，设置chattype，默认是单聊0
        int chatType = (int)call.argument("chatType");
        if (chatType == 1){
            message.setChatType(EMMessage.ChatType.GroupChat);
        } else if (chatType == 2) {
            message.setChatType(EMMessage.ChatType.ChatRoom);
        }
        //发送消息
        EMClient.getInstance().chatManager().sendMessage(message);
        message.setMessageStatusCallback(new EMCallBack() {
            @Override
            public void onSuccess() {
                registrar.activity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        EasemobResponseHandler.onMsgSendState("success");
                        result.success("success");
                    }
                });
            }

            @Override
            public void onError(int code, String error) {
                registrar.activity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        EasemobResponseHandler.onMsgSendState("error");
                        result.success("error");
                    }
                });
            }

            @Override
            public void onProgress(int progress, String status) {

            }
        });
    }

    /**
     * 发送图片消息
     */
    public static void sendImageMessage(MethodCall call, MethodChannel.Result result) {
        //imagePath为图片本地路径，false为不发送原图（默认超过100k的图片会压缩后发给对方），需要发送原图传true
        String imagePath = call.argument("imagePath");
        assert imagePath != null;
        boolean originally;
        if (call.argument("originally") != null) {
            originally = (boolean)call.argument("originally");
        } else {
            originally = false;
        }

        EMMessage message = EMMessage.createImageSendMessage(imagePath, originally, call.argument("toChatUsername"));
        //如果是群聊1或聊天室2，设置chattype，默认是单聊0
        int chatType = (int)call.argument("chatType");
        if (chatType == 1){
            message.setChatType(EMMessage.ChatType.GroupChat);
        } else if (chatType == 2) {
            message.setChatType(EMMessage.ChatType.ChatRoom);
        }
        //发送消息
        EMClient.getInstance().chatManager().sendMessage(message);
        message.setMessageStatusCallback(new EMCallBack() {
            @Override
            public void onSuccess() {

                registrar.activity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        EasemobResponseHandler.onMsgSendState("success");
                        result.success("success");
                    }
                });

            }

            @Override
            public void onError(int code, String error) {

                registrar.activity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        EasemobResponseHandler.onMsgSendState("error");
                        result.success("error");
                    }
                });

            }

            @Override
            public void onProgress(int progress, String status) {

            }
        });
    }

    /**
     * 注册接收消息监听
     */
    public static void addMessageListener(MethodCall call, MethodChannel.Result result) {
        EMClient.getInstance().chatManager().addMessageListener(msgListener);
    }

    private static EMMessageListener msgListener = new EMMessageListener() {

        @Override
        public void onMessageReceived(List<EMMessage> messages) {
            //收到消息
            registrar.activity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    EasemobResponseHandler.onMessageReceived(messages);
                }
            });
        }

        @Override
        public void onCmdMessageReceived(List<EMMessage> messages) {
            //收到透传消息
            registrar.activity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    EasemobResponseHandler.onMessageReceived(messages);
                }
            });
        }

        @Override
        public void onMessageRead(List<EMMessage> messages) {
            //收到已读回执
        }

        @Override
        public void onMessageDelivered(List<EMMessage> message) {
            //收到已送达回执
        }
        @Override
        public void onMessageRecalled(List<EMMessage> messages) {
            //消息被撤回
        }

        @Override
        public void onMessageChanged(EMMessage message, Object change) {
            //消息状态变动
        }
    };


    /**
     * 移除接收消息监听
     */
    public static void removeMessageListener(MethodCall call, MethodChannel.Result result) {
        EMClient.getInstance().chatManager().removeMessageListener(msgListener);
    }

    public static void getThumbPath(MethodCall call, MethodChannel.Result result) {
        String localImagePath = call.argument("localImagePath");
        assert localImagePath != null;
        String thumbPath = EaseImageUtils.getThumbnailImagePath(localImagePath);
        result.success(thumbPath);
    }

    /**
     * 获取聊天记录
     */
    public static void getAllMessages(MethodCall call, MethodChannel.Result result) {
        EMConversation conversation = EMClient.getInstance().chatManager().getConversation(call.argument("username"));
        //获取此会话的所有消息
        List<EMMessage> messages = conversation.getAllMessages();
        List<Map<String, Object>> msgList = new ArrayList<>();
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
                    String thumbPath = imgBody.thumbnailLocalPath();
                    if (!new File(thumbPath).exists()) {
                        // to make it compatible with thumbnail received in previous version
                        thumbPath = EaseImageUtils.getThumbnailImagePath(imgBody.getLocalUrl());
                    }
                    String imagePath = EaseImageUtils.getImagePath(imgBody.getRemoteUrl());
                    System.out.println(thumbPath);
                    map.put("body",thumbPath);
                    map.put("image",imagePath);
                    break;
                case VOICE:
                    map.put("type","VOICE");
                    EMVoiceMessageBody voiceBody = (EMVoiceMessageBody) messages.get(i).getBody();
                    map.put("body",voiceBody.getRemoteUrl());
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
            map.put("time",messages.get(i).getMsgTime());
            msgList.add(map);
        }
        result.success(msgList);
        //SDK初始化加载的聊天记录为20条，到顶时需要去DB里获取更多
    }

    /**
     * 获取更多聊天记录
     */
    public static void getAllMessagesMore(MethodCall call, MethodChannel.Result result) {
        String username = call.argument("username");
        String startMsgId = call.argument("startMsgId");
        EMConversation conversation = EMClient.getInstance().chatManager().getConversation(username);
        //获取startMsgId之前的pagesize条消息，此方法获取的messages SDK会自动存入到此会话中，APP中无需再次把获取到的messages添加到会话中
        List<EMMessage> messages = conversation.loadMoreMsgFromDB(startMsgId, 20);
        List<Map<String, Object>> msgList = new ArrayList<>();
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
                    String thumbPath = imgBody.thumbnailLocalPath();
                    if (!new File(thumbPath).exists()) {
                        // to make it compatible with thumbnail received in previous version
                        thumbPath = EaseImageUtils.getThumbnailImagePath(imgBody.getLocalUrl());
                    }
                    String imagePath = EaseImageUtils.getImagePath(imgBody.getRemoteUrl());
                    map.put("body",thumbPath);
                    map.put("image",imagePath);
                    break;
                case VOICE:
                    map.put("type","VOICE");
                    EMVoiceMessageBody voiceBody = (EMVoiceMessageBody) messages.get(i).getBody();
                    map.put("body",voiceBody.getRemoteUrl());
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
            long receiveTime = messages.get(i).getMsgTime();
            map.put("time",receiveTime);
            msgList.add(map);
        }
        result.success(msgList);
    }

    /**
     * 获取未读消息数量
     */
    public static void getUnreadMsgCount(MethodCall call, MethodChannel.Result result) {
        EMConversation conversation = EMClient.getInstance().chatManager().getConversation(call.argument("username"));
        result.success(conversation.getUnreadMsgCount());
    }

    /**
     * 未读消息数清零
     */
    public static void getMsgAsRead(MethodCall call, MethodChannel.Result result) {
        String username = call.argument("username");
        if ("".equals(username)) {
            //所有未读消息数清零
            EMClient.getInstance().chatManager().markAllConversationsAsRead();
        } else {
            EMConversation conversation = EMClient.getInstance().chatManager().getConversation(call.argument("username"));
            //指定会话消息未读数清零
            conversation.markAllMessagesAsRead();
        }
    }

    /**
     * 获取消息总数
     */
    public static void getAllMsgCount(MethodCall call, MethodChannel.Result result) {
        EMConversation conversation = EMClient.getInstance().chatManager().getConversation(call.argument("username"));
        //获取此会话在本地的所有的消息数量
        result.success(conversation.getAllMsgCount());
    }

    /**
     * 获取所有会话
     */
    public static void getAllConversations(MethodCall call, MethodChannel.Result result) {
        Map<String, EMConversation> conversations = EMClient.getInstance().chatManager().getAllConversations();
        Set<String> keys = conversations.keySet();
        Iterator<String> iterator = keys.iterator();
        HashMap<String, HashMap<String, Object>> listMap = new HashMap<>();
        while (iterator.hasNext()) {
            String key = iterator.next();
            EMConversation emConversation = conversations.get(key);
            HashMap<String, Object> map = new HashMap<>();
            if (emConversation != null) {
                EMConversation.EMConversationType type = emConversation.getType();
                if (type == EMConversation.EMConversationType.Chat) {
                    map.put("chatType","Chat");
                } else if (type == EMConversation.EMConversationType.GroupChat) {
                    map.put("chatType","GroupChat");
                } else if (type == EMConversation.EMConversationType.ChatRoom) {
                    map.put("chatType","ChatRoom");
                }
            }
            assert emConversation != null;
            String conversationId = emConversation.conversationId();
            map.put("conversationId", conversationId);
            int unReadCount = emConversation.getUnreadMsgCount();
            map.put("unReadCount", unReadCount);
            EMMessage emMessage = emConversation.getLastMessage();
            EMMessage.Type type = emMessage.getType();
            switch (type) {
                case TXT:
                    map.put("type","TXT");
                    EMTextMessageBody textBody = (EMTextMessageBody) emMessage.getBody();
                    map.put("body",textBody.getMessage());
                    break;
                case IMAGE:
                    map.put("type","IMAGE");
                    EMImageMessageBody imgBody = (EMImageMessageBody) emMessage.getBody();
                    String thumbPath = imgBody.thumbnailLocalPath();
                    if (!new File(thumbPath).exists()) {
                        // to make it compatible with thumbnail received in previous version
                        thumbPath = EaseImageUtils.getThumbnailImagePath(imgBody.getLocalUrl());
                    }
                    String imagePath = EaseImageUtils.getImagePath(imgBody.getRemoteUrl());
                    map.put("body",thumbPath);
                    map.put("image",imagePath);
                    break;
                case VOICE:
                    map.put("type","VOICE");
                    EMVoiceMessageBody voiceBody = (EMVoiceMessageBody) emMessage.getBody();
                    map.put("body",voiceBody.getRemoteUrl());
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
            long receiveTime = emMessage.getMsgTime();
            map.put("lastMsgTime",receiveTime);
            listMap.put(key,map);
            EasemobResponseHandler.onConversationGet(listMap);
        }
    }

    /**
     * 删除某个user会话，如果需要保留聊天记录，传false
     */
    public static void deleteConversation(MethodCall call, MethodChannel.Result result) {
        String username = call.argument("username");
        boolean isDelHistory = (boolean)call.argument("isDelHistory");
        EMClient.getInstance().chatManager().deleteConversation(username, isDelHistory);
    }

    /**
     * 获取好友列表
     */
    public static void getAllContactsFromServer(MethodCall call, MethodChannel.Result result) {
        try {
            List<String> usernames = EMClient.getInstance().contactManager().getAllContactsFromServer();
            result.success(usernames);
        } catch (HyphenateException e) {
            e.printStackTrace();
        }
    }

    /**
     * 添加好友
     */
    public static void addContact(MethodCall call, MethodChannel.Result result) {
        String toAddUsername = call.argument("toAddUsername");
        String reason = call.argument("reason");
        //参数为要添加的好友的username和添加理由
        try {
            EMClient.getInstance().contactManager().addContact(toAddUsername, reason);
        } catch (HyphenateException e) {
            e.printStackTrace();
        }
    }

    /**
     * 删除好友
     */
    public static void deleteContact(MethodCall call, MethodChannel.Result result) {
        String username = call.argument("username");
        try {
            EMClient.getInstance().contactManager().deleteContact(username);
        } catch (HyphenateException e) {
            e.printStackTrace();
        }
    }

    /**
     * 同意好友请求
     */
    public static void acceptInvitation(MethodCall call, MethodChannel.Result result) {
        String username = call.argument("username");
        try {
            EMClient.getInstance().contactManager().acceptInvitation(username);
        } catch (HyphenateException e) {
            e.printStackTrace();
        }
    }

    /**
     * 拒绝好友请求
     */
    public static void declineInvitation(MethodCall call, MethodChannel.Result result) {
        String username = call.argument("username");
        try {
            EMClient.getInstance().contactManager().declineInvitation(username);
        } catch (HyphenateException e) {
            e.printStackTrace();
        }
    }

    /**
     * 创建群组
     * groupName 群组名称
     * desc 群组简介
     * allMembers 群组初始成员，如果只有自己传空数组即可
     * reason 邀请成员加入的reason
     * option 群组类型选项，可以设置群组最大用户数(默认200)及群组类型{EMGroupStyle}
     *               option.inviteNeedConfirm表示邀请对方进群是否需要对方同意。
     *               option.extField创建群时可以为群组设定扩展字段，方便个性化订制。
     */
    public static void createGroup(MethodCall call, MethodChannel.Result result) {
        String groupName = call.argument("groupName");
        String desc = call.argument("desc");
        List<String> allMemberList = call.argument("allMembers");
        assert allMemberList != null;
        String[] allMembers = allMemberList.toArray(new String[allMemberList.size()]);
        String reason = call.argument("reason");
        int groupType = (int) call.argument("groupType");
        boolean inviteNeedConfirm = (boolean)call.argument("inviteNeedConfirm");

        EMGroupOptions options = new EMGroupOptions();
        options.maxUsers = 200;
        if (groupType == 0) {
            options.style = EMGroupManager.EMGroupStyle.EMGroupStylePublicOpenJoin;
        } else if (groupType == 1) {
            options.style = EMGroupManager.EMGroupStyle.EMGroupStylePublicJoinNeedApproval;
        } else if (groupType == 2) {
            options.style = EMGroupManager.EMGroupStyle.EMGroupStylePrivateOnlyOwnerInvite;
        } else if (groupType == 3) {
            options.style = EMGroupManager.EMGroupStyle.EMGroupStylePrivateMemberCanInvite;
        }
        options.inviteNeedConfirm = inviteNeedConfirm;
        try {
            EMClient.getInstance().groupManager().createGroup(groupName, desc, allMembers, reason, options);
        } catch (HyphenateException e) {
            e.printStackTrace();
        }
    }

    /**
     * 增加群组管理员，需要owner权限
     */
    public static void addGroupAdmin(MethodCall call, MethodChannel.Result result) {
        String groupId = call.argument("groupId");
        String admin = call.argument("admin");
        try {
            EMClient.getInstance().groupManager().addGroupAdmin(groupId, admin);
        } catch (HyphenateException e) {
            e.printStackTrace();
        }
        result.success("success");
    }

    /**
     * 删除群组管理员，需要owner权限
     */
    public static void removeGroupAdmin(MethodCall call, MethodChannel.Result result) {
        String groupId = call.argument("groupId");
        String admin = call.argument("admin");
        try {
            EMClient.getInstance().groupManager().removeGroupAdmin(groupId, admin);
        } catch (HyphenateException e) {
            e.printStackTrace();
        }
        result.success("success");
    }

    /**
     * 群组所有权给他人
     */
    public static void changeOwner(MethodCall call, MethodChannel.Result result) {
        String groupId = call.argument("groupId");
        String newOwner = call.argument("newOwner");
        try {
            EMClient.getInstance().groupManager().changeOwner(groupId, newOwner);
        } catch (HyphenateException e) {
            e.printStackTrace();
        }
        result.success("success");
    }

    /**
     * 群组加人(群主)
     */
    public static void addUsersToGroup(MethodCall call, MethodChannel.Result result) {
        String groupId = call.argument("groupId");
        List<String> newmemberList = call.argument("newmember");
        assert newmemberList != null;
        String[] newmenbers = newmemberList.toArray(new String[newmemberList.size()]);
        try {
            EMClient.getInstance().groupManager().addUsersToGroup(groupId,newmenbers);
        } catch (HyphenateException e) {
            e.printStackTrace();
        }
        result.success("success");
    }

    /**
     * 群组踢人
     */
    public static void removeUserFromGroup(MethodCall call, MethodChannel.Result result) {
        String groupId = call.argument("groupId");
        String username = call.argument("username");
        try {
            EMClient.getInstance().groupManager().removeUserFromGroup(groupId,username);
        } catch (HyphenateException e) {
            e.printStackTrace();
        }
        result.success("success");
    }

    /**
     * 群组加人(群主)
     */
    public static void inviteUser(MethodCall call, MethodChannel.Result result) {
        String groupId = call.argument("groupId");
        List<String> newmemberList = call.argument("newmember");
        assert newmemberList != null;
        String[] newmenbers = newmemberList.toArray(new String[newmemberList.size()]);
        try {
            EMClient.getInstance().groupManager().inviteUser(groupId,newmenbers,null);
        } catch (HyphenateException e) {
            e.printStackTrace();
        }
        result.success("success");
    }

    /**
     * 加入某个群组（只能用于加入公开群）
     * needApply true 需要申请验证（applyJoinToGroup）  false 直接加入（joinGroup）
     */
    public static void joinGroup(MethodCall call, MethodChannel.Result result) {
        String groupId = call.argument("groupId");
        boolean needApply = (boolean)call.argument("needApply");
        String reason = call.argument("reason");
        try {
            if (needApply) {
                EMClient.getInstance().groupManager().applyJoinToGroup(groupId,reason);
            } else {
                EMClient.getInstance().groupManager().joinGroup(groupId);
            }
        } catch (HyphenateException e) {
            e.printStackTrace();
        }
        result.success("success");
    }

    /**
     * 退出群组
     */
    public static void leaveGroup(MethodCall call, MethodChannel.Result result) {
        String groupId = call.argument("groupId");
        try {
            EMClient.getInstance().groupManager().leaveGroup(groupId);
        } catch (HyphenateException e) {
            e.printStackTrace();
        }
        result.success("success");
    }

    /**
     * 解散群组
     */
    public static void destroyGroup(MethodCall call, MethodChannel.Result result) {
        String groupId = call.argument("groupId");
        try {
            EMClient.getInstance().groupManager().destroyGroup(groupId);
        } catch (HyphenateException e) {
            e.printStackTrace();
        }
        result.success("success");
    }

    /**
     * 获取完整的群成员列表
     */
    public static void fetchGroupMembers(MethodCall call, MethodChannel.Result result) {
        String groupId = call.argument("groupId");
        List<String> memberList = new ArrayList<>();
        EMCursorResult<String> emResult = null;
        final int pageSize = 20;
        try {
            do {
                    emResult = EMClient.getInstance().groupManager().fetchGroupMembers(groupId,
                            emResult != null ? emResult.getCursor() : "", pageSize);
                    memberList.addAll(emResult.getData());
            } while (!TextUtils.isEmpty(emResult.getCursor()) && emResult.getData().size() == pageSize);
        } catch (HyphenateException e) {
            e.printStackTrace();
        }
        result.success(memberList);
    }

    /**
     * 获取群组列表
     */
    public static void getJoinedGroupsFromServer(MethodCall call, MethodChannel.Result result) {
        try {
            List<EMGroup> grouplist = EMClient.getInstance().groupManager().getJoinedGroupsFromServer();
            List<Map<String, Object>> maps = new ArrayList<>();
            for (int i = 0; i < grouplist.size(); i++) {
                EMGroup group = grouplist.get(i);
                String groupId = group.getGroupId();
                String groupOwner = group.getOwner();
                String groupName = group.getGroupName();
                String groupDescription = group.getDescription();
                List<String> adminList = group.getAdminList();
                int groupCount = group.getMemberCount();
                List<String> members = group.getMembers();
                int groupMaxCount = group.getMaxUserCount();
                Map<String, Object> map = new HashMap<>();
                map.put("groupId",groupId);
                map.put("groupOwner",groupOwner);
                map.put("groupName",groupName);
                map.put("groupDescription",groupDescription);
                map.put("adminList",adminList);
                map.put("groupCount",groupCount);
                map.put("members",members);
                map.put("groupMaxCount",groupMaxCount);
                maps.add(map);
            }
            result.success(maps);
        } catch (HyphenateException e) {
            e.printStackTrace();
        }
    }

    /**
     * 修改群组名称
     */
    public static void changeGroupName(MethodCall call, MethodChannel.Result result) {
        String groupId = call.argument("groupId");
        String changedGroupName = call.argument("changedGroupName");
        try {
            EMClient.getInstance().groupManager().changeGroupName(groupId,changedGroupName);
        } catch (HyphenateException e) {
            e.printStackTrace();
        }
        result.success("success");
    }

    /**
     * 修改群组描述
     */
    public static void changeGroupDescription(MethodCall call, MethodChannel.Result result) {
        String groupId = call.argument("groupId");
        String description = call.argument("description");
        try {
            EMClient.getInstance().groupManager().changeGroupDescription(groupId,description);
        } catch (HyphenateException e) {
            e.printStackTrace();
        }
        result.success("success");
    }

    /**
     * 群组信息
     */
    public static void getGroupFromServer(MethodCall call, MethodChannel.Result result) {
        String groupId = call.argument("groupId");
        try {
            //根据群组ID从服务器获取群组基本信息
            assert groupId != null;
            EMGroup group = EMClient.getInstance().groupManager().getGroupFromServer(groupId);
            String groupOwner = group.getOwner();
            String groupName = group.getGroupName();
            String groupDescription = group.getDescription();
            List<String> adminList = group.getAdminList();
            int groupCount = group.getMemberCount();
            List<String> members = group.getMembers();
            int groupMaxCount = group.getMaxUserCount();
            Map<String, Object> map = new HashMap<>();
            map.put("groupId",groupId);
            map.put("groupOwner",groupOwner);
            map.put("groupName",groupName);
            map.put("groupDescription",groupDescription);
            map.put("adminList",adminList);
            map.put("groupCount",groupCount);
            map.put("members",members);
            map.put("groupMaxCount",groupMaxCount);
            result.success(map);
        } catch (HyphenateException e) {
            e.printStackTrace();
        }
        result.success("success");
    }

    /**
     * 注册群组事件监听
     */
    public static void addGroupChangeListener(MethodCall call, MethodChannel.Result result) {
        EMClient.getInstance().groupManager().addGroupChangeListener(new EMGroupChangeListener() {
            @Override
            public void onInvitationReceived(String groupId, String groupName, String inviter, String reason) {
                //接收到群组加入邀请
                EasemobResponseHandler.onInvitationReceived(groupId, groupName, inviter, reason);
            }

            @Override
            public void onRequestToJoinReceived(String groupId, String groupName, String applicant, String reason) {
                //用户申请加入群
                EasemobResponseHandler.onRequestToJoinReceived(groupId, groupName, applicant, reason);
            }

            @Override
            public void onRequestToJoinAccepted(String groupId, String groupName, String accepter) {
                //加群申请被同意
                EasemobResponseHandler.onRequestToJoinAccepted(groupId, groupName, accepter);
            }

            @Override
            public void onRequestToJoinDeclined(String groupId, String groupName, String decliner, String reason) {
                //加群申请被拒绝
                EasemobResponseHandler.onRequestToJoinDeclined(groupId, groupName, decliner);
            }

            @Override
            public void onInvitationAccepted(String groupId, String invitee, String reason) {
                //群组邀请被同意
                EasemobResponseHandler.onInvitationAccepted(groupId, invitee,reason);
            }

            @Override
            public void onInvitationDeclined(String groupId, String invitee, String reason) {
                //群组邀请被拒绝
                EasemobResponseHandler.onInvitationDeclined(groupId, invitee,reason);
            }

            @Override
            public void onUserRemoved(String groupId, String groupName) {
                //用户被踢出群的通知
                EasemobResponseHandler.onUserRemoved(groupId, groupName);
            }

            @Override
            public void onGroupDestroyed(String groupId, String groupName) {
                //群解散的通知
                EasemobResponseHandler.onGroupDestroyed(groupId, groupName);
            }

            @Override
            public void onAutoAcceptInvitationFromGroup(String groupId, String inviter, String inviteMessage) {
                //接收邀请时自动加入到群组的通知
                EasemobResponseHandler.onAutoAcceptInvitationFromGroup(groupId, inviter,inviteMessage);
            }

            @Override
            public void onMuteListAdded(String groupId, List<String> mutes, long muteExpire) {
                //成员禁言的通知
            }

            @Override
            public void onMuteListRemoved(String groupId, List<String> mutes) {
                //成员从禁言列表里移除通知
            }

            @Override
            public void onAdminAdded(String groupId, String administrator) {
                //增加管理员的通知
                EasemobResponseHandler.onAdminAdded(groupId, administrator);
            }

            @Override
            public void onAdminRemoved(String groupId, String administrator) {
                //管理员移除的通知
                EasemobResponseHandler.onAdminRemoved(groupId, administrator);
            }

            @Override
            public void onOwnerChanged(String groupId, String newOwner, String oldOwner) {
                //群所有者变动通知
                EasemobResponseHandler.onOwnerChanged(groupId, newOwner, oldOwner);
            }

            @Override
            public void onMemberJoined(String groupId, String member) {
                //群组加入新成员通知
                EasemobResponseHandler.onMemberJoined(groupId, member);
            }

            @Override
            public void onMemberExited(String groupId, String member) {
                //群成员退出通知
                EasemobResponseHandler.onMemberExited(groupId, member);
            }

            @Override
            public void onAnnouncementChanged(String groupId, String announcement) {
                //群公告变动通知
            }

            @Override
            public void onSharedFileAdded(String groupId, EMMucSharedFile sharedFile) {
                //增加共享文件的通知
            }

            @Override
            public void onSharedFileDeleted(String groupId, String fileId) {
                //群共享文件删除通知
            }
        });
    }

    /**
     * 注册通话状态监听
     */
    public static void addCallStateChangeListener(MethodCall call, MethodChannel.Result result) {
        EMClient.getInstance().callManager().addCallStateChangeListener(new EMCallStateChangeListener() {
            @Override
            public void onCallStateChanged(CallState callState, CallError error) {
                switch (callState) {
                    case CONNECTING: // 正在连接对方
                        EasemobResponseHandler.onCallStateChange(1);
                        break;
                    case CONNECTED: // 双方已经建立连接
                        EasemobResponseHandler.onCallStateChange(2);
                        break;

                    case ACCEPTED: // 电话接通成功
                        EasemobResponseHandler.onCallStateChange(0);
                        break;
                    case DISCONNECTED: // 电话断了
                        EasemobResponseHandler.onCallStateChange(-1);
                        break;
                    case NETWORK_UNSTABLE: //网络不稳定
                        if(error == CallError.ERROR_NO_DATA){
                            //无通话数据
                            EasemobResponseHandler.onCallStateChange(-2);
                        }else{
                            EasemobResponseHandler.onCallStateChange(-2);
                        }
                        break;
                    case NETWORK_NORMAL: //网络恢复正常
                        EasemobResponseHandler.onCallStateChange(3);
                        break;
                    default:
                        break;
                }
            }
        });
    }

    /**
     * 拨打语音通话
     */
    public static void makeVoiceCall(MethodCall call, MethodChannel.Result result) {
        String username = call.argument("username");
        try {//单参数
            EMClient.getInstance().callManager().makeVoiceCall(username);
        } catch (EMServiceNotReadyException e) {
            e.printStackTrace();
        }
        result.success("success");
    }

    /**
     * 接听通话
     */
    public static void answerCall(MethodCall call, MethodChannel.Result result) {
        try {
            EMClient.getInstance().callManager().answerCall();
        } catch (EMNoActiveCallException e) {
            e.printStackTrace();
        }
        result.success("success");
    }

    /**
     * 拒绝接听
     */
    public static void rejectCall(MethodCall call, MethodChannel.Result result) {
        try {
            EMClient.getInstance().callManager().rejectCall();
        } catch (EMNoActiveCallException e) {
            e.printStackTrace();
        }
        result.success("success");
    }

    /**
     * 挂断通话
     */
    public static void endCall(MethodCall call, MethodChannel.Result result) {
        try {
            EMClient.getInstance().callManager().endCall();
        } catch (EMNoActiveCallException e) {
            e.printStackTrace();
        }
        result.success("success");
    }

    /**
     * 加入聊天室
     */
    public static void joinChatRoom(MethodCall call, MethodChannel.Result result) {

        String roomId = call.argument("roomId");
        //roomId为聊天室ID
        EMClient.getInstance().chatroomManager().joinChatRoom(roomId, new EMValueCallBack<EMChatRoom>() {

            @Override
            public void onSuccess(EMChatRoom value) {
                //加入聊天室成功
                registrar.activity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        result.success("success");
                    }
                });
            }

            @Override
            public void onError(final int error, String errorMsg) {
                //加入聊天室失败
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
     * 离开聊天室
     */
    public static void leaveChatRoom(MethodCall call, MethodChannel.Result result) {
        String roomId = call.argument("roomId");
        EMClient.getInstance().chatroomManager().leaveChatRoom(roomId);
        result.success("success");
    }

    /**
     * 获取聊天室详情
     */
    public static void getChatRoomDetail(MethodCall call, MethodChannel.Result result) {
        String roomId = call.argument("roomId");
        try {
            EMChatRoom room = EMClient.getInstance().chatroomManager().fetchChatRoomFromServer(roomId);
            String roomName = room.getName();
            String id = room.getId();
            String description = room.getDescription();
            String owner = room.getOwner();
            String announcement = room.getAnnouncement();
            int memberCount = room.getMemberCount();
            HashMap<String, Object> map = new HashMap<>();
            map.put("roomName",roomName);
            map.put("id",id);
            map.put("description",description);
            map.put("owner",owner);
            map.put("announcement",announcement);
            map.put("memberCount",memberCount);
            result.success(map);
        } catch (HyphenateException e) {
            e.printStackTrace();
        }
    }



}
