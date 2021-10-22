using System;
using System.Collections.Generic;

namespace Portal.Data.Entities
{
    public class Account
    {
        public Guid Id { get; set; }
        public Guid UserId { get; set; }
        public string AccountNo { get; set; }
        public bool IsActive { get; set; }
        public decimal CurrentBalance { get; set; }

        public virtual User User { get; set; }
        public virtual ICollection<Transaction> Transactions { get; set; }
    }
}