using System;

namespace Portal.Data.Dtos
{
    public class Profile
    {
        public Guid Id { get; set; }
        public DateTimeOffset LastLoginDate { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
    }
}