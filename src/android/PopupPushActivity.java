package com.alipush;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.RequiresApi;
import android.util.Log;

import com.alibaba.sdk.android.push.AndroidPopupActivity;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Map;


/**
 * https://help.aliyun.com/document_detail/30067.html?spm=a2c4g.11186623.6.626.314e52e7onm2OM
 * 辅助弹窗
 */
public class PopupPushActivity extends AndroidPopupActivity {
    private static final String onSysNoticeOpened="notificationOpened";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }
    /**
     * 实现通知打开回调方法，获取通知相关信息
     * @param title     标题
     * @param summary   内容
     * @param extMap    额外参数
     */
    @RequiresApi(api = Build.VERSION_CODES.GINGERBREAD)
    @Override
    protected void onSysNoticeOpened(String title, String summary, Map<String, String> extMap) {
        Log.i("==","辅助弹窗 onSysNoticeOpened, title: " + title + ", content: " + summary + ", extMap: " + extMap);
        Intent intent = new Intent(PopupPushActivity.this,com.alipush.AliyunPush.cls);
        startActivity(intent);
        savePushData(onSysNoticeOpened, title, summary, extMap);
        finish();

    }

    //将获取到的通知数据保存在sp中
    @RequiresApi(api = Build.VERSION_CODES.GINGERBREAD)
    private void savePushData(String type, String title, String content, Map<String, String> extraMap){
        try {
            JSONObject data = null;
            if (extraMap != null && !"".equals(extraMap)) {
                data = new JSONObject(extraMap);
            } else {
                data = new JSONObject();
            }
            setStringData(data, "type", type);
            setStringData(data, "title", title);
            setStringData(data, "content", content);

//            AliyunPush.pushData(data);
            //将获取到的通知数据保存在sp中
            new PushUtils(PopupPushActivity.this).setNoticeJsonData(data.toString());

        } catch (JSONException e) {
            e.printStackTrace();
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

}