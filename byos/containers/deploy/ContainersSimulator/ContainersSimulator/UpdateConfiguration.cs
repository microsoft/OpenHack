using ContainersSimulator.Models;
using ContainersSimulator.Wrappers;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Net.Http;
using System.Threading.Tasks;

namespace ContainersSimulator
{
    public class UpdateConfiguration
    {
        private readonly Settings settings;
        private readonly ITableClientWrapper<Configuration> tableClientWrapper;

        public UpdateConfiguration(IOptions<Settings> options, ITableClientWrapper<Configuration> tableClientWrapper)
        {
            settings = options.Value;
            this.tableClientWrapper = tableClientWrapper;
        }

        [FunctionName(nameof(UpdateConfiguration))]
        public async Task<IActionResult> Run([HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequestMessage req, ILogger log)
        {
            log.LogInformation($"{nameof(UpdateConfiguration)} Invoked.");

            var configuration = await req.Content.ReadAsAsync<Configuration>();
            configuration.PartitionKey = "Configuration";
            configuration.RowKey = settings.ResourceGroupName;

            await tableClientWrapper.CreateIfNotExistsAsync();
            await tableClientWrapper.CreateOrUpdateAsync(configuration);

            return new OkResult();
        }
    }
}
