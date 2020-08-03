namespace Simulator.DataObjects
{
    using Newtonsoft.Json;
    using System;

    public partial class User //: BaseDataObject
    {
        public Guid Id { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }

        public string UserId { get; set; }

        public string ProfilePictureUri { get; set; }

        public long Rating { get; set; }

        public long Ranking { get; set; }

        public double TotalDistance { get; set; }

        public long TotalTrips { get; set; }

        public long TotalTime { get; set; }

        public long HardStops { get; set; }

        public long HardAccelerations { get; set; }

        public long FuelConsumption { get; set; }

        public long MaxSpeed { get; set; }

        public string Version { get; set; }

        public DateTime CreatedAt { get; set; }

        public DateTime UpdatedAt { get; set; }

        public bool Deleted { get; set; }
    }

    public partial class User
    {
        public static User FromJson(string json) => JsonConvert.DeserializeObject<User>(json, Converter.Settings);
    }

    public static class UserSerializer
    {
        public static string ToJson(this User self) => JsonConvert.SerializeObject(self, Converter.Settings);
    }

    internal class ParseStringConverter : JsonConverter
    {
        public override bool CanConvert(Type t) => t == typeof(long) || t == typeof(long?);

        public override object ReadJson(JsonReader reader, Type t, object existingValue, JsonSerializer serializer)
        {
            if (reader.TokenType == JsonToken.Null) return null;
            var value = serializer.Deserialize<string>(reader);
            long l;
            if (Int64.TryParse(value, out l))
            {
                return l;
            }
            throw new Exception("Cannot unmarshal type long");
        }

        public override void WriteJson(JsonWriter writer, object untypedValue, JsonSerializer serializer)
        {
            if (untypedValue == null)
            {
                serializer.Serialize(writer, null);
                return;
            }
            var value = (long)untypedValue;
            serializer.Serialize(writer, value.ToString());
            return;
        }

        public static readonly ParseStringConverter Singleton = new ParseStringConverter();
    }
}