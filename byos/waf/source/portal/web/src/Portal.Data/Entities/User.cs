using System;
using System.Collections.Generic;

namespace Portal.Data.Entities
{
    public class User
    {
        public Guid Id { get; set; }
        public string Login { get; set; }
        public string Password { get; set; }
        public DateTimeOffset LastLoginDate { get; set; }
        public DateTimeOffset CurrentLoginDate { get; set; }
        public virtual Profile Profile { get; set; }
        public virtual ICollection<Account> Accounts { get; set; }
    }
}