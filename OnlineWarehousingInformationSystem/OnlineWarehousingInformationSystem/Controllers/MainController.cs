using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using OnlineWarehousingInformationSystem.Models;

namespace OnlineWarehousingInformationSystem.Controllers
{
    public class MyViewModel
    {
        public List<Packages> Package { get; set; }
        public List<Shipping> Shipping { get; set; }

        public MyViewModel()
        {
            this.Shipping = new List<Shipping>();
            this.Package = new List<Packages>();
        }
    }
    public class MainController : Controller
    {
        OWISDBEntities db = new OWISDBEntities();
        public ActionResult Index()
        {
            var rec = new List<Tuple<int,string,string>>
            {
                new Tuple<int,string,string>(db.Users.Count(),"User" , "Users"),
                new Tuple<int,string,string>(db.Warehouses.Count(),"Warehouse" , "Warehouses"),
                new Tuple<int,string,string>(db.Products.Count(),"Product" , "Products"),
                new Tuple<int,string,string>(db.Suppliers.Count(),"Supplier" , "Suppliers"),
                new Tuple<int,string,string>(db.Packages.Count(),"Package" , "Packages"),
                new Tuple<int,string,string>(db.Shipping.Count(),"Shipping" , "Shipping"),
            };
            ViewData["rec"] = rec;
            return View(ViewData);
        }

        public ActionResult Tracking(int search = -1)
        {
            int id;
            MyViewModel package = new MyViewModel();
            package.Package = db.Packages.Where(x => x.packageID == search || search == null).ToList();
            if (search != -1)
            {
                if (package.Package.Count() == 0)
                {
                    ViewData["non"] = true;
                    return View(package);
                }
                else
                {
                    id = package.Package.First().packageID;
                    package.Shipping = db.Shipping.Where(x => x.packageID == id).ToList();
                    ViewData["non"] = false;
                    return View(package);
                }
            }
            else if (search == -1)
            {
                ViewData["non"] = false;
                return View(package);
            }
            return View(package);
        }
    }
}