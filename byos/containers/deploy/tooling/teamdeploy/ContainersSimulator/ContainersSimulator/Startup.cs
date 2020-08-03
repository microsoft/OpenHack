using ContainersSimulator;
using ContainersSimulator.Models;
using ContainersSimulator.Wrappers;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection;
using System;

[assembly: FunctionsStartup(typeof(Startup))]
namespace ContainersSimulator
{
    public class Startup
        : FunctionsStartup
    {
        public override void Configure(IFunctionsHostBuilder builder)
        {
            builder.Services.Configure<Settings>(settings =>
            {
                settings.ResourceGroupName = Environment.GetEnvironmentVariable("ResourceGroupName");
                settings.DataStorageConnectionString = Environment.GetEnvironmentVariable("DataStorageConnectionString");
                settings.ApplicationInsightsKey = Environment.GetEnvironmentVariable("APPINSIGHTS_INSTRUMENTATIONKEY");
            });

            builder.Services.AddSingleton<ITableClientWrapper<Configuration>, TableClientWrapper<Configuration>>();
        }
    }
}
