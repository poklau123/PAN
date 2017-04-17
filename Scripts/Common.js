/// <reference path="jquery-1.9.1.js" />

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