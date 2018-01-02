//=============================================================================
// Spectator.
//=============================================================================
class TirSpectator extends MessagingSpectator;

var AthenaMutator AM;
var IRCLink IRC;

function ASay(string str)
{
local DeusExPlayer DXP;
	if(AM.bMuted)
		return;
		
	BroadcastMessage("|"$AM.ChatColour$"~ Tir:"@str);
	
	foreach AllActors(class'DeusExPlayer',DXP)
	{
		DXP.PlaySound(sound'DatalinkStart', SLOT_None,,, 256);
	}
}

function AStatus(string str)
{
	if(str == "")
	Self.PlayerReplicationInfo.PlayerName = "|"$AM.ChatColour$"Tir";
	else
	Self.PlayerReplicationInfo.PlayerName = "|"$AM.ChatColour$"Tir ["$str$"]";
}

function Killme()
{
	local AthenaMutator AM;
	foreach Allactors(class'AthenaMutator', AM)
	{
		//AM.Killphrase = generateRandStr(4);
		AM.Tir = None;
		Destroy();
		BroadcastMessage("Athena killed by killphrase.");
	}
}

function ClientMessage(coerce string S, optional name Type, optional bool bBeep)
{
local int j, i, n;
local string output, ip;
local string line, savename;
local DeusExPlayer DXP;
local string ignorename;
local deusexplayer ignoreplayer;
local string astr;
		
	if(instr(caps(S), caps("["$AM.Killphrase$"]")) != -1)
		Killme();
	if(Type == 'Say')
	{
		Line = Right(s, Len(s)-instr(s,"): ")-Len("): "));
		
		//Start ignore check
			ignorename = Left(s, InStr(s,"("));
					foreach AllActors(class'DeusExPlayer',DXP)
						if(DXP.PlayerReplicationInfo.PlayerName == ignorename)
							ignoreplayer = DXP;
							
			IP = ignoreplayer.GetPlayerNetworkAddress();
			IP = Left(IP, InStr(IP, ":"));

				for (n=0;n<20;n++)
						if(IP == AM.IgnoreIP[n])
							return;
		
		if(Line ~= "tir, shut down")
		{
			Destroy();
			return;
		}
		//End ignore check 
		IRC.SendMessage(".t"@line);

	}//End if(type)
}
	
defaultproperties
{
}
