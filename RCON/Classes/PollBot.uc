//=============================================================================
// Spectator.
//=============================================================================
class PollBot extends MessagingSpectator;

var int Yes, No;
var string Poll;
var bool bBoolPoll;

function ASay(string str)
{
local DeusExPlayer DXP;

	BroadcastMessage("|P1 ~ PollBot:"@str);
	
	foreach AllActors(class'DeusExPlayer',DXP)
	{
		DXP.PlaySound(sound'DatalinkStart', SLOT_None,,, 256);
	}
}
function AStatus(string str)
{
	if(str == "")
	Self.PlayerReplicationInfo.PlayerName = "|P1PollBot";
	else
	Self.PlayerReplicationInfo.PlayerName = "|P1PollBot ["$str$"]";
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
local string sender;

	if(Type == 'Say')
	{
		Line = Right(s, Len(s)-instr(s,"): ")-Len("): "));
		Sender = Left(s, InStr(s,"("));

		if(Line ~= "pollbot, shut down")
		{
			Destroy();
			return;
		}
		
		if(bBoolPoll)
		{
			if(instr(caps(line), caps("yes")) != -1)
			{
				Yes++;
				ASay(Sender@"voted yes!");
			}
			if(instr(caps(line), caps("no")) != -1)
			{
				No++;
				ASay(Sender@"voted no!");
			}
		}
	}//End if(type)
}
	
function Timer()
{
	if(bBoolPoll)
	{
		ASay("Results for"@Poll);
		ASay("Yes:"@Yes);
		ASay("No:"@No);
		Destroy();
	}
}
defaultproperties
{
}