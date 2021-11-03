using CommandLine;

namespace Deploy
{
    public class Options
    {
        // The following line was commented out by Joshua due to no longer being able to deploy an Azure DevOps tenant via the Azure portal
        //[Option('t', "token", HelpText = "A generated Azure AD access token (NOTE: This is NOT an Azure DevOps PAT).")]
        [Option('t', "token", HelpText = "An Azure DevOps Personal Access Token (PAT).")]
        public string AccessToken { get; set; }
        
        [Option('a', "auth", HelpText = "The path to the Azure AUTH file.")]
        public string AuthFile { get; set; }

        [Option('s', "source", HelpText = "The path of the parent source folder.")]
        public string Source { get; set; }

        [Option('i', "id", HelpText = "The Azure subscription Id.")]
        public string SubscriptionId { get; set; }

        [Option('o', "org", HelpText = "Optional. A pre-generated organization id.")]
        public string OrganizationId { get; set; }

        // The following lines were added by JoshuaD due to no longer being able to deploy an Azure DevOps tenant via the Azure portal
        [Option('d', "devops", HelpText = "Azure DevOps organization")]
        public string DevOps { get; set; }
    }

}