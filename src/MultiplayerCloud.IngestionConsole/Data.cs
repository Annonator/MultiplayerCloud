namespace MultiplayerCloud.IngestionConsole;

public class Data
{
    public Guid UserId { get; set; }
    public DateTime LastActivity { get; set; }

    public override string ToString()
    {
        return "UserId: " + UserId + " Last Activity: " + LastActivity;
    }
}