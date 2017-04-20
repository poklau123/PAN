using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.SessionState;
using PAN.Conf;

namespace PAN.Attribute
{
    /// <summary>
    /// 验证登录身份的特性
    /// </summary>
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Method, AllowMultiple = true)]    
    public class AuthenticationAttribute : System.Attribute
    {
        public AuthenticationAttribute()
        {
            dynamic session = HttpContext.Current.Session[App.Get("Authentication")["Key"]];
            if(session == null)
            {
                throw new APIException("请登录后操作", APIException.ERROR_NOLOGIN);
            }            
        }
    }
}