class UptimeKeeper extends RCONActors;

var int UptimeMinutes;
var int UptimeHours;
var string FinalUptime;
var string formattedmin;

function Timer()
{
	UptimeMinutes++;
	if(UptimeMinutes == 60)
	{
		UptimeMinutes = 0;
		UptimeHours++;
	}
	
	if(UptimeMinutes <= 9)
	{
		formattedmin = "0"$UptimeMinutes;
	}
	else
	{
		formattedmin = string(UptimeMinutes);
	}
	
	FinalUptime = UptimeHours$":"$formattedmin;
}


defaultproperties
{
bHidden=True
}
