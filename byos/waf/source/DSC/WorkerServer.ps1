Configuration WorkerServer {
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration, ComputerManagementDsc

    Node localhost {

        ScheduledTask TransactionProcessor
        {
            TaskName           = 'Process Bank Transactions'
            ActionExecutable   = 'D:\jobs\Processor.exe'
            ScheduleType       = 'Once'
            RepeatInterval     = '01:00:00'
            RepetitionDuration = 'Indefinitely'
        }
    }
}