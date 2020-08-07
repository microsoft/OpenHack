using ContainersSimulator.Models;
using Microsoft.Extensions.Options;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Table;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ContainersSimulator.Wrappers
{
    public interface ITableClientWrapper<T>
        where T : TableEntity, new()
    {
        Task CreateIfNotExistsAsync();

        Task<TableResult> CreateOrUpdateAsync(T entity);

        Task<TableResult> DeleteAsync(T entity);

        Task<IEnumerable<T>> FetchByPartitionKeyAsync(string partitionKey);

        Task<IEnumerable<T>> FetchByPartitionKeyAndRowKeyAsync(string partitionKey, string rowKey);
    }

    public class TableClientWrapper<T>
        : ITableClientWrapper<T>
        where T : TableEntity, new()
    {
        private readonly CloudTable cloudTable;

        public TableClientWrapper(IOptions<Settings> options)
        {
            var settings = options.Value;
            var cloudStorageAccount = CloudStorageAccount.Parse(settings.DataStorageConnectionString);
            var cloudTableClient = cloudStorageAccount.CreateCloudTableClient();
            cloudTable = cloudTableClient.GetTableReference(typeof(T).Name);
        }

        public async Task CreateIfNotExistsAsync()
        {
            await cloudTable.CreateIfNotExistsAsync();
        }

        public async Task<TableResult> CreateOrUpdateAsync(T entity)
        {
            var insertOrMergeOperation = TableOperation.InsertOrMerge(entity);
            return await cloudTable.ExecuteAsync(insertOrMergeOperation);
        }

        public async Task<TableResult> DeleteAsync(T entity)
        {
            var deleteOperation = TableOperation.Delete(entity);
            return await cloudTable.ExecuteAsync(deleteOperation);
        }

        public async Task<IEnumerable<T>> FetchByPartitionKeyAsync(string partitionKey)
        {
            var tableQuery = new TableQuery<T>().Where(TableQuery.GenerateFilterCondition("PartitionKey", QueryComparisons.Equal, partitionKey));
            var results = new List<T>();
            TableContinuationToken continuationToken = null;
            do
            {
                var items = await cloudTable.ExecuteQuerySegmentedAsync(tableQuery, continuationToken);
                results.AddRange(items.Results.OfType<T>());
            } while (continuationToken != null);
            return results;
        }

        public async Task<IEnumerable<T>> FetchByPartitionKeyAndRowKeyAsync(string partitionKey, string rowKey)
        {
            var partitionKeyQuery = TableQuery.GenerateFilterCondition("PartitionKey", QueryComparisons.Equal, partitionKey);
            var rowKeyQuery = TableQuery.GenerateFilterCondition("RowKey", QueryComparisons.Equal, rowKey);
            var combinedQuery = TableQuery.CombineFilters(partitionKeyQuery, TableOperators.And, rowKeyQuery);
            var tableQuery = new TableQuery<T>().Where(combinedQuery);

            var results = new List<T>();
            TableContinuationToken continuationToken = null;
            do
            {
                var items = await cloudTable.ExecuteQuerySegmentedAsync(tableQuery, continuationToken);
                results.AddRange(items.Results.OfType<T>());
            } while (continuationToken != null);
            return results;
        }
    }
}
