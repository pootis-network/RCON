class LagWatchActor extends RCONActors;
var AthenaSpectator Spect;
var int Delay, DelayDeco;
var bool bHadDecoWarning;

function Timer()
{
local deusexplayer dxp;
local deusexdecoration dxd;
local string Warning;
local int count;
local RCON RC;

	if(Spect != None)
	{
	Delay--;
		foreach AllActors(class'DeusExPlayer', DXP)
		{
			if(DXP.PlayerReplicationInfo.Ping >= 300 && DXP.PlayerReplicationInfo.Ping < 500 )
				Warning = "ping";
			else if(DXP.PlayerReplicationInfo.Ping >= 500 && DXP.PlayerReplicationInfo.Ping < 900 )
				Warning = "pingrisk";
			else if(DXP.PlayerReplicationInfo.Ping >= 900)
				Warning = "pingwarning";
		}
		foreach AllActors(class'DeusExDecoration',DXD)
			count++;
			
		if(Delay < 0)
		{
		if(Warning == "ping")
		Spect.ASay("Pings are above 300. There may be nothing to worry about, though.");
		else if(Warning == "pingrisk")
		Spect.ASay("Pings are above 500. If there is a downloader, please wait for it to pass. Otherwise, I recommend deleting some objects.");
		else if(Warning == "pingwarning")
		Spect.ASay("Severe ping detected. Errors may occur. I suggest deleting unneeded objects or restarting the server.");
			
		/*	if(count > 200)
			{
				if(bHadDecoWarning)
				{
					Spect.ASay("Precautions are being taken due to excessive decoration spawns.");
						foreach AllActors(class'RCON',RC)
						{
							if(RC.bPlayerSummoning)
							{
							RC.bPlayerSummoning=False;
							Spect.ASay("RCON Player Summoning command has been deactivated.");
							}
						}
						foreach AllActors(class'DeusExDecoration', DXD)
						{
							if(frand() < 0.2)
							
						}
				}
				else
				{
				Spect.ASay("There's quite a lot of decorations in the map. If this impacts server performance, I will begin taking precautions.");
				bHadDecoWarning=True;
				DelayDeco=60;
				}
			}
			else if(count <= 150 && bHadDecoWarning)
			{
				DelayDeco--;
				if(DelayDeco <= 0)
					bHadDecoWarning=False;
			}*/
		} 
		
		if(Warning != "")
			Delay = 10;
	}
}

defaultproperties
{
bHidden=True
}
