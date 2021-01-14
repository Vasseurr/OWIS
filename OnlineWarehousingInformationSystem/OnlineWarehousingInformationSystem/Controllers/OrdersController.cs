using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

using OnlineWarehousingInformationSystem.Models;
namespace OnlineWarehousingInformationSystem.Controllers
{
    public class OrdersController : Controller
    {
        public class MyViewModel
        {
            public List<Orders> Order { get; set; }
            public List<Packages> Packages { get; set; }

            public MyViewModel()
            {
                this.Packages = new List<Packages>();
                this.Order = new List<Orders>();
            }
        }
        // GET: Orders
        OWISDBEntities db = new OWISDBEntities();
        public ActionResult Index()
        {
            MyViewModel query = new MyViewModel();
            query.Order = db.Orders.Where(o => o.orderID > 0).Select(o => o).ToList();
            int ordrcnt = query.Order.Count();
            foreach (var item in query.Order)
            {
                query.Packages = db.Packages.Where(o => o.orderID == item.orderID).Select(o => o).ToList();
            }
            return View(query);
        }
        public ActionResult AddOrder()
        {
            return View();
        }

        [HttpPost]
        public ActionResult AddOrder(Orders order)
        {
            if(Session["StaffID"] != null)
                order.staffID = Convert.ToInt32(Session["StaffID"].ToString());
            db.Orders.Add(order);
            db.SaveChanges();
            return RedirectToAction("AddPayment", new { orderID = order.orderID });
        }

        public ActionResult AddPayment(int orderID)
        {
            var payment = new Payments();
            payment.orderID = orderID;
            var query = (from order in db.Orders
                         where order.orderID == orderID
                         select new
                         {
                             order.orderDate
                         }).ToList();
            payment.operationDate = query.FirstOrDefault().orderDate;
            return View(payment);
        }

        [HttpPost]
        public ActionResult AddPayment(Payments payment)
        {
            if (ModelState.IsValid)
            {
                db.Payments.Add(payment);
                db.SaveChanges();
                return RedirectToAction("Index");
            }
            return View(payment);    
        }

        public ActionResult DetailOrder(int id)
        {
            MyViewModel query = new MyViewModel();
            query.Order = db.Orders.Where(o => o.orderID == id).Select(o => o).ToList();
            query.Packages = db.Packages.Where(o => o.orderID == id).Select(o => o).ToList();
            return View(query);
        }

    public ActionResult EditOrder(int id)
        {
            var query = db.Orders.Find(id);
            return View(query);
        }

        [HttpPost]
        public ActionResult EditOrder(Orders order)
        {
            Orders u_order = db.Orders.Where(o => o.orderID == order.orderID).FirstOrDefault();
            u_order.warehouseID = order.warehouseID;
            u_order.orderDescription = order.orderDescription;
            u_order.orderDate = order.orderDate;
            db.SaveChanges();
            return RedirectToAction("Index");
        }

        public RedirectToRouteResult DeleteFromOrders(int id)
        {
            db.Orders.RemoveRange(db.Orders.Where(o => o.orderID == id));
            db.SaveChanges();
            return RedirectToAction("Index");
        }
    }
}