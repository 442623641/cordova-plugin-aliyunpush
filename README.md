# cordova-plugin-aliyunpush

## Install

> 注意：
> - 应用的包名一定要和 APP_KEY 对应应用的包名一致，否则推送服务无法注册成功。
> - 在使用 8 或以上版本的 Xcode 调试 iOS 项目时，需要先在项目配置界面的 Capabilities 中打开 Push Notifications 开关。
> - 如没有注册小米，华为，OPPO等通道不配置即可
> - 后台推送时可在ExtParameters参数中写入app跳转路径如ExtParameters:{url:'https://help.aliyun.com'},插件会把ExtParameters解析到push content中
> - 后台推送时 AndroidOpenType设置为APPLICATION：打开应用 默认值
> - 如项目中已存在 Application对象，安装完插件后请替换AndroidManifest.xml/application标签中属性android:name="com.alipush.PushApplication" 已有的Application类，然后在已有Application类onCreate() 钩子里初始化推送服务   
```
initPushService(this)  
```

- 通过 Cordova Plugins 安装，要求 Cordova CLI 5.0+：

  ```shell
  cordova plugin add https://github.com/442623641/cordova-plugin-aliyunpush.git
  ionic cordova build android --prod
  ```

- 或下载到本地安装：
  ```shell
  cordova plugin add Your_Plugin_Path 
  ```
修改项目级目录下build.gradle（{project}/build.gradle）：
添加maven（低版本gradle，可能会有问题）
```
  maven {
    url 'http://maven.aliyun.com/nexus/content/repositories/releases/'
  }
```
```
  buildscript {
    repositories {
    +  maven {
    +    url 'http://maven.aliyun.com/nexus/content/repositories/releases/'
    +  }
  }

  allprojects {
    repositories {
      +maven {
      +  url 'http://maven.aliyun.com/nexus/content/repositories/releases/'
      +}
    }
  }
```
如cordova build时出错请打开AndroidManifest.xml手动维护，修正多余标签属性

## Configuration

This plugin has several configuration options that can be set in `config.xml`.

### Android and iOS Preferences

Preferences available for both iOS and Android

### Android Preferences

- 对应Android系统推送，如果需要支持华为、小米、Google FCM（原GCM）系统通道，请在此页面配置对应的参数信息。可以根据需要配置一种或多种厂商辅助通道。
- [阿里云推送官方文档](https://help.aliyun.com/document_detail/92837.html?spm=a2c4g.11174283.6.637.52eb6d16cxZ6zi)

<img src="http://docs-aliyun.cn-hangzhou.oss.aliyun-inc.com/assets/pic/92837/cn_zh/1538961570959/%E5%BA%94%E7%94%A8%E9%85%8D%E7%BD%AE.png" width ="70%" height="70%" div align="center" />

> - AliyunAppKey:阿里云appKey
> - AliyunAppSecret:阿里云appSecret
> - XiaoMiAppId:可不配置，小米通道AppId，如已注册，需在阿里云后台推送配置中配置
> - XiaoMiAppKey:可不配置，小米通道AppKey，如已注册，需在阿里云后台推送配置中配置
> - OPPOAppKey:可不配置，OPPO通道AppKey，如已注册，需在阿里云后台推送配置中配置
> - OPPOAppSecret可不配置，OPPO通道AppSecret，如已注册，需在阿里云后台推送配置中配置
```xml
<config-file parent="/manifest/application" target="AndroidManifest.xml" xmlns:android="http://schemas.android.com/apk/res/android">
    <meta-data android:name="AliyunAppKey" android:value="25532868" />
    <meta-data android:name="AliyunAppSecret" android:value="28688f0fba136fcbb8a90c0a78b2cc83" />
    <meta-data android:name="XiaoMiAppId" android:value="2868303761518018487" />
    <meta-data android:name="XiaoMiAppKey" android:value="2868801843487" />
    <meta-data android:name="OPPOAppKey" android:value="286856813b8745928c2102c20dd49fde" />
    <meta-data android:name="OPPOAppSecret" android:value="2868c44b4eee471097243658679910d1" />
</config-file>
```
### IOS Preferences
```xml
  <edit-config file="*AliyunEmasServices-Info.plist" mode="merge" target="emas.appKey">
    <string>44342758</string>
  </edit-config>
  <edit-config file="*AliyunEmasServices-Info.plist" mode="merge" target="emas.appSecret">
    <string>7edda2aee310aef6803c46555d8de198</string>
  </edit-config>
  <edit-config file="*AliyunEmasServices-Info.plist" mode="merge" target="emas.bundleId">
    <string>com.ionic.app</string>
  </edit-config>
```


## Usage

### API

```
    /**
     * 获取设备唯一标识deviceId，deviceId为阿里云移动推送过程中对设备的唯一标识（并不是设备UUID/UDID）
     * @param  {Function} successCallback 成功回调
     * @param  {Function} errorCallback   失败回调
     * @return {void}  
     */
    getRegisterId: function(successCallback, errorCallback)

    /**
     * 阿里云推送绑定账号名
     * @param  {string} account         账号
     * @param  {Function} successCallback 成功回调
     * @param  {Function} errorCallback   失败回调
     * @return {void} 
     */
    bindAccount: function(account, successCallback, errorCallback)

    /**
     * 阿里云推送解除账号名,退出或切换账号时调用
     * @param  {Function} successCallback 成功回调
     * @param  {Function} errorCallback   失败回调
     * @return {void} 
     */
    unbindAccount: function(successCallback, errorCallback)

    /**
     * 阿里云推送绑定标签
     * @param  {string[]} tags            标签列表
     * @param  {Function} successCallback 成功回调
     * @param  {Function} errorCallback   失败回调
     * @return {void}  
     */
    bindTags: function(tags, successCallback, errorCallback) 

    /**
     * 阿里云推送解除绑定标签
     * @param  {string[]} tags            标签列表
     * @param  {Function} successCallback 成功回调
     * @param  {Function} errorCallback   失败回调
     * @return {void}               
     */
    unbindTags: function(tags, successCallback, errorCallback)

    /**
     * 阿里云推送解除绑定标签
     * @param  {Function} successCallback 成功回调
     * @param  {Function} errorCallback   失败回调
     * @return {void}           
     */
    listTags: function(successCallback, errorCallback) 

    /**
      * 没有权限时，请求开通通知权限，其他路过
      * @param  string msg  请求权限的描述信息
      * @param {} successCallback 
      * @param {*} errorCallback 
      */
    requireNotifyPermission:function(msg,successCallback, errorCallback)
    
    /**
    * 阿里云推送消息透传回调
    * @param  {Function} successCallback 成功回调
    */
    onMessage:function(sucessCallback) ;

    # sucessCallback:调用成功回调方法，注意没有失败的回调，返回值结构如下：
    #json: {
      type:string 消息类型,
      title:string '阿里云推送',
      content:string '推送的内容',
      extra:string | Object<k,v> 外健,
      url:路由（后台发送推送时，在ExtParameters参数里写入url如{url:'demoapp://...'}）
    }

    #消息类型
    {
      message:透传消息，
      notification:通知接收，
      notificationOpened:通知点击，
      notificationReceived：通知到达，
      notificationRemoved：通知移除，
      notificationClickedWithNoAction：通知到达，
      notificationReceivedInApp：通知到达打开 app
    }

```


