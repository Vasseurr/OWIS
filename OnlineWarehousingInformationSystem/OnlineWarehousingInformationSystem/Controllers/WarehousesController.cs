using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

using OnlineWarehousingInformationSystem.Models;
namespace OnlineWarehousingInformationSystem.Controllers
{
    public class WarehousesController : Controller
    {
        // GET: Warehouses
        OWISDBEntities db = new OWISDBEntities();
        public ActionResult Index()
        {
            var warehouses = db.Warehouses.Where(w => w.warehouseID > 0).Select(w => w);
            return View(warehouses);
        }
        public ActionResult AddWarehouse()
        {
            return View();
        }

        [HttpPost]
        public ActionResult AddWarehouse(Warehouses warehouse)
        {
            warehouse.currentCapacity = 0;
            db.Warehouses.Add(warehouse);
            db.SaveChanges();
            return RedirectToAction("Index");
        }

        public ActionResult DetailWarehouse(int id)
        {
            var query = db.Warehouses.Where(w => w.warehouseID == id).Select(w => w);
            return View(query);
        }

        public ActionResult EditWarehouse(int id)
        {
            var query = db.Warehouses.Find(id);
            return View(query);
        }

        [HttpPost]
        public ActionResult EditWarehouse(Warehouses warehouse)
        {
            Warehouses u_warehouse = db.Warehouses.Where(w => w.warehouseID == warehouse.warehouseID).FirstOrDefault();
            if (u_warehouse.currentCapacity > warehouse.maxCapacity)
            {
                ModelState.AddModelError("", "Current capacity could not be more than max capacity!");
                var query = db.Warehouses.Find(warehouse.warehouseID);
                return View(query);
            }
            u_warehouse.maxCapacity = warehouse.maxCapacity;
            u_warehouse.warehouseName = warehouse.warehouseName;
            u_warehouse.country = warehouse.country;
            u_warehouse.city = warehouse.city;
            u_warehouse.warehouseAddress = warehouse.warehouseAddress;
            u_warehouse.ZIP = warehouse.ZIP;
            u_warehouse.warehouseStatus = warehouse.warehouseStatus;
            u_warehouse.phoneNumber = warehouse.phoneNumber;
            u_warehouse.email = warehouse.email;
            db.SaveChanges();
            return RedirectToAction("Index");
        }

        public RedirectToRouteResult DeleteFromWarehouses(int id)
        {
            db.Warehouses.RemoveRange(db.Warehouses.Where(w => w.warehouseID == id));
            db.SaveChanges();
            return RedirectToAction("Index");
        }

        public ActionResult ShowContents(int id)
        {
            var query = db.WarehouseContents.Where(w => w.warehouseID == id).Select(w => w);
            return View(query);
        }
    }
}