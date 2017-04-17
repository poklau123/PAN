using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Web;
using System.Web.Script.Serialization;

/// <summary>
/// RequestProcess 的摘要说明
/// </summary>
public class RequestProcess
{
    /// <summary>
    /// 请求的数据格式
    /// </summary>
    class RequestObject
    {
        /// <summary>
        /// 请求要执行的类名
        /// </summary>
        public string controller { get; set; }
        /// <summary>
        /// 请求要执行的方法名
        /// </summary>
        public string method { get; set; }
        /// <summary>
        /// 数据部分
        /// </summary>
        public dynamic data { get; set; }
    }

    /// <summary>
    /// HttpContext句柄
    /// </summary>
    private HttpContext context;    

    private JavaScriptSerializer js = new JavaScriptSerializer();

    RequestObject requestObj;


    /// <summary>
    /// 构造函数
    /// </summary>
    /// <param name="_context">请求句柄</param>
    public RequestProcess(HttpContext _context)
    {
        this.context = _context;
    }

    /// <summary>
    /// 执行
    /// </summary>
    /// <returns></returns>
    public dynamic run()
    {
        this.getContextClassAndMethod();
        Type cInfo = null;
        MethodInfo mInfo = null;
        try
        {
            cInfo = Type.GetType(this.requestObj.controller);
            mInfo = cInfo.GetMethod(this.requestObj.method);
        }
        catch(Exception)
        {
            string errorType = cInfo == null ? "类" : "方法";
            throw new APIException("调用的"+errorType+"不存在", APIException.ERROR_PATH);
        }
        Assembly assembly = Assembly.GetExecutingAssembly();        //加载当前程序集
        object controller = assembly.CreateInstance
            (
                this.requestObj.controller,
                true,
                System.Reflection.BindingFlags.Default,
                null,
                new object[] { this.requestObj.data},
                null,
                null
            );
        dynamic result = mInfo.Invoke(controller, null);
        return result;
    }

    /// <summary>
    /// 解析请求中的数据
    /// </summary>
    private void getContextClassAndMethod()
    {
        StreamReader reader = new StreamReader(this.context.Request.InputStream);
        string stringData = reader.ReadToEnd();
        this.requestObj = js.Deserialize<RequestObject>(stringData);
    }
}