using System;
using System.Collections.Generic;
using diag = System.Diagnostics;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using System.Threading;
using System.Runtime.InteropServices;
using Microsoft.TeamFoundation.Core.WebApi;
using Microsoft.VisualStudio.Services.Common;
using Microsoft.VisualStudio.Services.Operations;
using Microsoft.VisualStudio.Services.WebApi;
using Microsoft.TeamFoundation.SourceControl.WebApi;
using System.Text;

namespace Deploy
{
    public class AdoHelper
    {
        private VssCredentials _credentials;
        private string _collectionUrl;
        private VssConnection _connection;

        private AdoHelper() { }
        public AdoHelper(VssCredentials credentials, string collectionUrl)
        {
            _credentials = credentials;
            _collectionUrl = collectionUrl;
            _connection = new VssConnection(new Uri(_collectionUrl), _credentials);
        }

        public TeamProject CreateProject(string project)
        {
            // Version control properties
            Dictionary<string, string> versionControlProperties = new Dictionary<string, string>();
            versionControlProperties[TeamProjectCapabilitiesConstants.VersionControlCapabilityAttributeName] = SourceControlTypes.Git.ToString();

            // Process properties
            ProcessHttpClient processClient = _connection.GetClient<ProcessHttpClient>();
            Guid processId = processClient.GetProcessesAsync().Result.Find(process => { return process.Name.Equals("Agile", StringComparison.InvariantCultureIgnoreCase); }).Id;

            Dictionary<string, string> processProperties = new Dictionary<string, string>();
            processProperties[TeamProjectCapabilitiesConstants.ProcessTemplateCapabilityTemplateTypeIdAttributeName] = processId.ToString();

            // Capabilities dictionary
            Dictionary<string, Dictionary<string, string>> capabilities = new Dictionary<string, Dictionary<string, string>>();
            capabilities[TeamProjectCapabilitiesConstants.VersionControlCapabilityName] = versionControlProperties;
            capabilities[TeamProjectCapabilitiesConstants.ProcessTemplateCapabilityName] = processProperties;

            // Create 'Bicep' project
            var projectCreateParams = new TeamProject()
            {
                Name = project,
                Capabilities = capabilities
            };

            var projectClient = _connection.GetClient<ProjectHttpClient>();

            TeamProject createdProject = null;
            try
            {
                Console.WriteLine($"Queuing project creation '{project}'...");

                OperationReference operation = projectClient.QueueCreateProject(projectCreateParams).Result;

                Operation completedOperation = WaitForLongRunningOperation(_connection, operation.Id, 5, 30).Result;

                if (completedOperation.Status == OperationStatus.Succeeded)
                {
                    createdProject = projectClient.GetProject(projectCreateParams.Name, includeCapabilities: true, includeHistory: true).Result;

                    Console.WriteLine();
                    Console.WriteLine($"Project created (ID: {createdProject.Id})...");
                }
                else
                {
                    Console.WriteLine("Project creation operation failed: " + completedOperation.ResultMessage);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Exception during create project: ", ex.Message);
            }

            Console.WriteLine();
            return createdProject;
        }

        public GitRepository CreateRepository(TeamProject project, string repoName, bool isTemp = false)
        {
            GitHttpClient gitClient = _connection.GetClient<GitHttpClient>();
            GitRepositoryCreateOptions options = new GitRepositoryCreateOptions()
            {
                Name = repoName,
                ProjectReference = project
            };

            if (isTemp)
                Console.WriteLine($"- Creating temp repo...");
            else
                Console.WriteLine($"- Creating new repo '{repoName}'...");

            var repo = gitClient.CreateRepositoryAsync(options).Result;
            Console.WriteLine($"  - Repo created successfully (ID: {repo.Id})...");
            
            return repo;
        }

        public void RemoveRepository(TeamProject project, string repoName, bool isDefault = false, bool isTemp = false)
        {
            GitHttpClient gitClient = _connection.GetClient<GitHttpClient>();
            GitRepositoryCreateOptions options = new GitRepositoryCreateOptions()
            {
                Name = repoName,
                ProjectReference = project
            };

            var repos = gitClient.GetRepositoriesAsync(project.Id).Result;
            var repo = repos.SingleOrDefault(r => r.Name.ToLower() == repoName.ToLower());

            if (repo is not null) {
                if (isDefault)
                    Console.WriteLine($"- Removing default repo...");
                else if (isTemp)
                    Console.WriteLine($"- Removing temp repo...");
                else
                    Console.WriteLine($"- Removing repo '{repoName}'...");

                gitClient.DeleteRepositoryAsync(repo.Id).SyncResult();
                Console.WriteLine("  - Deletion completed...");
            }
        }

        public void CommitRepository(string org, TeamProject project, GitRepository repo, string pat, string path)
        {
            var patBytes = Encoding.UTF8.GetBytes(":" + pat);
            string patBase64 = Convert.ToBase64String(patBytes);

            GitHttpClient gitClient = _connection.GetClient<GitHttpClient>();

            Console.WriteLine($"- Pushing repo '{repo.Name}'...");

            diag.Process.Start("git", $@"init {Path.GetFullPath(path)}").WaitForExit();
            diag.Process.Start("git", $@"-C {Path.GetFullPath(path)} branch -m main").WaitForExit();
            diag.Process.Start("git", $@"-C {Path.GetFullPath(path)} remote add {org} {repo.RemoteUrl}").WaitForExit();
            diag.Process.Start("git", $@"-C {Path.GetFullPath(path)} add .").WaitForExit();
            diag.Process.Start("git", $@"-C {Path.GetFullPath(path)} commit -a -m ""Initial commit""").WaitForExit();
            diag.Process.Start("git", $@"-C {Path.GetFullPath(path)} -c http.extraHeader=""Authorization: Basic {patBase64}"" push -u {org} --all").WaitForExit();
            
            Console.WriteLine($"  - Commit completed successfully)...");
        }

        private async Task<Operation> WaitForLongRunningOperation(VssConnection connection, Guid operationId, int interavalInSec = 5, int maxTimeInSeconds = 60, CancellationToken cancellationToken = default(CancellationToken))
        {
            OperationsHttpClient operationsClient = connection.GetClient<OperationsHttpClient>();
            DateTime expiration = DateTime.Now.AddSeconds(maxTimeInSeconds);
            int checkCount = 0;

            while (true)
            {
                Console.WriteLine(" Checking status ({0})... ", (checkCount++));

                Operation operation = await operationsClient.GetOperation(operationId, cancellationToken);

                if (!operation.Completed)
                {
                    Console.WriteLine("   Pausing {0} seconds", interavalInSec);

                    await Task.Delay(interavalInSec * 1000);

                    if (DateTime.Now > expiration)
                    {
                        throw new Exception(String.Format("Operation did not complete in {0} seconds.", maxTimeInSeconds));
                    }
                }
                else
                {
                    return operation;
                }
            }
        }
    }
}