using System;
using System.Diagnostics;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;

namespace Portal.Data
{
    public class SqlitePortalContext : PortalContext
    {
        public SqlitePortalContext(IConfiguration configuration) : base(configuration) { }

        protected override void OnConfiguring(DbContextOptionsBuilder options)
        {
            var connection = new SqliteConnection("Filename=" + Configuration.GetConnectionString("PortalContext"));
            connection.Open();

            connection.CreateFunction("newid", () => Guid.NewGuid());

            options.UseSqlite(connection, x => x.MigrationsAssembly("Portal.Api"));
            options.LogTo(message => Debug.WriteLine(message));
        }
    }
}