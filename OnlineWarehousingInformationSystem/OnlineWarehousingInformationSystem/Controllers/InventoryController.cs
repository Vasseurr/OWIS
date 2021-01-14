using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using OnlineWarehousingInformationSystem.Models;

namespace OnlineWarehousingInformationSystem.Controllers
{
    public class InventoryController : Controller
    {
        OWISDBEntities db = new OWISDBEntities();
        // GET: Inventory
        
        public ActionResult Index()
        {
            var inv = db.Inventory.Where(i => i.productID > 0).Select(i => i);
            return View(inv);
        }
    }
}