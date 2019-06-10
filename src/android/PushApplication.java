package com.alipush;

import android.app.Application;

import android.content.pm.PackageManager;

import com.septnet.check.utils.TeacherCheckApp;

import static com.alipush.PushUtils.getCurProcessName;
import static com.alipush.PushUtils.initPushService;

public class PushApplication extends Application {

    @Override
    public void onCreate() {
        super.onCreate();

        if (getApplicationInfo().packageName.equals(getCurProcessName(getApplicationContext()))) {
            TeacherCheckApp.getInstance().init(this);
        }
        try {
            initPushService(this);
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
    }

}
