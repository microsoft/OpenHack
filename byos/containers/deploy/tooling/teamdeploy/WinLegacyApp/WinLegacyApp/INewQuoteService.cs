using System.ServiceModel;

namespace WinLegacyApp
{
    [ServiceContract]
    public interface INewQuoteService
    {

        [OperationContract]
        string GetData(string value);
    }

}
