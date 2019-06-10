var exec = require('cordova/exec');

var AliyunPush = {
    registered: false,
    errorCallback: function(msg) {
        console.log('AliyunPush Callback Error: ' + msg)
    },

    callNative: function(name, args, successCallback, errorCallback) {
        if (errorCallback) {
            cordova.exec(successCallback, errorCallback, 'AliyunPush', name, args)
        } else {
            cordova.exec(successCallback, this.errorCallback, 'AliyunPush', name, args)
        }
    },

    /**
     * 阿里云推送消息透传回调
     * @param  {Function} successCallback 成功回调
     * @return {void}  
     */
    onMessage: function(successCallback) {
        this.callNative('onMessage', [], successCallback)
    },
    

    /**
     * 没有权限时，请求开通通知权限，其他路过
     * @param {} successCallback 
     * @param {*} errorCallback 
     */
    requireNotifyPermission:function(msg,successCallback, errorCallback){
        this.callNative('requireNotifyPermission', [msg], successCallback,errorCallback);
    },

    /**
     * 获取设备唯一标识deviceId，deviceId为阿里云移动推送过程中对设备的唯一标识（并不是设备UUID/UDID）
     * @param  {Function} successCallback 成功回调
     * @param  {Function} errorCallback   失败回调
     * @return {void}  
     */
    getRegisterId: function(successCallback, errorCallback) {
        this.callNative('getRegisterId', [], successCallback,errorCallback);
    },

    /**
     * 阿里云推送绑定账号名
     * @param  {string} account         账号
     * @param  {Function} successCallback 成功回调
     * @param  {Function} errorCallback   失败回调
     * @return {void} 
     */
    bindAccount: function(account, successCallback, errorCallback) {
        this.callNative('bindAccount', [account], successCallback, errorCallback);
    },

    /**
     * 阿里云推送解除账号名,退出切换账号时调用
     * @param  {Function} successCallback 成功回调
     * @param  {Function} errorCallback   失败回调
     * @return {void} 
     */
    unbindAccount: function(successCallback, errorCallback) {
        this.callNative('unbindAccount', [], successCallback, errorCallback);
    },

    /**
     * 阿里云推送绑定标签
     * @param  {string[]} tags            标签列表
     * @param  {Function} successCallback 成功回调
     * @param  {Function} errorCallback   失败回调
     * @return {void}  
     */
    bindTags: function(tags, successCallback, errorCallback) {
        this.callNative('bindTags', [tags], successCallback, errorCallback)
    },

    /**
     * 阿里云推送解除绑定标签
     * @param  {string[]} tags            标签列表
     * @param  {Function} successCallback 成功回调
     * @param  {Function} errorCallback   失败回调
     * @return {void}               
     */
    unbindTags: function(tags, successCallback, errorCallback) {
        this.callNative('unbindTags', [tags], successCallback, errorCallback)
    },

    /**
     * 阿里云推送解除绑定标签
     * @param  {Function} successCallback 成功回调
     * @param  {Function} errorCallback   失败回调
     * @return {void}           
     */
    listTags: function(successCallback, errorCallback) {
        this.callNative('listTags', [], successCallback,errorCallback)
    },

    AliyunPush: AliyunPush
}
module.exports = AliyunPush;