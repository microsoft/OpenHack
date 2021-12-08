using System;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;
using Microsoft.Azure.Management.Fluent;
using Microsoft.Azure.Management.ResourceManager.Fluent.Core;
using Microsoft.Azure.Management.ResourceManager.Fluent.Models;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using System.Text;

namespace Deploy
{
    public class AzureHelper
    {
        private IAzure _azure;
        private string _subscriptionId;
        private string _orgId;

        private AzureHelper() { }
        public AzureHelper(IAzure azure, string subscriptionId, string orgId)
        {
            _azure = azure;
            _subscriptionId = subscriptionId;
            _orgId = orgId;
        }

        public void DeployTemplate(string path)
        {
            Console.WriteLine("- Building ARM Template from Bicep...");
            if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
                Process.Start("CMD.exe", $@"/C az bicep build --file " + Path.GetFullPath(path + "/main.bicep")).WaitForExit();
            else
                Process.Start("az", $@"bicep build --file " + Path.GetFullPath(path + "/main.bicep")).WaitForExit();
            
            Console.WriteLine("- Parsing ARM Template...");
            var templateJson = GetArmTemplate(Path.GetFullPath(path + "/main.json"));

            Console.WriteLine("- Creating resource group 'webapp'...");
            _azure.ResourceGroups.Define("webapp")
                .WithRegion(Region.USEast)
                .Create();

            Console.WriteLine($"- Deploying template to subscription '{_subscriptionId}' (this may take 15-20 minutes)...");
            _azure.Deployments.Define("woodgrove")
                .WithExistingResourceGroup("webapp")
                .WithTemplate(templateJson)
                .WithParameters("{}")
                .WithMode(DeploymentMode.Complete)
                .Create();

            File.Delete(Path.GetFullPath(path + "/main.json"));
        }

        public void DeployAzDoTemplate(string path)
        {
            Console.WriteLine("- Parsing ARM Template...");
            var templateJson = GetAzDoArmTemplate(Path.GetFullPath(path + "/azuredevops.json"));

            Console.WriteLine($"- Creating Azure DevOps tenant 'WAFOpenHack{_orgId}'...");
            _azure.ResourceGroups.Define("azdoTenant")
                .WithRegion(Region.USCentral)
                .Create();

            Console.WriteLine($"- Deploying template to subscription '{_subscriptionId}' (this may take a few minutes)...");

            Process.Start("az", $@"deployment group create --output none --resource-group azdoTenant --name azdo --template-file {System.IO.Path.GetFullPath(path + "/azuredevops.json")} --parameters devOpsOrgId={_orgId}").WaitForExit();
            
            /*
            * The below is commented out due to deploying an Azure DevOps tenant using the FluidAPI will generate an error about no user provided.
            * Therefore, the above process is leveraging the Azure CLI for deploying Azure DevOps. Once the bug is fixed, the below code can be used
            * in favor over the above process.
            */
            /*
            _azure.Deployments.Define("azdo")
                .WithExistingResourceGroup("azdoTenant")
                .WithTemplate(templateJson)
                .WithParameters("{}")
                .WithMode(DeploymentMode.Complete)
                .Create();
            */
        }

        public string GetArmTemplate(string templateFileName)
        {
            var armTemplateString = File.ReadAllText(templateFileName);
            var parsedTemplate = JObject.Parse(armTemplateString);

            parsedTemplate.SelectToken("parameters.region")["defaultValue"] = "eastus2";
            parsedTemplate.SelectToken("parameters.vnetName")["defaultValue"] = "vnet-webapp";
            parsedTemplate.SelectToken("parameters.elbName")["defaultValue"] = "elbwebapp";
            parsedTemplate.SelectToken("parameters.storageWeb")["defaultValue"] = "storwdgrvweb" + _orgId;
            parsedTemplate.SelectToken("parameters.storageProc")["defaultValue"] = "storwdgrvproc" + _orgId;
            parsedTemplate.SelectToken("parameters.storageSql")["defaultValue"] = "storwdgrvsql" + _orgId;
            parsedTemplate.SelectToken("parameters.web1vmDnsLabel")["defaultValue"] = "woodgroveweb1" + _orgId;
            parsedTemplate.SelectToken("parameters.web2vmDnsLabel")["defaultValue"] = "woodgroveweb2" + _orgId;
            parsedTemplate.SelectToken("parameters.worker1vmDnsLabel")["defaultValue"] = "woodgroveworker1" + _orgId;
            parsedTemplate.SelectToken("parameters.sqlsvr1vmDnsLabel")["defaultValue"] = "woodgrovesql1" + _orgId;
            parsedTemplate.SelectToken("parameters.elbDnsLabel")["defaultValue"] = "woodgroveelb" + _orgId;
            parsedTemplate.SelectToken("parameters.adminUsername")["defaultValue"] = "cloudadmin";
            parsedTemplate.SelectToken("parameters.adminPassword")["defaultValue"] = "Pass@word1234!";
            parsedTemplate.SelectToken("parameters.sqlAdminUsername")["defaultValue"] = "cloudsqladmin";
            parsedTemplate.SelectToken("parameters.sqlAdminPassword")["defaultValue"] = "(Pass@word)1234!";

            return parsedTemplate.ToString();
        }

        public string GetAzDoArmTemplate(string templateFileName)
        {
            var armTemplateString = File.ReadAllText(templateFileName);
            var parsedTemplate = JObject.Parse(armTemplateString);

            parsedTemplate.SelectToken("parameters.devOpsOrgId")["defaultValue"] = _orgId;

            return parsedTemplate.ToString();
        }

        public async Task<string> GeneratePat(string accessToken)
        {
            using (var client = new HttpClient()) {
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
                
                string json = Newtonsoft.Json.JsonConvert.SerializeObject(new {
                    displayName = "openhack",
                    scope = "app_token",
                    allOrgs = false
                });

                var data = new StringContent(json, Encoding.UTF8, "application/json");
                var response = await client.PostAsync($"https://vssps.dev.azure.com/WAFOpenHack{_orgId}/_apis/Tokens/Pats?api-version=6.1-preview", data);

                var result = response.Content.ReadAsStringAsync().Result;
                var jObj = JObject.Parse(result);
                return jObj["patToken"]["token"].ToString();
            }
        }
    }
}