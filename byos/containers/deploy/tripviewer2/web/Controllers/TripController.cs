using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using Simulator.DataObjects;
using Simulator.DataStore.Stores;
using TripViewer.Utility;


namespace TripViewer.Controllers
{
    public class TripController : Controller
    {
        private readonly TripViewerConfiguration _envvars;

        public TripController(IOptions<TripViewerConfiguration> EnvVars)
        {
            _envvars = EnvVars.Value ?? throw new ArgumentNullException(nameof(EnvVars));
        }
        [HttpGet]
        public IActionResult Index()
        {
            var teamendpoint = _envvars.TRIPS_API_ENDPOINT;
            var bingMapsKey = _envvars.BING_MAPS_KEY;

            //Get trips
            TripStore t = new TripStore(teamendpoint);
            List<Trip> trips = t.GetItemsAsync().Result;
            //Get Last Trip
            var last = trips.Max(trip => trip.RecordedTimeStamp);
            var tlast = from Trip latest in trips
                        where latest.RecordedTimeStamp == last
                        select latest;
            //Get TripPoints
            TripPointStore tps = new TripPointStore(teamendpoint);
            List<TripPoint> tripPoints = tps.GetItemsAsync(tlast.First()).Result;
            
            ViewData["MapKey"] = bingMapsKey;
            return View(tripPoints);
        }

        public PartialViewResult RenderMap()
        {
            var teamendpoint = _envvars.TRIPS_API_ENDPOINT;
            //Get trips
            TripStore t = new TripStore(teamendpoint);
            List<Trip> trips = t.GetItemsAsync().Result;
            //Get Last Trip
            var last = trips.Max(trip => trip.RecordedTimeStamp);
            var tlast = from Trip latest in trips
                        where latest.RecordedTimeStamp == last
                        select latest;
            //Get TripPoints
            TripPointStore tps = new TripPointStore(teamendpoint);
            List<TripPoint> tripPoints = tps.GetItemsAsync(tlast.First()).Result;

            
            return PartialView(tripPoints);
        }
    }
}