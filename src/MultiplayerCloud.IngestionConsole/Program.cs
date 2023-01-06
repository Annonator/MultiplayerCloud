// See https://aka.ms/new-console-template for more information

using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Producer;
using MultiplayerCloud.IngestionConsole;

Console.WriteLine("Hello, World!");

var connectionString =
    "";
var eventHubName = "analyticshub";

var producer = new EventHubProducerClient(
    connectionString,
    eventHubName);
try
{
    while (true)
    {
        using var eventBatch = await producer.CreateBatchAsync();

        for (var counter = 0; counter < 10; ++counter)
        {
            var data = new Data
            {
                UserId = Guid.NewGuid(),
                LastActivity = DateTime.Now
            };

            Console.WriteLine(data);

            var eventBody = new BinaryData(data);
            var eventData = new EventData(eventBody);

            if (!eventBatch.TryAdd(eventData))
                // At this point, the batch is full but our last event was not
                // accepted.  For our purposes, the event is unimportant so we
                // will intentionally ignore it.  In a real-world scenario, a
                // decision would have to be made as to whether the event should
                // be dropped or published on its own.
                break;
        }

        // When the producer publishes the event, it will receive an
        // acknowledgment from the Event Hubs service; so long as there is no
        // exception thrown by this call, the service assumes responsibility for
        // delivery.  Your event data will be published to one of the Event Hub
        // partitions, though there may be a (very) slight delay until it is
        // available to be consumed.
        await producer.SendAsync(eventBatch);

        Thread.Sleep(1000);
    }
}
catch
{
    // Transient failures will be automatically retried as part of the
    // operation. If this block is invoked, then the exception was either
    // fatal or all retries were exhausted without a successful publish.
}
finally
{
    await producer.CloseAsync();
}