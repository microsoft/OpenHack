using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Simulator.DataStore.Stores
{
    public interface IBaseStore<T>
    {
        Task InitializeStoreAsync();

        Task<T> GetItemAsync(string id);

        Task<IEnumerable<T>> GetItemsAsync();

        Task<bool> CreateItemAsync(T item);

        Task<bool> UpdateItemAsync(T item);

        Task<bool> DeleteItemAsync(T item);
    }
}
