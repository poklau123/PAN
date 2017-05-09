<%@ WebHandler Language="C#" Class="UploadHandler" %>

using System;
using System.Web;
using System.IO;
using Newtonsoft.Json;
using System.Collections.Generic;
using PAN.Conf;
using PAN.Attribute;
using Model;
using System.Linq;
using System.Web.SessionState;

public class UploadHandler : IHttpHandler, IRequiresSessionState
{
    [Authentication]
    public void ProcessRequest(HttpContext context)
    {
        int chunk = Convert.ToInt32(context.Request["chunk"]); //当前分块
        int chunks = Convert.ToInt32(context.Request["chunks"]);//总的分块数量
        string savePath = App.Get("SavePath");                  //文件存储位置
        string tmpPath = App.Get("TmpPath");                   //分片文件临时存储位置
                                                               //如果目录不存在则创建目录
        if (!Directory.Exists(tmpPath))
        {
            Directory.CreateDirectory(tmpPath);
        }
        foreach (string upload in context.Request.Files)
        {
            if (upload != null && upload.Trim() != "")
            {
                System.Web.HttpPostedFile postedFile = context.Request.Files[upload];   //获取客户端上载文件的集合
                string filename = context.Request["filename"]; //获取上传的文件名

                string tmpFileName = filename;
                if (chunks > 0)
                {
                    tmpFileName = chunk + "_" + filename;   //按文件块重命名块文件
                }
                string tmpFilePath = tmpPath + tmpFileName;   //将块文件和临时文件夹路径绑定
                postedFile.SaveAs(tmpFilePath);    //保存上载文件内容

                if (chunks > 0 && chunk + 1 == chunks)    //判断块总数大于1 并且当前分块+1==块总数(指示是否为最后一个分块)
                {
                    string fileGUIDName = System.Guid.NewGuid().ToString();
                    using (FileStream fsw = new FileStream(savePath + fileGUIDName, FileMode.Create, FileAccess.Write))
                    {
                        BinaryWriter bw = new BinaryWriter(fsw);
                        // 遍历文件合并 
                        for (int i = 0; i < chunks; i++)
                        {
                            string tmpStr = tmpPath + i.ToString() + "_" + filename;       //获取第i个文件分片路径
                            bw.Write(File.ReadAllBytes(tmpStr));    //打开一个文件读取流信息，将其写入新文件
                            File.Delete(tmpStr);        //删除指定文件信息
                            bw.Flush(); //清理缓冲区
                        }
                        bool ret = this.InsertIntoDatabase(fileGUIDName, fsw.Length);
                        if (!ret)
                        {
                            fsw.Close();
                        }
                    }

                }

            }
        }
        string jsonRet = JsonConvert.SerializeObject(new { jsonrpc = "2.0", result = "", id = "id" });
        context.Response.ContentType = "application/json";
        context.Response.Write(jsonRet);
    }

    /// <summary>
    /// 将上传文件数据插入数据库
    /// </summary>
    /// <param name="guid"></param>
    /// <param name="size"></param>
    /// <returns></returns>
    private bool InsertIntoDatabase(string guid, decimal size)
    {
        PanDataClassesDataContext db = new PanDataClassesDataContext();
        decimal? folderId;      //上传的文件夹编号(null为根文件夹)
        try
        {
            folderId = Convert.ToDecimal(HttpContext.Current.Request["currentFolder"]);
        }
        catch (Exception)
        {
            folderId = null;
        }
        //检查文件夹是否是当前用户的
        decimal currentUid = HttpContext.Current.Session[App.Get("Authentication")["Key"]];
        var checkFolder = folderId == null || (from c in db.folders
                           where c.use_id == currentUid && Equals(c.id, folderId)
                           select c).Count() > 0;
        if (!checkFolder)
        {
            return false;
        }
        string filename = HttpContext.Current.Request["filename"];
        decimal fileType = this.getFileType(filename);
        try
        {
            db.files.InsertOnSubmit(new files
            {
                fol_id = folderId,
                fil_id = fileType,
                use_id = currentUid,
                name = filename,
                size = size,
                guid = guid,
                softdelete = false,
                created_at = DateTime.Now,
                updated_at = DateTime.Now
            });
            db.users.Where(u => u.id == currentUid).FirstOrDefault().savedsize += size;
            db.SubmitChanges();
            return true;
        }
        catch (Exception)
        {
            return false;
        }
    }

    /// <summary>
    /// 根据文件名返回文件类型
    /// </summary>
    /// <param name="file">文件名</param>
    /// <returns></returns>
    private decimal getFileType(string filename)
    {
        string fileExtension = Path.GetExtension(filename).Trim().ToLower().Substring(1);
        Dictionary<decimal, List<string>> types = App.Get("FileTypes");
        foreach (KeyValuePair<decimal, List<string>> type in types)
        {
            if (type.Value.Contains(fileExtension))
            {
                return type.Key;
            }
        }
        return 6;
    }

    public bool IsReusable
    {
        get
        {
            return true;
        }
    }

}