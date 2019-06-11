package com.alipush;

import android.app.Application;

import android.content.pm.PackageManager;
import static com.alipush.PushUtils.initPushService;

public class PushApplication extends Application {

    @Override
    public void onCreate() {
        super.onCreate();
        try {
            initPushService(this);
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
    }

}
