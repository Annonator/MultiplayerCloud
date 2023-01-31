using System.Net;
using System.Security.AccessControl;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace MultiplayerCloud.AnalyticsIngest;

public class UserLoggedIn
{
    private readonly ILogger _logger;

    public UserLoggedIn(ILoggerFactory loggerFactory)
    {
        _logger = loggerFactory.CreateLogger<UserLoggedIn>();
    }

    [Function("Ingest")]
    public async Task<CustomResult> Run([HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequestData req)
    {
        var payload = await req.ReadAsStringAsync();
        
        _logger.LogInformation(payload);

        var message = payload!;

        var response = req.CreateResponse(HttpStatusCode.OK);
        response.Headers.Add("Content-Type", "text/plain; charset=utf-8");

        return new CustomResult()
        {
            Event = message,
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