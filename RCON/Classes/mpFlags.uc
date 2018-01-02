// *Multiplayer Flags info
//  *By Kaiz0r
// 	 *RCON v10
//============================
class mpFlags extends RCONActors;

/* TO DO
 * Add flags for allowing to RCON Summon/Cheat override, disabling for restricted players
 */
 
//Core variables
var PlayerPawn Flagger;
var AthenaMutator AM;
var string LinkedAccount;
var string iName;

//Players Flags
var string Nickname, Killphrase;
var bool bMuteAthena, bRestricted, bAdmin;

//Temp vars
var bool bRan;

function PostBeginPlay()
{
	local AthenaMutator Mutz;
	
	foreach AllActors(class'AthenaMutator', Mutz)
		if(Mutz != None)
		{
			AM = Mutz;
			Log("Flags actor has been connected to Athena.",'Flags');
		}
		else
		{
			Log("ERROR - Athena was not found.",'Flags');
		}
		
	SetTimer(1,true);
}

function Timer()
{
	local LoginInfo li;
	
	foreach AllActors(class'LoginInfo',li)
	{
		if((flagger != None) && (li.Flagger == Flagger))
		{
			LinkedAccount = li.LinkedAccount;
			bRestricted=li.bRestrict;
		}
	}
	
	iName = getName(Flagger);
	
	if(!bRan && Flagger != None)
	{
		bAdmin = Flagger.bAdmin;
		Log("Flags actor created for"@GetName(Flagger),'Flags');
		bRan=True;
	}

	if(Flagger == None || iName == "")
	{	
		if(AM.bConnectionVoice)
		{
			AM.AS.AVoice(sound'Athena.AthenaPlayerLeft');
		}
		Log("Player no longer exists.",'Flags');
		Destroy();
	}	
	
	//Hook for Athenas Admin Notify
	if(Flagger != None && bAdmin != Flagger.bAdmin) //Check to see if state is the same. If it isn't, do something.
	{
		AM.AdminNotify(Flagger, Flagger.bAdmin); //If sends True, player has logged in, if sends False, player has logged out
		bAdmin = Flagger.bAdmin;
		Log("Called AdminNotify("$GetName(Flagger)$","$Flagger.bAdmin$")");
	}
	
	if(bRestricted && Flagger != None)
	{
		if(Flagger.bAdmin)
		{
			Flagger.bAdmin = false;
			Flagger.PlayerReplicationInfo.bAdmin = False;
			BroadcastMessage("|P2A restricted player was logged out from administrator access..");
		}
	}
}

//Deprecated functions
function bool CheckFlag(string input)
{
	/*local string killflag;
	
	if(instr(caps(Flags), caps("@kill#")) != -1)
	{
		killflag = Right(Flags, Len(Flags)-instr(Flags,"@kill#"));
		killflag = Left(killflag, InStr(killflag,"#kill"));
		if(instr(caps(input), caps(killflag)) != -1)
		return true;
	}
	
	if(instr(caps(Flags), caps(input)) != -1)
			return True;*/
}

function AddFlag(string AddFlag)
{
	//Flags = Flags@AddFlag;
	//Log("Adding:"@AddFlag$" (New: "$Flags, 'Flags');
}

function string RemoveFlag(string RemFlag)
{
/*local string TempMessage, TempLeft, TempRight, OutMessage, _TmpString;
	OutMessage=Flags;
	Log("Input:"@Flags, 'Flags');
    while (instr(caps(outmessage), RemFlag) != -1)
    {
        tempRight=(right(OutMessage, (len(OutMessage)-instr(caps(OutMessage), RemFlag))-Len(Remflag)));
        tempLeft=(left(OutMessage, instr(caps(OutMessage), RemFlag)) );
        OutMessage=TempLeft$TempRight;
        Log("Output:"@OutMessage, 'Flags');
    }
	return OutMessage;*/
}
function string GetName(PlayerPawn P)
{
	if(P != None)
		return P.PlayerReplicationInfo.PlayerName;
	else return "[No player found]";
}

defaultproperties
{
	bHidden=True
}
