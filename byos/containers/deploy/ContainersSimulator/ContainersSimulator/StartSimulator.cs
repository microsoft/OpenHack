using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using System;
using System.Net.Http;

namespace ContainersSimulator
{
    public class StartSimulator
    {
        [FunctionName(nameof(StartSimulator))]
        public IActionResult Run([HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequestMessage req, ILogger log)
        {
            log.LogInformation($"{nameof(StartSimulator)} Invoked.");

            Environment.SetEnvironmentVariable("StartTimers", "Start");

            return new OkResult();
        }
    }
}
