namespace Simulator.DataStore.Stores
{
    using Simulator.DataObjects;
    using System.Collections.Generic;
    using System.Net.Http;
    using System.Threading.Tasks;
    using System.Linq;
    using Newtonsoft.Json;

    public class UserStore : BaseStore//, IBaseStore<User>
    {
        public UserStore(string EndPoint)
        {
            base.InitializeStore(EndPoint);

        }
        public async Task<User> GetItemAsync(string id)
        {
            User user = null;
            HttpResponseMessage response = await Client.GetAsync($"/api/user/{id}");
            if (response.IsSuccessStatusCode)
            {
                var str = await response.Content.ReadAsStringAsync();
                user = (JsonConvert.DeserializeObject<List<User>>(str)).First();
            }
            return user;
        }

        public async Task<List<User>> GetItemsAsync()
        {
            List<User> users = null;
            HttpResponseMessage response = await Client.GetAsync("/api/user");
            if (response.IsSuccessStatusCode)
            {
                var str = await response.Content.ReadAsStringAsync();
                users = JsonConvert.DeserializeObject<List<User>>(str);
            }
            return users;
        }

        
    }
}