using System;
using System.Web;
using PAN.Conf;

namespace PAN.Controller
{
    /// <summary>
    /// 控制器基类Controller
    /// </summary>
    public abstract class Controller
    {
        /// <summary>
        /// Http句柄
        /// </summary>
        protected HttpContext httpContext;
        /// <summary>
        /// 传入数据
        /// </summary>
        protected dynamic requestData;
        /// <summary>
        /// 传出数据
        /// </summary>
        protected dynamic resultData;
        
        public Controller()
        {
            resultData = null;
        }
        
        /// <summary>
        /// 初始化
        /// </summary>
        /// <param name="httpContext"></param>
        /// <param name="requestData"></param>
        public void init(HttpContext httpContext, dynamic requestData)
        {
            this.httpContext = httpContext;
            this.requestData = requestData;
        }

        /// <summary>
        /// 获取控制器处理的结果（传出数据）
        /// </summary>
        /// <returns></returns>
        public dynamic getResult()
        {
            return this.resultData;
        }

        public Int32 uid
        {
            get
            {
                return Convert.ToInt32(this.httpContext.Session[App.Get("Authentication")["Key"]]);
            }
        }
    }
}