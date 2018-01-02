class ClockWatchActor extends RCONActors;
var AthenaSpectator Spect;
var() string AlarmTime;
var int Ran;
var string mealtime, stringtime;

function Timer()
{
local DeusExPlayer DXP;
local bool bFound;

	if(level.minute == 0 && Ran != level.hour)
	{
		Ran = level.hour;
			foreach AllActors(class'DeusExPlayer', DXP)
				bFound=True;
		
		if(bFound)		
			Spect.ASay("The current time is now"@GetTime());
	}
	if(GetTime() == AlarmTime)
	{
		Spect.ASay("Alarm!");
		AlarmTime = "";
	}
}

function string GetTime()
{
local string formattedmin;
	if(level.minute <= 9)
	{
		formattedmin = "0"$level.minute;
	}
	else
	{
		formattedmin = string(level.minute);
	}
return level.hour$":"$formattedmin;
}

function string GetTimeStr()
{
	if(Level.Hour >= 5 && Level.Hour < 12)
		return "morning";
	else if(Level.Hour >= 12 && Level.Hour < 17)
		return "afternoon";
	else if(Level.Hour >= 17 && Level.Hour < 22)
		return "evening";
	else 
		return "night";
}

function string GetMealStr()
{
	if(Level.Hour >= 5 && Level.Hour < 11)
		return "breakfast";
	else if(Level.Hour >= 11 && Level.Hour < 14)
		return "lunch";
	else if(Level.Hour >= 14 && Level.Hour < 19)
		return "dinner";
	else
		return "supper";
}

defaultproperties
{
bHidden=True
}
