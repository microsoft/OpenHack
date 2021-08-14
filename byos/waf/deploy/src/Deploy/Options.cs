using CommandLine;

namespace Deploy
{
    public class Options
    {
        [Option('p', "pat", HelpText = "A personal access token for Azure DevOps.")]
        public string AccessToken { get; set; }
        
        [Option('a', "auth", HelpText = "The path to the Azure AUTH file.")]
        public string AuthFile { get; set; }

        [Option('o', "org", HelpText = "The name of the Azure DevOps organization.")]
        public string Organization { get; set; }

        [Option('s', "source", HelpText = "The path of the parent source folder.")]
        public string Source { get; set; }

        [Option('u', "subscriptionId", HelpText = "The Azure subscription Id.")]
        public string SubscriptionId { get; set; }
    }

}