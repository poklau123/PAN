<%@ WebHandler Language="C#" Class="Handler" %>

using System;
using System.Web;
using System.Web.Script.Serialization;

public class Handler : IHttpHandler {

    /// <summary>
    /// 返回信息数据格式
    /// </summary>
    class RetMessageBag
    {
        public int code { get; set; }           //成功执行时为0,
        public string msg { get; set; }         //当code不为0时此值有效
        public dynamic data { get; set; }        //当code为0时此值有效
    }

    JavaScriptSerializer js = new JavaScriptSerializer();
    RetMessageBag retBag = null;

    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "application/json";

        try
        {
            RequestProcess rp = new RequestProcess(context);
            Object data = rp.run();

            retBag = new RetMessageBag
            {
                code = 0,
                data = data
            };
        }
        catch (APIException e)
        {
            retBag = new RetMessageBag
            {
                code = e.code,
                msg = e.Message
            };
        }
        catch (Exception e)
        {
            retBag = new RetMessageBag
            {
                code = APIException.ERROR_RUNTIME,
                msg = e.Message
            };
        }
        finally
        {
            context.Response.Write(js.Serialize(retBag));
        }        
    }

    public bool IsReusable {
        get {
            return true;
        }
    }

}