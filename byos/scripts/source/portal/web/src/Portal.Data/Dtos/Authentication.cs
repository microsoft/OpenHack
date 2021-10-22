using System.ComponentModel.DataAnnotations;

namespace Portal.Data.Dtos
{
    public class Authentication
    {
        public string Username { get; set; }

        [DataType(DataType.Password)]
        public string Password { get; set; }
    }
}