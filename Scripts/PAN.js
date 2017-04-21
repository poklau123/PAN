/// <reference path="jquery-1.12.4.js" />

//云盘类
function PAN() {
    //获取所有dom节点
    this.dom = {
        btn_upload: $('#uploadBtn'),        //上传文件按钮
        btn_addFolder: $('#addFolderBtn'),  //新建文件夹按钮
        btn_multiDel: $('#multiDelBtn'),    //批量删除按钮
        input_search: $('#searchContent'),  //搜索输入框
        btn_search: $('#searchBtn'),        //搜索按钮
        
        label_path: $('.current .path'),        //当前路径显示标签
        label_dirInfo: $('.current .dirinfo'),  //当前目录信息标签
    
        typelistItems: $('.filetype_area a'),   //左侧文件类型列表选项
        filelists: $('.filelists'),             //文件列表容器
        table: $('.filelists table'),           //文件列表内表格
        table_body: $('.filelists table tbody'),//文件列表区域
    };
    //文件类型编号对应文件图标名称(无后缀)(构造节点用)
    this.typeIcon = {
        '0': 'folder',              //文件夹类型
        '1': 'picture',             //图片类型
        '2': 'document',            //文档类型
        '3': 'video',               //视频类型
        '4': 'music',               //音乐类型
        '5': 'zip',                 //压缩包类型
        '6': 'file',                //其它类型
    };

    this.init();
}
//初始化
PAN.prototype.init = function () {
    var self = this;

    //浏览器resize事件
    $(window).resize(function () {
        var window_height = window.outerHeight;
        var filelist_height = window_height - 71 - 40 - 27;
        self.dom.filelists.css('height', filelist_height + 'px');
    });
    $(window).resize(); //初始化时主动调用一次resize事件
    self.dom.filelists.niceScroll();   //给filelists添加niceScroll样式
    self.dom.table_body.on('mouseover mouseout', 'tr', function (e) {
        if (e.type == 'mouseover') {
            $(this).find('.operate').show();
        } else {
            $(this).find('.operate').hide();
        }
    });

    //上传按钮点击事件
    self.dom.btn_upload.click(function () {
        
    });
    //新建文件夹按钮点击事件
    self.dom.btn_addFolder.click(function () {

    });
    //搜索按钮点击事件
    self.dom.btn_search.click(function () {

    });
    //类型列表点击事件
    self.dom.typelistItems.click(function () {
        var type = $(this).attr('data-type');
        console.log(type);
    });
    //文件双击事件
    self.dom.table_body.on('dblclick', '.fileinfo', function () {
        console.log('double click');
    });
    //文件操作点击事件
    self.dom.table_body.on('click', '.operate a', function (e) {
        console.log(e);
    });
}
//构造云盘文件节点{'id':'文件编号','type':'文件类型编号','filename':'文件名','del':'bool是否删除','size':'文件字节数','time':'修改时间'}
PAN.prototype.constructFileNode = function (opts) {
    var self = this;
    var tr = $('<tr>').attr('data-info',JSON.stringify(opts));
    var td_info = $('<td>'),
        td_size = $('<td>'),
        td_time = $('<td>');
    tr.append(td_info).append(td_size).append(td_time);
    
    td_info.append('<span class="cbdiv"><input type="checkbox" /></span>');
    td_info.append('<a class="fileinfo" href="javascript:;"><img src="images/' + self.typeIcon[opts.type] + '.svg" /><span class="filename">' + opts.filename + '</span></a>');
    var div_operate = $('<div class="pull-right operate"></div>');
    td_info.append(div_operate);
    div_operate.html(function (opts) {
        //如果是删除状态则只显示还原按钮
        if (opts.del == false) {
            //如果是文件类型
            if(opts.type > 0){
                return '<a href="javascript:;" class="download"><img src="images/download.svg" /></a><a href="javascript:;" class="rename"><img src="images/rename.svg" /></a><a href="javascript:;" class="delete"><img src="images/delete.svg" /></a>';
            }else{
                return;
            }
        } else {
            return '<a href="javascript:;" class="restore"><img src="images/restore.svg" /></a>';
        }
    }(opts));
    
    td_size.html(function (opts) {  //根据byte输出可读大小字符串
        if (opts.type == 0) {
            return '-';
        }
        var size = opts.size;
        var tag = ['KB', 'MB', 'GB', 'TB'];
        for (i = 0; i < tag.length; i++) {
            size /= 1024;
            if (size < 1024) {
                return size.toFixed(2) + tag[i];
            }
        }
    }(opts));

    td_time.html(opts.time);

    return tr;
}