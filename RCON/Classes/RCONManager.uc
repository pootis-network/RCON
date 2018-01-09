//=============================================================================
// RCONManager
//=============================================================================
class RCONManager expands RCONActors
config(RCON);

var(RCON) config bool bRCONMutator;
var(RCON) config bool bNameguard;
var(RCON) config bool bNPTProxy;
var(RCON) config bool bAutomaticTeamSorting;
var(RCON) config bool bLoadouts;
var(RCON) config bool bReplacer;
var(RCON) config bool bForceNPTUscriptAPI;
var(RCON) config bool bIRC;
var(RCON) config bool bStats;
var(RCON) config bool bMessager;
var(RCON) config bool bAthena;
var(RCON) config bool bAccounts;
var(RCON) config bool bForceGametype;
var(RCON) config string ForceGametype;
var(RCON) config bool bFixDecoPushsounds;
var(RCON) config bool bForceNetUpdateFrequencies;
var(RCON) config int ForcedNetUpdateFrequency;
var(RCON) config bool bSMDEBUG;
var(RCON) config bool bRPG;

var(RCON) config bool bHasUpdate;
var string netversion;
var string GSCData;
var float TimeUntilUpdate;
const version = "180109";

function CodeBase _CodeBase()
{
	return Spawn(class'CodeBase');
}

function UpdateCheck()
{
	local GenericSiteQuery GSC;
	
	GSC = Spawn(class'GenericSiteQuery');
	GSC.browse("deusex.ucoz.net", "/deusex.txt", 80, 5);
	GSC.CallbackActor = Self;
	GSC.bDestroyAfterQuery=True;
}

function PostBeginPlay()
{			
	local RCON R;
	local ServerController SC;
	local RCONProxy RP;
	local NephthysDrv np;
	local RCONAutoTeam Au;
	local Loadouts AC;
	local RCONReplacer rep;
	local IRCLink IRC;
	local RCONStats Stat;
	local RCONGreeter Greet;
	local rMessager rmsgr;
	local Accounts acc;
	local bool bNPTOK;
	local AthenaMutator Ath;
	local Actor A;
	local bool bMutatorFound, bMutatorFound2, bMutatorFound3, bMutatorFound4, bMutatorFound5, bMutatorFound6, bMutatorFound7, bMutatorFound8, bMutatorFound9, bMutatorFound10, bMutatorFound11, bMutatorFound12;

	TimeUntilUpdate = RandRange(60,120);
		if (Level.NetMode != NM_Standalone && Role == ROLE_Authority)
		{
			Log("",'RCON');
			Log("RCON Manager spawned has initiated successfully.",'RCON');
			Log("RCON Version 10. By Kai 'TheClown'. ",'RCON');
			Log("WEB: http://www.deusex.ucoz.net",'RCON');
			Log("Join the discord: google for DXMP Discord",'RCON');
			Log("Running update check...");
			UpdateCheck();
			Log("-LIST MUTATOR ACTIONS-",'RCON');
			
			//Spawn(class'mpFlags');
			if(bRPG)
				Level.Game.BaseMutator.AddMutator(Spawn(class'RPGHandler'));
				
			if(bSMDEBUG)
				Level.Game.BaseMutator.AddMutator(Spawn(class'SM'));
				
			if(bForceNPTUscriptAPI)
			{
			ConsoleCommand("Set NephthysDrv bUscriptAPI True");
			Log("RCON/NPT bridged.",'RCON');
			bNPTOK=True;
			}
			if(bRCONMutator)
			{
				foreach allactors (class'RCON', R)
					if (R != None)
						bMutatorFound = True;
				if (!bMutatorFound)	
					Log("RCON Command Mutator enabled.",'RCON');
					Level.Game.BaseMutator.AddMutator(Spawn(class'RCON'));
			}
			if(bNameguard)
			{
				foreach allactors (class'ServerController', SC)
					if (SC != None)
						bMutatorFound2 = True;
				if (!bMutatorFound2)	
					Log("Nameguard enabled.",'RCON');
					Level.Game.BaseMutator.AddMutator(Spawn(class'ServerController'));
			}
			if(bNPTProxy)
			{
				foreach allactors (class'RCONProxy', RP)
					if (RP != None)
						bMutatorFound3 = True;
				if (!bMutatorFound3)	
					Log("RCON NPT Proxy spawned.",'RCON');
					Spawn(class'RCONProxy');
					if(bNPTOK)
					{
						Log("NPT internal check: OK",'RCON');
					}
					else
					{
						Log("NPT internal check: WARNING",'RCON');
						Log("RCON is not handling the bridge. If you have set bUscriptAPI=True in Nephthys, disregard this warning.",'RCON');
					}
			}
			
			if(bAutomaticTeamSorting)
			{
				foreach allactors (class'RCONAutoTeam', AU)
					if (RP != None)
						bMutatorFound4 = True;
				if (!bMutatorFound4)	
					Log("Team Balance enabled",'RCON');
					Level.Game.BaseMutator.AddMutator(Spawn(class'RCONAutoTeam'));
			}
						
			if(bLoadouts)
			{
				foreach allactors (class'Loadouts', Ac)
					if (RP != None)
						bMutatorFound5 = True;
				if (!bMutatorFound5)	
					Log("Loadouts enabled",'RCON');
					Level.Game.BaseMutator.AddMutator(Spawn(class'Loadouts'));
			}
			
			if(bReplacer)
			{
				foreach allactors (class'RCONReplacer', ReP)
					if (ReP != None)
						bMutatorFound6 = True;
				if (!bMutatorFound6)	
					Log("RCON Replacer enabled.",'RCON');
					Spawn(class'RCONReplacer');
			}
			
			if(bIRC)
			{
				foreach allactors (class'IRCLink', IRC)
					if (IRC != None)
						bMutatorFound7 = True;
				if (!bMutatorFound7)			
					Log("IRC Link spawned.",'RCON');
					spawn(class'IRCLink');
			}
			if(bStats)
			{
				foreach allactors (class'RCONStats', stat)
					if (stat != None)
						bMutatorFound8 = True;
				if (!bMutatorFound8)	
					Log("RCON Stat Tracking enabled.",'RCON');
					Level.Game.BaseMutator.AddMutator(Spawn(class'RCONStats'));
			}
			if(bMessager)
			{
				foreach allactors (class'rMessager', rmsgr)
					if (rmsgr != None)
						bMutatorFound10 = True;
				if (!bMutatorFound10)	
					Log("Messager by ChaosIncarnate enabled.",'RCON');
					Spawn(class'rMessager');
			}
			if(bAthena)
			{
				foreach allactors (class'AthenaMutator', Ath)
					if (Ath != None)
						bMutatorFound11 = True;
				if (!bMutatorFound11)	
					Log("Athena Controller enabled.",'RCON');
					Level.Game.BaseMutator.AddMutator(Spawn(class'AthenaMutator'));
			}
			if(bAccounts)
			{
				foreach allactors (class'Accounts', acc)
					if (acc != None)
						bMutatorFound12 = True;
				if (!bMutatorFound12)	
					Log("Accounts Manager enabled.",'RCON');
					Level.Game.BaseMutator.AddMutator(Spawn(class'Accounts'));
			}
			Log("RCONManager has ended. RCON Core is now running with selected features.",'RCON');
				foreach AllActors(class'Actor', A)
				{
					 if(string(a.class) ~= "FLK3Fix.FLK3MutFix" || string(a.class) ~= "Battleground.TCControls") 
					 {
						a.bHidden=True;
					 }
				}
			if(bForceGametype)
				SetTimer(3,false);
			Log("",'RCON');
		}
}

