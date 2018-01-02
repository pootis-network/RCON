class CLC extends Actor;

var string ChatLogs[80];

function GetLogs()
{
	local AthenaSpectator AS;
	local int i;
	
	foreach AllActors(class'AthenaSpectator', AS)
	{
			for(i=0; i<79; i++)
			{
				Chatlogs[i] = AS.Chatlogs[i];
			}
	}
}
defaultproperties
{
}