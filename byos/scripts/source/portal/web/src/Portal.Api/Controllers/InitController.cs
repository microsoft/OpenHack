using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Portal.Data;

namespace Portal.Api.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class InitController : ControllerBase
    {
        private readonly ILogger<InitController> _logger;
        private readonly PortalContext _context;

        public InitController(ILogger<InitController> logger, PortalContext context)
        {
            _logger = logger;
            _context = context;
        }

        [HttpGet]
        public void Get()
        {
            // Stub to init the EF data model
        }
    }
}
