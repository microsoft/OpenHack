namespace WinLegacyApp
{
    public class NewQuoteService: INewQuoteService
    {
        public string GetData(string value)
        {
            return string.Format("Processing request for {0}'s new quote", value);
        }

    }
}
