using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using OnlineWarehousingInformationSystem.Models;

namespace OnlineWarehousingInformationSystem.Controllers
{
    public class SuppliersController : Controller
    {
        // GET: Suppliers
        OWISDBEntities db = new OWISDBEntities();
        public ActionResult Index()
        {
            var suppliers = db.Suppliers.Where(s => s.supplierID > 0).Select(s => s);
            return View(suppliers);
        }
        public ActionResult AddSupplier()
        {
            return View();
        }

        [HttpPost]
        public ActionResult AddSupplier(Suppliers supplier)
        {
            db.Suppliers.Add(supplier);
            db.SaveChanges();
            return RedirectToAction("Index");
        }

        public ActionResult DetailSupplier(int id)
        {
            var query = db.Suppliers.Where(s => s.supplierID == id).Select(s => s);
            return View(query);
        }

        public ActionResult EditSupplier(int id)
        {
            var query = db.Suppliers.Find(id);
            return View(query);
        }

        [HttpPost]
        public ActionResult EditSupplier(Suppliers supplier)
        {
            Suppliers u_supplier = db.Suppliers.Where(s => s.supplierID == supplier.supplierID).FirstOrDefault();
            u_supplier.supplierName = supplier.supplierName;
            u_supplier.country = supplier.country;
            u_supplier.city = supplier.city;
            u_supplier.supplierAddress = supplier.supplierAddress;
            u_supplier.phoneNumber = supplier.phoneNumber;
            u_supplier.email = supplier.email;
            db.SaveChanges();
            return RedirectToAction("Index");
        }

        public RedirectToRouteResult DeleteFromSuppliers(int id)
        {
            db.Suppliers.RemoveRange(db.Suppliers.Where(s => s.supplierID == id));
            db.SaveChanges();
            return RedirectToAction("Index");
        }
    }
}