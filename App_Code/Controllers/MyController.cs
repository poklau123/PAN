using PAN.Attribute;
using System;

namespace PAN.Controller
{
    /// <summary>
    /// MyController 的摘要说明
    /// </summary>
    
    public class MyController : Controller
    {
        public MyController()
        {
            
        }

        [Authentication]
        public void MyMethod()
        {
            this.resultData = this.requestData;
        }
    }
}