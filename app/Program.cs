using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);

builder.Configuration.AddEnvironmentVariables();

var app = builder.Build();

var configuration = app.Services.GetRequiredService<IConfiguration>();

app.MapGet("/", () =>
{
    // the directory containing the configuration files (mounted externally)
    var configurationPath = configuration["ConfigurationPath"];

    // retrieve a specific configuration file from the directory
    var dataPath = Path.Combine(configurationPath, "data.json");

    // parse and output the "connection" value
    var jsonContent = File.ReadAllText(dataPath);
    var jsonDocument = JsonDocument.Parse(jsonContent);

    var connection = jsonDocument.RootElement.GetProperty("connection").ToString();

    return Results.Ok(connection);    
});

app.Run();