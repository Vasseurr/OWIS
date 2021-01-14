using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

using OnlineWarehousingInformationSystem.Models;
namespace OnlineWarehousingInformationSystem.Controllers
{
    public class ProductsController : Controller
    {
        // GET: Products
        OWISDBEntities db = new OWISDBEntities();
        public ActionResult Index()
        {
            var products = db.Products.Where(p => p.productID > 0).Select(p => p);
            return View(products);
        }

        public ActionResult AddProduct()
        {
            return View();
        }

        [HttpPost]
        public ActionResult AddProduct(Products product)
        {
            db.Products.Add(product);
            db.SaveChanges();
            return RedirectToAction("Index");
        }

        public ActionResult DetailProduct(int id)
        {
            var query = db.Products.Where(p => p.productID == id).Select(p => p);
            return View(query);
        }

        public ActionResult EditProduct(int id)
        {
            var query = db.Products.Find(id);
            return View(query);
        }

        [HttpPost]
        public ActionResult EditProduct(Products product)
        {
            Products u_product = db.Products.Where(p => p.productID == product.productID).FirstOrDefault();
            u_product.productName = product.productName;
            u_product.manufacturer = product.manufacturer;
            u_product.productWeight = product.productWeight;
            u_product.productDescription = product.productDescription;
            db.SaveChanges();
            return RedirectToAction("Index");
        }

        public RedirectToRouteResult DeleteFromProducts(int id)
        {
            db.Products.RemoveRange(db.Products.Where(p => p.productID == id));
            db.SaveChanges();
            return RedirectToAction("Index");
        }
    }
}