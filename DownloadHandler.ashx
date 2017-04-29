<%@ WebHandler Language="C#" Class="DownloadHandler" %>

using System;
using System.Web;
using System.Threading;
using System.Diagnostics;
using System.IO;
using System.Linq;
using Model;
using PAN.Conf;
using System.Collections.Generic;

public class DownloadHandler : IHttpHandler
{

    public void ProcessRequest(HttpContext context)
    {
        PanDataClassesDataContext db = new PanDataClassesDataContext();
        decimal id = Convert.ToDecimal(context.Request.QueryString["id"]);
        files file = (from c in db.files
                      where c.id == id
                      select c).FirstOrDefault();
        string savePath = App.Get("SavePath");
        List<record> record = (from c in db.record
                               where c.fil_id == file.id
                               select c).ToList<record>();
        if (record.Count() > 0)
        {
            record.First().time = DateTime.Now;
        }
        else
        {
            db.record.InsertOnSubmit(new record
            {
                fil_id = file.id,
                time = DateTime.Now
            });
        }

        db.SubmitChanges();
        ResponseFile(context, savePath + file.guid, file.name, (long)App.Get("DownloadSpeed"));
    }

    public bool IsReusable
    {
        get
        {
            return true;
        }
    }

    /// <summary>
    /// 下载文件
    /// </summary>
    /// <param name="context">句柄</param>
    /// <param name="_fullPath">完整文件路径</param>
    /// <param name="_fileName">文件下载默认名称</param>
    /// <param name="_speed">下载速度(Byte)</param>
    /// <returns></returns>
    public static bool ResponseFile(HttpContext context, string _fullPath, string _fileName, long _speed)
    {
        HttpRequest _Request = context.Request;
        HttpResponse _Response = context.Response;
        string strFileName = new FileInfo(_fullPath).Name;
        try
        {
            FileStream myFile = new FileStream(_fullPath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite);
            BinaryReader br = new BinaryReader(myFile);
            try
            {
                _Response.AddHeader("Accept-Ranges", "bytes");
                _Response.Buffer = false;
                long fileLength = myFile.Length;
                long startBytes = 0;

                _Response.AddHeader("Content-Length", (fileLength - startBytes).ToString());
                if (startBytes != 0)
                {
                    _Response.AddHeader("Content-Range", string.Format(" bytes {0}-{1}/{2}", startBytes, fileLength - 1, fileLength));
                }
                _Response.AddHeader("Connection", "Keep-Alive");
                _Response.ContentType = "application/octet-stream";
                _Response.AddHeader("Content-Disposition", "attachment;filename=" + HttpUtility.UrlEncode(_fileName, System.Text.Encoding.UTF8));

                int pack = 10240; //10K bytes       进行拆包,每包大小                   
                byte[] buff = new byte[pack];
                var contentLength = br.Read(buff, 0, pack);
                double d = 1000 / (_speed / pack); // 限速时每个包的时间
                Stopwatch wa = new Stopwatch();
                while (contentLength != 0)
                {
                    if (_Response.IsClientConnected)
                    {
                        wa.Restart();
                        _Response.BinaryWrite(buff);
                        _Response.Flush();
                        contentLength = br.Read(buff, 0, pack);
                        wa.Stop();
                        if (wa.ElapsedMilliseconds < d) //如果实际带宽小于限制时间就不需要等待
                        {
                            Thread.Sleep((int)(d - wa.ElapsedMilliseconds));
                        }
                    }
                    else
                    {
                        break;
                    }
                }
            }
            catch
            {
                return false;
            }
            finally
            {
                br.Close();
                myFile.Close();
            }
        }
        catch
        {
            return false;
        }
        return true;
    }

}