using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

using OnlineWarehousingInformationSystem.Models;
namespace OnlineWarehousingInformationSystem.Controllers
{
    public class ShippingController : Controller
    {
        // GET: Shipping
        OWISDBEntities db = new OWISDBEntities();
        public ActionResult Index()
        {
            var shipping = db.Shipping.Where(o => o.packageID > 0).Select(o => o);
            return View(shipping);
        }
        public ActionResult AddShipping(int id)
        {
            Shipping ship = new Shipping();
            ship.packageID = id;
            return View(ship);
        }

        [HttpPost]
        public ActionResult AddShipping(Shipping shipping)
        {
            db.Shipping.Add(shipping);
            db.SaveChanges();
            return RedirectToAction("Index","Packages");
        }

        public ActionResult DetailShipping(int id)
        {
            var query = db.Shipping.Where(o => o.packageID == id).ToList();
            return View(query);
        }

        public ActionResult EditShipping(int id)
        {
            var query = db.Shipping.SingleOrDefault(s => s.packageID == id);
            return View(query);
        }

        [HttpPost]
        public ActionResult EditShipping(Shipping shipping)
        {
            Shipping u_shipping = db.Shipping.Where(o => o.packageID == shipping.packageID).First();
            u_shipping.estimatedDeliveryDate = shipping.estimatedDeliveryDate;
            if (shipping.shippingDate != DateTime.MinValue)
            {
                u_shipping.shippingDate = shipping.shippingDate;
            }
            u_shipping.deliveryDate = shipping.deliveryDate;
            u_shipping.currentLocation = shipping.currentLocation;
            u_shipping.currentStatus = shipping.currentStatus;
            u_shipping.shippingNote = shipping.shippingNote;
            db.SaveChanges();
            return RedirectToAction("Index");
        }

        public RedirectToRouteResult DeleteFromShippings(int id)
        {
            db.Shipping.RemoveRange(db.Shipping.Where(o => o.packageID == id));
            db.SaveChanges();
            return RedirectToAction("Index");
        }
    }
}