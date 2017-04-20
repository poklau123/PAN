using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Model;
using System.Web.Security;
using System.Security.Cryptography;
using System.Text;
using PAN.Conf;

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
        
        /// <summary>
        /// 用户注册
        /// </summary>
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

        /// <summary>
        /// 用户登录
        /// </summary>
        public void Login()
        {
            string name = this.requestData.name;
            string password = this.requestData.password;

            if(String.IsNullOrWhiteSpace(name) || String.IsNullOrWhiteSpace(password))
            {
                throw new APIException("请正确输入账号密码",APIException.ERROR_PARAMETERS);
            }

            users user = (from c in db.users
                          where c.name == name
                          select c).FirstOrDefault();
            if(user == null)
            {
                throw new APIException("用户不存在", -1);
            }
            if(user.password.Trim() != BitConverter.ToString(new SHA1CryptoServiceProvider().ComputeHash(UTF8Encoding.Default.GetBytes(password))))
            {
                throw new APIException("用户密码错误", -1);
            }

            Dictionary<string, dynamic> authentication = App.Get("Authentication");
            this.httpContext.Session[authentication["Key"]] = user.id;
            this.httpContext.Session.Timeout = (int)authentication["TimeOut"];

            this.resultData = new
            {
                id = user.id,
                name = user.name,
                savedsize = user.savedsize
            };
        }

        /// <summary>
        /// 退出登录
        /// </summary>
        public void Logout()
        {
            Dictionary<string, dynamic> authentication = App.Get("Authentication");
            this.httpContext.Session[authentication["Key"]] = null;
        }
    }
}