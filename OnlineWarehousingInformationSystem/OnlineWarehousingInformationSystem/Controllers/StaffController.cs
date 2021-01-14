using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using OnlineWarehousingInformationSystem.Models;

namespace OnlineWarehousingInformationSystem.Controllers
{
    public class StaffController : Controller
    {
        OWISDBEntities db = new OWISDBEntities();
        public ActionResult Index()
        {
            var staff = db.Staff.Where(s => s.staffID > 0).Select(s => s);
            return View(staff);
        }

        public ActionResult EditStaff(int id)
        {
            var query = db.Staff.Find(id);
            return View(query);
        }

        [HttpPost]
        public ActionResult EditStaff(Staff staff)
        {
            Staff u_staff = db.Staff.Where(s => s.staffID == staff.staffID).FirstOrDefault();
            u_staff.title = staff.title;
            u_staff.warehouseID = staff.warehouseID;
            u_staff.userID = staff.userID;
            db.SaveChanges();
            return RedirectToAction("Index");
        }

    }
}