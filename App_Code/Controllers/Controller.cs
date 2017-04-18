using System.Web;
using System.Web.Script.Serialization;

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

        JavaScriptSerializer js = new JavaScriptSerializer();

        public Controller()
        {

        }
        
        public void init(HttpContext httpContext, dynamic requestData)
        {
            this.httpContext = httpContext;
            this.requestData = requestData;
        }

        public dynamic getResult()
        {
            return js.Serialize(this.resultData);
        }
    }
}