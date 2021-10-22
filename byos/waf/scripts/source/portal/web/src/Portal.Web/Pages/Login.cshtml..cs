using System;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Portal.Data.Dtos;
using Newtonsoft.Json;
using System.Text;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication;
using Portal.Web.Helpers;

namespace Portal.Web.Pages
{
    public class LoginModel : PageModel
    {
        private readonly ILogger<LoginModel> _logger;
        private readonly IConfiguration _configuration;

        public LoginModel(ILogger<LoginModel> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;
        }

        public async Task<IActionResult> OnPost([FromForm] Authentication auth)
        {
            var api = _configuration.GetValue<string>("API.BASEURL");
            var content = new StringContent(JsonConvert.SerializeObject(auth), Encoding.UTF8, "application/json");

            using (var client = new HttpClient())
            {
                client.BaseAddress = new Uri(api);
                var result = await client.PostAsync("Users/Authenticate", content);
                var resultContent = await result.Content.ReadAsStringAsync();

                if (result.IsSuccessStatusCode) {
                    await HttpContext.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme, Claims.CreatePrincipal(auth.Username, resultContent));
                    return RedirectToPage("/Accounts");
                }
            }

            ModelState.AddModelError("", "Login unsuccessful. Please try again.");
            return Page();
        }
    }
}
