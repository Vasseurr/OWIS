//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace OnlineWarehousingInformationSystem.Models
{
    using System;
    using System.Collections.Generic;
    
    public partial class ordersFromAbroad
    {
        public int orderID { get; set; }
        public string orderDescription { get; set; }
        public System.DateTime orderDate { get; set; }
        public int warehouseID { get; set; }
        public string warehouseName { get; set; }
        public string city { get; set; }
        public Nullable<int> currentCapacity { get; set; }
        public string warehouseStatus { get; set; }
        public string email { get; set; }
    }
}
