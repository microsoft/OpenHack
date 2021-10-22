using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using Microsoft.AspNetCore.Authentication.Cookies;

namespace Portal.Web.Helpers
{
    public static class Claims {
        public static ClaimsPrincipal CreatePrincipal(string username, string sid) {
            var claims = new List<Claim> {
                new Claim(ClaimTypes.Name, username),
                new Claim(ClaimTypes.PrimarySid, sid)
            };

            var claimsIdentity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
            return new ClaimsPrincipal(claimsIdentity);
        }

        public static string GetUsername(ClaimsPrincipal user) {
            return user.Claims.Where(c => c.Type == ClaimTypes.Name).Select(c => c.Value).SingleOrDefault();
        }

        public static string GetSid(ClaimsPrincipal user) {
            return user.Claims.Where(c => c.Type == ClaimTypes.PrimarySid).Select(c => c.Value).SingleOrDefault().Replace("\"", "");
        }
    }
}