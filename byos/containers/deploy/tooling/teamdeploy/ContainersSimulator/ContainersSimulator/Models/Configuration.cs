using Microsoft.WindowsAzure.Storage.Table;

namespace ContainersSimulator.Models
{
    public class Configuration
        : TableEntity
    {
        public string TeamName { get; set; }

        public string HostEndpointUri { get; set; }

        public int SimulationSize { get; set; }
    }
}
