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

        uploadModal: $('#uploadModal'),         //文件上传模态框
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
    //当前路径栈
    this.currentPath = [];
    //当前文件夹编号
    this.currentFolder = null;

    //规定请求默认配置
    this.ajax = function(mtd, data, callback){
        $.sendData({
            ctl: 'HomeController',
            mtd: mtd,
            data: data
        }).done(function (data) {
            checkRetCode(data, function (info) {
                callback(info);
            });
        });
    }

    this.init();
}
//初始化
PAN.prototype.init = function () {
    var self = this;

    //加载默认根文件夹数据
    self.getIntoFolder();

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
        self.dom.uploadModal.modal('show');
    });
    //新建文件夹按钮点击事件
    self.dom.btn_addFolder.click(function () {
        var newFolderNode = self.dom.table_body.find('tr[data-id=-1]');
        //不允许新建多个(尚未保存的)文件夹
        if (newFolderNode.length == 0) {
            self.addNewNode({
                id: '-1',
                type: 0,
                filename: '新建文件夹',
                del: false,
                time: '-'
            });
        }
        self.dom.table_body.find('tr[data-id=-1] .operate a.rename').click();
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
        var type = e.currentTarget.className;
        var tr = $(this).parents('tr');
        var tr_data = JSON.parse(tr.attr('data-info'));
        switch (type) {
            case 'download': (function (node, data) {
                window.open('./DownloadHandle.ashx?id'+ data.id);
            })(tr, tr_data); break;
            case 'rename': (function (node, data) {
                node.find('.filename').html('<input type="text" value="' + data.filename + '"/><img class="check" class="check" src="images/check.svg" />');
                //如果不是创建文件夹的话则有取消按钮
                if (data.id != -1) {
                    node.find('.filename').append('<img class="times" src="images/times.svg" />');
                }
                node.find('.filename input').select();
            })(tr, tr_data); break;
            case 'delete': (function (node, data) {
                self.fileDelete(data);
            })(tr, tr_data); break;
            case 'restore': (function (node, data) {
                self.fileRestore(data);
            })(tr, tr_data); break;
        }
    });
    //文件\文件夹重命名确认\取消操作
    self.dom.table_body.on('click', '.filename img', function (e) {
        var type = e.currentTarget.className;
        var tr = $(this).parents('tr');
        var tr_data = JSON.parse(tr.attr('data-info'));
        switch (type) {
            case 'check': (function (node, data) {
                self.fileRename(data, node.find('.filename input').val().trim());
            })(tr, tr_data); break;
            case 'times': (function (node, data) {
                node.find('.filename').html(data.filename);
            })(tr, tr_data); break;
        }
    });
    //初始化plupload
    $("#uploader").plupload({
        runtimes: 'html5,flash,silverlight,html4',
        url: 'UploadHandler.ashx',
        max_file_count: 20,      // 最大文件上传数目
        max_file_size: '6097mb', // 文件上传最大限制
        chunk_size: '1mb',
        // 如果是上传图片，则调整在浏览器上的显示比例
        resize: {
            width: 200,
            height: 200,
            quality: 90,
            crop: true
        },
        filters: {
            max_file_size: '1000mb',    //单文件上传大小限制
            // 上传文件类型限制
            mime_types: [
                { title: "picture", extensions: "jpg,gif,png,bmp,jpeg" },
                { title: "document", extensions: "txt,doc,docx,xls,xlsx,ppt,pptx" },
                { title: "video", extensions: "mp4,avi,rm,mov,wmv,flv,3gp,mkv" },
                { title: "music", extensions: "mp3,wav,wma,ogg" },
                { title: "zip", extensions: "rar,zip,7z,tar" }
            ]
        },
        rename: true,   //允许点击文件名进行重命名文件
        sortable: true, //排序
        dragdrop: true, //允许文件拖动到div内上传(需HTML5支持)
        // 上传视图
        views: {
            list: true,
            thumbs: true, // 显示缩略图
            active: 'list'
        },
        flash_swf_url: 'Scripts/plupload/js/Moxie.swf', //Flash文件位置
        silverlight_xap_url: 'Scripts/plupload/js/Moxie.xap', //silverlight文件位置
        init: {
            BeforeUpload: function (up, file) {     //上传文件前设置参数
                up.settings.multipart_params = {
                    filename: file.name,
                    currentFolder: self.currentFolder
                }
            },
            UploadComplete: function (up, file) {
                self.dom.uploadModal.modal('hide');
                self.getIntoFolder();
            }
        }
    });
}
//构造云盘文件节点{'id':'文件编号','type':'文件类型编号','filename':'文件名','del':'bool是否删除','size':'文件字节数','time':'修改时间'}
PAN.prototype.constructFileNode = function (opts) {
    var self = this;
    var tr = $('<tr></tr>');
    tr.attr('data-info',JSON.stringify(opts)).attr('data-id',opts.id).attr('data-type',opts.type);
    var td_info = $('<td>'),
        td_size = $('<td>'),
        td_time = $('<td>');
    tr.append(td_info).append(td_size).append(td_time);
    
    td_info.append('<span class="cbdiv"><input type="checkbox" /></span>');
    td_info.append('<span class="fileinfo" href="javascript:;"><img src="images/' + self.typeIcon[opts.type] + '.svg" /><span class="filename">' + opts.filename + '</span></span>');
    var div_operate = $('<div class="pull-right operate"></div>');
    td_info.append(div_operate);
    div_operate.html(function (opts) {
        //如果是删除状态则只显示还原按钮
        if (opts.del == false) {
            //如果是文件类型
            if(opts.type > 0){
                return '<a href="javascript:;" class="download"><img src="images/download.svg" /></a><a href="javascript:;" class="rename"><img src="images/rename.svg" /></a><a href="javascript:;" class="delete"><img src="images/delete.svg" /></a>';
            }else{
                return '<a href="javascript:;" class="rename"><img src="images/rename.svg" /></a><a href="javascript:;" class="delete"><img src="images/delete.svg" /></a>';
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
        for (var i = 0; i < tag.length; i++) {
            size /= 1024;
            if (size < 1024) {
                return size.toFixed(2) + tag[i];
            }
        }
    }(opts));

    td_time.html(opts.time);

    return tr;
}
//渲染文件列表
PAN.prototype.constructFiles = function (data) {
    var self = this;
    self.dom.table_body.html('');
    for (var i = 0; i < data.length; i++) {
        var node = self.constructFileNode(data[i]);
        self.dom.table_body.append(node);
    }
}
//向文件列表中添加一个文件\文件夹(仅DOM操作)
PAN.prototype.addNewNode = function (data) {
    var self = this;
    var node = self.constructFileNode(data);
    if (data.type == 0) {
        var pos = self.dom.table_body.find('tr[data-type=0]:first');
        if (pos.length == 0) {
            self.dom.table_body.prepend(node);
        } else {
            pos.before(node);
        }
    } else {
        var pos = self.dom.table_body.find('tr[data-type=0]:last');
        if (pos.length == 0) {
            self.dom.table_body.append(node);
        } else {
            pos.next(node);
        }
    }
}
//重命名(添加)文件夹确认
PAN.prototype.fileRename = function (data, name) {
    var self = this;
    //判断是否是创建文件夹
    if (data.id == -1) {
        self.ajax('AddFolder', {
            currentFolder: self.currentFolder,
            name: name
        }, function (info) {
            self.dom.table_body.find('tr[data-id=-1]').remove();
            self.addNewNode(info);
        });
    } else {
        self.ajax('Rename', {
            info: data,
            name: name
        }, function (info) {
            var node = self.constructFileNode(info);
            self.dom.table_body.find('tr[data-id=' + data.id + '][data-type='+data.type+']').replaceWith(node);
        });
    }
}
//获取当前文件夹内文件列表
PAN.prototype.getIntoFolder = function () {
    var self = this;
    self.ajax('FolderList', {
        currentFolder: self.currentFolder
    }, function (info) {
        self.constructFiles(info);
    });
}