function Timer()
{
    local string currentMap;
    local class<GameInfo> currentGameClass,newGameClass;

    currentGameClass=level.game.class;
    currentMap = left(string(level),instr(string(level),"."));
	if(string(currentGameClass) != ForceGametype)
	{
        log("Loading "$forcegametype$"...",'RCON');
        ConsoleCommand("servertravel"@currentMap$"?Game="$forcegametype);
	}
}

function Tick(float deltatime)
{
local DeusExDecoration DXD;
local string datastring, DataStore, corever;
	
	if(TimeUntilUpdate > 0)
		TimeUntilUpdate-=1;
		
	if(GSCData != "" && TimeUntilUpdate <= 0)
	{
		DataStore = GSCData;
		GSCData = "";
		Log("Data from Update Client found.... filtering version string.", 'RCON');
		datastring = _CodeBase().Split(DataStore, "<rcon>", "</rcon>");
		Log("Returned net version: "$datastring$" - Current version: "$version, 'RCON');
		BroadcastMessage(_CodeBase().Split(DataStore, "<motd>", "</motd>"));

		if(datastring != version)
		{
			bHasUpdate=True;
			SaveConfig();
			Log("Version mismatch.. update available? Check for updates at https://github.com/Kaiz0r/RCON", 'RCON');
			BroadcastMessage("RCON has an update available!");
		}
		else
		{
			bHasUpdate=False;
			SaveConfig();
			Log("RCON is up-to-date.", 'RCON');
		}
	}
	
	
	if(bFixDecoPushsounds)
		Foreach AllActors(class'DeusExDecoration', DXD)	
			if(DXD.PushSound != None)
				DXD.PushSound = None;
	
	if(bForceNetUpdateFrequencies)
		Foreach AllActors(class'DeusExDecoration', DXD)
			if(DXD.NetUpdateFrequency != ForcedNetUpdateFrequency)
				DXD.NetUpdateFrequency = ForcedNetUpdateFrequency;
}

defaultproperties
{
bHidden=True
}
