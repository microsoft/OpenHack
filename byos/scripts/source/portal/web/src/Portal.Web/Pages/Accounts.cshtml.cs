using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Security.Claims;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Portal.Web.Helpers;
using Newtonsoft.Json;
using Portal.Data.Dtos;

namespace Portal.Web.Pages
{
    public class AccountsModel : PageModel
    {
        private readonly ILogger<AccountsModel> _logger;
        private readonly IConfiguration _configuration;
        public Profile Profile = null;
        public Account CurrentAccount = null;
        public List<Account> Accounts = null;
        public IEnumerable<Transaction> Transactions = null;
        
        public AccountsModel(ILogger<AccountsModel> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;
        }

        public void OnGet()
        {
            this.Profile = GetProfile().Result;
            this.Accounts = GetAccounts().Result;
            this.CurrentAccount = this.Accounts.First();
            this.Transactions = GetTransactions().Result;
        }

        private async Task<Profile> GetProfile() 
        {
            var api = _configuration.GetValue<string>("API.BASEURL");
            
            using (var client = new HttpClient())
            {
                client.BaseAddress = new Uri(api);
                var result = await client.GetAsync("Profiles?id=" + Claims.GetSid(User));
                var resultContent = JsonConvert.DeserializeObject<Profile>(await result.Content.ReadAsStringAsync());

                if (result.IsSuccessStatusCode) {
                    return resultContent;
                } else {
                    throw new Exception();
                }
            }
        }

        private async Task<List<Account>> GetAccounts() 
        {
            var api = _configuration.GetValue<string>("API.BASEURL");
            
            using (var client = new HttpClient())
            {
                client.BaseAddress = new Uri(api);
                var result = await client.GetAsync("Accounts?id=" + Claims.GetSid(User));
                var resultContent = JsonConvert.DeserializeObject<List<Account>>(await result.Content.ReadAsStringAsync());

                if (result.IsSuccessStatusCode) {
                    return resultContent;
                } else {
                    throw new Exception();
                }
            }
        }

        private async Task<IEnumerable<Transaction>> GetTransactions() 
        {
            var api = _configuration.GetValue<string>("API.BASEURL");
            
            using (var client = new HttpClient())
            {
                client.BaseAddress = new Uri(api);
                var result = await client.GetAsync("Transactions?id=" + Claims.GetSid(User) + "&acct=" + this.CurrentAccount.Id);
                var resultContent = JsonConvert.DeserializeObject<List<Transaction>>(await result.Content.ReadAsStringAsync());

                if (result.IsSuccessStatusCode) {
                    return resultContent.OrderByDescending(x => x.XtnDate).Take(60);
                } else {
                    throw new Exception();
                }
            }
        }
    }
}
