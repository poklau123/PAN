using System.Collections.Generic;


namespace PAN.Conf
{
    /// <summary>
    /// 系统配置参数
    /// </summary>
    public class App
    {
        /// <summary>
        /// 配置项键值对
        /// </summary>
        public static Dictionary<string, dynamic> dict = new Dictionary<string, dynamic>();

        /// <summary>
        /// 静态构造函数
        /// </summary>
        static App()
        {
            //控制器命名空间
            dict.Add("Namespace_Controller", "PAN.Controller");
            dict.Add("Authentication", new Dictionary<string, dynamic>
            {
                {"Driver", "SESSION"},
                {"Key", "AUTH"},
                {"TimeOut", 120 }
            });
            dict.Add("SavePath", System.AppDomain.CurrentDomain.BaseDirectory + "Storage\\");       //文件存储位置
            dict.Add("TmpPath", System.AppDomain.CurrentDomain.BaseDirectory + "Storage\\Temp\\");  //临时文件存储位置
            dict.Add("FileTypes", new Dictionary<decimal, List<string>> {
                {1, new List<string> { "jpg", "gif", "png", "bmp", "jpeg"} },  //图片
                {2, new List<string> { "txt", "doc", "docx", "xls", "xlsx", "ppt", "pptx"} },  //文档
                {3, new List<string> { "mp4", "avi", "rm", "mov", "wmv", "flv", "3gp", "mkv"} },  //视频
                {4, new List<string> { "mp3", "wav", "wma", "ogg" } },  //音乐
                {5, new List<string> { "rar", "zip", "7z", "tar"} },  //压缩包
                //否则为其它类型
            });
            dict.Add("DownloadSpeed", 300 * 1024);     //下载速度(Byte)
        }

        public static dynamic Get(string _key)
        {
            return dict[_key];
        }
    }
}