package com.alipush;

import android.content.Context;
import android.util.Log;

import com.alibaba.sdk.android.push.MessageReceiver;
import com.alibaba.sdk.android.push.notification.CPushMessage;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Map;

public class PushMessageReceiver extends MessageReceiver {
    /** LOG TAG */
    private static final String LOG_TAG = "==PushMessageReceiver";
    /** 回调类型 */
    private static final String ONMESSAGE="message";
    private static final String ONNOTIFICATION="notification";
    private static final String ONNOTIFICATIONOPENED="notificationOpened";
    private static final String ONNOTIFICATIONRECEIVED="notificationReceived";
    private static final String ONNOTIFICATIONREMOVED="notificationRemoved";
    private static final String ONNOIFICATIONCLICKEDWITHNOACTION="notificationClickedWithNoAction";
    private static final String ONNOTIFICATIONRECEIVEDINAPP="notificationReceivedInApp";


    @Override
    public void onNotification(Context context, String title, String summary, Map<String, String> extraMap) {
        Log.i("==", "收到通知 Receive notification, title: " + title + ", summary: " + summary + ", extraMap: " + extraMap);

        sendPushData(ONNOTIFICATION,title,summary,extraMap);
    }
    @Override
    public void onMessage(Context context, CPushMessage cPushMessage) {
        Log.i("==", "收到消息 onMessage, messageId: " + cPushMessage.getMessageId() + ", title: " + cPushMessage.getTitle() + ", content:" + cPushMessage.getContent());

        sendPushData(ONMESSAGE,cPushMessage.getTitle(),cPushMessage.getContent(),null,null,cPushMessage.getMessageId());

    }
    @Override
    public void onNotificationOpened(Context context, String title, String summary, String extraMap) {
        Log.i("==", "打开通知 onNotificationOpened, title: " + title + ", summary: " + summary + ", extraMap:" + extraMap);
        sendPushData(ONNOTIFICATIONOPENED,title,summary,extraMap);

    }
    @Override
    protected void onNotificationClickedWithNoAction(Context context, String title, String summary, String extraMap) {
        Log.i("==", "onNotificationClickedWithNoAction, title: " + title + ", summary: " + summary + ", extraMap:" + extraMap);
        sendPushData(ONNOIFICATIONCLICKEDWITHNOACTION,title,summary,extraMap);

    }
    @Override
    protected void onNotificationReceivedInApp(Context context, String title, String summary, Map<String, String> extraMap, int openType, String openActivity, String openUrl) {
        Log.i("==", "onNotificationReceivedInApp, title: " + title + ", summary: " + summary + ", extraMap:" + extraMap + ", openType:" + openType + ", openActivity:" + openActivity + ", openUrl:" + openUrl);
        sendPushData(ONNOTIFICATIONRECEIVEDINAPP,title,summary,extraMap,openUrl);

    }
    @Override
    protected void onNotificationRemoved(Context context, String messageId) {
        Log.i("==", "移除通知 onNotificationRemoved");
//        EventBus.getDefault().post("移除通知 onNotificationRemoved");
        try {
            JSONObject data = new JSONObject();
            setStringData(data, "id", messageId);
            setStringData(data, "type", ONNOTIFICATIONREMOVED);
            AliyunPush.pushData(data);
        } catch (JSONException e) {
            Log.e(LOG_TAG, e.getMessage(), e);
        }
    }

    /**
     * 设定字符串类型JSON对象，如值为空时不设定
     *
     * @param jsonObject JSON对象
     * @param name 关键字
     * @param value 值
     * @throws JSONException JSON异常
     */
    private void setStringData(JSONObject jsonObject, String name, String value) throws JSONException {
        if (value != null && !"".equals(value)) {
            jsonObject.put(name, value);
        }
    }

    private void sendPushData(String type,String title, String content, Map<String, String> extraMap, String ...openUrl){
        try {
            JSONObject data = null;
            if (extraMap != null && !"".equals(extraMap)) {
                data = new JSONObject(extraMap);
            } else {
                data = new JSONObject();
            }
            if (openUrl.length != 0 ) {
                if(openUrl[0]!=null&& !"".equals(openUrl[0])) {
                    setStringData(data, "url", openUrl[0]);
                }
                if(openUrl.length>1&& openUrl[1]!=null&& !"".equals(openUrl[1])) {
                    setStringData(data, "id", openUrl[1]);
                }
            }
            setStringData(data, "type", type);
            setStringData(data, "title", title);
            setStringData(data, "content", content);
            AliyunPush.pushData(data);
        } catch (JSONException e) {
            Log.e(LOG_TAG, e.getMessage(), e);
        }
    }
    private void sendPushData(String type,String title, String content, String extraMap){
        Log.d(LOG_TAG, type);
        if(AliyunPush.pushCallbackContext==null) {
            return;
        }
        try {
            JSONObject data = new JSONObject();
            if (extraMap != null && !"".equals(extraMap)) {
                try {
                    data=new JSONObject(extraMap);
                }catch (JSONException e) {
                    Log.e(LOG_TAG, e.getMessage(), e);
                    setStringData(data,"extra", extraMap);
                }
            }
            setStringData(data, "type", type);
            setStringData(data, "title", title);
            setStringData(data, "content", content);
            AliyunPush.pushData(data);
        } catch (JSONException e) {
            Log.e(LOG_TAG, e.getMessage(), e);
        }
    }
}