class DelayCMD extends RCONActors;

var string TCMD, ExtraCMD;
var int CDown;

function BeginPlay()
{
	SetTimer(1,True);
}

function Timer()
{
local string cInterp;

	CDown--;

		if(CDown == 10 || CDown == 20 || CDown == 30 || CDown == 40 || CDown == 50 || CDown == 60)
		{
			BroadcastMessage(caps(TCMD)@ExtraCMD$" in "$CDown$" seconds.");
		}
		if(CDown <= 5 && CDown >= 1)
		{
			BroadcastMessage(CDown$" until "$caps(TCMD)@ExtraCMD);
		}
		
		if(CDown == 0)
		{
			if(TCMD ~= "server close")
			{
				ConsoleCommand("quit");
				Destroy();
			}
			
			if(TCMD ~= "restart")
			{
				ConsoleCommand("Servertravel "$Left(string(Level), InStr(string(Level), ".")));
				Destroy();
			}
			
			if(TCMD ~= "travel")
			{
				ConsoleCommand("Servertravel "$ExtraCMD);
				Destroy();
			}	
		}
}

defaultproperties
{
bHidden=True
}
