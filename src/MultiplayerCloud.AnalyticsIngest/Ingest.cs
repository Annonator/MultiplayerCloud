using System.Net;
using System.Security.AccessControl;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;

namespace MultiplayerCloud.AnalyticsIngest;

public class Ingest
{
    private readonly ILogger _logger;

    public Ingest(ILoggerFactory loggerFactory)
    {
        _logger = loggerFactory.CreateLogger<Ingest>();
    }

    [Function("Ingest")]
    public CustomResult Run([HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequestData req)
    {
        _logger.LogInformation("C# HTTP trigger function processed a request.");

        var message = $"Send Event at {DateTime.Now}";

        var response = req.CreateResponse(HttpStatusCode.OK);
        response.Headers.Add("Content-Type", "text/plain; charset=utf-8");

        response.WriteString("Welcome to Azure Functions!");

        return new CustomResult()
        {
            Event = $"Send Event at {DateTime.Now}",
            HttpResponse = response
        };
    }
}

public class CustomResult
{    
    [EventHubOutput("analyticsHub", Connection = "analyticsHub")]
    public string Event { get; set; }
    public HttpResponseData HttpResponse { get; set; }
}