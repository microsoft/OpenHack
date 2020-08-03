using Newtonsoft.Json;
using System;

namespace ContainersSimulator.Models
{
    public class UserProfile
    {
        [JsonProperty("id")]
        public Guid Id { get; set; }

        [JsonProperty("firstName")]
        public string FirstName { get; set; }

        [JsonProperty("lastName")]
        public long LastName { get; set; }

        [JsonProperty("userId")]
        public string UserId { get; set; }

        [JsonProperty("profilePictureUri")]
        public string ProfilePictureUri { get; set; }

        [JsonProperty("rating")]
        public long Rating { get; set; }

        [JsonProperty("ranking")]
        public long Ranking { get; set; }

        [JsonProperty("totalDistance")]
        public double TotalDistance { get; set; }

        [JsonProperty("totalTrips")]
        public long TotalTrips { get; set; }

        [JsonProperty("totalTime")]
        public long TotalTime { get; set; }

        [JsonProperty("hardStops")]
        public long HardStops { get; set; }

        [JsonProperty("hardAccelerations")]
        public long HardAccelerations { get; set; }

        [JsonProperty("fuelConsumption")]
        public long FuelConsumption { get; set; }

        [JsonProperty("maxSpeed")]
        public long MaxSpeed { get; set; }

        [JsonProperty("version")]
        public string Version { get; set; }

        [JsonProperty("createdAt")]
        public DateTime CreatedAt { get; set; }

        [JsonProperty("updatedAt")]
        public DateTime UpdatedAt { get; set; }

        [JsonProperty("deleted")]
        public bool Deleted { get; set; }
    }


    public class Trip
    {
        public string Id { get; set; }
        public string Name { get; set; }
        public string UserId { get; set; }
        public string RecordedtimeStamp { get; set; }
        public string EndtimeStamp { get; set; }
        public int Rating { get; set; }
        public bool IsComplete { get; set; }
        public bool HasSimulatedOBDData { get; set; }
        public int AverageSpeed { get; set; }
        public int FuelUsed { get; set; }
        public int HardStops { get; set; }
        public int HardAccelerations { get; set; }
        public int Distance { get; set; }
        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset? UpdatedAt { get; set; }
        public bool Deleted { get; set; }
    }

    public class TripPoint
    {
        public string Id { get; set; }
        public string TripId { get; set; }
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public int Speed { get; set; }
        public DateTime RecordedTimeStamp { get; set; }
        public int Sequence { get; set; }
        public int RPM { get; set; }
        public int ShortTermFuelBank { get; set; }
        public int LongTermFuelBank { get; set; }
        public int ThrottlePosition { get; set; }
        public int RelativeThrottlePosition { get; set; }
        public int Runtime { get; set; }
        public int DistanceWithMalfunctionLight { get; set; }
        public int EngineLoad { get; set; }
        public int MassFlowRate { get; set; }
        public int EngineFuelRate { get; set; }
        public NullString VIN { get; set; }
        public bool HasOBDData { get; set; }
        public bool HasSimulatedOBDData { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public bool Deleted { get; set; }
    }

    public class NullString
    {
        public string String { get; set; }

        public bool Valid { get; set; }
    }

    public class PointOfInterest
    {
        public string Id { get; set; }
        public string TripId { get; set; }
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public int PoiType { get; set; }
        public DateTime Timestamp { get; set; }
        public bool Deleted { get; set; }
    }
}
