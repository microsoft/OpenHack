namespace Simulator.DataObjects
{
    using Newtonsoft.Json;
    using System;

    public partial class Trip // : BaseDataObject
    {
        [JsonProperty("Id")]
        public string Id { get; set; }

        [JsonProperty("Name")]
        public string Name { get; set; }

        [JsonProperty("UserId")]
        public string UserId { get; set; }

        [JsonProperty("RecordedTimeStamp")]
        public DateTime RecordedTimeStamp { get; set; }

        [JsonProperty("EndTimeStamp")]
        public DateTime EndTimeStamp { get; set; }

        [JsonProperty("Rating")]
        public long Rating { get; set; }

        [JsonProperty("IsComplete")]
        public bool IsComplete { get; set; }

        [JsonProperty("HasSimulatedOBDData")]
        public bool HasSimulatedObdData { get; set; }

        [JsonProperty("AverageSpeed")]
        public long AverageSpeed { get; set; }

        [JsonProperty("FuelUsed")]
        public long FuelUsed { get; set; }

        [JsonProperty("HardStops")]
        public long HardStops { get; set; }

        [JsonProperty("HardAccelerations")]
        public long HardAccelerations { get; set; }

        [JsonProperty("Distance")]
        public double Distance { get; set; }

        [JsonProperty("Created")]
        public DateTime Created { get; set; }

        [JsonProperty("UpdatedAt")]
        public DateTime UpdatedAt { get; set; }
    }

    public partial class Trip
    {
        public static Trip FromJson(string json) => JsonConvert.DeserializeObject<Trip>(json, Converter.Settings);
    }

    public static class TripSerializer
    {
        public static string ToJson(this Trip self) => JsonConvert.SerializeObject(self, Converter.Settings);
    }
}