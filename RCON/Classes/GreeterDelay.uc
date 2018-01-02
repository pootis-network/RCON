class GreeterDelay extends RCONActors;

var string Greets, Warnings;
var bool bWarning, bDone;
var DeusExPlayer LockOnHim;
var bool bKickem, bKickemFinal;
var string MarkStr;
var AthenaSpectator AS;
var bool SoloPlayerMsg;

function BeginPlay()
{
local AthenaSpectator Aspec;
	foreach AllActors(class'AthenaSpectator',Aspec)
	{
		if(Aspec!=None)
			AS = Aspec;
	}
	
	SetTimer(3,False);
	
}

function Timer()
{
local int n;
	if(Greets!="")
	{
		if(AS != None)
		{
			AS.ASay(Greets);
				if(warnings == "marked")
				{
					Greets="";
					SetTimer(3,False);
				}
		}
		else
		{
			BroadcastMessage("|P4"$Greets);
				if(warnings == "marked")
				{
					Greets="";
					SetTimer(3,False);
				}
		}
	}
		if(warnings == "marked")
		{
			if(AS != None)
			{
				n=Rand(4);
				if(n==0)
					MarkStr = "Oh, look who it is, "$LockOnHim.PlayerReplicationInfo.PlayerName$" the trouble maker.";
				if(n==1)
					MarkStr = "This guys a pain in the ass.";
				if(n==2)
					MarkStr = "Watch out, this guy is known to cause trouble.";
				if(n==3)
					MarkStr = LockOnHim.PlayerReplicationInfo.PlayerName$" is a known trouble maker, watch out.";
			AS.ASay(MarkStr);
			}
			else
			{
			MarkStr = "This player is a known trouble maker.";
			BroadcastMessage(MarkStr);
			}
			destroy();
		}
}

defaultproperties
{
bHidden=True
}
