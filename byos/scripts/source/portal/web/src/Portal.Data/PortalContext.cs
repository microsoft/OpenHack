using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.SqlServer;
using Microsoft.Extensions.Configuration;
using Portal.Data.Entities;

namespace Portal.Data
{
    public class PortalContext : DbContext
    {
        protected readonly IConfiguration Configuration;

        public PortalContext(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        protected override void OnConfiguring(DbContextOptionsBuilder options)
        {
            options.UseSqlServer(Configuration.GetConnectionString("PortalContext"), x => x.MigrationsAssembly("Portal.Api"));
        }

        public DbSet<User> Users { get; set; }
        public DbSet<Profile> Profiles { get; set; }
        public DbSet<Account> Accounts { get; set; }
        public DbSet<Transaction> Transactions { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            User[] users = new List<User>() {
                new User() {
                    Id = Guid.NewGuid(),
                    Login = "dmelamed3244", 
                    Password = "AQAAAAEAACcQAAAAEDIqmsf247/x1et+A3X8EuUmi28a5qv3y+5zap7qLx1wKggXy4pYAqb4IdbYbXF7GA==", 
                    LastLoginDate = DateTimeOffset.MinValue,
                    Profile = new Profile() {
                        
                        FirstName = "Daniel",
                        LastName = "Melamed"
                    },
                    Accounts = new List<Account> {
                        new Account() {
                            Id = Guid.NewGuid(),
                            AccountNo = "686847363244",
                            IsActive = true,
                            CurrentBalance = 0M
                        }
                    }
                },
                new User() {
                    Id = Guid.NewGuid(),
                    Login = "tniu5629", 
                    Password = "AQAAAAEAACcQAAAAEBpBdRt4iTKKnJGc1m9LPXHpSIeUb0McYEjeGg2v5bHUQlJGJROTMTj2V7Is45M8xQ==", 
                    LastLoginDate = DateTimeOffset.MinValue,
                    Profile = new Profile() {
                        FirstName = "Ting",
                        LastName = "Niu"
                    },
                    Accounts = new List<Account> {
                        new Account() {
                            Id = Guid.NewGuid(),
                            AccountNo = "815571025629",
                            IsActive = true,
                            CurrentBalance = 0M
                        }
                    }
                }
            }.ToArray();

            modelBuilder.Entity<User>(user =>
            {
                user.HasKey(u => u.Id);
                user.Property(u => u.Id)
                    .IsRequired()
                    .HasDefaultValueSql("NEWID()");
                user.Property(u => u.Login)
                    .IsRequired()
                    .HasMaxLength(25);
                user.Property(u => u.Password)
                    .IsRequired()
                    .HasMaxLength(255);

                user.HasOne(u => u.Profile)
                    .WithOne(p => p.User);

                user.HasData(new User() { Id = users[0].Id, Login = users[0].Login, Password = users[0].Password, LastLoginDate = users[0].LastLoginDate });
                user.HasData(new User() { Id = users[1].Id, Login = users[1].Login, Password = users[1].Password, LastLoginDate = users[1].LastLoginDate });
            });

            modelBuilder.Entity<Profile>(profile =>
            {
                profile.HasKey(p => p.UserId);
                profile.Property(p => p.UserId)
                    .IsRequired();
                profile.Property(p => p.FirstName)
                    .IsRequired()
                    .HasMaxLength(25);
                profile.Property(p => p.LastName)
                    .IsRequired()
                    .HasMaxLength(25);

                profile.HasOne(p => p.User)
                    .WithOne(u => u.Profile);

                profile.HasData(new Profile() { UserId = users[0].Id, FirstName = users[0].Profile.FirstName, LastName = users[0].Profile.LastName});
                profile.HasData(new Profile() { UserId = users[1].Id, FirstName = users[1].Profile.FirstName, LastName = users[1].Profile.LastName});
            });

            modelBuilder.Entity<Account>(account =>
            {
                account.HasKey(a => a.Id);
                account.Property(a => a.Id)
                    .IsRequired()
                    .HasDefaultValueSql("NEWID()");
                account.Property(a => a.AccountNo)
                    .IsRequired();
                account.Property(a => a.IsActive)
                    .HasDefaultValue(true);
                account.Property(a => a.CurrentBalance)
                    .IsRequired()
                    .HasPrecision(12, 2)
                    .HasDefaultValueSql("0.00");

                account.HasOne<User>(a => a.User)
                    .WithMany(u => u.Accounts)
                    .HasForeignKey(a => a.UserId);

                account.HasData(new Account() { UserId = users[0].Id, Id = users[0].Accounts.First().Id, AccountNo = users[0].Accounts.First().AccountNo, IsActive = users[0].Accounts.First().IsActive, CurrentBalance = users[0].Accounts.First().CurrentBalance });
                account.HasData(new Account() { UserId = users[1].Id, Id = users[1].Accounts.First().Id, AccountNo = users[1].Accounts.First().AccountNo, IsActive = users[1].Accounts.First().IsActive, CurrentBalance = users[1].Accounts.First().CurrentBalance });
            });

            modelBuilder.Entity<Transaction>(xtn =>
            {
                xtn.HasKey(x => x.Id);
                xtn.Property(x => x.Id)
                    .IsRequired()
                    .HasDefaultValueSql("NEWID()");
                xtn.Property(x => x.XtnDate)
                    .IsRequired();
                xtn.Property(x => x.Description)
                    .IsRequired()
                    .HasMaxLength(50);
                xtn.Property(x => x.XtnType)
                    .IsRequired();
                xtn.Property(x => x.Amount)
                    .HasPrecision(12, 2)
                    .HasDefaultValueSql("0.00");                    
                xtn.Property(x => x.PostedBalance)
                    .HasPrecision(12, 2)
                    .HasDefaultValueSql("0.00");

                xtn.HasOne<Account>(x => x.Account)
                    .WithMany(x => x.Transactions)
                    .HasForeignKey(x => x.AccountId);
            });
        }
    }
}