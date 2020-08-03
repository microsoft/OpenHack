namespace Simulator.DataStore.Stores
{
    using System;
    using System.Net.Http;
    using System.Net.Http.Headers;
    using System.Threading.Tasks;
    using System.Collections.Generic;
    

    public class BaseStore
        //<T> : IBaseStore<T> where T : class, IBaseDataObject, new()
    {
        public string EndPoint { get; set; }
        public HttpClient Client { get; set; }
        public DateTime DateTime { get; set; }

        public Task InitializeStore(string EndPoint)
        {
            Client = new HttpClient();
            Client.BaseAddress = new Uri(EndPoint);
            Client.DefaultRequestHeaders.Accept.Clear();
            Client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

            DateTime = DateTime.UtcNow;

            return Task.CompletedTask;
        }

       
    }

    
}


