Configuration SqlServer {
    
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [PSCredential]
        $ServerCredential,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [PSCredential]
        $DatabaseCredential
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration, SqlServerDsc, NetworkingDsc

    Node localhost {

        SqlDatabase CreateDatabase
        {
            Ensure          = 'Present'
            ServerName      = 'sqlsvr1'
            InstanceName    = 'MSSQLSERVER'
            Name            = 'CustomerPortal'

            PsDscRunAsCredential = $ServerCredential
        }

        SqlLogin CreateDatabaseLogin
        {
            Ensure          = 'Present'
            Name            = 'webapp'
            LoginType       = 'SqlLogin'
            ServerName      = 'sqlsvr1'
            InstanceName    = 'MSSQLSERVER'
            LoginCredential = $DatabaseCredential
            LoginMustChangePassword        = $false
            LoginPasswordExpirationEnabled = $false
            LoginPasswordPolicyEnforced    = $true

            PsDscRunAsCredential = $ServerCredential
            DependsOn       = '[SqlDatabase]CreateDatabase'
        }

        SqlDatabaseUser CreateDatabaseUser
        {
            Ensure          = 'Present'
            ServerName      = 'sqlsvr1'
            InstanceName    = 'MSSQLSERVER'
            DatabaseName    = 'CustomerPortal'
            Name            = 'webapp'
            UserType        = 'Login'
            LoginName       = 'webapp'

            PsDscRunAsCredential = $ServerCredential
            DependsOn       = '[SqlLogin]CreateDatabaseLogin'
        }

        SqlDatabaseRole SetUserAsOwner
        {
            Ensure          = 'Present'
            ServerName      = 'sqlsvr1'
            InstanceName    = 'MSSQLSERVER'
            DatabaseName    = 'CustomerPortal'
            Name            = 'db_owner'
            MembersToInclude = @('webapp')

            PsDscRunAsCredential = $ServerCredential
            DependsOn       = '[SqlDatabaseUser]CreateDatabaseUser'
        }

        FirewallProfile ConfigurePrivateFirewallProfile
        {
            Name            = 'Private'
            Enabled         = 'False'
        }

        FirewallProfile ConfigurePublicFirewallProfile
        {
            Name            = 'Public'
            Enabled         = 'False'
        }

        FirewallProfile ConfigureDomainFirewallProfile
        {
            Name            = 'Domain'
            Enabled         = 'False'
        }
    }
}