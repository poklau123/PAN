using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Model;
using System.Web.Security;
using System.Security.Cryptography;
using System.Text;

namespace PAN.Controller
{
    /// <summary>
    /// 用于对权限的控制，如注册与登录
    /// </summary>
    public class AuthController: Controller
    {
        PanDataClassesDataContext db;
        public AuthController()
        {
            db = new PanDataClassesDataContext();
        }

        public void Register()
        {
            string name = this.requestData.name;
            string password = this.requestData.password;
            bool exists = db.users.Where(u => u.name == name).Count() > 0;
            if (exists)
            {
                throw new APIException("账号已被注册", -1);
            }
            else if(String.IsNullOrWhiteSpace(password) || password.Length < 6)
            {
                throw new APIException("账号密码长度错误", APIException.ERROR_PARAMETERS);
            }
            
            db.users.InsertOnSubmit(new users
            {
                name = name,
                password = BitConverter.ToString(new SHA1CryptoServiceProvider().ComputeHash(UTF8Encoding.Default.GetBytes(password)))
            });
            db.SubmitChanges();
        }
    }
}