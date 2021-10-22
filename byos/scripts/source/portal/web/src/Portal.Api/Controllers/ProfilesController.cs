using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Portal.Data;
using Portal.Data.Dtos;

namespace Portal.Api.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ProfilesController : ControllerBase
    {
        private readonly ILogger<ProfilesController> _logger;
        private readonly PortalContext _context;

        public ProfilesController(ILogger<ProfilesController> logger, PortalContext context)
        {
            _logger = logger;
            _context = context;
        }

        [HttpGet]
        public IActionResult Get([FromQuery] string id)
        {
            var user = _context.Users.Include("Profile").SingleOrDefault(u => u.Id == new Guid(id));
            if (user is null)
                return new NotFoundResult();

            var profile = new Profile() {
                Id = user.Id,
                FirstName = user.Profile.FirstName,
                LastName = user.Profile.LastName,
                LastLoginDate = user.LastLoginDate
            };

            return new OkObjectResult(profile);
        }
    }
}
