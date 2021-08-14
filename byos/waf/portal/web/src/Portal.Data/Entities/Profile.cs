using System;
using System.Collections.Generic;

namespace Portal.Data.Entities
{
    public class Profile
    {
        public Guid UserId { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }

        public virtual User User { get; set; }
    }
}