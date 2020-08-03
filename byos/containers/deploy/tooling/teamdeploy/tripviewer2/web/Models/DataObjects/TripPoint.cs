namespace Simulator.DataObjects
{
    using Newtonsoft.Json;

    using System;

    public partial class TripPoint//: BaseDataObject
    {
        [JsonProperty("Id")]
        public string Id { get; set; }

        [JsonProperty("TripId")]
        public Guid TripId { get; set; }

        [JsonProperty("Latitude")]
        public double Latitude { get; set; }

        [JsonProperty("Longitude")]
        public double Longitude { get; set; }

        [JsonProperty("Speed")]
        public double Speed { get; set; }

        [JsonProperty("RecordedTimeStamp")]
        public DateTime RecordedTimeStamp { get; set; }

        [JsonProperty("Sequence")]
        public int Sequence { get; set; }

        [JsonProperty("RPM")]
        public double Rpm { get; set; }

        [JsonProperty("ShortTermFuelBank")]
        public double ShortTermFuelBank { get; set; }

        [JsonProperty("LongTermFuelBank")]
        public double LongTermFuelBank { get; set; }

        [JsonProperty("ThrottlePosition")]
        public double ThrottlePosition { get; set; }

        [JsonProperty("RelativeThrottlePosition")]
        public double RelativeThrottlePosition { get; set; }

        [JsonProperty("Runtime")]
        public double Runtime { get; set; }

        [JsonProperty("DistanceWithMalfunctionLight")]
        public double DistanceWithMalfunctionLight { get; set; }

        [JsonProperty("EngineLoad")]
        public double EngineLoad { get; set; }

        [JsonProperty("EngineFuelRate")]
        public double EngineFuelRate { get; set; }

        [JsonProperty("VIN")]
        public Vin Vin { get; set; }

        [JsonProperty("CreatedAt")]
        public DateTime CreatedAt { get; set; }

        [JsonProperty("UpdatedAt")]
        public DateTime UpdatedAt { get; set; }
    }

    public partial class Vin
    {
        [JsonProperty("String")]
        public string String { get; set; }

        [JsonProperty("Valid")]
        public bool Valid { get; set; }
    }

    public partial class TripPoint
    {
        public static TripPoint FromJson(string json) => JsonConvert.DeserializeObject<TripPoint>(json, Converter.Settings);
    }

    public static class TripPointSerializer
    {
        public static string ToJson(this TripPoint self) => JsonConvert.SerializeObject(self, Converter.Settings);
    }

    internal static class Converter
    {
        public static readonly JsonSerializerSettings Settings = new JsonSerializerSettings
        {
            MetadataPropertyHandling = MetadataPropertyHandling.Ignore,
            //DateParseHandling = DateParseHandling.None,
            //Converters = {new IsoDateTimeConverter { DateTimeStyles = DateTimeStyles.None } },
        };
    }
}