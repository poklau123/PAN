using PAN.Attribute;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Model;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using PAN.Conf;
using System.IO;


namespace PAN.Controller
{
    /// <summary>
    /// JSON.NET的日期格式化
    /// </summary>
    public class DateTimeFormat : IsoDateTimeConverter
    {
        public DateTimeFormat()
        {
            base.DateTimeFormat = "yyyy-MM-dd HH:mm";
        }
    }
    public class NodeData
    {
        public decimal id { get; set; }
        public decimal type { get; set; }
        public string filename { get; set; }
        public bool del { get; set; }
        public string size { get; set; }
        [JsonConverter(typeof(DateTimeFormat))]
        public DateTime time { get; set; }

    }
    /// <summary>
    /// 用户登录后的数据接口
    /// </summary>
    public class HomeController : Controller
    {
        PanDataClassesDataContext db;
        public HomeController()
        {
            db = new PanDataClassesDataContext();
        }

        /// <summary>
        /// 获取我的信息
        /// </summary>
        [Authentication]
        public void MyInfo()
        {
            var ret = (from c in db.users
                       where c.id == this.uid
                       select c).FirstOrDefault();
            this.resultData = new
            {
                id = ret.id,
                name = ret.name.Trim(),
                savedsize = ret.savedsize
            };
        }

        /// <summary>
        /// 新建文件夹
        /// </summary>
        [Authentication]
        public void AddFolder()
        {
            folders folder = new folders
            {
                fol_id = this.requestData.currentFolder,
                use_id = this.uid,
                name = this.requestData.name,
                created_at = DateTime.Now,
                updated_at = DateTime.Now
            };
            db.folders.InsertOnSubmit(folder);
            db.SubmitChanges();
            this.resultData = new NodeData
            {
                id = folder.id,
                type = 0,
                filename = folder.name.Trim(),
                time = folder.updated_at,
                del = false,
                size = "-"
            };
        }

        /// <summary>
        /// 获取文件夹下文件夹或文件数据
        /// </summary>
        [Authentication]
        public void FolderList()
        {
            decimal? currentFolder = this.requestData.currentFolder;

            List<NodeData> retFolder = (from c in db.folders
                                        where Equals(c.fol_id, currentFolder)
                                        orderby c.updated_at descending
                                        select new NodeData
                                        {
                                            id = c.id,
                                            type = 0,
                                            filename = c.name.Trim(),
                                            time = c.updated_at,
                                            del = false,
                                            size = "-"
                                        }).ToList();
            List<NodeData> retFile = (from c in db.files
                                      where Equals(c.softdelete, false) && c.use_id == this.uid && Equals(c.fol_id, currentFolder)
                                      orderby c.updated_at descending
                                      select new NodeData
                                      {
                                          id = c.id,
                                          type = c.fil_id == null ? 6 : (decimal)c.fil_id,
                                          filename = c.name.Trim(),
                                          time = c.updated_at,
                                          del = c.softdelete,
                                          size = c.size.ToString()
                                      }).ToList();

            List<NodeData> ret = retFolder.Concat(retFile).ToList();

            this.resultData = ret;
        }

        /// <summary>
        /// 文件夹或文件重命名
        /// </summary>
        [Authentication]
        public void Rename()
        {
            decimal id = this.requestData.info.id;
            decimal type = this.requestData.info.type;
            string name = this.requestData.name;

            NodeData ret = null;

            if (type == 0)   //文件夹类型
            {
                folders folder = (from c in db.folders
                                  where c.id == id
                                  select c).FirstOrDefault();
                folder.name = name;
                folder.updated_at = DateTime.Now;
                db.SubmitChanges();
                ret = new NodeData
                {
                    id = folder.id,
                    type = 0,
                    filename = folder.name.Trim(),
                    time = folder.updated_at,
                    del = false,
                    size = "-"
                };
            }
            else
            {
                files file = (from c in db.files
                              where c.id == id
                              select c
                              ).FirstOrDefault();
                file.name = name;
                file.updated_at = DateTime.Now;
                db.SubmitChanges();
                ret = new NodeData
                {
                    id = file.id,
                    type = file.fil_id == null ? 6 : (decimal)file.fil_id,
                    filename = file.name.Trim(),
                    time = file.updated_at,
                    del = file.softdelete,
                    size = file.size.ToString()
                };
            }

            this.resultData = ret;
        }

        /// <summary>
        /// 删除文件或文件夹
        /// </summary>
        [Authentication]
        public void Delete()
        {
            decimal id = this.requestData.id;
            decimal type = this.requestData.type;
            //判断是文件夹还是文件
            if (type == 0)
            {
                BFSDeleteFolder(id);
            }
            else
            {
                files file = (from c in db.files
                             where c.id == id
                             select c).FirstOrDefault();
                FileDelete(file);
            }
            this.resultData = null;
        }

        /// <summary>
        /// BFS删除文件夹(软删除)
        /// </summary>
        /// <param name="fid"></param>
        private void BFSDeleteFolder(decimal fid)
        {
            List<decimal> f = (from c in db.folders
                               where c.fol_id == fid
                               select c.id).ToList<decimal>();
            f.ForEach((item) =>
            {
                BFSDeleteFolder(item);
            });

            List<files> file = (from c in db.files
                                where c.fol_id == fid
                                select c).ToList<files>();
            file.ForEach((e) =>
            {
                FileDelete(e);
            });
            db.folders.DeleteOnSubmit(db.folders.Where(u => u.id == fid).FirstOrDefault());
            db.SubmitChanges();
        }

        /// <summary>
        /// 删除文件(软删除)
        /// </summary>
        /// <param name="fid">文件编号</param>
        private void FileDelete(files file)
        {
            string path = App.Get("SavePath");
            if (file != null)
            {
                File.Delete(path + file.guid);
                file.fol_id = null;
                file.softdelete = true;
            }
            db.SubmitChanges();
        }
    }
}