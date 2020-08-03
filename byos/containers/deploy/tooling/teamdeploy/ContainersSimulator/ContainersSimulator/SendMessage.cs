using Bogus;
using ContainersSimulator.Models;
using Microsoft.ApplicationInsights;
using Microsoft.ApplicationInsights.DataContracts;
using Microsoft.ApplicationInsights.Extensibility;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Net.Http.Headers;
using System.Threading.Tasks;

namespace ContainersSimulator
{
    public class SendMessage
    {
        private static UserProfile user = null;
        private readonly TelemetryClient telemetryClient;

        public SendMessage(IOptions<Settings> options)
        {
            var settings = options.Value;
            telemetryClient = new TelemetryClient(new TelemetryConfiguration() { InstrumentationKey = settings.ApplicationInsightsKey });
        }

        [FunctionName(nameof(SendMessage))]
        public async Task Run([QueueTrigger("simulator-items", Connection = "DataStorageConnectionString")]SendMessageItem sendMessageItem, ILogger log)
        {
            log.LogInformation($"{nameof(SendMessage)} Invoked.");

            var dateTime = DateTime.UtcNow;
            if (user == null)
            {
                user = (await SendDataAsync(new Uri(sendMessageItem.MessageUri, "/api/user"), HttpMethods.GET, DateTime.UtcNow, new List<UserProfile>())).FirstOrDefault();
            }

            // trip records
            var tripGenerator = new Faker<Trip>()
                .RuleFor(t => t.Id, new Guid().ToString())
                .RuleFor(t => t.CreatedAt, dateTime.AddTicks(-1 * dateTime.Ticks % 10000))
                .RuleFor(t => t.UpdatedAt, dateTime.AddTicks(-1 * dateTime.Ticks % 10000))
                .RuleFor(t => t.AverageSpeed, p => p.Random.Int(15, 60))
                .RuleFor(t => t.Distance, p => p.Random.Int(10, 1000))
                .RuleFor(t => t.EndtimeStamp, p => p.Date.Soon(3).ToString("yyyy-MM-dd"))
                .RuleFor(t => t.FuelUsed, p => p.Random.Int(1, 40))
                .RuleFor(t => t.HardAccelerations, p => p.Random.Int(1, 10))
                .RuleFor(t => t.HardStops, p => p.Random.Int(1, 50))
                .RuleFor(t => t.HasSimulatedOBDData, p => p.Random.Bool())
                .RuleFor(t => t.IsComplete, p => p.Random.Bool())
                .RuleFor(t => t.Name, p => $"API-Trip {DateTime.Now}")
                .RuleFor(t => t.Rating, p => p.Random.Int(1, 5))
                .RuleFor(t => t.RecordedtimeStamp, p => p.Date.Soon(2).ToString("yyyy-MM-dd"))
                .RuleFor(t => t.UserId, p => "Hacker 1");

            var trip = tripGenerator.Generate(1).FirstOrDefault();

            try
            {
                // trip points
                var nullStringGenerator = new Faker<NullString>()
                    .RuleFor(ns => ns.String, p => p.Vehicle.Vin())
                    .RuleFor(ns => ns.Valid, true);

                var vins = nullStringGenerator.Generate(100);

                var tripPointsGenerator = new Faker<TripPoint>()
                    .RuleFor(tp => tp.CreatedAt, dateTime.AddTicks(-1 * dateTime.Ticks % 10000))
                    .RuleFor(tp => tp.UpdatedAt, dateTime.AddTicks(-1 * dateTime.Ticks % 10000))
                    .RuleFor(tp => tp.RecordedTimeStamp, dateTime.AddTicks(-1 * dateTime.Ticks % 10000))
                    .RuleFor(tp => tp.Latitude, p => p.Address.Latitude(25, 50))
                    .RuleFor(tp => tp.Longitude, p => p.Address.Longitude(70, 125))
                    .RuleFor(tp => tp.Speed, p => p.Random.Int(15, 100))
                    .RuleFor(tp => tp.ThrottlePosition, 0)
                    .RuleFor(tp => tp.DistanceWithMalfunctionLight, 0)
                    .RuleFor(tp => tp.EngineFuelRate, 0)
                    .RuleFor(tp => tp.EngineLoad, 0)
                    .RuleFor(tp => tp.HasOBDData, false)
                    .RuleFor(tp => tp.HasSimulatedOBDData, false)
                    .RuleFor(tp => tp.LongTermFuelBank, 0)
                    .RuleFor(tp => tp.MassFlowRate, 0)
                    .RuleFor(tp => tp.RelativeThrottlePosition, 0)
                    .RuleFor(tp => tp.RPM, 0)
                    .RuleFor(tp => tp.Runtime, 0)
                    .RuleFor(tp => tp.Sequence, 0)
                    .RuleFor(tp => tp.ShortTermFuelBank, 0)
                    .RuleFor(tp => tp.VIN, p => p.PickRandom(vins))
                    .RuleFor(tp => tp.TripId, trip.Id);

                var tripPoints = tripPointsGenerator.Generate(10);

                var createdTrip = await SendDataAsync(new Uri(sendMessageItem.MessageUri, "/api/trips"), HttpMethods.POST, DateTime.UtcNow, trip);
                foreach (var relatedTripPoint in tripPoints)
                {
                    relatedTripPoint.TripId = createdTrip.Id;
                    await SendDataAsync(new Uri(sendMessageItem.MessageUri, $"/api/trips/{createdTrip.Id}/trippoints"), HttpMethods.POST, DateTime.UtcNow, relatedTripPoint);
                }

                // points of interests
                // 25 - 50 lat is for US
                // 70 - 125 long is for US
                var pointOfInterestGenerator = new Faker<PointOfInterest>()
                    .RuleFor(poi => poi.Id, p => p.Random.Guid().ToString())
                    .RuleFor(poi => poi.TripId, p => trip.Id)
                    .RuleFor(poi => poi.Timestamp, p => DateTime.UtcNow)
                    .RuleFor(poi => poi.Latitude, p => p.Address.Latitude(25, 50))
                    .RuleFor(poi => poi.Longitude, p => p.Address.Longitude(70, 125))
                    .RuleFor(poi => poi.PoiType, p => p.Random.Int(0, 3));

                var pointOfInterest = pointOfInterestGenerator.Generate(1).FirstOrDefault();

                await SendDataAsync(new Uri(sendMessageItem.MessageUri, "/api/poi"), HttpMethods.POST, DateTime.UtcNow, pointOfInterest);

                user.TotalTrips++;
                user.TotalDistance = user.TotalDistance + trip.Distance;
                user.FuelConsumption = user.FuelConsumption + trip.FuelUsed;
                user.HardAccelerations = user.HardAccelerations + trip.HardAccelerations;
                user.HardStops = user.HardStops + trip.HardStops;
                var currentMaxSpeed = user.MaxSpeed;
                user.MaxSpeed = trip.AverageSpeed > currentMaxSpeed ? trip.AverageSpeed : currentMaxSpeed;
                user.Rating = (user.Rating + trip.Rating / 2);

                await SendDataAsync(new Uri(sendMessageItem.MessageUri, $"api/user-java/{user.Id}"), HttpMethods.PATCH, DateTime.UtcNow, user);

                log.LogInformation($"{nameof(SendMessage)} Completed.");
            }
            catch (Exception)
            {
                log.LogInformation($"Trip was not Recorded Successfully: \n Trip Name : {trip.Name} \n Trip Guid: {trip.Id}");
            }

        }


