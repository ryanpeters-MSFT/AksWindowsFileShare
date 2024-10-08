using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);

builder.Configuration.AddEnvironmentVariables();

var app = builder.Build();

var configuration = app.Services.GetRequiredService<IConfiguration>();

app.MapGet("/", () =>
{
    var configurationPath = configuration["ConfigurationPath"];

    var dataPath = Path.Combine(configurationPath, "data.json");

    var jsonContent = File.ReadAllText(dataPath);
    var jsonDocument = JsonDocument.Parse(jsonContent);

    var connection = jsonDocument.RootElement.GetProperty("connection").ToString();

    return Results.Ok(connection);    
});

app.Run();