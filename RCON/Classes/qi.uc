class qi extends RCONActors;

var() bool QIL, QNP;
var() DeusExPlayer iPlayer;

function Timer()
{
	if(QIL) //Quit if player is none
	{
		if(iPlayer == None || iPlayer.PlayerReplicationInfo.PlayerName == "")
			ConsoleCommand("quit");
	}
	
	if(QNP)
	{
		if(GPC() == 0)
		{
			ConsoleCommand("quit");
		}
	}
}

function int GPC()
{
	local PlayerPawn P;
	local int i;
	
	foreach AllActors(class'PlayerPawn',P)
		i++;
		
	return i;
}
defaultproperties
{
}
