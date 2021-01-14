using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace OnlineWarehousingInformationSystem.Models
{
    public class LoginModel
    {
        [Required(ErrorMessage = "Please enter user name.")]
        [DataType(DataType.Text)]
        [Display(Name = "Username")]
        [StringLength(20)]
        public string UserName { get; set; }

        [Required(ErrorMessage = "Please enter password.")]
        [DataType(DataType.Password)]
        [Display(Name = "Password")]
        [StringLength(20)]
        public string Password { get; set; }

        [Display(Name = "Remember Me")]
        public bool remember { get; set; }

        [Table("tblUser")]
        public class tblUser
        {
            [Key]
            [DatabaseGeneratedAttribute(DatabaseGeneratedOption.Identity)]
            public int UserID { get; set; }
            public string UserName { get; set; }
            public string Password { get; set; }
        }
    }
}