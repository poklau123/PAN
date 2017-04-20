using PAN.Attribute;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Model;


namespace PAN.Controller
{
    /// <summary>
    /// 用户登录后的数据接口
    /// </summary>
    public class HomeController : Controller
    {
        PanDataClassesDataContext db;
        public HomeController()
        {
            db = new PanDataClassesDataContext();
        }

        /// <summary>
        /// 获取我的信息
        /// </summary>
        [Authentication]
        public void MyInfo()
        {
            var ret = (from c in db.users
                       where c.id == this.uid
                       select c).FirstOrDefault();
            this.resultData = new
            {
                id = ret.id,
                name = ret.name.Trim(),
                savedsize = ret.savedsize
            };  
        }
    }
}