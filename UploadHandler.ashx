<%@ WebHandler Language="C#" Class="UploadHandler" %>

using System;
using System.Web;
using System.IO;
using Newtonsoft.Json;

public class UploadHandler : IHttpHandler
{

    public void ProcessRequest(HttpContext context)
    {
        string msg = string.Empty;
        int chunk = Convert.ToInt32(context.Request["chunk"]); //当前分块
        int chunks = Convert.ToInt32(context.Request["chunks"]);//总的分块数量
        foreach (string upload in context.Request.Files)
        {
            if (upload != null && upload.Trim() != "")
            {
                string path = AppDomain.CurrentDomain.BaseDirectory + "Temp\\";
                if (!Directory.Exists(path))    //判断给定的路径上是否存在该目录
                {
                    Directory.CreateDirectory(path);    //不存在则创建该目录
                }
                System.Web.HttpPostedFile postedFile = context.Request.Files[upload];   //获取客户端上载文件的集合
                string filename = context.Request["filename"]; //

                string newFileName = filename;
                if (chunks > 1)
                {
                    newFileName = chunk + "_" + filename;   //按文件块重命名块文件
                }
                string fileNamePath = path + newFileName;   //将块文件和临时文件夹路径绑定
                postedFile.SaveAs(fileNamePath);    //保存上载文件内容

                if (chunks > 1 && chunk + 1 == chunks)    //判断块总数大于1 并且当前分块+1==块总数(指示是否为最后一个分块)
                {
                    using (FileStream fsw = new FileStream(path + filename, FileMode.Create, FileAccess.Write))
                    {
                        BinaryWriter bw = new BinaryWriter(fsw);
                        // 遍历文件合并 
                        for (int i = 0; i < chunks; i++)
                        {
                            bw.Write(System.IO.File.ReadAllBytes(path + i.ToString() + "_" + filename));    //打开一个文件读取流信息，将其写入新文件
                            System.IO.File.Delete(path + i.ToString() + "_" + filename);        //删除指定文件信息
                            bw.Flush(); //清理缓冲区
                        }
                    }

                }

            }
        }
        string jsonRet = JsonConvert.SerializeObject(new { jsonrpc = "2.0", result = "", id = "id" });
        context.Response.ContentType = "application/json";
        context.Response.Write(jsonRet);
    }

    public bool IsReusable
    {
        get
        {
            return true;
        }
    }

}