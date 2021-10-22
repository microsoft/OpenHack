using System;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Portal.Api.Migrations.SqliteMigrations
{
    public partial class InitialCreate : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Users",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false, defaultValueSql: "NEWID()"),
                    Login = table.Column<string>(type: "TEXT", maxLength: 25, nullable: false),
                    Password = table.Column<string>(type: "TEXT", maxLength: 255, nullable: false),
                    LastLoginDate = table.Column<DateTimeOffset>(type: "TEXT", nullable: false),
                    CurrentLoginDate = table.Column<DateTimeOffset>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Users", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Accounts",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false, defaultValueSql: "NEWID()"),
                    UserId = table.Column<Guid>(type: "TEXT", nullable: false),
                    AccountNo = table.Column<string>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false, defaultValue: true),
                    CurrentBalance = table.Column<decimal>(type: "TEXT", precision: 12, scale: 2, nullable: false, defaultValueSql: "0.00")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Accounts", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Accounts_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Profiles",
                columns: table => new
                {
                    UserId = table.Column<Guid>(type: "TEXT", nullable: false),
                    FirstName = table.Column<string>(type: "TEXT", maxLength: 25, nullable: false),
                    LastName = table.Column<string>(type: "TEXT", maxLength: 25, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Profiles", x => x.UserId);
                    table.ForeignKey(
                        name: "FK_Profiles_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Transactions",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false, defaultValueSql: "NEWID()"),
                    AccountId = table.Column<Guid>(type: "TEXT", nullable: false),
                    XtnDate = table.Column<DateTimeOffset>(type: "TEXT", nullable: false),
                    Description = table.Column<string>(type: "TEXT", maxLength: 50, nullable: false),
                    XtnType = table.Column<int>(type: "INTEGER", nullable: false),
                    Amount = table.Column<decimal>(type: "TEXT", precision: 12, scale: 2, nullable: false, defaultValueSql: "0.00"),
                    PostedBalance = table.Column<decimal>(type: "TEXT", precision: 12, scale: 2, nullable: false, defaultValueSql: "0.00")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Transactions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Transactions_Accounts_AccountId",
                        column: x => x.AccountId,
                        principalTable: "Accounts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "CurrentLoginDate", "LastLoginDate", "Login", "Password" },
                values: new object[] { new Guid("215d6524-19d2-4ed1-b38c-53813905a110"), new DateTimeOffset(new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeSpan(0, 0, 0, 0, 0)), new DateTimeOffset(new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeSpan(0, 0, 0, 0, 0)), "dmelamed3244", "AQAAAAEAACcQAAAAEDIqmsf247/x1et+A3X8EuUmi28a5qv3y+5zap7qLx1wKggXy4pYAqb4IdbYbXF7GA==" });

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "CurrentLoginDate", "LastLoginDate", "Login", "Password" },
                values: new object[] { new Guid("3ae1dab6-8675-4b8a-9aa3-cb55d1cd5901"), new DateTimeOffset(new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeSpan(0, 0, 0, 0, 0)), new DateTimeOffset(new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeSpan(0, 0, 0, 0, 0)), "tniu5629", "AQAAAAEAACcQAAAAEBpBdRt4iTKKnJGc1m9LPXHpSIeUb0McYEjeGg2v5bHUQlJGJROTMTj2V7Is45M8xQ==" });

            migrationBuilder.InsertData(
                table: "Accounts",
                columns: new[] { "Id", "AccountNo", "IsActive", "UserId" },
                values: new object[] { new Guid("d025d833-9669-4112-818e-d30cc9ea2f90"), "686847363244", true, new Guid("215d6524-19d2-4ed1-b38c-53813905a110") });

            migrationBuilder.InsertData(
                table: "Accounts",
                columns: new[] { "Id", "AccountNo", "IsActive", "UserId" },
                values: new object[] { new Guid("76405848-2c80-4a43-bb7d-a0dce7bbb38b"), "815571025629", true, new Guid("3ae1dab6-8675-4b8a-9aa3-cb55d1cd5901") });

            migrationBuilder.InsertData(
                table: "Profiles",
                columns: new[] { "UserId", "FirstName", "LastName" },
                values: new object[] { new Guid("215d6524-19d2-4ed1-b38c-53813905a110"), "Daniel", "Melamed" });

            migrationBuilder.InsertData(
                table: "Profiles",
                columns: new[] { "UserId", "FirstName", "LastName" },
                values: new object[] { new Guid("3ae1dab6-8675-4b8a-9aa3-cb55d1cd5901"), "Ting", "Niu" });

            migrationBuilder.CreateIndex(
                name: "IX_Accounts_UserId",
                table: "Accounts",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Transactions_AccountId",
                table: "Transactions",
                column: "AccountId");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Profiles");

            migrationBuilder.DropTable(
                name: "Transactions");

            migrationBuilder.DropTable(
                name: "Accounts");

            migrationBuilder.DropTable(
                name: "Users");
        }
    }
}
