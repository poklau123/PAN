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
                {"Key", "AUTH"}
            });
        }

        public static dynamic Get(string _key)
        {
            return dict[_key];
        }
    }
}