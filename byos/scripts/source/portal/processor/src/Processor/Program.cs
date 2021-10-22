using System;
using System.Collections.Generic;
using System.Data.Common;
using System.Linq;
using Microsoft.Data.SqlClient;
using Microsoft.Data.Sqlite;
using Microsoft.Extensions.Configuration;
using Portal.Processor.Models;

namespace Portal.Processor
{
    class Program
    {
        static void Main(string[] args)
        {
            var config = GetConfiguration();

            using (var conn = GetConnection(config["ConnectionStrings:PortalContext"])) {
                conn.Open();

                var accounts = GetAccounts(conn);
                UpdateAccounts(conn, accounts);
            }
        }

        private static IConfiguration GetConfiguration()
        {
            var env = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT");
            var builder = new ConfigurationBuilder()
                            .AddJsonFile($"appsettings.json", false, true)
                            .AddJsonFile($"appsettings.{env}.json", true, true)
                            .AddJsonFile($"appsettings.Local.json", true, true)
                            .AddEnvironmentVariables();

            return builder.Build();
        }

        private static DbConnection GetConnection(string connectionString)
        {
            if (connectionString.Contains("Server="))
                return new SqlConnection(connectionString);
            else
                return new SqliteConnection("Filename=" + connectionString);
        }

        private static List<Account> GetAccounts(DbConnection conn)
        {
            List<Account> accounts = new List<Account>();

            var command = conn.CreateCommand();
            command.CommandText = "SELECT * FROM Accounts WHERE [IsActive] = 1";

            using (var reader = command.ExecuteReader())
            {
                while (reader.Read())
                {
                    var account = new Account()
                    {
                        Id = new Guid(reader["Id"].ToString()),
                        UserId = new Guid(reader["UserId"].ToString()),
                        AccountNo = reader["AccountNo"].ToString(),
                        IsActive = Convert.ToBoolean(reader["IsActive"]),
                        CurrentBalance = Convert.ToDecimal(reader["CurrentBalance"].ToString())
                    };

                    accounts.Add(account);
                }
            }


            return accounts;
        }

        private static void UpdateAccounts(DbConnection conn, List<Account> accounts)
        {
            foreach (var account in accounts)
            {
                var lastXtn = GetLastTransaction(conn, account);
                var currBalance = AddTransactions(conn, account, lastXtn);
                UpdateBalance(conn, account, currBalance);
            }
        }

        private static Transaction GetLastTransaction(DbConnection conn, Account account)
        {
            List<Transaction> xtns = new List<Transaction>();
            
            var command = conn.CreateCommand();
            command.CommandText = "SELECT * FROM Transactions WHERE [AccountId] = '" + account.Id.ToString().ToUpper() + "'";
            
            using (var reader = command.ExecuteReader())
            {
                while (reader.Read())
                {
                    var xtn = new Transaction();

                    xtn.Id = new Guid(reader["Id"].ToString());
                    xtn.AccountId = new Guid(reader["AccountId"].ToString());
                    xtn.XtnDate = DateTimeOffset.Parse(reader["XtnDate"].ToString());
                    xtn.Description = reader["Description"].ToString();
                    xtn.XtnType = (TransactionType)Convert.ToInt32(reader["XtnType"]);
                    xtn.Amount = Convert.ToDecimal(reader["Amount"]);
                    xtn.PostedBalance = Convert.ToDecimal(reader["PostedBalance"]);

                    xtns.Add(xtn);
                }
            }

            if (xtns.Count == 0)
                return null;
            else
                return xtns.OrderByDescending(x => x.XtnDate).First();
        }

        private static decimal AddTransactions(DbConnection conn, Account account, Transaction lastXtn)
        {
            bool initialDeposit = lastXtn is null;
            decimal lastBalance = initialDeposit ? 0.0M : lastXtn.PostedBalance;
            DateTimeOffset lastDateTimeOffset = initialDeposit ? DateTimeOffset.Now.AddDays(-3500) : lastXtn.XtnDate;
            DateTime endDate = DateTime.Now;

            var datePtr = lastDateTimeOffset;

            while (datePtr <= endDate)
            {
                var numXtns = new Random().Next(0, 5);

                for (int i = 0; i <= numXtns; i++)
                {
                    datePtr = datePtr.AddTicks(Convert.ToInt64(TimeSpan.TicksPerDay * new Random().NextDouble()));
                    if (datePtr > endDate)
                        break;

                    int xtnType = new Random().Next(1, 3);
                    var amount = Convert.ToDecimal(Convert.ToDecimal(xtnType == 1 ? new Random().NextDouble() * 1000 : new Random().NextDouble() * Convert.ToDouble(lastBalance)).ToString("0.00"));
                    lastBalance = xtnType == 1 || initialDeposit ? lastBalance + amount : lastBalance - amount;

                    var command = conn.CreateCommand();
                    command.CommandText = "INSERT INTO Transactions (Id, AccountId, XtnDate, Description, XtnType, Amount, PostedBalance) VALUES (" +
                                            "'" + Guid.NewGuid().ToString().ToUpper() + "', " +
                                            "'" + account.Id.ToString().ToUpper() + "', " +
                                            "'" + datePtr.ToString() + "', " +
                                            "'" + GetRandomDescripton(initialDeposit, xtnType) + "', " +
                                            xtnType.ToString() + ", " +
                                            "'" + amount.ToString("0.00") + "', " +
                                            "'" + lastBalance.ToString("0.00") + "')";
                    command.ExecuteNonQuery();

                    initialDeposit = false;
                }

                datePtr = DateTime.SpecifyKind(new DateTime(datePtr.Year, datePtr.Month, datePtr.Day, 0, 0, 0).AddDays(1), DateTimeKind.Utc);
            }

            return lastBalance;
        }

        private static void UpdateBalance(DbConnection conn, Account account, Decimal currBalance)
        {
            var command = conn.CreateCommand();
            command.CommandText = "UPDATE Accounts SET CurrentBalance = '" + currBalance.ToString("0.00") + "' WHERE Id = '" + account.Id.ToString().ToUpper() + "'";
            command.ExecuteNonQuery();
        }

        private static string GetRandomDescripton(bool firstXtn, int xtnType) {
            if (firstXtn) 
                return "Opening Balance";

            if (xtnType == 1)
                return "Deposit";

            String[] descriptions = new List<string> { 
                "Dining", 
                "Entertainment",
                "Professional Services",
                "Utilities",
                "Miscellaneous",
                "Transportation",
                "Insurance",
                "Medical & Healthcare",
                "Lawn Care",
                "Phone"
            }.ToArray();
            
            return descriptions[new Random().Next(0, 10)];
        }
    }
}
