using System;

namespace Portal.Processor.Models
{
    public class Account
    {
        public Guid Id { get; set; }
        public Guid UserId { get; set; }
        public string AccountNo { get; set; }
        public bool IsActive { get; set; }
        public decimal CurrentBalance { get; set; }
    }
}