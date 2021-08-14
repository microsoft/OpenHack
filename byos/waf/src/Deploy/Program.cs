using System;
using CommandLine;
using Microsoft.Azure.Management.Fluent;
using Microsoft.Azure.Management.ResourceManager.Fluent;
using Microsoft.Azure.Management.ResourceManager.Fluent.Core;
using Microsoft.VisualStudio.Services.Common;


namespace Deploy
{
    class Program
    {
        static void Main(string[] args)
        {
            VssCredentials creds = null;
            string accessToken = string.Empty;
            string collectionUrl = string.Empty;
            string path = string.Empty;
            string authFile = string.Empty;
            string subscriptionId = string.Empty;

            Parser.Default.ParseArguments<Options>(args)
                .WithParsed<Options>(o =>
                {
                    if (String.IsNullOrWhiteSpace(o.AccessToken))
                    {
                        throw new ArgumentNullException(@"Argument ""access token"" was not supplied.");
                    }
                    else
                    {
                        accessToken = o.AccessToken;
                        creds = new VssBasicCredential(string.Empty, o.AccessToken);
                    }

                    if (String.IsNullOrWhiteSpace(o.Organization))
                    {
                        throw new ArgumentNullException(@"Argument ""organization"" was not supplied.");
                    }
                    else
                    {
                        collectionUrl = "https://dev.azure.com/" + o.Organization;
                    }

                    if (String.IsNullOrWhiteSpace(o.Source))
                    {
                        throw new ArgumentNullException(@"Argument ""source"" was not supplied.");
                    }
                    else if (!System.IO.Directory.Exists(o.Source))
                    {
                        throw new ArgumentException(@"Path ""source"" does not exist.");
                    }
                    else
                    {
                        path = o.Source;
                    }

                    if (String.IsNullOrWhiteSpace(o.AuthFile))
                    {
                        throw new ArgumentNullException(@"Argument ""auth file"" was not supplied.");
                    }
                    else if (!System.IO.File.Exists(o.AuthFile))
                    {
                        throw new ArgumentException(@"File ""auth file"" was not found.");
                    }
                    else
                    {
                        authFile = o.AuthFile;
                    }

                    if (String.IsNullOrWhiteSpace(o.SubscriptionId))
                    {
                        throw new ArgumentNullException(@"Argument ""subscription id"" was not supplied.");
                    }
                    else
                    {
                        subscriptionId = o.SubscriptionId;
                    }
                });

            DeployDevOps(creds, accessToken, collectionUrl, path);
            DeployAzureTenant(authFile, subscriptionId, path);
        }

        static void DeployDevOps(VssCredentials credentials, string accessToken, string collectionUrl, string path) {
            var adoHelper = new AdoHelper(credentials, collectionUrl);

            Console.WriteLine("*********************************");
            Console.WriteLine("*                               *");
            Console.WriteLine("* Deploying Azure DevOps Tenant *");
            Console.WriteLine("*                               *");
            Console.WriteLine("*********************************");

            // Create Bicep project
            var bicepProject = adoHelper.CreateProject("Bicep");
            var bicepTempRepo = adoHelper.CreateRepository(bicepProject, "temp", true);
            adoHelper.RemoveRepository(bicepProject, "Bicep", isDefault: true);
            var bicepRepo = adoHelper.CreateRepository(bicepProject, "bicep");
            adoHelper.CommitRepository(bicepProject, bicepRepo, accessToken, path + "/bicep");
            adoHelper.RemoveRepository(bicepProject, "temp", isTemp: true);

            // Create Portal project
            var portalProject = adoHelper.CreateProject("Portal");
            var processorRepo = adoHelper.CreateRepository(portalProject, "processor");
            adoHelper.CommitRepository(portalProject, processorRepo, accessToken, path + "/portal/processor");
            var webRepo = adoHelper.CreateRepository(portalProject, "web");
            adoHelper.CommitRepository(portalProject, webRepo, accessToken, path + "/portal/web");
            adoHelper.RemoveRepository(portalProject, "Portal", isDefault: true);

            Console.WriteLine();
        }

        static void DeployAzureTenant(string authFile, string subscriptionId, string path) {
            var credentials = SdkContext.AzureCredentialsFactory.FromFile(authFile);

            Console.WriteLine("*********************************");
            Console.WriteLine("*                               *");
            Console.WriteLine("* Deploying Azure Resources     *");
            Console.WriteLine("*                               *");
            Console.WriteLine("*********************************");

            var azure = Azure
                            .Configure()
                            .WithLogLevel(HttpLoggingDelegatingHandler.Level.Basic)
                            .Authenticate(credentials)
                            .WithSubscription(subscriptionId);

            var azureHelper = new AzureHelper(azure);
            azureHelper.DeployTemplate(subscriptionId, path + "/bicep");

            Console.WriteLine();
        }
    }
}
