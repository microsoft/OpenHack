using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Portal.Data;
using Portal.Data.Entities;
using Portal.Data.Dtos;
using Microsoft.AspNetCore.Identity;

namespace Portal.Api.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class UsersController : ControllerBase
    {
        private readonly ILogger<UsersController> _logger;
        private readonly PortalContext _context;

        public UsersController(ILogger<UsersController> logger, PortalContext context)
        {
            _logger = logger;
            _context = context;
        }

        [HttpPost]
        [Route("Authenticate")]
        public IActionResult Authenticate([FromBody] Authentication auth) {
            var user = _context.Users.SingleOrDefault(u => u.Login == auth.Username);

            if (user is null)
                return new NotFoundResult();

            var passwordHasher = new PasswordHasher<string>();
            if (passwordHasher.VerifyHashedPassword(null, user.Password, auth.Password) == PasswordVerificationResult.Success) {
                user.LastLoginDate = user.CurrentLoginDate;
                user.CurrentLoginDate = DateTimeOffset.Now;
                _context.SaveChanges();
                return new OkObjectResult(user.Id);
            } else {
                return new UnauthorizedResult();
            }
        }
    }
}
