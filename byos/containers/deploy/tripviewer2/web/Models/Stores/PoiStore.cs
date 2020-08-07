namespace Simulator.DataStore.Stores
{
    using Simulator.DataObjects;
    using System.Collections.Generic;
    using System.Net.Http;
    using System.Threading.Tasks;

    public class PoiStore : BaseStore, IBaseStore<Poi>
    {

        public PoiStore(string EndPoint)
        {
            base.InitializeStore(EndPoint);
        }

        public async Task<Poi> GetItemAsync(string id)
        {
            Poi poi = null;
            HttpResponseMessage response = await Client.GetAsync($"/api/poi/{id}");
            if (response.IsSuccessStatusCode)
            {
                response.Content.Headers.ContentType.MediaType = "application/json";
                poi = await response.Content.ReadAsAsync<Poi>();
            }
            return poi;
        }

        public async Task<List<Poi>> GetItemsAsync()
        {
            List<Poi> trips = null;
            HttpResponseMessage response = await Client.GetAsync("api/poi/");
            if (response.IsSuccessStatusCode)
            {
                response.Content.Headers.ContentType.MediaType = "application/json";
                trips = await response.Content.ReadAsAsync<List<Poi>>();
            }
            return trips;
        }

        public async Task<Poi> CreateItemAsync(Poi item)
        {
            HttpResponseMessage response = await Client.PostAsJsonAsync<Poi>("api/poi", item);
            response.EnsureSuccessStatusCode();
            if (response.IsSuccessStatusCode)
            {
                response.Content.Headers.ContentType.MediaType = "application/json";
                item = await response.Content.ReadAsAsync<Poi>();
            }
            return item;
        }

        public async Task<bool> UpdateItemAsync(Poi item)
        {

            HttpResponseMessage response = await Client.PatchAsJsonAsync($"api/poi/{item.Id}", item);
            response.EnsureSuccessStatusCode();
            if (response.IsSuccessStatusCode)
                response.Content.Headers.ContentType.MediaType = "application/json";
            return true;
        }

        public async Task<bool> DeleteItemAsync(Poi item)
        {
            HttpResponseMessage response = await Client.DeleteAsync($"api/poi/{item.Id}");
            response.EnsureSuccessStatusCode();
            if (response.IsSuccessStatusCode)
                response.Content.Headers.ContentType.MediaType = "application/json";
            return true;
        }
    }
}