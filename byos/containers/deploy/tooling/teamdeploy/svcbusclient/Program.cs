// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

namespace SendCredentials
{
    using Microsoft.Azure.ServiceBus;
    using Microsoft.Azure.ServiceBus.InteropExtensions;
    using System;
    using System.IO;
    using System.Text;
    using System.Threading;
    using System.Threading.Tasks;
    using System.Collections.Generic;
    using System.Runtime.Serialization;

    class Program
    {
        // Connection String for the namespace can be obtained from the Azure portal under the 
        // 'Shared Access policies' section.
        static IQueueClient queueClient;

        static void Main(string[] args)
        {
            string ServiceBusConnectionString;
            string QueueName;
            string recipientEmail;
            string MessageBody;

            Console.WriteLine(args.Length);

            try {

                ServiceBusConnectionString = args[0];
                QueueName = args[1];
                recipientEmail = args[2];
                MessageBody = args[3];

                Console.WriteLine("Sending to queue " + QueueName);
                MainAsync(ServiceBusConnectionString, QueueName, recipientEmail, MessageBody).GetAwaiter().GetResult();
            }
            catch (Exception exception)
            {
                Console.WriteLine($"{DateTime.Now} :: Exception: {exception.Message}");
            }
        }

        static async Task MainAsync(string ServiceBusConnectionString, string QueueName, string recipientEmail, string MessageBody)
        {
            Console.WriteLine($"mainAsync");
            queueClient = new Microsoft.Azure.ServiceBus.QueueClient(ServiceBusConnectionString, QueueName);
            Console.WriteLine($"before send ansync");
            // Send Messages
            await SendMessagesAsync(recipientEmail, MessageBody);

            await queueClient.CloseAsync();
        }

        static async Task SendMessagesAsync(string recipientEmail, string messageBody)
        {
            Random rnd = new Random();
            try
            {
                Console.WriteLine($"SendMessagesAsync");
                    // Create a new message to send to the queue
                    var message = new Dictionary<string, string>
                    {
                        { "ReceiverEmail", recipientEmail },
                        { "Message", messageBody }
                    };

                    var serializer = DataContractBinarySerializer<Dictionary<string, string>>.Instance;
                    byte[] data;

                    using (MemoryStream stream = new MemoryStream())
                    {
                        serializer.WriteObject(stream, message);
                        data = stream.ToArray();
                    }

                   var sbmessage = new Message(data);
                   await queueClient.SendAsync(sbmessage);

            }
            catch (Exception exception)
            {
                Console.WriteLine($"{DateTime.Now} :: Exception: {exception.Message}");
            }
        }
    }
}