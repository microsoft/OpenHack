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
            string accessToken = string.Empty;
            string path = string.Empty;
            string authFile = string.Empty;
            string subscriptionId = string.Empty;
            string organizationId = GenerateOrgId();
            // The following line was added by JoshuaD due to no longer being able to deploy an Azure DevOps tenant via the Azure portal
            string devops = string.Empty;

            Parser.Default.ParseArguments<Options>(args)
                .WithParsed<Options>(o =>
                {
                    if (!String.IsNullOrWhiteSpace(o.AccessToken))
                    {
                        accessToken = o.AccessToken.Replace("\"", "");
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

                    if (!String.IsNullOrWhiteSpace(o.OrganizationId))
                    {
                        organizationId = o.OrganizationId;
                    }

                      // The following lines were added by JoshuaD due to no longer being able to deploy an Azure DevOps tenant via the Azure portal
                    if (!String.IsNullOrWhiteSpace(o.DevOps))
                    {
                        devops = o.DevOps.Replace("\"", "");
                    }
                });

            var azure = GenerateAzureInstance(authFile, subscriptionId);
        
            // The following line was commented out by JoshuaD due to no longer being able to deploy an Azure DevOps tenant via the Azure portal
            //DeployAzureDevOpsTenant(azure, subscriptionId, path, organizationId);

            var pat = GeneratePat(organizationId, accessToken);

            DeployAzureTenant(azure, subscriptionId, path + "/repos", organizationId);

            // The following line was commented out by JoshuaD due to no longer being able to deploy an Azure DevOps tenant via the Azure portal
            //DeployDevOps(pat, path + "/repos", organizationId);

            // The following line was added by JoshuaD due to no longer being able to deploy an Azure DevOps tenant via the Azure portal
            DeployDevOps(pat, path + "/repos", devops);
        }

        static string GenerateOrgId()
        {
            return new Random().Next(0, 1000000).ToString("D6");
        }

        static IAzure GenerateAzureInstance(string authFile, string subscriptionId)
        {
            var credentials = SdkContext.AzureCredentialsFactory.FromFile(authFile);

            return Azure
                    .Configure()
                    .WithLogLevel(HttpLoggingDelegatingHandler.Level.Basic)
                    .Authenticate(credentials)
                    .WithSubscription(subscriptionId);
        }

        static string GeneratePat(string orgId, string accessToken)
        {
            if (string.IsNullOrEmpty(accessToken))
            {
                Console.WriteLine();
                // The following line was commented out by JoshuaD due to no longer being able to deploy an Azure DevOps tenant via the Azure portal
                //Console.Write($"Token not provided. Enter PAT manually (WAFOpenHack{orgId}): ");

                // The following line was added by JoshuaD due to no longer being able to deploy an Azure DevOps tenant via the Azure portal
                Console.Write($"Token not provided. Enter PAT manually: ");
                accessToken = Console.ReadLine();

                return accessToken;
            }
            else
            {
                // The following lines were commented out by JoshuaD due to no longer being able to deploy an Azure DevOps tenant via the Azure portal
                /*
                var azureHelper = new AzureHelper(null, null, orgId);
                    
                return azureHelper.GeneratePat(accessToken).Result;
                */

                // The following line was added by JoshuaD due to no longer being able to deploy an Azure DevOps tenant via the Azure portal
                return accessToken;
            }
        }

        static void DeployAzureDevOpsTenant(IAzure azure, string subscriptionId, string path, string orgId)
        {
            Console.WriteLine("*********************************");
            Console.WriteLine("*                               *");
            Console.WriteLine("* Deploying Azure DevOps Tenant *");
            Console.WriteLine("*                               *");
            Console.WriteLine("*********************************");

            var azureHelper = new AzureHelper(azure, subscriptionId, orgId);
            azureHelper.DeployAzDoTemplate(path + "/azdo");

            Console.WriteLine();
        }

        static void DeployAzureTenant(IAzure azure, string subscriptionId, string path, string orgId)
        {
            Console.WriteLine("*********************************");
            Console.WriteLine("*                               *");
            Console.WriteLine("* Deploying Azure Resources     *");
            Console.WriteLine("*                               *");
            Console.WriteLine("*********************************");

            var azureHelper = new AzureHelper(azure, subscriptionId, orgId);
            azureHelper.DeployTemplate(path + "/bicep");

            Console.WriteLine();
        }

        static void DeployDevOps(string accessToken, string path, string orgId)
        {
            var credentials = new VssBasicCredential(string.Empty, accessToken);
            // The following line was commented out by JoshuaD due to no longer being able to deploy an Azure DevOps tenant via the Azure portal
            // var organization = "WAFOpenHack" + orgId;

            // The following line was added by JoshuaD due to no longer being able to deploy an Azure DevOps tenant via the Azure portal
            var organization = orgId;
            var adoHelper = new AdoHelper(credentials, "https://dev.azure.com/" + organization);

            Console.WriteLine("*********************************");
            Console.WriteLine("*                               *");
            Console.WriteLine("* Deploying Azure DevOps Repos  *");
            Console.WriteLine("*                               *");
            Console.WriteLine("*********************************");

            // Create Bicep project
            var bicepProject = adoHelper.CreateProject("Bicep");
            var bicepTempRepo = adoHelper.CreateRepository(bicepProject, "temp", true);
            adoHelper.RemoveRepository(bicepProject, "Bicep", isDefault: true);
            var bicepRepo = adoHelper.CreateRepository(bicepProject, "bicep");
            adoHelper.CommitRepository(organization, bicepProject, bicepRepo, accessToken, path + "/bicep");
            adoHelper.RemoveRepository(bicepProject, "temp", isTemp: true);

            // Create Portal project
            var portalProject = adoHelper.CreateProject("Portal");
            var processorRepo = adoHelper.CreateRepository(portalProject, "processor");
            adoHelper.CommitRepository(organization, portalProject, processorRepo, accessToken, path + "/portal/processor");
            var webRepo = adoHelper.CreateRepository(portalProject, "web");
            adoHelper.CommitRepository(organization, portalProject, webRepo, accessToken, path + "/portal/web");
            adoHelper.RemoveRepository(portalProject, "Portal", isDefault: true);

            Console.WriteLine();
        }
    }
}
