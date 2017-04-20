<%@ WebHandler Language="C#" Class="Handler" %>

using System;
using System.Web;
using System.Web.SessionState;
using Newtonsoft.Json;


public class Handler : IHttpHandler, IRequiresSessionState  {

    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "application/json";
        object retBag = null;
        try
        {
            RequestProcess rp = new RequestProcess(context);
            Object data = rp.run();

            retBag = new
            {
                code = 0,
                data = data
            };
        }
        catch (APIException e)
        {
            retBag = new
            {
                code = e.code,
                msg = e.Message
            };
        }
        catch (Exception e)
        {
            e = e.InnerException == null ? e : e.InnerException;
            retBag = new
            {
                code = APIException.ERROR_RUNTIME,
                msg = e.Message
            };
        }
        finally
        {
            context.Response.Write(JsonConvert.SerializeObject(retBag, Formatting.Indented, new JsonSerializerSettings{ NullValueHandling = NullValueHandling.Ignore}));
        }
    }

    public bool IsReusable {
        get {
            return true;
        }
    }

}