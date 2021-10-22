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
    public class TransactionsController : ControllerBase
    {
        private readonly ILogger<TransactionsController> _logger;
        private readonly PortalContext _context;

        public TransactionsController(ILogger<TransactionsController> logger, PortalContext context)
        {
            _logger = logger;
            _context = context;
        }

        [HttpGet]
        public List<Transaction> Get([FromQuery] string id, [FromQuery] string acct)
        {
            var xtns = _context.Transactions.Where(t => t.Account.UserId == new Guid(id) && t.AccountId == new Guid(acct))
                                            .Select(x => 
                                                new Transaction {
                                                    Id = x.Id,
                                                    XtnDate = x.XtnDate,
                                                    Description = x.Description,
                                                    XtnType = x.XtnType,
                                                    Amount = x.Amount,
                                                    PostedBalance = x.PostedBalance
                                                }).ToList();

            return xtns;
        }
    }
}
