using System;
using System.IO;
using System.Reflection;
using System.Web;
using Newtonsoft.Json;
using PAN.Controller;
using PAN.Conf;

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
    private HttpContext httpContext;    
    
    RequestObject requestObj;


    /// <summary>
    /// 构造函数
    /// </summary>
    /// <param name="_context">请求句柄</param>
    public RequestProcess(HttpContext _httpContext)
    {
        this.httpContext = _httpContext;
    }

    /// <summary>
    /// 执行
    /// </summary>
    /// <returns></returns>
    public dynamic run()
    {
        this.getContextControllerAndMethod();
        string namespace_controller = App.Get("Namespace_Controller");
        Type cInfo = null;              //request controller Type
        MethodInfo mInfo = null;        //request method
        try
        {
            cInfo = Type.GetType(namespace_controller + '.' + this.requestObj.controller);
            mInfo = cInfo.GetMethod(this.requestObj.method);
        }
        catch(Exception)
        {
            string errorType = cInfo == null ? "类" : "方法";
            throw new APIException("调用的"+errorType+"不存在", APIException.ERROR_PATH);
        }
        Assembly assembly = Assembly.GetExecutingAssembly();        //加载当前程序集
        object controller = assembly.CreateInstance                 //实例化controller
            (
                namespace_controller+ '.' + this.requestObj.controller,
                true,
                System.Reflection.BindingFlags.Default,
                null,
                null,
                null,
                null
            );
        ((Controller)controller).init(this.httpContext, this.requestObj.data);      //request信息初始化
        cInfo.GetCustomAttributes(false);                                           //Attribute
        mInfo.GetCustomAttributes(false);                                           //Attribute
        mInfo.Invoke(controller, null);                                             //执行方法
        return ((Controller)controller).getResult();                                //获取返回数据
    }

    /// <summary>
    /// 解析请求中的数据
    /// </summary>
    private void getContextControllerAndMethod()
    {
        StreamReader reader = new StreamReader(this.httpContext.Request.InputStream);
        string stringData = reader.ReadToEnd();
        this.requestObj = JsonConvert.DeserializeObject<RequestObject>(stringData);
    }
}