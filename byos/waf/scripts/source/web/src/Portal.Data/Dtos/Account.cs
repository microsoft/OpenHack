using System;

namespace Portal.Data.Dtos
{
    public class Account
    {
        public Guid Id { get; set; }
        public Guid UserId { get; set; }
        public string AccountNo { get; set; }
        public decimal CurrentBalance { get; set; }
    }
}