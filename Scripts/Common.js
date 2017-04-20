/// <reference path="jquery-1.9.1.js" />
/// <reference path="toastr.js" />

//toastr默认配置
toastr.options = {
    closeButton: true,
    showMethod: 'slideDown',
    timeOut: 1000
};

var nologin_toastr = null;  //未登录弹窗

function checkRetCode(data, success_callback, failed_callback) {
    /// <summary>检查ajax返回数据是否有错误并进行回调</summary>
    /// <param name="data" type="object">ajax的返回数据</param>
    /// <param name="success_callback" type="function">调用成功时候的回调(有默认参数)</param>
    /// <param name="failed_callback" type="function">调用失败时候的回调(有默认参数)</param>
    success_callback = success_callback || function () { };
    failed_callback = failed_callback || function () { };

    if (data.code != 0) {
        if (toastr) {
            if (data.code == 1) {
                if (!nologin_toastr) {
                    nologin_toastr = toastr.error('当前不在登录状态，正在跳转到登录页', "Error!", {
                        onHidden: function () {
                            location.href = './index.html';
                        }
                    });
                }
            } else {
                toastr.error(data.msg, "Error!");
            }
        }
        failed_callback(data.data);
    } else {
        success_callback(data.data);
    }
}

(function () {
    //检测jQuery是否被加载
    if (typeof jQuery == 'undefined') {
        console.error('JQuery未被加载');
        return;
    }
    //ajax通用设置
    $.ajaxSetup({
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        error: function (e) {
            console.error(e);
        }
    });
    //拓展jQuery数据发送（payload方式）
    $.extend({
        sendData: function (obj) {
            return $.ajax({
                type: 'post',
                url: './Handler.ashx',                
                data: JSON.stringify({
                    controller: obj.ctl, 
                    method: obj.mtd,
                    data: obj.data
                })
            });

        }
    });
})()