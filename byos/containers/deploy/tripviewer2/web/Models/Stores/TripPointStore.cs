namespace Simulator.DataStore.Stores
{ 
    using Simulator.DataObjects;
    using System;
    using System.Collections.Generic;
    using System.Net.Http;
    using System.Threading.Tasks;

    public class TripPointStore : BaseStore//, IBaseStore<TripPoint>
    {

        public TripPointStore(string EndPoint)
        {
            base.InitializeStore(EndPoint);
        }
        public async Task<TripPoint> GetItemAsync(string id)
        {
            //Deviating implemetnation because of complxity of the nested API
            TripPoint tripPoint = null;
            HttpResponseMessage response = await Client.GetAsync($"/api/trips/{id}/trippoints/{id}");
            if (response.IsSuccessStatusCode)
            {
                response.Content.Headers.ContentType.MediaType = "application/json";
                tripPoint = await response.Content.ReadAsAsync<TripPoint>();
            }
            return tripPoint;
        }

        public async Task<TripPoint> GetItemAsync(TripPoint item)
        {
            //Deviating implemetnation because of complxity of the nested API
            TripPoint tripPoint = null;
            HttpResponseMessage response = await Client.GetAsync($"/api/trips/{item.TripId}/trippoints/{item.Id}");
            if (response.IsSuccessStatusCode)
            {
                response.Content.Headers.ContentType.MediaType = "application/json";
                tripPoint = await response.Content.ReadAsAsync<TripPoint>();
            }
            return tripPoint;
        }

        public Task<List<TripPoint>> GetItemsAsync()
        {
            throw new NotImplementedException();
        }

        public async Task<List<TripPoint>> GetItemsAsync(Trip item)
        {
            List<TripPoint> tripPoints = null;
            HttpResponseMessage response = await Client.GetAsync($"api/trips/{item.Id}/trippoints");
            if (response.IsSuccessStatusCode)
            {
                response.Content.Headers.ContentType.MediaType = "application/json";
                tripPoints = await response.Content.ReadAsAsync<List<TripPoint>>();
            }
            return tripPoints;
        }

        public async Task<TripPoint> CreateItemAsync(TripPoint item)
        {
            string apiPath = $"api/trips/{item.TripId.ToString()}/trippoints";
            HttpResponseMessage response = await Client.PostAsJsonAsync<TripPoint>(apiPath, item);
            response.EnsureSuccessStatusCode();
            response.Content.Headers.ContentType.MediaType = "application/json";

            item = await response.Content.ReadAsAsync<TripPoint>();

            return item;
        }

        public Task<bool> UpdateItemAsync(TripPoint item)
        {
            throw new NotImplementedException();
        }

        public Task<bool> DeleteItemAsync(TripPoint item)
        {
            throw new NotImplementedException();
        }
    }
}