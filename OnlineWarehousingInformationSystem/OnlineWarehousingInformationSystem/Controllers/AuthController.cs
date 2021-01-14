using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

using OnlineWarehousingInformationSystem.Models;

namespace OnlineWarehousingInformationSystem.Controllers
{
    public class AuthController : Controller
    {
        // GET: Auth
        OWISDBEntities db = new OWISDBEntities();
        public ActionResult Login()
        {
            return View();
        }

        [HttpPost]
        public ActionResult Login(LoginModel login)
        {
            if (ModelState.IsValid)
            {
                OWISDBEntities db = new OWISDBEntities();
                var user = (from userlist in db.Users
                            where userlist.userName == login.UserName && userlist.userPassword == login.Password
                            select new
                            {
                                userlist.userID,
                                userlist.userName,
                                userlist.firstName,
                                userlist.lastName,
                                userlist.userType,
                                userlist.userGender
                            }).ToList();
                if (user.FirstOrDefault() != null)
                {
                    Session["Name"] = user.FirstOrDefault().firstName;
                    Session["Surname"] = user.FirstOrDefault().lastName;
                    Session["UserName"] = user.FirstOrDefault().userName;
                    Session["UserID"] = user.FirstOrDefault().userID;
                    Session["UserType"] = user.FirstOrDefault().userType;
                    int userID = Convert.ToInt32(Session["UserID"].ToString());
                    if (user.FirstOrDefault().userType.Equals("1"))
                    {
                        var staff = (from st in db.Staff where st.userID == userID select new { st.staffID, st.warehouseID }).ToList();
                        Session["StaffID"] = staff.FirstOrDefault().staffID;
                    }
                    return Redirect("/Main/Index");
                }
                else
                {
                    ModelState.AddModelError(string.Empty, "The user name or password is incorrect");
                }
            }
            return View(login);
        }

        public ActionResult Logout()
        {

            Session.Clear();
            return Redirect("Login");
        }
    }
}