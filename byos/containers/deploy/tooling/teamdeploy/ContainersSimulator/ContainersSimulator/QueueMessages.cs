using ContainersSimulator.Models;
using ContainersSimulator.Wrappers;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections;
using System.Linq;
using System.Threading.Tasks;

namespace ContainersSimulator
{
    public class QueueMessages
    {
        private readonly Settings settings;
        private readonly ITableClientWrapper<Configuration> tableClientWrapper;

        public QueueMessages(IOptions<Settings> options, ITableClientWrapper<Configuration> tableClientWrapper)
        {
            settings = options.Value;
            this.tableClientWrapper = tableClientWrapper;
        }

        [FunctionName(nameof(QueueMessages))]
        public async Task Run([TimerTrigger("* * * * * *")]TimerInfo queueMessagesTimer, [Queue("simulator-items", Connection = "DataStorageConnectionString")]IAsyncCollector<SendMessageItem> sendMessageQueue, ILogger log)
        {
            log.LogInformation($"{nameof(QueueMessages)} Invoked.");

            if (Environment.GetEnvironmentVariable("StartTimers") == "Start" && !string.IsNullOrWhiteSpace(settings.ResourceGroupName))
            {
                var configurations = await tableClientWrapper.FetchByPartitionKeyAndRowKeyAsync("Configuration", settings.ResourceGroupName);
                var configuration = configurations.Single();

                if (configuration.HostEndpointUri != null)
                {
                    var sendMessageItem = new SendMessageItem()
                    {
                        MessageUri = new Uri(configuration.HostEndpointUri),
                    };

                    if (configuration.SimulationSize == (int)SimulationSize.Small)
                    {
                        await sendMessageQueue.AddAsync(sendMessageItem);
                    }

                    if (configuration.SimulationSize == (int)SimulationSize.Medium)
                    {
                        foreach (var index in Enumerable.Range(1, 100))
                        {
                            await sendMessageQueue.AddAsync(sendMessageItem);
                        }
                    }

                    if (configuration.SimulationSize == (int)SimulationSize.Large)
                    {
                        foreach (var index in Enumerable.Range(1, 1000))
                        {
                            await sendMessageQueue.AddAsync(sendMessageItem);
                        }
                    }
                }
            }
        }
    }
}
