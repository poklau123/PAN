using System;

/// <summary>
/// 自定义异常，拓展异常代码(code)
/// </summary>
public class APIException : Exception
{
    /// <summary>
    /// 异常代码
    /// </summary>
    public int code { get; set; }

    /// <summary>
    /// 未登录
    /// </summary>
    public const int ERROR_NOLOGIN = 1;
    /// <summary>
    /// 参数错误
    /// </summary>
    public const int ERROR_PARAMETERS = 2;
    /// <summary>
    /// 运行错误
    /// </summary>
    public const int ERROR_RUNTIME = 3;
    /// <summary>
    /// 调用路径错误（controller对应的类或method对应的方法不存在）
    /// </summary>
    public const int ERROR_PATH = 4;

    /// <summary>
    /// 构造函数
    /// </summary>
    /// <param name="message">错误消息</param>
    /// <param name="code">错误代码</param>
    public APIException(string message, int code = 1):base(message)
    {
        this.code = code;
    }
}