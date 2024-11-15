using GetTvShowTotalLength;
using System.Net.Http.Headers;
using System.Text.Json;

if (args.Length == 0)
    Exit10NoShows();

using HttpClient client = new();
client.DefaultRequestHeaders.Accept.Clear();
client.DefaultRequestHeaders.Accept.Add(
    new MediaTypeWithQualityHeaderValue("application/json"));
client.DefaultRequestHeaders.Add("User-Agent", "TV Show Length Checker");
await ProcessTvShowAsync(client, args[0]);

static async Task ProcessTvShowAsync(HttpClient client, string showName)
{
    await using Stream showsStream = await client.GetStreamAsync(
        "https://api.tvmaze.com/search/shows?q=" + showName);
    var tvShows = await JsonSerializer.DeserializeAsync<List<TvShowDto>>(showsStream);
    if (tvShows!.Count == 0)
        Exit10NoShows();

    var show = tvShows.Select(show => show.show).Where(show => show.name.Equals(showName,StringComparison.InvariantCultureIgnoreCase))
        .OrderByDescending(show => show.premiered).FirstOrDefault();
    if(show == null)
        Exit10NoShows();

    await using Stream episodesStream = await client.GetStreamAsync(
        $"https://api.tvmaze.com/shows/{show!.id}/episodes");
    var episodes = await JsonSerializer.DeserializeAsync<List<Episode>>(episodesStream);
    var sumRuntime= episodes!.Sum(ep => ep.runtime);
    Console.WriteLine(sumRuntime);
}

static void Exit10NoShows()
{
    Environment.Exit(10);
}