        private async Task<T> SendDataAsync<T>(Uri uri, HttpMethods method, DateTime startTime, T data)
        {
            var httpClient = new HttpClient();
            httpClient.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            HttpResponseMessage httpResponse = null;
            switch (method)
            {
                case HttpMethods.GET:
                    httpResponse = await httpClient.GetAsync(uri);
                    break;
                case HttpMethods.POST:
                    httpResponse = await httpClient.PostAsJsonAsync(uri, data);
                    break;
                case HttpMethods.PATCH:
                    var content = new ObjectContent<T>(data, new JsonMediaTypeFormatter());
                    content.Headers.ContentType = new MediaTypeHeaderValue("application/json");
                    var request = new HttpRequestMessage(new HttpMethod("PATCH"), uri) { Content = content };

                    httpResponse = await httpClient.SendAsync(request);
                    break;
            }

            var httpMessage = await httpResponse.Content.ReadAsStringAsync();
            if (!httpResponse.IsSuccessStatusCode)
                throw new InvalidOperationException($"There was an error calling: {uri}. Response status code: {httpResponse.StatusCode}. Response message: {httpMessage}.");

            var endTime = DateTime.UtcNow;
            var dependencyTelemetry = new DependencyTelemetry()
            {
                Name = $"{method} {uri}",
                Target = uri.DnsSafeHost,
                Timestamp = startTime,
                Data = data != null ? JsonConvert.SerializeObject(data) : "",
                Duration = endTime - startTime,
                Success = true,
            };


            telemetryClient.TrackDependency(dependencyTelemetry);

            try
            {

                var json = await httpResponse.Content.ReadAsStringAsync();
                return JsonConvert.DeserializeObject<T>(json);

            }
            catch(JsonReaderException)
            {
                return default(T);
            }


        }

        private enum HttpMethods
        {
            GET,
            POST,
            PATCH
        }
    }
}
