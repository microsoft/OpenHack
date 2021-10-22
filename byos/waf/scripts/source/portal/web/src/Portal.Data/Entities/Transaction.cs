using System;

namespace Portal.Data.Entities
{
    public class Transaction
    {
        public Guid Id { get; set; }
        public Guid AccountId { get; set; }
        public DateTimeOffset XtnDate { get; set; }
        public string Description { get; set; }
        public TransactionType XtnType { get; set; }
        public decimal Amount { get; set; }
        public decimal PostedBalance { get; set; }

        public virtual Account Account { get; set; }
    }
}