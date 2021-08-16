using System;
using System.Diagnostics;
using System.IO;
using Microsoft.Azure.Management.Fluent;
using Microsoft.Azure.Management.ResourceManager.Fluent.Core;
using Microsoft.Azure.Management.ResourceManager.Fluent.Models;
using Newtonsoft.Json.Linq;

namespace Deploy
{
    public class AzureHelper
    {
        private IAzure _azure;

        private AzureHelper() { }
        public AzureHelper(IAzure azure)
        {
            _azure = azure;
        }

        public void DeployTemplate(string subscriptionId, string path)
        {
            Console.WriteLine("- Building ARM Template from Bicep...");
            Process.Start("az", $@"bicep build --file " + Path.Combine(path, "\\main.bicep")).WaitForExit();

            Console.WriteLine("- Parsing ARM Template...");
            var templateJson = GetArmTemplate(Path.Combine(path + "\\main.json"));

            Console.WriteLine("- Creating resource group 'webapp'...");
            _azure.ResourceGroups.Define("webapp")
                .WithRegion(Region.USEast)
                .Create();

            Console.WriteLine($"- Deploying template to subscription '{subscriptionId}' (this may take 15-20 minutes)...");
            _azure.Deployments.Define("woodgrove")
                .WithExistingResourceGroup("webapp")
                .WithTemplate(templateJson)
                .WithParameters("{}")
                .WithMode(DeploymentMode.Complete)
                .Create();
        }

        public string GetArmTemplate(string templateFileName)
        {
            var armTemplateString = File.ReadAllText(templateFileName);
            var parsedTemplate = JObject.Parse(armTemplateString);
            var rand = new Random().Next(0, 1000000).ToString("D6");

            parsedTemplate.SelectToken("parameters.resource_group_name")["defaultValue"] = "webapp";
            parsedTemplate.SelectToken("parameters.region")["defaultValue"] = "eastus";
            parsedTemplate.SelectToken("parameters.vnet_name")["defaultValue"] = "vnet-webapp";
            parsedTemplate.SelectToken("parameters.elb_name")["defaultValue"] = "elbwebapp";
            parsedTemplate.SelectToken("parameters.nsg_name")["defaultValue"] = "nsg-webapp";
            parsedTemplate.SelectToken("parameters.storage_web")["defaultValue"] = "storwoodgroveweb" + rand;
            parsedTemplate.SelectToken("parameters.storage_sql")["defaultValue"] = "storwoodgrovesql" + rand;
            parsedTemplate.SelectToken("parameters.web1vm_dnslabel")["defaultValue"] = "woodgroveweb1" + rand;
            parsedTemplate.SelectToken("parameters.web2vm_dnslabel")["defaultValue"] = "woodgroveweb2" + rand;
            parsedTemplate.SelectToken("parameters.worker1vm_dnslabel")["defaultValue"] = "woodgroveworker1" + rand;
            parsedTemplate.SelectToken("parameters.sqlsvr1vm_dnslabel")["defaultValue"] = "woodgrovesql1" + rand;
            parsedTemplate.SelectToken("parameters.external_load_balancer_dnslabel")["defaultValue"] = "woodgroveelb" + rand;
            parsedTemplate.SelectToken("parameters.admin_username")["defaultValue"] = "cloudadmin";
            parsedTemplate.SelectToken("parameters.admin_password")["defaultValue"] = "Pass@word1234!";
            parsedTemplate.SelectToken("parameters.sql_admin_username")["defaultValue"] = "cloudsqladmin";
            parsedTemplate.SelectToken("parameters.sql_admin_password")["defaultValue"] = "(Pass@word)1234!";

            return parsedTemplate.ToString();
        }
    }
}