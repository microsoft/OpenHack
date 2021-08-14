using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Portal.Data;
using Portal.Data.Dtos;
namespace Portal.Api.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class AccountsController : ControllerBase
    {
        private readonly ILogger<AccountsController> _logger;
        private readonly PortalContext _context;

        public AccountsController(ILogger<AccountsController> logger, PortalContext context)
        {
            _logger = logger;
            _context = context;
        }

        [HttpGet]
        public List<Account> Get([FromQuery] string id)
        {
            var accounts = _context.Accounts.Where(u => u.UserId == new Guid(id) && u.IsActive).Select(a => 
                                new Account {
                                    Id = a.Id,
                                    UserId = a.UserId,
                                    AccountNo = a.AccountNo,
                                    CurrentBalance = a.CurrentBalance
                                }).ToList();

            return accounts;
        }
    }
}
