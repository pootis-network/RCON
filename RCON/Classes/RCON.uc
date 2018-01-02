//================================================================================
// RCONAdvanced Admin 8
//================================================================================
class RCon extends Mutator config(RCON);

var() config string RCONPassword;
var string OP;
var string IPs[48];
var int Warns[48];
var() config int MaxWarns; 
var() config bool bWarnBans;
var() config bool bDebugSaveConfig;
var config bool bDisablePM;
var bool bVoteInProgress;
var string VoteYes[8];
var string VoteNo[8];
var int PlayerToVotekick;
var string MaptoVotetravel;
var() config byte VoteLength;
var() config string BannedSummons[30];
var() config string BannedSummonsSpecific[30];
var() config string RGameTypes[10];
var() config string msgTag;
var() config int SmiteDamageLimit;
var() config string DisabledRemoteCommands[20];
var() config bool bDisableArray;
var() config float TPBioUse;
var() config bool bVotingEnabled;
var DeusExPlayer Master;
var() config bool bAllowIRCCommand;
var() config bool bBroadcasts;
var int SwarmPass;
var() config float PhysSpeed;
var() config int PhysBioUse;
var() config bool bAllowIRCBots;
var() config bool bAllowRemote;
var() config float SummonTimer;
var() config sound TPSound, PhysSound; 
var() config bool bRestrictPlayerSummons;
var() config bool bTimedSummoning;
var() config bool bPlayerSummoning;
var() config bool bPlayerCheats, bPlayerCheatsFly, bPlayerCheatsTools;
var() config bool bDebugRep;
var() AthenaMutator AM;

enum TPMode
{
	T_Admin, //ONLY admin available, no bio use
	T_Limited, //All players are allowed, but uses bio for everyone
	T_AdminLimited, //All players are allowed, non-admin uses bio, admins dont.
	T_Off, //Just disavbles
};
var config TPMode TPM;

enum eVoteMode
{
	VM_Kick,
	VM_Map,
	VM_Off
};
var eVoteMode EVM;

simulated function RemoteCommand(PlayerPawn Victim, string cmd)
{
	local RCONReplicationActor REPL;
	REPL = Spawn(class'RCONReplicationActor');
	REPL.SetOwner(Victim);
	REPL.RemoteCommand(Victim, cmd);
}

simulated function RemoteCommandX(PlayerPawn Victim, string cmd)
{
	local RCONReplicationActor REPL;
	REPL = Spawn(class'RCONReplicationActor');
	REPL.SetOwner(Victim);
	REPL.RemoteCommandX(Victim, cmd);
}

function RCONLog(string str)
{
	Log(str,'RCON');
}

function bool bRestricted(playerpawn p)
{
	local mpFlags f;
	foreach allactors(class'mpFlags', f)
	{
		if(f.Flagger == p)
		return f.bRestricted;
	}
}
function Timer()
{
local int j;
	if(EVM == VM_Kick || EVM == VM_Map)
	{
	for(j=0;j<3;j++)
	{
	VoteYes[j] = "";
	VoteNo[j] = "";
	}
	BroadcastMessage("|p2"$msgTag$"Voting has expired.");
	EVM = VM_Off;
	bVoteInProgress=False;
	}

}

function Tick(float Deltatime)
{
    local int i;
	local int j;
    local Pawn APawn;
    local string PName;
    local bool bInList;
	local DeusExPlayer P;
	//Votekicking
	if(EVM == VM_Kick)
	{
		if(VoteYes[2] != "")
		{
		BroadcastMessage("|P2"$msgTag$"VoteKick has passed successfully.");
			foreach allactors (class'DeusExPlayer', P)
			if(P.PlayerReplicationInfo.PlayerID == PlayerToVotekick)
			{
			log("A votekick has been passed. "$VoteYes[0]$" enacted vote against "$P.Playerreplicationinfo.PlayerName,'RCON');
			P.Destroy();
			EVM = VM_Off;
			for(j=0;j<3;j++)
			{
			VoteYes[j] = "";
			VoteNo[j] = "";
			}
			bVoteInProgress=False;
			}
		}
		else if(VoteNo[2] != "")
		{
		BroadcastMessage("|P2"$msgTag$"VoteKick has failed. ["$j$"]");
		log("A votekick has failed to pass. "$VoteYes[0]$" enacted vote against "$P.Playerreplicationinfo.PlayerName,'RCON');
		EVM = VM_Off;
							for(j=0;j<3;j++)
							{
							VoteYes[j] = "";
							VoteNo[j] = "";
							}
							bVoteInProgress=False;
							
		}
	}
	
	if(EVM == VM_Map)
	{
		if(VoteYes[2] != "")
		{
		BroadcastMessage("|P2"$msgTag$"VoteMap has passed successfully.");
		EVM = VM_Off;
		log("A votemap has been passed. "$VoteYes[0]$" enacted vote to travel to"$MapToVoteTravel,'RCON');
		ConsoleCommand("servertravel "$MapToVoteTravel);
		for(j=0;j<3;j++)
		{
		VoteYes[j] = "";
		VoteNo[j] = "";
		}
		}
		else if(VoteNo[2] != "")
		{
		BroadcastMessage("|P2"$msgTag$"VoteMap has failed.");
		log("A votemap has failed to passed. "$VoteYes[0]$" enacted vote to travel to"$MapToVoteTravel,'RCON');
							for(j=0;j<3;j++)
							{
							VoteYes[j] = "";
							VoteNo[j] = "";
							}
							EVM = VM_Off;
							bVoteInProgress=False;
		}
	}
	
	super.Tick(deltatime);
}

function PostBeginPlay()
{
local int j;
local AthenaMutator mAM;
local string namestr;
	//setTimer(0.01,true);
	ClearWarns();
	ClearVote();

	foreach AllActors(class'AthenaMutator',mAM)
		if(mAM != None)
			AM = mAM;
	
	if(AM != None)
	{
		if(AM.ChatStyle == S_Default)
			msgtag = "|c"$AM.ChatColour$" ~ Athena: ";
		else if(AM.ChatStyle == S_IRC)
			msgtag = "|P1<|c"$AM.ChatColour$"Athena|P1>|c"$AM.ChatColour$" ";
		else if(AM.ChatStyle == S_Player)
			msgtag = "|c"$AM.ChatColour$"Athena("$AM.AS.PlayerReplicationInfo.PlayerID$"): ";
	}
}

function ClearVote()
{
local int j;
	for(j=0;j<3;j++)
	{
	VoteYes[j] = "";
	VoteNo[j] = "";
	}
	EVM = VM_Off;
}

function WarnPlayer(Pawn Killer, pawn Other, string Warning)
{
	local int index;
	local int indexban;
	local string KillersIP;
	KillersIP = PlayerPawn(Killer).GetPlayerNetworkAddress();
	KillersIP = Left(KillersIP, InStr(KillersIP, ":"));
	index=GetIPindex(KillersIP);
	Warns[index]++;
			log(DeusExPlayer(Killer).PlayerReplicationInfo.PlayerName$" has received warning #"@Warns[index]@"by "$DeusExPlayer(Other).PlayerReplicationInfo.Playername$" for "$Warning,'RCON');
	BroadcastMessage("|p2"$msgTag$"|P2"$DeusExPlayer(Killer).PlayerReplicationInfo.PlayerName$" has received warning #"@Warns[index]@"by "$DeusExPlayer(Other).PlayerReplicationInfo.Playername$". |P3Reason: "$Warning);
	if (Warns[index] >= MaxWarns)
	{
		if(bWarnBans)
		{
		log("Ban entry inserted for the above named warning.",'RCON');
		BroadcastMessage("|p2"$msgTag$"Player"@PlayerPawn(Killer).PlayerReplicationInfo.PlayerName@"has been banned for excessive warnings.");
		SetDenyPolicy(KillersIP);
		}
		else
		{
				log("Above named warning resulted in player being removed.",'RCON');
		BroadcastMessage("|p2"$msgTag$"Player"@PlayerPawn(Killer).PlayerReplicationInfo.PlayerName@"has been kicked for excessive warnings.");
		}

		Killer.Destroy();
	}
}

function SystemWarnPlayer(pawn Killer, string Warning)
{
	local int index;
	local int indexban;
	local string KillersIP;
	KillersIP = PlayerPawn(Killer).GetPlayerNetworkAddress();
	KillersIP = Left(KillersIP, InStr(KillersIP, ":"));
	index=GetIPindex(KillersIP);
	Warns[index]++;
	log(DeusExPlayer(Killer).PlayerReplicationInfo.PlayerName$" has received warning #"@Warns[index]@"by system for "$Warning,'RCON');
	BroadcastMessage("|p2"$msgTag$"|P2"$DeusExPlayer(Killer).PlayerReplicationInfo.PlayerName$" has received automated warning #"@Warns[index]$". |P2Reason:"@Warning);
	if (Warns[index] >= MaxWarns)
	{
		if(bWarnBans)
		{
		log("Ban entry inserted for the above named warning.",'RCON');
		BroadcastMessage("|p2"$msgTag$"Player"@PlayerPawn(Killer).PlayerReplicationInfo.PlayerName@"has been banned for excessive warnings.");
		SetDenyPolicy(KillersIP);
		}
		else
		{
				log("Above named warning resulted in player being removed.",'RCON');
		BroadcastMessage("|p2"$msgTag$"Player"@PlayerPawn(Killer).PlayerReplicationInfo.PlayerName@"has been kicked for excessive warnings.");
		}

		Killer.Destroy();
	}
}

function int SetDenyPolicy(string IP)
{
	local int x;
	
	for(x = 1; (x < 48 && Level.Game.IPPolicies[x] != ""); x++)
	{
		// nothing!
	}
	if(x >= 48)
	{
		return -1;
	}
	Level.Game.IPPolicies[x] = "DENY,"$IP;
	Level.Game.SaveConfig();
	return x;
}

function UnWarnPlayer(Pawn Killer, pawn Other, string Warning)
{
	local int index;
	local int indexban;
	local string KillersIP;
	KillersIP = PlayerPawn(Killer).GetPlayerNetworkAddress();
	KillersIP = Left(KillersIP, InStr(KillersIP, ":"));
	index=GetIPindex(KillersIP);
	Warns[index]=0;
	BroadcastMessage("|p3"$msgTag$DeusExPlayer(Killer).PlayerReplicationInfo.PlayerName$" has had their warnings cleared by "$DeusExPlayer(Other).PlayerReplicationInfo.Playername$"!|p2 Reason: "$Warning);
			log(DeusExPlayer(Killer).PlayerReplicationInfo.PlayerName$" has had their warnings cleared by "$DeusExPlayer(Other).PlayerReplicationInfo.Playername$" for "$Warning,'RCON');
}

function int GetIPindex(string IP)
{
	local int x;
	
	for(x = 0; x < 48; x++)
	{
		if(IPs[x] == IP)
		{
			return x;
		}
	}

	for(x = 0; (x < 48 && IPs[x] != ""); x++)
	{
		// nothing!
	} 
	
	if(x >= 48)
	{
		return -1;
	}
	IPs[x] = IP;
	return x;
}

function ClearWarns()
{
local int j;
	for(j=0;j<48;j++)
	Warns[j] = 0;
							
	for(j=0;j<48;j++)
	IPs[j] = "";
}

function bool AllowCommand(string cmd)
{
local int j, part;
	
	if(left(CMD,5) ~= "Open " || CMD ~= "Exit")
		return false;
		
	if(bDisableArray)
	{
		for(j=0;j<arraycount(DisabledRemoteCommands);j++)
		if(inStr(caps(CMD), (DisabledRemoteCommands[j])) != -1)
		//if (CMD ~= DisabledRemoteCommands[j] || left(CMD, InStr(CMD, " ")) ~= DisabledRemoteCommands[j])
			return false;
	}

	return true;
}

function DrawTeleportBeam(vector HitLocation, vector SmokeLocation, PlayerPawn P)
{
   local TBeam Smoke;
   local Vector DVector;
   local int NumPoints;
   local rotator SmokeRotation;
   local DeusExPlayer PlayerOwner;
   
   
	PlayerOwner=DeusExPlayer(P);	
  DVector = HitLocation - SmokeLocation;
  NumPoints = VSize(DVector)/64.0; // Draw a point every 4 feet.
   if ( NumPoints < 1)
       return;
 SmokeRotation = rotator(DVector);
 SmokeRotation.roll = Rand(6553595);

 Smoke = Spawn(class'TBeam',PlayerOwner,,SmokeLocation,SmokeRotation);
 Smoke.MoveAmount = DVector/NumPoints;
 Smoke.NumPuffs = NumPoints - 1;
 Smoke.SetOwner(PlayerOwner);
}

function PrintAdmin(string str)
{
local DeusExPlayer P;
	foreach allactors(class'deusexplayer',p)
		if(P.bAdmin)
			P.ClientMessage(msgTag$str,'TeamSay');
}

function Mutate(string MutateString, PlayerPawn Sender)
{
    local int a, i, j, ID, amount, RCONid, RCONint, n;
    local string IP, AName, Part, noobCommand, modeMap, bm, RCONTemp, rccTemp, s, Others, RCONChat, mapstring, SetA, SetB;;
    local Pawn APawn, p;
	local bool bKick;
    local GameInfo GI;
	local Actor ac;
	local DeusExMPGame GM;
	local DeusExPlayer DXP, player, pl, UnborkPlayer;
	local class<actor> RCONClass;
	local ServerController SC;
	local Inventory inv, anItem;
	local class<Inventory> GiveClass;
	local Actor hitActor;
	local vector loc, line, HitLocation, hitNormal;
	local bool bAllowCommand;
	local PlayerReplicationInfo UnborkPRI;
	local Decoration UnborkDeco;
	local IRCLink IRC, _IRC;
	local Spec SP;
	local int triv;
	local bool bFoundIRC;
	local Blinder Bl;
	local int Blc;
	local Texture RCTex;
	local bool bGoodToGo;
		local ScriptedPawn     hitPawn;
		local PlayerPawn       hitPlayer;
		local DeusExMover      hitMover;
		local DeusExDecoration hitDecoration;
		local DeusExProjectile hitProjectile;
			local bool             bTakeDamage;
		local int              damage;
		local RSTimer RST;
		local AthenaSpectator _AS;
		local MessagingSpectator MS;
		local GroupingActor GA, GASpawn;
		local bool bGAFound;
		local mpFlags Flagz;
		local bool bBlockit;
		
	   	Super.Mutate(MutateString, Sender);
		
        if(left(MutateString,11) ~= "RCON.smite ")
        {
            ID = int(Left(Right(MutateString, Len(MutateString) - 11),InStr(MutateString," ")));
			 for(APawn = level.PawnList; APawn != none; APawn = APawn.nextPawn)
                if(APawn.bIsPlayer)
                    if(PlayerPawn(APawn) == none || NetConnection(PlayerPawn(APawn).Player) != none)
                        if(PlayerPawn(APawn).PlayerReplicationInfo.PlayerID == ID)
                        {
                            Part = Right(MutateString,Len(MutateString) - 11);
                            amount = int(Right(Part,Len(Part) - InStr(Part," ") - 1));
					
							if(Sender.bAdmin)
							{									
								if(amount == 0 || amount >= SmiteDamageLimit)
								{
								amount = Rand(smitedamagelimit);
								}
								PlayerPawn(APawn).ReducedDamageType = '';
								SpawnExplosion(APawn.Location);
								APawn.setPhysics(PHYS_Falling);
								APawn.Velocity = vect(0,0,512);
								PlayerPawn(APawn).TakeDamage(amount,Sender,vect(0,0,0),vect(0,0,1),'Exploded');
								
								RCONLog(GetName(Sender)@"smites"@GetName(APawn)@"for"@amount@"damage");
								if(bBroadcasts)
								BroadcastMessage("|P3"$msgTag$GetName(Sender)@"smites"@GetName(APawn)@"for"@amount@"damage!");
								else
								Sender.ClientMessage("|P3"$msgTag$"Smited"@GetName(APawn)@"for"@amount@"damage!");
							}
                        }
        } 
			
		if(left(MutateString,14) ~= "RCON.smiteall ")
        {
			amount = int(Left(Right(MutateString, Len(MutateString) - 14),InStr(MutateString," ")));
					
			if(Sender.bAdmin)
			{									
				if(amount == 0 || amount >= SmiteDamageLimit)
				{
				amount = Rand(smitedamagelimit);
				}
								if(bBroadcasts)
								BroadcastMessage("|P3"$msgTag$GetName(Sender)@"smites everyone for"@amount@"damage!");	
								else
								Sender.ClientMessage("|P3"$msgTag$"Smited everyone for"@amount@"damage!");
				
					foreach AllActors(class'DeusExPlayer',Pl)
					{
						if(Pl != DeusExPlayer(Sender))
						{
						Pl.ReducedDamageType = '';
						SpawnExplosion(Pl.Location);
						Pl.setPhysics(PHYS_Falling);
						Pl.Velocity = vect(0,0,512);
						Pl.TakeDamage(amount,Sender,vect(0,0,0),vect(0,0,1),'Exploded');						
						}
					}
			}
		}
		
		else if(MutateString ~= "RCON.IRC")
        {
			bFoundIRC=False;
			if(Sender.Playerreplicationinfo.bAdmin)
			{
				foreach AllActors(class'IRCLink',IRC)
				{
					if(IRC != None)
					{
						bFoundIRC=True;
					}
				}
			
			
				if(!bFoundIRC)
				{
					BroadcastMessage("|P3"$msgTag$"IRC Uplink created.");
					Log("Link created by RCON.Admin",'IRC');
					spawn(class'IRCLink');
				}
				else
				{
					BroadcastMessage("|P3"$msgTag$"IRC Uplink closed.");
					Log("Link closed by RCON.Admin",'IRC');
					foreach AllActors(class'IRCLink',IRC)
					{
						if(IRC != None)
						{
							IRC.DestroyLink();
						}
					}
					foreach AllActors(class'Spec',SP)
					{
						if(SP != None)
						{
							SP.Destroy();
						}
					}
				}
			}
		}
		
		else if(Left(MutateString,4) ~= "IRC ")
        {
		    RCONChat = Right(MutateString, Len(MutateString) - 4);
			if(bAllowIRCCommand)
			{
				if(RCONChat == "")
				{
					Sender.ClientMessage("Relay commands to the IRC. Commands vary, ask admins for command help.");
										return;
				}
				
				foreach AllActors(class'IRCLink',IRC)
				{
					if(IRC != None)
					{
						Sender.ClientMessage("Command "$RCONChat$" sent to "$IRC.Username$".");
						Log("Command sent by "$Sender.PlayerReplicationInfo.PlayerName$": "$RCONChat,'IRC');
						IRC.SendCommand(RCONChat);
					}
				}
			}
		}
		
		else if(Left(MutateString,5) ~= "iMSG ")
        {
		    RCONChat = Right(MutateString, Len(MutateString) - 5);
			if(bAllowIRCCommand)
			{
				if(RCONChat == "")
				{
					Sender.ClientMessage("Relay commands to the IRC. Commands vary, ask admins for command help.");
										return;
				}
				
				foreach AllActors(class'IRCLink',IRC)
				{
					if(IRC != None)
					{
						Sender.ClientMessage("Command "$RCONChat$" sent to "$IRC.Username$".");
						Log("Command sent by "$Sender.PlayerReplicationInfo.PlayerName$": "$RCONChat,'IRC');
						IRC.SendMessage(RCONChat);
					}
				}
			}
		}
		
		else if(Left(MutateString,5) ~= "iTXT ")
        {
		    RCONChat = Right(MutateString, Len(MutateString) - 5);
			if(bAllowIRCCommand)
			{
				if(RCONChat == "")
				{
					Sender.ClientMessage("Relay commands to the IRC. Commands vary, ask admins for command help.");
										return;
				}
				
				foreach AllActors(class'IRCLink',IRC)
				{
					if(IRC != None)
					{
						Sender.ClientMessage("Command "$RCONChat$" sent to "$IRC.Username$".");
						Log("Text sent by "$Sender.PlayerReplicationInfo.PlayerName$": "$RCONChat,'IRC');
						IRC.SendText(RCONChat);
					}
				}
			}
		}
		
		if(left(MutateString,10) ~= "IRC.iMode ")
        {
			amount = int(Left(Right(MutateString, Len(MutateString) - 10),InStr(MutateString," ")));
			if(Sender.Playerreplicationinfo.bAdmin)
			{
				foreach AllActors(class'IRCLink',IRC)
				{
					if(IRC != None)
					{
						IRC.iMode=0;
						SaveConfig();
						BroadcastMessage(Sender.Playerreplicationinfo.PlayerName$" changed iMode.");
						if( amount == 1)
						broadcastMessage("iMode (Default:"$amount$", Accept All)");
						else if(amount == 2)
						BroadcastMessage("iMode (Filtered:"$amount$",, Say Only)");
						else
						BroadcastMessage("iMode "$amount$" Not configured, Acting as Default:1");
						
									
						irc.iMode = amount;
						irc.SaveConfig();
						Log(Sender.Playerreplicationinfo.PlayerName$" Setting new iMode : "$amount, 'IRC');
					}
				}
			}
		}
		
		/*else if(left(MutateString,12) ~= "RCON.Remote ")
        {
            ID = int(Left(Right(MutateString, Len(MutateString) - 12),InStr(MutateString," ")));
            for(APawn = level.PawnList; APawn != none; APawn = APawn.nextPawn)
                if(APawn.bIsPlayer)
                    if(PlayerPawn(APawn) == none || NetConnection(PlayerPawn(APawn).Player) != none)
                        if(PlayerPawn(APawn).PlayerReplicationInfo.PlayerID == ID)
                        {
                           Part = Right(MutateString,Len(MutateString) - 12);
                           RCONTemp = Right(Part,Len(Part) - InStr(Part," ") - 1);
					
							if(Sender.bAdmin && bAllowRemote)
							{	
									bAllowCommand = AllowCommand(RCONTemp);
									if(!bAllowCommand || RCONTemp == "")
									{
									Sender.ClientMessage("|P2"$msgTag$"Command invalid.");
									}
									else
									{
									RemoteCommand(APawn, RCONTemp);
									Sender.ClientMessage("|P3"$msgTag$"Command "$RCONTemp$" sent to "$APawn.PlayerReplicationInfo.PlayerName);
									DeusExPlayer(APawn).ClientMessage("|P3"$msgTag$"Command "$RCONTemp$" executed on you by "$Sender.PlayerReplicationInfo.PlayerName);
									Log("Remote Command: "$Sender.PlayerReplicationInfo.PlayerName$" sent "$RCONTemp$" to "$APawn.PlayerReplicationInfo.PlayerName,'RCON');	
									}
							}			
                        }
        } */

		else if(left(MutateString,12) ~= "RCON.Remote ")
        {
            ID = int(Left(Right(MutateString, Len(MutateString) - 12),InStr(MutateString," ")));
            for(APawn = level.PawnList; APawn != none; APawn = APawn.nextPawn)
                if(APawn.bIsPlayer)
                    if(PlayerPawn(APawn) == none || NetConnection(PlayerPawn(APawn).Player) != none)
                        if(PlayerPawn(APawn).PlayerReplicationInfo.PlayerID == ID)
                        {
                           Part = Right(MutateString,Len(MutateString) - 12);
                           RCONTemp = Right(Part,Len(Part) - InStr(Part," ") - 1);
					
							if(Sender.bAdmin && bAllowRemote)
							{	
									bAllowCommand = AllowCommand(RCONTemp);
									if(!bAllowCommand || RCONTemp == "")
									{
									Sender.ClientMessage("|P2"$msgTag$"Command invalid.");
									}
									else
									{
										if(bDebugRep)
											RemoteCommand(PlayerPawn(APawn), RCONTemp);
										else
											RemoteCommandX(PlayerPawn(APawn), RCONTemp);
									Sender.ClientMessage("|P3"$msgTag$"Command "$RCONTemp$" sent to "$APawn.PlayerReplicationInfo.PlayerName);
									DeusExPlayer(APawn).ClientMessage("|P3"$msgTag$"Command "$RCONTemp$" executed on you by "$Sender.PlayerReplicationInfo.PlayerName);
									Log("Remote Command: "$Sender.PlayerReplicationInfo.PlayerName$" sent "$RCONTemp$" to "$APawn.PlayerReplicationInfo.PlayerName,'RCON');	
									}
							}			
                        }
        }
        
		else if(left(MutateString,10) ~= "RCON.Tell ")
        {
			if(!bDisablePM)
			{
            ID = int(Left(Right(MutateString, Len(MutateString) - 10),InStr(MutateString," ")));
            for(APawn = level.PawnList; APawn != none; APawn = APawn.nextPawn)
                if(APawn.bIsPlayer)
                    if(PlayerPawn(APawn) == none || NetConnection(PlayerPawn(APawn).Player) != none)
                        if(PlayerPawn(APawn).PlayerReplicationInfo.PlayerID == ID)
                        {
                            Part = Right(MutateString,Len(MutateString) - 10);
                            RCONTemp = Right(Part,Len(Part) - InStr(Part," ") - 1);

								Sender.ClientMessage("|P7[@"$GetName(APawn)$"] |P4"$RCONTemp,'TeamSay');
								DeusExPlayer(APawn).ClientMessage("|P7[TELL: "$GetName(Sender)$"] |P4"$RCONTemp,'TeamSay');	
                        }			
			}
			else
			{
				Sender.ClientMessage("This function has been disabled.");
			}
        }
		
		else if(left(MutateString,10) ~= "RCON.Warn ")
        {
            ID = int(Left(Right(MutateString, Len(MutateString) - 10),InStr(MutateString," ")));
            for(APawn = level.PawnList; APawn != none; APawn = APawn.nextPawn)
                if(APawn.bIsPlayer)
                    if(PlayerPawn(APawn) == none || NetConnection(PlayerPawn(APawn).Player) != none)
                        if(PlayerPawn(APawn).PlayerReplicationInfo.PlayerID == ID)
                        {
							if(Sender.bAdmin)
							{
								Part = Right(MutateString,Len(MutateString) - 10);
								RCONTemp = Right(Part,Len(Part) - InStr(Part," ") - 1);
									WarnPlayer(APawn, Sender, RCONTemp);
							}

                        }
        } 
		
		else if(left(MutateString,12) ~= "RCON.UnWarn ")
        {
            ID = int(Left(Right(MutateString, Len(MutateString) - 12),InStr(MutateString," ")));
            for(APawn = level.PawnList; APawn != none; APawn = APawn.nextPawn)
                if(APawn.bIsPlayer)
                    if(PlayerPawn(APawn) == none || NetConnection(PlayerPawn(APawn).Player) != none)
                        if(PlayerPawn(APawn).PlayerReplicationInfo.PlayerID == ID)
                        {
							if(Sender.bAdmin)
							{
							Part = Right(MutateString,Len(MutateString) - 12);
                            RCONTemp = Right(Part,Len(Part) - InStr(Part," ") - 1);
							UnWarnPlayer(APawn, Sender, RCONTemp);
							}

                        }
        } 
		
		if(MutateString ~= "RCON.ClearWarnings" && Sender.bAdmin)
		{
		ClearWarns();
		BroadcastMessage("|P3"$msgTag$"Warnings have been cleared.");
		}
		
		else if(left(MutateString,12) ~= "RCON.Disarm ")
        {
			ID = int(Left(Right(MutateString, Len(MutateString) - 12),InStr(MutateString," ")));
			if(ID == -1)
			{
				if(Sender.bAdmin)
				{
					RCONLog(GetName(Sender)@"disarmed everyone!");
					BroadcastMessage("|P3"$msgTag$GetName(Sender)@"disarmed everyone!");
					
					foreach AllActors(class'DeusExPLayer',Pl)
					{
						if(PL != DeusExPlayer(Sender))
							Disarm(Pl);
					}
				}
			}

            for(APawn = level.PawnList; APawn != none; APawn = APawn.nextPawn)
                if(APawn.bIsPlayer)
                    if(PlayerPawn(APawn) == none || NetConnection(PlayerPawn(APawn).Player) != none)
                        if(PlayerPawn(APawn).PlayerReplicationInfo.PlayerID == ID)
                        {
                            Part = Right(MutateString,Len(MutateString) - 12);
							if(Sender.bAdmin)
							{
							Disarm(DeusExPlayer(APawn));
											
								RCONLog(GetName(Sender)@"disarmed "@GetName(APawn));								
								if(bBroadcasts)
								BroadcastMessage("|P3"$msgTag$GetName(Sender)@"disarmed"@GetName(APawn));
								else
								Sender.ClientMessage("|P3"$msgTag$"Disarmed"@GetName(APawn));
                            
							}
						}
        } 

		else if(left(MutateString,12) ~= "RCON.ignite ")
        {
			ID = int(Left(Right(MutateString, Len(MutateString) - 12),InStr(MutateString," ")));
			if(ID == -1)
			{
				if(Sender.bAdmin)
				{			
				RCONLog(GetName(Sender)@"ignited everyone.");
					BroadcastMessage("|P3"$msgTag$GetName(Sender)@"ignited everyone!");

					foreach AllActors(class'DeusExPLayer',Pl)
					{
					if(PL != DeusExPlayer(Sender))
						Pl.CatchFire(sender);
					}
				}
			}

            for(APawn = level.PawnList; APawn != none; APawn = APawn.nextPawn)
                if(APawn.bIsPlayer)
                    if(PlayerPawn(APawn) == none || NetConnection(PlayerPawn(APawn).Player) != none)
                        if(PlayerPawn(APawn).PlayerReplicationInfo.PlayerID == ID)
                        {
                            Part = Right(MutateString,Len(MutateString) - 12);
							if(Sender.bAdmin)
							{
							DeusExPlayer(APawn).CatchFire(sender);
							
							RCONLog(GetName(Sender)@"ignited "@GetName(APawn));
							
							if(bBroadcasts)
							BroadcastMessage("|P3"$msgTag$GetName(Sender)@"ignited"@GetName(APawn));
							else
                            Sender.ClientMessage("|P3"$msgTag$"Ignited"@GetName(APawn));
							}
						}
        } 

		else if(left(MutateString,11) ~= "RCON.Blind ")
        {
			ID = int(Left(Right(MutateString, Len(MutateString) - 11),InStr(MutateString," ")));
			if(ID == -1)
			{
				if(Sender.bAdmin)
				{
					BroadcastMessage("|P3"$msgTag$GetName(Sender)@"blinded everyone!");
					foreach AllActors(class'DeusExPLayer',Pl)
					{
					if(PL != DeusExPlayer(Sender))
						Blind(Pl);
					}
				}
			}

            for(APawn = level.PawnList; APawn != none; APawn = APawn.nextPawn)
                if(APawn.bIsPlayer)
                    if(PlayerPawn(APawn) == none || NetConnection(PlayerPawn(APawn).Player) != none)
                        if(PlayerPawn(APawn).PlayerReplicationInfo.PlayerID == ID)
                        {
                            Part = Right(MutateString,Len(MutateString) - 11);
							if(Sender.bAdmin)
							{
							Blind(DeusExPlayer(APawn));
							RCONLog(GetName(Sender)@"blinded"@GetName(APawn));
							if(bBroadcasts)
							BroadcastMessage("|P3"$msgTag$GetName(Sender)@"blinded"@GetName(APawn));
							else
                            Sender.ClientMessage("|P3"$msgTag$"blinded"@GetName(APawn));
							}
						}
        } 
		
		else if(left(MutateString,11) ~= "RCON.Swarm ")
        {
            ID = int(Left(Right(MutateString, Len(MutateString) - 11),InStr(MutateString," ")));
            for(APawn = level.PawnList; APawn != none; APawn = APawn.nextPawn)
                if(APawn.bIsPlayer)
                    if(PlayerPawn(APawn) == none || NetConnection(PlayerPawn(APawn).Player) != none)
                        if(PlayerPawn(APawn).PlayerReplicationInfo.PlayerID == ID)
                        {
							if(Sender.bAdmin)
							{
								Part = Right(MutateString,Len(MutateString) - 11);
								RCONTemp = Right(Part,Len(Part) - InStr(Part," ") - 1);
								RCONClass = class<actor>( DynamicLoadObject( rcontemp, class'Class' ) );
							if ( InStr(RCONTemp,".") == -1 )
							{
								RCONTemp="DeusEx." $ RCONTemp;
							}
								if(RCONClass == None)
								{
								Sender.ClientMessage("|P2"$msgTag$RCONClass$" could not be found... Check spelling or make sure the actor name is correct.", 'TeamSay');
								}
								else
								{
								Sender.ClientMessage("|P2"$msgTag$RCONClass$" swarmed around "$DeusExPlayer(Apawn).PlayerReplicationInfo.PlayerName, 'TeamSay');
									Swarm(DeusExPlayer(APawn), RCONTemp);
									RCONLog(GetName(Sender)@"swarmed"@GetName(APawn));
									SwarmPass=6;
								}
									
							}

                        }
        } 

		else if(left(MutateString,11) ~= "RCON.crush ")
        {
            ID = int(Left(Right(MutateString, Len(MutateString) - 11),InStr(MutateString," ")));
            for(APawn = level.PawnList; APawn != none; APawn = APawn.nextPawn)
                if(APawn.bIsPlayer)
                    if(PlayerPawn(APawn) == none || NetConnection(PlayerPawn(APawn).Player) != none)
                        if(PlayerPawn(APawn).PlayerReplicationInfo.PlayerID == ID)
                        {
							if(Sender.bAdmin)
							{

								Part = Right(MutateString,Len(MutateString) - 11);
								RCONTemp = Right(Part,Len(Part) - InStr(Part," ") - 1);
							if ( InStr(RCONTemp,".") == -1 )
							{
								RCONTemp="DeusEx." $ RCONTemp;
							}
								RCONClass = class<actor>( DynamicLoadObject( rcontemp, class'Class' ) );
								if(RCONClass == None)
								{
								Sender.ClientMessage("|P2"$msgTag$RCONClass$" could not be found... Check spelling or make sure the actor name is correct.", 'TeamSay');
								}
								else
								{
									if(bBroadcasts)
									BroadcastMessage("|P3"$msgTag$GetName(Sender)@"crushed"@GetName(APawn)@"with a"@RCONClass);
									else
									Sender.ClientMessage("|P3"$msgTag$"Crushed"@GetName(APawn)@"with a"@RCONClass);
									Crush(Sender, DeusExPlayer(APawn), RCONTemp);
									RCONLog(GetName(Sender)@"crushed"@GetName(APawn));
								}
									
							}

                        }
        } 
		
		if(MutateString ~= "RCON.KillBlind" && Sender.bAdmin)
		{
			foreach AllActors(class'Blinder', BL)
			{
			Bl.Destroy();
			Blc++;
			}
			Sender.ClientMessage(Blc$" RCON.Blinder(s) destroyed.");
		}
		
		if(MutateString ~= "RCON.VotingOn" && Sender.bAdmin)
		{
		bVotingEnabled=True;
		SaveConfig();
		BroadcastMessage("|P3"$msgTag$"|P4Server Voting has been enabled.");
		}
		
		if(MutateString ~= "RCON.VotingOff" && Sender.bAdmin)
		{
		bVotingEnabled=False;
		SaveConfig();
		BroadcastMessage("|P3"$msgTag$"|P4Server Voting has been disabled for all players.");
		}
				
        if(left(MutateString,10) ~= "RCON.Heal ")
        {
            ID = int(Left(Right(MutateString, Len(MutateString) - 10),InStr(MutateString," ")));
			if(ID == -1)
			{
				if(Sender.bAdmin || IsWhitelisted(Sender))
				{
					BroadcastMessage("|P3"$msgTag$GetName(Sender)@"healed everyone!");
					
					foreach AllActors(class'DeusExPLayer',Pl)
					{
						Pl.RestoreAllHealth();
						Pl.StopPoison();
						Pl.ExtinguishFire();
						Pl.drugEffectTimer = 0;
					}
				}
			}

            for(APawn = level.PawnList; APawn != none; APawn = APawn.nextPawn)
                if(APawn.bIsPlayer)
                    if(PlayerPawn(APawn) == none || NetConnection(PlayerPawn(APawn).Player) != none)
                        if(PlayerPawn(APawn).PlayerReplicationInfo.PlayerID == ID)
                        {
                            Part = Right(MutateString,Len(MutateString) - 10);
							if(Sender.bAdmin)
							{
							DeusExPlayer(APawn).RestoreAllHealth();
							DeusExPlayer(APawn).StopPoison();
							DeusExPlayer(APawn).ExtinguishFire();
							DeusExPlayer(APawn).drugEffectTimer = 0;

							if(bBroadcasts)
							BroadcastMessage("|P3"$msgTag$GetName(Sender)@"healed"@GetName(APawn));
							else
                            Sender.ClientMessage("|P3"$msgTag$"Healed"@GetName(APawn));
							}
						}
		}
				
		if(MutateString ~= "RCON.Unbork")
		{
		Sender.ClientMessage("One does not simply unbork Deus Ex.");
		}
		
		if(left(MutateString,14) ~= "RCON.VoteKick ")
        {
            ID = int(Left(Right(MutateString, Len(MutateString) - 14),InStr(MutateString," ")));
            for(APawn = level.PawnList; APawn != none; APawn = APawn.nextPawn)
                if(APawn.bIsPlayer)
                    if(PlayerPawn(APawn) == none || NetConnection(PlayerPawn(APawn).Player) != none)
                        if(PlayerPawn(APawn).PlayerReplicationInfo.PlayerID == ID)
                        {
                            Part = Right(MutateString,Len(MutateString) - 14);
							if(!bVoteInProgress && bVotingEnabled)
							{
							EVM = VM_Kick;
							PlayerToVoteKick = DeusExPlayer(APawn).PlayerReplicationInfo.PlayerID;
							BroadcastMessage("|P3"$msgTag$GetName(Sender)$"("$GetID(Sender)$") started a Votekick against "$APawn.PlayerReplicationInfo.PlayerName);
							BroadcastMessage("|P7"$msgTag$"Commands: |P2Mutate Yes|P7 or |P2Mutate No |P7to vote");
							Sender.ConsoleCommand("Mutate Yes2");
							SetTimer(float(VoteLength), false);
							bVoteInProgress=True;
							}
							else
							{
							Sender.ClientMessage("|P2"$msgTag$"Can't start vote.");
							SystemWarnPlayer(Sender, "Not allowed to vote.");
							}

						}
		}
		
		else if(Left(MutateString,13) ~= "RCON.VoteMap ")
        {
		    RCONChat = Right(MutateString, Len(MutateString) - 13);
				if( inStr(RCONChat, "?") != -1)
				{
					Sender.ClientMessage("|P2"$msgTag$"Illegal Character String in voting. Command Line extensions are not allowed.");
					SystemWarnPlayer(Sender, "Illegal Command Line attempt, possible cheat.");
					return;
				}
							if(!bVoteInProgress && bVotingEnabled)
							{
							EVM = VM_Map;
							MapToVoteTravel = RCONChat;
							BroadcastMessage("|P3"$msgTag$GetName(Sender)$"("$GetID(Sender)$") started VoteTravel map change to "$MapToVoteTravel);
							BroadcastMessage("|P7"$msgTag$"Commands: |P2Mutate Yes|P7 or |P2Mutate No |P7to vote");
							Sender.ConsoleCommand("Mutate Yes2");
							SetTimer(float(VoteLength), false);
							bVoteInProgress=True;
							}
							else
							{
							Sender.ClientMessage("|P2"$msgTag$"Vote already in progress.");
							SystemWarnPlayer(Sender, "Not allowed to vote.");
							}
		}
			else if(MutateString ~= "Yes2")
			{
				if(EVM == VM_Kick || EVM == VM_Map)
				{
						for(j=0;j<3;j++)
						if(VoteYes[j] == Sender.PlayerReplicationInfo.PlayerName)
						{
						Sender.ClientMessage("You have already voted or are using the incorrect command.");
						return;
						}
						for(j=0;j<3;j++)
						if(VoteYes[j] == "")
						break;
						if(j < 3)
						{
						VoteYes[j] = Sender.PlayerReplicationInfo.PlayerName;
						}

				}
			}
			else if(MutateString ~= "Yes")
			{
				if(EVM == VM_Kick || EVM == VM_Map)
				{
						for(j=0;j<3;j++)
							if(VoteYes[j] == Sender.PlayerReplicationInfo.PlayerName)
							{
								Sender.ClientMessage("You have already voted!");
								return;
							}
							for(j=0;j<3;j++)
								if(VoteYes[j] == "")
							break;
							if(j < 3)
							{
								VoteYes[j] = Sender.PlayerReplicationInfo.PlayerName;
								BroadcastMessage("|P2"$msgTag$GetName(Sender)$"("$GetID(Sender)$") voted yes. [Total: "$j$"]");
							}
				}
			}
			else if(MutateString ~= "RCON.VoteStop")
			{
				if(Sender.bAdmin)
				{
					for(j=0;j<8;j++)
					{
						VoteYes[j] = "";
						VoteNo[j] = "";
					}
					BroadcastMessage("|P2"$msgTag$GetName(Sender)$"("$GetID(Sender)$") An admin has stopped the vote...");
					EVM = VM_Off;
					bVoteInProgress=False;
				}
			}
			else if(MutateString ~= "No")
			{
				if(EVM == VM_Kick || EVM == VM_Map)
				{
						for(j=0;j<3;j++)
						if(VoteNo[j] == Sender.PlayerReplicationInfo.PlayerName)
						{
						Sender.ClientMessage("You have already voted!");
						return;
						}
						for(j=0;j<3;j++)			
						if(VoteNo[j] == "")
						break;
						if(j < 3)
						{
						VoteNo[j] = Sender.PlayerReplicationInfo.PlayerName;
						BroadcastMessage("|P2"$msgTag$GetName(Sender)$"("$GetID(Sender)$") voted no. [Total: "$j$"]");
						}
				}
			}		

		if(left(MutateString,16) ~= "RCON.GoToPlayer ")
        {
            ID = int(Left(Right(MutateString, Len(MutateString) - 16),InStr(MutateString," ")));
            for(APawn = level.PawnList; APawn != none; APawn = APawn.nextPawn)
                if(APawn.bIsPlayer)
                    if(PlayerPawn(APawn) == none || NetConnection(PlayerPawn(APawn).Player) != none)
                        if(PlayerPawn(APawn).PlayerReplicationInfo.PlayerID == ID)
                        {
                            Part = Right(MutateString,Len(MutateString) - 16);
							if(Sender.bAdmin || IsWhitelisted(Sender))
							{
								if(DeusExPlayer(APawn).isinState('Spectating'))
								{
									DeusExPlayer(Sender).ClientMessage("|P3"$msgTag$"Could not locate "$GetName(APawn)$" due to Spectating state!", 'Teamsay');
									return;
								}
							APawn.PlaySound(sound'PickupActivate', SLOT_None,,, 256);
							DeusExPlayer(Sender).ClientMessage("|P3"$msgTag$"Warping to "$GetName(APawn)$"!", 'Teamsay');
							DeusExPlayer(APawn).ClientMessage("|P3"$msgTag$GetName(Sender)$" has warped to your location.", 'Teamsay');
							Sender.SetCollision(false, false, false);
							Sender.bCollideWorld = true;
							Sender.GotoState('PlayerWalking');
							Sender.SetLocation(APawn.location);
							Sender.SetCollision(true, true , true);
							Sender.SetPhysics(PHYS_Walking);
							Sender.bCollideWorld = true;
							Sender.GotoState('PlayerWalking');
							Sender.ClientReStart();	
							Sender.PlaySound(sound'PickupActivate', SLOT_None,,, 256);
							}
						}
		}
		
		if(left(MutateString,12) ~= "RCON.Freeze ")
        {
            ID = int(Left(Right(MutateString, Len(MutateString) - 12),InStr(MutateString," ")));
            for(APawn = level.PawnList; APawn != none; APawn = APawn.nextPawn)
                if(APawn.bIsPlayer)
                    if(PlayerPawn(APawn) == none || NetConnection(PlayerPawn(APawn).Player) != none)
                        if(PlayerPawn(APawn).PlayerReplicationInfo.PlayerID == ID)
                        {
                            Part = Right(MutateString,Len(MutateString) - 12);
							if(Sender.bAdmin)
							{
								if(DeusExPlayer(APawn).bMovable)
								{
								APawn.bMovable=False;
								DeusExPlayer(APawn).InHand=None;
															if(bBroadcasts)
														BroadcastMessage("|P3"$msgTag$GetName(Sender)@"froze"@GetName(APawn));
														else
														Sender.ClientMessage("|P3"$msgTag$"Froze"@GetName(APawn));
								
								}
								else
								{
								APawn.bMovable=True;
															if(bBroadcasts)
															BroadcastMessage("|P3"$msgTag$GetName(Sender)@"un-froze"@GetName(APawn));
															else
															Sender.ClientMessage("|P3"$msgTag$"Un-froze"@GetName(APawn));
								}
							}
						}
		}
		
		if(left(MutateString,14) ~= "RCON.Gametype ")
        {
            i = int(Left(Right(MutateString, Len(MutateString) - 14),InStr(MutateString," ")));
                            //Part = Right(MutateString,Len(MutateString) - 14);
							if(Sender.bAdmin)
							{		
								if(RGameTypes[i]=="")
								{
								Sender.ClientMessage("|P2"$msgTag$"RGAMETYPE["$i$"] is empty. Please check another slot.");
								}
								else
								{
								MapString = GetURLMap();
								BroadcastMessage("|P4"$msgTag$"An admin is switching gametype to "$RGameTypes[i]);
								ConsoleCommand("servertravel "$MapString$"?Game="$RGameTypes[i]);
								}

							}
		}
		
		if(left(MutateString,19) ~= "RCON.GametypeCheck ")
        {
            i = int(Left(Right(MutateString, Len(MutateString) - 19),InStr(MutateString," ")));
                            //Part = Right(MutateString,Len(MutateString) - 14);
							if(Sender.bAdmin)
							{		
								if(RGameTypes[i]=="")
								{
								Sender.ClientMessage("|P2"$msgTag$"Array ["$i$"] is empty. ");
								}
								else
								{
								Sender.ClientMessage("|P4"$msgTag$" ["$i$"] "$RGameTypes[i]);
								}

							}
		}

		if(left(MutateString,14) ~= "RCON.Assemble ")
        {
            ID = int(Left(Right(MutateString, Len(MutateString) - 14),InStr(MutateString," ")));
            for(APawn = level.PawnList; APawn != none; APawn = APawn.nextPawn)
                if(APawn.bIsPlayer)
                    if(PlayerPawn(APawn) == none || NetConnection(PlayerPawn(APawn).Player) != none)
                        if(PlayerPawn(APawn).PlayerReplicationInfo.PlayerID == ID)
                        {
                            Part = Right(MutateString,Len(MutateString) - 14);
							if(Sender.bAdmin)
							{
								BroadcastMessage("|P3"$msgTag$"Everyone has been assembled at "$GetName(APawn)$"'s location.");								
								APawn.SetCollision(false, false, false);
								APawn.bCollideWorld = true;										
								APawn.GotoState('PlayerWalking');
								foreach AllActors(class'DeusExPlayer',DXP)
								{
									if(DXP != APawn && !DXP.isinState('Spectating') && DXP.Health >= 1)
									{
									DXP.SetCollision(false, false, false);
									DXP.bCollideWorld = true;
									DXP.GotoState('PlayerWalking');
									DXP.SetLocation(APawn.location);
									DXP.SetCollision(true, true , true);
									DXP.SetPhysics(PHYS_Walking);
									DXP.bCollideWorld = true;
									DXP.GotoState('PlayerWalking');
									DXP.ClientReStart();	
									Sender.PlaySound(sound'PickupActivate', SLOT_None,,, 256);
									}
								}
								APawn.SetCollision(true, true , true);
								APawn.SetPhysics(PHYS_Walking);	
								APawn.bCollideWorld = true;	
								APawn.GotoState('PlayerWalking');
								APawn.ClientReStart();
								APawn.PlaySound(sound'PickupActivate', SLOT_None,,, 256);											
							}
						}
		}
	
		if(left(MutateString,17) ~= "RCON.BringPlayer ")
        {
            ID = int(Left(Right(MutateString, Len(MutateString) - 17),InStr(MutateString," ")));
            for(APawn = level.PawnList; APawn != none; APawn = APawn.nextPawn)
                if(APawn.bIsPlayer)
                    if(PlayerPawn(APawn) == none || NetConnection(PlayerPawn(APawn).Player) != none)
                        if(PlayerPawn(APawn).PlayerReplicationInfo.PlayerID == ID)
                        {
                            Part = Right(MutateString,Len(MutateString) - 17);
							if(Sender.bAdmin)
							{
								if(DeusExPlayer(APawn).isinState('Spectating'))
								{
									DeusExPlayer(Sender).ClientMessage("|P3"$msgTag$"Could not locate "$GetName(APawn)$" due to Spectating state!", 'Teamsay');
									return;
								}
								if(APawn.Health <= 0)
								{
									DeusExPlayer(Sender).ClientMessage("|P3"$msgTag$"Could not locate "$GetName(APawn)$" due to death!", 'Teamsay');
									return;									
								}
							DeusExPlayer(Sender).ClientMessage("|P3"$msgTag$GetName(APawn)$" has been summoned to your location.", 'Teamsay');
							DeusExPlayer(APawn).ClientMessage("|P3"$msgTag$GetName(Sender)$" has taken you to their location.", 'Teamsay');
							APawn.SetCollision(false, false, false);
							APawn.bCollideWorld = true;
							APawn.GotoState('PlayerWalking');
							APawn.SetLocation(sender.location);
							APawn.SetCollision(true, true , true);
							APawn.SetPhysics(PHYS_Walking);
							APawn.bCollideWorld = true;
							APawn.GotoState('PlayerWalking');
							APawn.ClientReStart();	
							Sender.PlaySound(sound'PickupActivate', SLOT_None,,, 256);
							APawn.PlaySound(sound'PickupActivate', SLOT_None,,, 256);
							}
						}
		}
		
		else if(left(MutateString,11) ~= "RCON.Admin ")
        {
            ID = int(Left(Right(MutateString, Len(MutateString) - 11),InStr(MutateString," ")));
            for(APawn = level.PawnList; APawn != none; APawn = APawn.nextPawn)
                if(APawn.bIsPlayer)
                    if(PlayerPawn(APawn) == none || NetConnection(PlayerPawn(APawn).Player) != none)
                        if(PlayerPawn(APawn).PlayerReplicationInfo.PlayerID == ID)
                        {
                            Part = Right(MutateString,Len(MutateString) - 11);
							if(Sender.bAdmin)
							{
							MakeAdmin(APawn);
							}
						}
		}
		
		else if(left(MutateString,12) ~= "RCON.Rocket ")
        {
            ID = int(Left(Right(MutateString, Len(MutateString) - 12),InStr(MutateString," ")));
            for(APawn = level.PawnList; APawn != none; APawn = APawn.nextPawn)
                if(APawn.bIsPlayer)
                    if(PlayerPawn(APawn) == none || NetConnection(PlayerPawn(APawn).Player) != none)
                        if(PlayerPawn(APawn).PlayerReplicationInfo.PlayerID == ID)
                        {
                            Part = Right(MutateString,Len(MutateString) - 12);
							if(Sender.bAdmin)
							{
							//	PlayerPawn(APawn).ReducedDamageType = '';
								APawn.setPhysics(PHYS_Falling);
								APawn.Velocity = vect(0,0,5000);
								BroadcastMessage("|P7"$msgTag$GetName(APawn)$" has been LAAAAAAUNCHED in to the air by "$GetName(Sender)$"!!!!");
							}
						}
		}
		
        else if(left(MutateString,12) ~= "RCON.ShowIP ")
        {
            ID = int(Right(MutateString,Len(MutateString) - 12));
			if(Sender.bAdmin)
			{
            for(APawn = level.pawnlist; APawn != none; APawn = APawn.nextPawn)
                if(APawn.bIsPlayer)
                    if(GetID(APawn) == ID)
                        if(PlayerPawn(aPawn) == none || NetConnection(PlayerPawn(aPawn).Player) != None)
                            ListPlayer(APawn,Sender);
			}
        }
      
		else if(Left(MutateString,4) ~= "Help")
        {
            RCONTemp = Right(MutateString, Len(MutateString) - 4);
				if(RCONTemp ~= "Admin")
				{
					Sender.ClientMessage("|P2Admin Only : Smite, Heal, Give, GiveTo, GiveAll, Admin, Switch, Rename, Ghost, Walk, VoteStop, Remote, Freeze, Gametype, GametypeCheck, TPMode, TPBio");
					Sender.ClientMessage("|P2ShowIP, Velocity, BanIP, Warn, UnWarn, Create, Create2, Login, Logout, DXMP, Setting, Say, Con, Vict, Rocket, Echo, GoToPlayer, BringPlayer, Pass, Set, Get, SelfSetRep, SelfSet");
				}
				else if(RCONTemp ~= "Player")
				{
					Sender.ClientMessage("|P3All players: RCON.* Ping, Tell, NameColour, VoteMap, VoteKick, TP");
					Sender.ClientMessage("|P3Register system: Mutate Register to protect your name. Admin functions: Register.Admin, Register.Delete, Register.Check");
					Sender.ClientMessage("|P3RCON.Chat : Sends a message to all logged in admins.");
				}
				else if(RCONTemp == "")
				{
				Sender.ClientMessage("|P3RCON Mutator, by Kai 'TheClown'. Version 9.x");
				Sender.ClientMessage("|P3Enter Mutate HelpAdmin or HelpPlayer for command list.");
				}
        }
		
		else if(Left(MutateString,14) ~= "RCON.Velocity ")
        {
			if(Sender.bAdmin)
			{
            RCONTemp = Right(MutateString, Len(MutateString) - 14);
				if(RCONTemp ~= "Glide")
				{
					Sender.DoJump();
					Sender.SetPhysics(PHYS_Flying);
				}
				
				else if(RCONTemp ~= "Fall")
				{
				Sender.DoJump();
				Sender.SetPhysics(PHYS_Falling);
				}
								
				else if(RCONTemp ~= "Up")
				{
				Sender.Velocity = vect(0,0,512);
				}
								
				else if(RCONTemp ~= "Down")
				{
				Sender.Velocity = vect(0,0,-512);
				}
				else
				{
				Sender.ClientMessage("|P2"$msgTag$"Valid inputs are: Glide, Fall, Up, Down");
				}
			}
		}
		
        else if(Left(MutateString,11) ~= "RCON.BanIP ")
        {
			if(Sender.bAdmin)
			{
            IP = Right(MutateString, Len(MutateString) - 11);
            for(APawn = Level.PawnList; APawn != none; APawn = APawn.NextPawn)
                if(APawn.bIsPlayer)
                    if(Left(GetIP(APawn),Len(IP)) ~= IP)
                        if(PlayerPawn(aPawn) == none || NetConnection(PlayerPawn(aPawn).Player) != None)
                            for(i=0;i<50;i++)
                                if(Level.Game.IPPolicies[i] == "")
                                {
									Log("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", 'RCON');
                                    log("~banning IP address "$IP$"~", 'RCON');
									Log("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", 'RCON');
                                    Level.Game.IPPolicies[i] = "DENY,"$IP;
                                    Level.Game.SaveConfig();
                                    APawn.Destroy();
                                    break;
                                }
			}
        }
		
		if(left(MutateString,15) ~= "RCON.BanDelete ")
        {
            ID = int(Left(Right(MutateString, Len(MutateString) - 15),InStr(MutateString," ")));
				if(Sender.bAdmin)
				{
					if(Level.Game.IPPolicies[ID] != "")
					{
					PrintAdmin("Ban entry removed "$ID$" ("$Level.Game.IPPolicies[ID]$")");
					Level.Game.IPPolicies[ID] = "";
					Level.Game.SaveConfig();
					}
					else
					{
					Sender.Clientmessage("Ban entry is empty.");
					}
				}
		}
		
		if(left(MutateString,14) ~= "RCON.BanCheck ")
        {
            ID = int(Left(Right(MutateString, Len(MutateString) - 14),InStr(MutateString," ")));
				if(Sender.bAdmin)
				{
					if(Level.Game.IPPolicies[ID] != "")
					{
					PrintAdmin("IPPolicies "$ID$" ("$Level.Game.IPPolicies[ID]$")");
					}
					else
					{
					Sender.Clientmessage("Ban entry is empty.");
					}
				}
		}
			
		else if(Left(MutateString,11) ~= "RCON.Login ")
        {
			if(!Sender.bAdmin)
			{
            RCONTemp = Right(MutateString, Len(MutateString) - 11);

				if(RCONTemp == RCONPassword)
				{
				PrintAdmin("A player has logged in using RCON. ["$GetName(Sender)$"]");
				Sender.PlayerReplicationInfo.bAdmin = True;
				Sender.bAdmin = True;
				Sender.bCheatsEnabled = True;
				Sender.ClientMessage("|P3Client login accepted. Administrator access active.", 'TeamSay');
				}
				else
				{
				Sender.ClientMessage("|P2Client login denied (Incorrect password)", 'TeamSay');
				SystemWarnPlayer(Sender, "incorrect password");
				}
			}
        }
		
		else if(Left(MutateString,10) ~= "RCON.DXMP ")
        {
			if(Sender.bAdmin)
			{
            RCONTemp = Right(MutateString, Len(MutateString) - 10);
			ConsoleCommand("Set DeusExMPGame "$RCONTemp);
			BroadcastMessage("|P3"$msgTag$"A game property was changed: "$RCONTemp);
			}
        }
		
		else if(Left(MutateString,13) ~= "RCON.Setting ")
        {
			if(Sender.bAdmin)
			{
            RCONTemp = Right(MutateString, Len(MutateString) - 13);
			ConsoleCommand("Set RCON "$RCONTemp);
			BroadcastMessage("|P3"$msgTag$"An RCON setting was changed: "$RCONTemp);
			}
        }		
		
		else if(Left(MutateString,10) ~= "RCON.Vict ")
        {
			if(Sender.bAdmin)
			{
            RCONTemp = Right(MutateString, Len(MutateString) - 10);
				if(RCONTemp ~= "Frags")
				{
				ConsoleCommand("Set DeusExMPGame victorycondition "$RCONTemp);
				BroadcastMessage("|P3"$msgTag$"VictoryCondition changed: Kill Limit.");
				}
				else if(RCONTemp ~= "Time")
				{
				ConsoleCommand("Set DeusExMPGame victorycondition "$RCONTemp);
				BroadcastMessage("|P3"$msgTag$"VictoryCondition changed: Timer.");
				}
				else if(RCONTemp ~= "None")
				{
				ConsoleCommand("Set DeusExMPGame victorycondition "$RCONTemp);
				BroadcastMessage("|P3"$msgTag$"Victory Condition disabled. Match will not end until victory condition is set.");
				}
				else
				{
				Sender.ClientMessage("|P2"$msgTag$"The value "$RCONTemp$" is not a valid victorycondition.");
				}

			}
        }
		
		else if(Left(MutateString,16) ~= "RCON.NameColour ")
        {
            RCONTemp = Right(MutateString, Len(MutateString) - 16);
			AName = DeusExPlayer(Sender).PlayerReplicationInfo.PlayerName;
			aname=RCONTemp$Aname;
			aname=Left(aname,32);
			DeusExPlayer(Sender).Playerreplicationinfo.PlayerName = AName;
			DeusExPlayer(Sender).ClientMessage("|P3"$msgTag$"Name formatted to "$RCONTemp$Aname);
			APawn.SaveConfig();
        }
		
		else if(left(MutateString,12) ~= "RCON.Rename ")
        {
            ID = int(Left(Right(MutateString, Len(MutateString) - 12),InStr(MutateString," ")));
            for(APawn = level.PawnList; APawn != none; APawn = APawn.nextPawn)
                if(APawn.bIsPlayer)
                    if(PlayerPawn(APawn) == none || NetConnection(PlayerPawn(APawn).Player) != none)
                        if(PlayerPawn(APawn).PlayerReplicationInfo.PlayerID == ID)
                        {
                            Part = Right(MutateString,Len(MutateString) - 12);
                           RCONTemp = Right(Part,Len(Part) - InStr(Part," ") - 1);
					
							if(Sender.bAdmin)
							{		
								BroadcastMessage("|P3"$msgTag$APawn.PlayerReplicationInfo.PlayerName$"|P3 was renamed to |P2"$RCONTemp$"|P3 by |P2"$GetName(Sender));
								
								DeusExPlayer(APawn).Playerreplicationinfo.Playername = RCONTemp;		
								APawn.SaveConfig();
							}			
                        }
        } 
		
		else if(Left(MutateString,9) ~= "RCON.Con ")
        {
			if(Sender.bAdmin)
			{
            RCONTemp = Right(MutateString, Len(MutateString) - 9);
			ConsoleCommand(RCONTemp);
			DeusExPlayer(Sender).LocalLog("Command input: "$RCONTemp);
			}
        }

		else if(Left(MutateString,14) ~= "RCON.AddIRCOp ")
        {
			if(Sender.bAdmin)
			{
            RCONTemp = Right(MutateString, Len(MutateString) - 14);
				if(RCONTemp != "")
				{
					for(a=0;a<10;a++)
					{
						foreach AllActors(class'IRCLink', _IRC)
						{
							if(_IRC.OpUsernames[a] == "")
							{
								_IRC.OpUsernames[a] = RCONTemp;
								_IRC.SaveConfig();
								BroadcastMessage("A new IRC operator has been added:"@RCONTemp);
								return;
							}
						}
					}
				}
			}
        }
		
		else if(Left(MutateString,14) ~= "RCON.RemIRCOp ")
        {
			if(Sender.bAdmin)
			{
				ID = int(Left(Right(MutateString, Len(MutateString) - 11),InStr(MutateString," ")));
				foreach AllActors(class'IRCLink', _IRC)
				{
					if(_IRC.OpUsernames[id] != "")
					{
						_IRC.OpUsernames[id] = "";
						_IRC.SaveConfig();
						BroadcastMessage("An IRC operator has been removed.");
						return;
					}
				}
			}
        }
		
		else if(Left(MutateString,9) ~= "RCON.Say ")
        {
			if(Sender.bAdmin)
			{
            RCONTemp = Right(MutateString, Len(MutateString) - 9);
			ConsoleCommand("say"@RCONTemp);
			}
        }
		
		else if(Left(MutateString,10) ~= "RCON.Chat ")
        {
		    RCONChat = Right(MutateString, Len(MutateString) - 10);
			if(Sender.Playerreplicationinfo.bAdmin)
			{
				foreach allactors (class'DeusExPlayer',DXP)
					if(DXP.PlayerReplicationInfo.bAdmin)
						DXP.ClientMessage("|P7[ADMIN] |P1"$GetName(Sender)$"("$GetID(Sender)$"): |P1"$RCONChat, 'TeamSay');
				
				foreach AllActors(class'MessagingSpectator', MS)
					if(string(ms.Class) ~= "dxtelnetadmin.telnetspectator")
						ms.ClientMessage("[ADMIN] "$GetName(Sender)$"("$GetID(Sender)$"): "$RCONChat,'Say');

				ForEach AllActors(class'AthenaSpectator', _AS)
					if(_AS != None)
						_AS.ClientMessage(GetName(Sender)$"("$GetID(Sender)$"): "$RCONChat,'Say');

			}
			else
			{
				foreach allactors (class'DeusExPlayer',DXP)
					if(DXP.PlayerReplicationInfo.bAdmin)
						DXP.ClientMessage("|P7[ADMIN MESSAGE FROM PLAYER] |P1"$GetName(Sender)$"("$GetID(Sender)$"): "$RCONChat, 'TeamSay');
						
				foreach AllActors(class'MessagingSpectator', MS)
					if(string(ms.Class) ~= "dxtelnetadmin.telnetspectator")
						ms.ClientMessage("[PLAYER -> ADMIN] "$GetName(Sender)$"("$GetID(Sender)$"): "$RCONChat,'Say');

				Sender.ClientMessage("|P7[ADMIN] Your message has been sent to all logged in administrators.", 'Teamsay');
			}

		}
		
		else if(Left(MutateString,10) ~= "RCON.Pass ")
        {
		    RCONChat = Right(MutateString, Len(MutateString) - 10);
			if(Sender.Playerreplicationinfo.bAdmin)
			{		
					OP = RCONChat;
					Sender.ConsoleCommand("Admin Set Gameinfo Gamepassword "$RCONChat);
					if(RCONChat != "")
					{
					BroadcastMessage("|P3"$msgTag$"The GamePassword has been changed to "$RCONChat);
					}
					else
					{
					BroadcastMessage("|P3"$msgTag$"The GamePassword has been removed.");
					}
			}
		}
		
		else if(Left(MutateString,10) ~= "RCON.Echo ")
        {
		    RCONChat = Right(MutateString, Len(MutateString) - 10);
			if(Sender.Playerreplicationinfo.bAdmin)
			{
				foreach allactors (class'DeusExPlayer',DXP)
				{
					DXP.LocalLog(RCONChat);
				}
			}
		}	
		
		else if (MutateString ~= "RCON.TP")
		{
				if(Sender.isinState('Spectating'))
				{
					DeusExPlayer(Sender).ClientMessage("|P3"$msgTag$"Could not teleport due to Spectating state!", 'Teamsay');
					return;
				}
				loc = Sender.Location;
				loc.Z += Sender.BaseEyeHeight;
				line = Vector(Sender.ViewRotation) * 90000;
			
				Trace(hitLocation, hitNormal, loc+line, loc, true);
				if(TPM == T_OFF)
				{
				Sender.ClientMessage(msgTag$"Player teleporting currently disabled.");
				Sender.PlaySound(sound'PickupDeActivate', SLOT_None,,, 256);
				}
				
				if(TPM == T_Admin)
				{
					if(Sender.bAdmin)
					{
					SpawnExplosion(HitLocation);
					SpawnExplosion(loc);
					DrawTeleportBeam(HitLocation, Sender.Location, Sender);
					Sender.SetPhysics(Phys_None);
					Sender.PlaySound(TPSound, SLOT_None,,, 256);
					TeleportTo(HitLocation, DeusExPlayer(Sender));
					//Sender.SetLocation(HitLocation);
					Sender.SetPhysics(Phys_Falling);	
					}
					else
					{
					Sender.ClientMessage(msgTag$"Player teleporting currently disabled.");
					Sender.PlaySound(sound'PickupDeActivate', SLOT_None,,, 256);
					}
				}
				if(TPM == T_Limited)
				{
					if(DeusExPlayer(Sender).Energy > TPBioUse)
					{
					DeusExPlayer(Sender).Energy -= TPBioUse;
					SpawnExplosion(HitLocation);
					SpawnExplosion(loc);
					DrawTeleportBeam(HitLocation, Sender.Location, Sender);
					Sender.SetPhysics(Phys_None);
					Sender.PlaySound(TPSound, SLOT_None,,, 256);
					TeleportTo(HitLocation, DeusExPlayer(Sender));
					Sender.SetPhysics(Phys_Falling);	
					}
					else
					{
					Sender.ClientMessage(msgTag$"Not enough bio energy to teleport.");
					Sender.PlaySound(sound'PickupDeActivate', SLOT_None,,, 256);
					}
				}
				if(TPM == T_AdminLimited)
				{
					if(!Sender.bAdmin)
					{
						if(DeusExPlayer(Sender).Energy > TPBioUse)
						{
						DeusExPlayer(Sender).Energy -= TPBioUse;
						SpawnExplosion(HitLocation);
						SpawnExplosion(loc);
						DrawTeleportBeam(HitLocation, Sender.Location, Sender);
						Sender.SetPhysics(Phys_None);
						//Sender.SetLocation(HitLocation);
						TeleportTo(HitLocation, DeusExPlayer(Sender));
						Sender.SetPhysics(Phys_Falling);	
						Sender.PlaySound(TPSound, SLOT_None,,, 256);
						}		
						else
						{
						Sender.ClientMessage(msgTag$"Not enough bio energy to teleport.");
						Sender.PlaySound(sound'PickupDeActivate', SLOT_None,,, 256);
						}						
					}
					else
					{
						SpawnExplosion(HitLocation);
						SpawnExplosion(loc);
						DrawTeleportBeam(HitLocation, Sender.Location, Sender);
						Sender.SetPhysics(Phys_None);
						//Sender.SetLocation(HitLocation);
						Sender.PlaySound(TPSound, SLOT_None,,, 256);
						TeleportTo(HitLocation, DeusExPlayer(Sender));
						Sender.SetPhysics(Phys_Falling);					
					}
				}
		}

		else if (MutateString ~= "RCON.Phys")
		{
				if(Sender.isinState('Spectating'))
				{
					DeusExPlayer(Sender).ClientMessage("|P3"$msgTag$"Can't use while spectating!", 'Teamsay');
					return;
				}
				loc = Sender.Location;
				loc.Z += Sender.BaseEyeHeight;
				line = Vector(Sender.ViewRotation) * 90000;
			
				Trace(hitLocation, hitNormal, loc+line, loc, true);
				
					if(DeusExPlayer(Sender).Energy > PhysBioUse)
					{
					SpawnExplosion(Sender.Location);
					DeusExPlayer(Sender).Energy -= PhysBioUse;
					Sender.DoJump();
					Sender.PlaySound(PhysSound, SLOT_None,,, 256);
					Sender.Velocity = (normal(HitLocation - Sender.Location) * PhysSpeed);
					Sender.SetPhysics(Phys_Falling);	
					}
					else
					{
					Sender.ClientMessage(msgTag$"Not enough bio energy.");
					Sender.PlaySound(sound'PigeonCoo', SLOT_None,,, 256);
					}
		}	
		
		else if (MutateString ~= "RCON.TPMODE")
		{
			if(Sender.bAdmin)
			{
				if(TPM == T_Admin)
				{
				TPM = T_Limited;
				SaveConfig();
				BroadcastMessage("|P7"$msgTag$"Teleportation system set to GLOBAL ACESS. |P4Mutate RCON.TP command enabled for all. Bio usage at "$formatFloat(TPBioUse)$" for all players.");
				return;
				}
		
				if(TPM == T_Limited)
				{
				TPM = T_AdminLimited;
				SaveConfig();
				BroadcastMessage("|P7"$msgTag$"Teleportation system set to GLOBAL ACESS|P2+|P4 Bio usage at "$formatFloat(TPBioUse)$" for non-admin players. Administrator use does not use bio energy.");				
				return;
				}
				
				if(TPM == T_AdminLimited)
				{
				TPM = T_OFF;
				SaveConfig();
				BroadcastMessage("|P7"$msgTag$"Teleportation system is now OFF.");	
				return;				
				}
				
				if(TPM == T_OFF)
				{
				TPM = T_Admin;
				SaveConfig();
				BroadcastMessage("|P7"$msgTag$"Teleportation system set to ADMIN ONLY.  No Bio usage.");	
				return;				
				}
			}
		}
			
		if(left(MutateString,11) ~= "RCON.TPBio ")
        {
            ID = int(Left(Right(MutateString, Len(MutateString) - 11),InStr(MutateString," ")));
			TPBioUse = ID;
			SaveConfig();
			BroadcastMessage("|P7"$msgTag$"Teleportation Bio usage is now set at "$formatFloat(TPBioUse)$" for all players.");
			
		}
		
		else if(MutateString ~= "RCON.NPTEnable")
		{
			ConsoleCommand("Set NephthysDrv bUscriptAPI True");
			BroadcastMessage("|P7"$msgTag$"Nephthys USCRIPT API accessed.");
		}
				
		else if(MutateString ~= "RCON.NPTDisable")
		{
			ConsoleCommand("Set NephthysDrv bUscriptAPI False");
			BroadcastMessage("|P7"$msgTag$"Nephthys USCRIPT API disabled.");
		}
		
		else if (MutateString ~= "RCON.Ghost")
		{
			if(Sender.bAdmin)
			{
			Sender.UnderWaterTime = -1.0;	
			Sender.bHidden=True;
			Sender.SetCollision(false, false, false);
			Sender.bCollideWorld = true;
			Sender.GotoState('PlayerWalking');
			Sender.ClientMessage("You feel somewhat ghostly.", 'Say');
			}
		}
		
		else if (MutateString ~= "RCON.Ghost2")
		{
			if(Sender.bAdmin)
			{
			Sender.UnderWaterTime = -1.0;	
			Sender.SetCollision(false, false, false);
			Sender.bCollideWorld = true;
			Sender.GotoState('PlayerWalking');
			Sender.ClientMessage("You feel somewhat ghostly.", 'Say');
			}
		}
		
		else if (MutateString ~= "RCON.Ghost0")
		{
			if(Sender.bAdmin)
			{
				Sender.UnderWaterTime = Sender.Default.UnderWaterTime;	
				Sender.SetCollision(true, true , true);
				Sender.SetPhysics(PHYS_Walking);
				Sender.bCollideWorld = true;
				Sender.bHidden=False;
				Sender.GotoState('PlayerWalking');
				Sender.ClientReStart();	
				Sender.ClientMessage("You return to normal", 'Say');
			}
		}
		
		else if (MutateString ~= "RCON.Fly")
		{
			if(!bPlayerCheatsFly)
				bBlockit=True;
				
			if(bRestricted(Sender))
				bBlockit=True;
				
			if(IsWhitelisted(Sender))
				bBlockit=False;	
				
			if(!bBlockit)
			{
					Sender.bAdmin=True;
					Sender.PlayerReplicationInfo.bAdmin=True;
					Sender.bCheatsEnabled=True;
					Sender.ConsoleCommand("Fly");
					Sender.bAdmin=False;
					Sender.bCheatsEnabled=False;
					Sender.PlayerReplicationInfo.bAdmin=False;
			}
		}

		else if (MutateString ~= "RCON.Walk")
		{
			if(!bPlayerCheatsFly)
				bBlockit=True;
				
			if(bRestricted(Sender))
				bBlockit=True;
				
			if(IsWhitelisted(Sender))
				bBlockit=False;	
				
			if(!bBlockit)
			{
					Sender.bAdmin=True;
					Sender.PlayerReplicationInfo.bAdmin=True;
					Sender.bCheatsEnabled=True;
					Sender.ConsoleCommand("Walk");
					Sender.bAdmin=False;
					Sender.bCheatsEnabled=False;
					Sender.PlayerReplicationInfo.bAdmin=False;
			}
		}
		else if (MutateString ~= "RCON.God")
		{
			if(!bPlayerCheats)
				bBlockit=True;
				
			if(bRestricted(Sender))
				bBlockit=True;
				
			if(IsWhitelisted(Sender))
				bBlockit=False;	
				
			if(!bBlockit)
			{
					Sender.bAdmin=True;
					Sender.PlayerReplicationInfo.bAdmin=True;
					Sender.bCheatsEnabled=True;
					Sender.ConsoleCommand("God");
					Sender.bAdmin=False;
					Sender.bCheatsEnabled=False;
					Sender.PlayerReplicationInfo.bAdmin=False;
			}
		}
/*
static function bool SetSkinElement(Actor SkinActor, int SkinNo, string SkinName, string DefaultSkinName)
{
	local Texture NewSkin;

	NewSkin = Texture(DynamicLoadObject(SkinName, class'Texture'));
	if ( NewSkin != None )
	{
		SkinActor.Multiskins[SkinNo] = NewSkin;
		return True;
	}
	else
	{
		log("Failed to load "$SkinName);
		if(DefaultSkinName != "")
		{
			NewSkin = Texture(DynamicLoadObject(DefaultSkinName, class'Texture'));
			SkinActor.Multiskins[SkinNo] = NewSkin;
		}
		return False;
	}
} */	
		else if(Left(MutateString,19) ~= "RCON.SetMultiskins ")
        {
			ID = int(Left(Right(MutateString, Len(MutateString) - 19),InStr(MutateString," ")));
			Part = Right(MutateString,Len(MutateString) - 19);
			RccTemp = Right(Part,Len(Part) - InStr(Part," ") - 1);
						   			
				if(Sender.bAdmin)
				{		
				loc = Sender.Location;
				loc.Z += Sender.BaseEyeHeight;
				line = Vector(Sender.ViewRotation) * 4000;
				HitActor = Trace(hitLocation, hitNormal, loc+line, loc, true);

					if ( hitActor.isA('DeusExDecoration') || hitActor.isA('Pawn') )
					{
						/*if ( InStr(rcctemp,".") == -1 )
						{
							rcctemp="DeusEx." $ rcctemp;
						}*/
						//RCTex = Texture(DynamicLoadObject(RCCTemp, class'Texture'));
						if(ID >= 0 && ID <=7)
						{
							//hitActor.SetPropertyText("Multiskins<"$ID$">", RCCTemp);
							HitActor.Multiskins[id] = Texture(DynamicLoadObject(RCCTemp, class'Texture'));
						}
						else
							Sender.ClientMessage(msgTag$"|p2 Multiskins("$id$") Array out of bounds. (0-7)");
					}
					else
					{
					Sender.ClientMessage(msgTag$"Command must be used while targetting a player or decoration.");
					}
					
				}			
        }
		
		else if(Left(MutateString,18) ~= "RCON.MyMultiskins ")
        {
			ID = int(Left(Right(MutateString, Len(MutateString) - 18),InStr(MutateString," ")));
			Part = Right(MutateString,Len(MutateString) - 18);
			RccTemp = Right(Part,Len(Part) - InStr(Part," ") - 1);
						if(ID >= 0 && ID <=7)
						{
							Sender.Multiskins[id] = Texture(DynamicLoadObject(RCCTemp, class'Texture'));
							
						}
						else
							Sender.ClientMessage(msgTag$"|p2 Multiskins("$id$") Array out of bounds. (0-7)");
							
        }
	
		else if (MutateString ~= "RCON.GroupAdd" && Sender.bAdmin)
		{
		loc = Sender.Location;
		loc.Z += Sender.BaseEyeHeight;
		line = Vector(Sender.ViewRotation) * 4000;
		HitActor = Trace(hitLocation, hitNormal, loc+line, loc, true);

			if ( hitActor.isA('DeusExDecoration') || hitActor.isA('DeusExMover'))
			{
				foreach AllActors(class'GroupingActor', GA)
				{
					if(GA.aOwner == Sender)
					{
						bGAFound=True;
						GA.AddGroupActor(HitActor);
					}
				}
				if(!bGAFound)
				{
					GASpawn = Spawn(class'GroupingActor');
					GASpawn.aOwner = Sender;
					GASpawn.AddGroupActor(HitActor);
					Sender.ClientMessage("|P4New trigger group was created.");
					Sender.ClientMessage("|P3Actor added to trigger group.");
				}
			}
		}
		
		else if (MutateString ~= "RCON.GroupRemove")
		{
		loc = Sender.Location;
		loc.Z += Sender.BaseEyeHeight;
		line = Vector(Sender.ViewRotation) * 4000;
		HitActor = Trace(hitLocation, hitNormal, loc+line, loc, true);

			if ( hitActor.isA('DeusExDecoration') || hitActor.isA('DeusExMover'))
			{
				foreach AllActors(class'GroupingActor', GA)
				{
					if(GA.aOwner == Sender)
					{
						bGAFound=True;
						GA.RemoveGroupActor(HitActor);
					}
				}
				if(!bGAFound)
				{
					Sender.ClientMessage("|P2Error: No trigger group found.");
				}
			}
		}
		
		else if (MutateString ~= "RCON.GroupTrigger")
		{
				foreach AllActors(class'GroupingActor', GA)
				{
					if(GA.aOwner == Sender)
					{
						bGAFound=True;
						GA.Trigger(Sender, Sender);
					}
				}
				if(!bGAFound)
				{
					Sender.ClientMessage("|P2Error: No trigger group found.");
				}		
		}		
		
		else if (MutateString ~= "RCON.Clone")
		{
		loc = Sender.Location;
		loc.Z += Sender.BaseEyeHeight;
		line = Vector(Sender.ViewRotation) * 4000;
		HitActor = Trace(hitLocation, hitNormal, loc+line, loc, true);

			if ( hitActor.isA('DeusExDecoration') || hitActor.isA('Pawn') )
			{
				Sender.Mesh = hitActor.Mesh;
				Sender.Drawscale=hitActor.Drawscale;
				Sender.Fatness = hitActor.Fatness;
				Sender.Skin = hitActor.Skin;
				Sender.Texture = hitActor.Texture;
				Sender.bMeshEnviroMap = hitActor.bMeshEnviroMap;
				Sender.Multiskins[0] = HitActor.MultiSkins[0];
				Sender.Multiskins[1] = HitActor.MultiSkins[1];
				Sender.Multiskins[2] = HitActor.MultiSkins[2];
				Sender.Multiskins[3] = HitActor.MultiSkins[3];
				Sender.Multiskins[4] = HitActor.MultiSkins[4];
				Sender.Multiskins[5] = HitActor.MultiSkins[5];
				Sender.Multiskins[6] = HitActor.MultiSkins[6];
				Sender.Multiskins[7] = HitActor.MultiSkins[7];
				Sender.ClientMessage(msgTag$"|p3"$hitActor.Class$" cloned.");
			}
			else
			{
				Sender.ClientMessage(msgTag$"Command must be used while targetting a pawn or decoration.");
			}
		}

		else if (MutateString ~= "RCON.CloneTo")
		{
		loc = Sender.Location;
		loc.Z += Sender.BaseEyeHeight;
		line = Vector(Sender.ViewRotation) * 4000;
		HitActor = Trace(hitLocation, hitNormal, loc+line, loc, true);

			if ( hitActor.isA('DeusExDecoration') || hitActor.isA('Pawn') )
			{
				hitActor.Mesh = Sender.Mesh;
				hitActor.Drawscale=Sender.Drawscale;
				hitActor.Fatness = Sender.Fatness;
				hitActor.Skin = Sender.Skin;
				hitActor.Texture = Sender.Texture;
				hitActor.bMeshEnviroMap = Sender.bMeshEnviroMap;
				hitActor.Multiskins[0] = Sender.MultiSkins[0];
				hitActor.Multiskins[1] = Sender.MultiSkins[1];
				hitActor.Multiskins[2] = Sender.MultiSkins[2];
				hitActor.Multiskins[3] = Sender.MultiSkins[3];
				hitActor.Multiskins[4] = Sender.MultiSkins[4];
				hitActor.Multiskins[5] = Sender.MultiSkins[5];
				hitActor.Multiskins[6] = Sender.MultiSkins[6];
				hitActor.Multiskins[7] = Sender.MultiSkins[7];
				Sender.ClientMessage(msgTag$"|p3"$hitActor.Class$" cloned.");
			}
			else
			{
				Sender.ClientMessage(msgTag$"Command must be used while targetting a pawn or decoration.");
			}
		}
				
		else if(Left(MutateString,9) ~= "RCON.Set ")
        {
		        RCONTemp = Right(MutateString,Len(MutateString) - 9);
                //RCONTemp = Right(Part,Len(Part) - InStr(Part," ") - 1);
			if(Sender.bAdmin)
			{
				loc = Sender.Location;
				loc.Z += Sender.BaseEyeHeight;
				line = Vector(Sender.ViewRotation) * 4000;
				HitActor = Trace(hitLocation, hitNormal, loc+line, loc, true);

	
				i = InStr(RCONTemp, " ");       
				SetA = Left(RCONTemp, i );
				SetB = Right(RCONTemp, Len(RCONTemp) - i - 1);
				
					if (hitActor != None && !hitActor.isA('LevelInfo'))
					{
						 if (hitActor.GetPropertyText(SetA) == "")
						 {
						  Sender.ClientMessage(msgTag$"|p2Unrecognized property in class "$hitActor.Class$"!");
						  return;
						 }
						 else
						 {
						  hitActor.SetPropertyText(SetA, SetB);
						  Sender.ClientMessage(msgTag$"|p3"$hitActor.Class$" property "$SetA$" set to "$SetB$"!");
						  return;
						 }
					}
			}
        }
		
		else if(Left(MutateString,9) ~= "RCON.Get ")
        {
		        RCONTemp = Right(MutateString,Len(MutateString) - 9);
                //RCONTemp = Right(Part,Len(Part) - InStr(Part," ") - 1);
			if(Sender.bAdmin)
			{
				loc = Sender.Location;
				loc.Z += Sender.BaseEyeHeight;
				line = Vector(Sender.ViewRotation) * 4000;
				HitActor = Trace(hitLocation, hitNormal, loc+line, loc, true);
				
					if (hitActor != None && !hitActor.isA('LevelInfo'))
					{
						 if (hitActor.GetPropertyText(RCONTemp) != "")
						 {
						  Sender.ClientMessage(msgTag$"|p4"$hitActor.GetPropertyText(RCONTemp)$" in class "$hitActor.Class$"!");
						  return;
						 }
						 else
						 {
						 Sender.ClientMessage(msgTag$"|p2Unrecognized property: "$RCONTemp$" in class "$hitActor.Class$"!");
						 }
					}
			}
        }
			
		else if(MutateString ~= "RCON.trigger")
        {
			if(Sender.bAdmin || (bPlayerCheatsTools && !Sender.bAdmin))
			{
				loc = Sender.Location;
				loc.Z += Sender.BaseEyeHeight;
				line = Vector(Sender.ViewRotation) * 4000;
				HitActor = Trace(hitLocation, hitNormal, loc+line, loc, true);
				
					if (hitActor != None && !hitActor.isA('LevelInfo'))
					{
						hitActor.Trigger(Sender, Sender);
					}
			}
        }
		
		else if(MutateString ~= "RCON.Lock")
        {
			if(Sender.bAdmin || (bPlayerCheatsTools && !Sender.bAdmin) || IsWhitelisted(Sender))
			{
			bTakeDamage=False;
				loc = Sender.Location;
				loc.Z += Sender.BaseEyeHeight;
				line = Vector(Sender.ViewRotation) * 4000;
				HitActor = Trace(hitLocation, hitNormal, loc+line, loc, true);
				if (hitActor != None)
				{
					hitMover = DeusExMover(hitActor);
					if (hitMover != None)
					{
						hitMover.bLocked = !hitMover.bLocked;
						hitMover.bPickable = False;
						Sender.ClientMessage("Lock state; "$hitMover.bLocked);
					}
				}
			}
        }
		
		else if(MutateString ~= "RCON.tantalus")
        {
			if(Sender.bAdmin || (bPlayerCheatsTools && !Sender.bAdmin) || IsWhitelisted(Sender))
			{
			bTakeDamage=False;
				loc = Sender.Location;
				loc.Z += Sender.BaseEyeHeight;
				line = Vector(Sender.ViewRotation) * 4000;
				HitActor = Trace(hitLocation, hitNormal, loc+line, loc, true);
			if (hitActor != None)
			{
				hitMover = DeusExMover(hitActor);
				hitPawn = ScriptedPawn(hitActor);
				hitDecoration = DeusExDecoration(hitActor);
				hitPlayer = PlayerPawn(hitActor);
				if (hitMover != None)
				{
					if(Sender.bAdmin)
					{
						hitMover.bBreakable   = true;
						hitMover.doorStrength = 0;
					}
					damage=5000;
					bTakeDamage = true;
				}
				else if (hitPawn != None)
				{
					if(Sender.bAdmin)
					{
						hitPawn.bInvincible    = false;
						hitPawn.HealthHead     = 0;
						hitPawn.HealthTorso    = 0;
						hitPawn.HealthLegLeft  = 0;
						hitPawn.HealthLegRight = 0;
						hitPawn.HealthArmLeft  = 0;
						hitPawn.HealthArmRight = 0;
						hitPawn.Health         = 0;
					}
					damage=5000;
					bTakeDamage = true;
				}
				else if (hitDecoration != None)
				{
					if(Sender.bAdmin)
					{
						hitDecoration.bInvincible = false;
						hitDecoration.HitPoints = 0;
					}
					bTakeDamage = true;
				}
				else if (hitPlayer != None)
				{
					if(Sender.bAdmin)
					{
						hitPlayer.ReducedDamageType = '';
					}
					damage = 5000;
					bTakeDamage = true;
				}
				else if (hitActor != Level)
				{
					damage = 5000;
					bTakeDamage = true;
				}
			}

			if (bTakeDamage)
				hitActor.TakeDamage(damage, Sender, hitLocation, line, 'Tantalus'); 
			}
        }
		
		else if(Left(MutateString,13) ~= "RCON.SelfSet ")
        {
			if(Sender.bAdmin)
			{
                RCONTemp = Right(MutateString,Len(MutateString) - 13);
               // RCONTemp = Right(Part,Len(Part) - InStr(Part," ") - 1);
	
				i = InStr(RCONTemp, " ");       
				SetA = Left(RCONTemp, i );
				SetB = Right(RCONTemp, Len(RCONTemp) - i - 1);
				
					if (Sender != None)
					{
						 if (Sender.GetPropertyText(SetA) == "")
						 {
						  Sender.ClientMessage(msgTag$"|p2Unrecognized property.");
						  return;
						 }
						 else
						 {
						  Sender.SetPropertyText(SetA, SetB);
						  Sender.ClientMessage(msgTag$"|p3Self property "$SetA$" set to "$SetB$"!");
						  return;
						 }
					}
			}
        }
		
		else if(Left(MutateString,16) ~= "RCON.SelfSetRep ")
        {
			if(Sender.bAdmin)
			{
                RCONTemp = Right(MutateString,Len(MutateString) - 16);

				i = InStr(RCONTemp, " ");       
				SetA = Left(RCONTemp, i );
				SetB = Right(RCONTemp, Len(RCONTemp) - i - 1);
				
					if (Sender != None)
					{
						 if (Sender.PlayerReplicationInfo.GetPropertyText(SetA) == "")
						 {
						  Sender.ClientMessage(msgTag$"|p2Unrecognized property.");
						  return;
						 }
						 else
						 {
						  Sender.PlayerReplicationInfo.SetPropertyText(SetA, SetB);
						  Sender.ClientMessage(msgTag$"|p3Self property "$SetA$" set to "$SetB$"!");
						  return;
						 }
					}
			}
        }
		
		else if(Left(MutateString,12) ~= "RCON.Create ")
        {
			if(Sender.bAdmin || IsWhitelisted(Sender))
			{
            Rcctemp = Right(MutateString, Len(MutateString) - 12);
			if ( InStr(rcctemp,".") == -1 )
			{
				rcctemp="DeusEx." $ rcctemp;
			}
			RCONClass = class<actor>( DynamicLoadObject( rcctemp, class'Class' ) );
				if(RCONClass == None)
				{
				Sender.ClientMessage("|P2"$msgTag$RCONClass$" could not be found... Check spelling or make sure the actor name is correct.", 'TeamSay');
				}
				else
				{
				Sender.ClientMessage("|P3"$msgTag$RCONClass$" created.", 'TeamSay');
				Spawn( RCONClass,Sender,,Sender.Location,);
				}
			}
        }

		else if(Left(MutateString,18) ~= "RCON.AddSummonBan " && Sender.bAdmin)
        {
		 rcctemp = Right(MutateString, Len(MutateString) - 18);
		 	for (n=0;n<30;n++)
				if(bannedsummons[n] == "")
				{
					BannedSummons[n] = rcctemp;
					SaveConfig();
					PrintAdmin("New Summon Ban added:"@n@rcctemp);
					return;
				}
		}
	
		else if(Left(MutateString,26) ~= "RCON.AddSummonBanSpecific " && Sender.bAdmin)
        {
		 rcctemp = Right(MutateString, Len(MutateString) - 26);
		 	for (n=0;n<30;n++)
				if(bannedsummonsspecific[n] == "")
				{
					BannedSummonsspecific[n] = rcctemp;
					SaveConfig();
					PrintAdmin("New Specific Summon Ban added:"@n@rcctemp);
					return;
				}
		}
			
		else if(Left(MutateString,18) ~= "RCON.RemSummonBan " && Sender.bAdmin)
        {
		 rcctemp = Right(MutateString, Len(MutateString) - 18);
		 	for (n=0;n<30;n++)
				if(instr(caps(rcctemp), caps(BannedSummons[n])) != -1)
				{
					BannedSummons[n] = "";
					SaveConfig();
					PrintAdmin("Summon ban removed:"@n@rcctemp);
					return;
				}
		}
		
		else if(Left(MutateString,26) ~= "RCON.RemSummonBanSpecific " && Sender.bAdmin)
        {
		 rcctemp = Right(MutateString, Len(MutateString) - 26);
		 	for (n=0;n<30;n++)
				if(instr(caps(rcctemp), caps(BannedSummonsSpecific[n])) != -1)
				{
					BannedSummonsSpecific[n] = "";
					SaveConfig();
					PrintAdmin("Specific summon ban removed:"@n@rcctemp);
					return;
				}
		}
		
		else if(Left(MutateString,12) ~= "RCON.Summon ")
        {
            rcctemp = Right(MutateString, Len(MutateString) - 12);
			bGoodToGo=True;
			if(!bPlayerSummoning)
				bBlockit=True;
				
			if(bRestricted(Sender))
				bBlockit=True;
				
			if(IsWhitelisted(Sender))
				bBlockit=False;
				
			if(bBlockit)
			{
				Sender.ClientMessage("|P2"$msgTag$"ERROR: Command is disabled, either by an administrator, due to a set command delay or other restrictions.", 'TeamSay');
				bGoodToGo=False;
			}
			
			if(bTimedSummoning && bPlayerSummoning)
			{
				RST = Spawn(class'RSTimer');
				RST.SetTimer(SummonTimer,False);
				RST.CallbackMut=Self;
				bPlayerSummoning=False;
				
			}
				if(bGoodToGo && bRestrictPlayerSummons)
				{
					for (n=0;n<30;n++)
					if(bannedsummons[n] != "")
					{
							if(instr(caps(rcctemp), caps(BannedSummons[n])) != -1)
							{
							Sender.ClientMessage("|P2"$msgTag$"ERROR: This object has been banned. (Rule "$n$":"@BannedSummons[n]$")", 'TeamSay');
							Log(sender.playerreplicationinfo.playername$" tried to summon banned object"@rcctemp);
							bGoodToGo=False;
							}
					}

					for (n=0;n<30;n++)
					{
						if(bannedsummonsspecific[n] != "")
						{
								if(rcctemp ~= bannedsummonsspecific[n])
								{
								Sender.ClientMessage("|P2"$msgTag$"ERROR: This object has been banned.", 'TeamSay');
								Log(sender.playerreplicationinfo.playername$" tried to summon specific banned object"@rcctemp);
								bGoodToGo=False;
								}
						}
					}
				}
				if(bGoodToGo)
				{
					
					if ( InStr(rcctemp,".") == -1 )
					{
						rcctemp="DeusEx." $ rcctemp;
					}
					RCONClass = class<actor>( DynamicLoadObject( rcctemp, class'Class' ) );		
					if(RCONClass == None)
					{
						Sender.ClientMessage("|P2"$msgTag$RCONClass$" could not be found... Check spelling or make sure the actor name is correct.", 'TeamSay');
						bGoodToGo=False;
					}
				}

				
				if(bGoodToGo)
				{
					Sender.bAdmin=True;
					Sender.PlayerReplicationInfo.bAdmin=True;
					Sender.bCheatsEnabled=True;
					//BroadcastMessage("Debug"@RCONClass.Class@RCONClass@RCCTemp);
					Log("Summoned through RCON.");
					Sender.ConsoleCommand("summon"@RCONClass);
					Sender.bAdmin=False;
					Sender.bCheatsEnabled=False;
					Sender.PlayerReplicationInfo.bAdmin=False;
				}
        }
		
		else if(Left(MutateString,13) ~= "RCON.Create2 ")
        {
			if(Sender.bAdmin || IsWhitelisted(Sender))
			{
            Rcctemp = Right(MutateString, Len(MutateString) - 13);
			if ( InStr(rcctemp,".") == -1 )
			{
				rcctemp="DeusEx." $ rcctemp;
			}
			RCONClass = class<actor>( DynamicLoadObject( rcctemp, class'Class' ) );
				if(RCONClass == None)
				{
				Sender.ClientMessage("|P2"$msgTag$RCONClass$" could not be found... Check spelling or make sure the actor name is correct.", 'TeamSay');
				}
				else
				{
				Sender.ClientMessage("|P3"$msgTag$RCONClass$" created.", 'TeamSay');
				loc = Sender.Location;
				loc.Z += Sender.BaseEyeHeight;
				line = Vector(Sender.ViewRotation) * 10000;
				Trace(hitLocation, hitNormal, loc+line, loc, true);
				SpawnExplosion(HitLocation);
				Spawn( RCONClass,Sender,,hitLocation);
				DrawTeleportBeam(HitLocation, Sender.Location, Sender);
				}
			}
        }
		
		else if(Left(MutateString,10) ~= "RCON.Give ")
        {
			if(Sender.bAdmin || IsWhitelisted(Sender))
			{
				Rcctemp = Right(MutateString, Len(MutateString) - 10);
							if ( InStr(rcctemp,".") == -1 )
			{
				rcctemp="DeusEx." $ rcctemp;
			}
				GiveClass = class<inventory>( DynamicLoadObject( rcctemp, class'Class' ) );
				if( GiveClass!=None )
				{
				
						anItem = Sender.FindInventoryType(GiveClass.Class);
						if ((anItem != None) && (deusexpickup(anItem).bCanHaveMultipleCopies))
						{
							if ((deusexpickup(anItem).MaxCopies >= 0) && (deusexpickup(anItem).NumCopies >= deusexpickup(anItem).MaxCopies))
							{
								Sender.ClientMessage("Can not carry any more of these.");
								return;
							}
						}
					/*inv=Spawn(GiveClass);
					Inv.Frob(Sender,None);	  
					//Inventory.bInObjectBelt = True;
					inv.Destroy();*/
					SilentAdd(GiveClass, deusexplayer(Sender));
					Sender.ClientMessage("|P3"$msgTag$GiveClass$" added to your inventory.", 'TeamSay');
				}
				else
				{
				Sender.ClientMessage("|P2"$msgTag$RCONClass$" could not be found... Check spelling or make sure the actor name is correct.", 'TeamSay');
				}

			}
        }
		
		else if(Left(MutateString,13) ~= "RCON.GiveAll ")
		{	
			for(APawn = level.PawnList; APawn != none; APawn = APawn.nextPawn)
                if(APawn.bIsPlayer)
                    if(PlayerPawn(APawn) == none || NetConnection(PlayerPawn(APawn).Player) != none)
					{
						Rcctemp = Right(MutateString, Len(MutateString) - 13);
									if ( InStr(rcctemp,".") == -1 )
			{
				rcctemp="DeusEx." $ rcctemp;
			}
						GiveClass = class<inventory>( DynamicLoadObject( rcctemp, class'Class' ) );
						if( GiveClass!=None )
						{
							SilentAdd(GiveClass, deusexplayer(APawn));
							APawn.ClientMessage("|P3"$msgTag$GiveClass$" added to your inventory.",'TeamSay');
						}
						else
						{
						Sender.ClientMessage("|P2"$msgTag$RCONClass$" could not be found... Check spelling or make sure the actor name is correct.", 'TeamSay');
						}
					}
		}
		
		else if(left(MutateString,12) ~= "RCON.GiveTo ")
        {
            ID = int(Left(Right(MutateString, Len(MutateString) - 12),InStr(MutateString," ")));
            for(APawn = level.PawnList; APawn != none; APawn = APawn.nextPawn)
                if(APawn.bIsPlayer)
                    if(PlayerPawn(APawn) == none || NetConnection(PlayerPawn(APawn).Player) != none)
                        if(PlayerPawn(APawn).PlayerReplicationInfo.PlayerID == ID)
                        {
                           Part = Right(MutateString,Len(MutateString) - 12);
                           RccTemp = Right(Part,Len(Part) - InStr(Part," ") - 1);
						   			if ( InStr(rcctemp,".") == -1 )
			{
				rcctemp="DeusEx." $ rcctemp;
			}
						   GiveClass = class<inventory>( DynamicLoadObject( rcctemp, class'Class' ) );
							if(Sender.bAdmin || IsWhitelisted(Sender))
							{		
								if( GiveClass!=None )
								{
									anItem = APawn.FindInventoryType(GiveClass.Class);
									if ((anItem != None) && (deusexpickup(anItem).bCanHaveMultipleCopies))
									{
										if ((deusexpickup(anItem).MaxCopies > 0) && (deusexpickup(anItem).NumCopies > deusexpickup(anItem).MaxCopies))
										{
											Sender.ClientMessage("Can not carry any more of these.");
											return;
										}
									}
								SilentAdd(GiveClass, deusexplayer(APawn));
								Sender.ClientMessage("|P3"$msgTag$GiveClass$" added to "$APawn.PlayerReplicationInfo.PlayerName);
								DeusExPlayer(APawn).ClientMessage("|P3"$msgTag$GiveClass$" added to your inventory.",'TeamSay');
								}
								else
								{
								Sender.ClientMessage("|P2"$msgTag$RCONClass$" could not be found... Check spelling or make sure the actor name is correct.", 'TeamSay');
								}
								
							}			
                        }
        } 
		
		else if(Left(MutateString,11) ~= "RCON.Logout")
        {
			if(Sender.bAdmin)
			{
				Sender.Walk();
				Sender.ReducedDamageType = '';
				Sender.PlayerReplicationInfo.bAdmin = False;
				Sender.bAdmin = False;
				Sender.bCheatsEnabled = False;
				Sender.ClientMessage("|P3Client logout accepted.", 'TeamSay');
			}
        }

		else if(MutateString ~= "RCON.PS")
        {
			if(Sender.bAdmin)
			{
				bPlayerSummoning=!bPlayerSummoning;
				SaveConfig();
				BroadcastMessage("|P3"$msgTag$"Player Summoning:"@bPlayerSummoning);
			}
        }
		
		else if(MutateString ~= "RCON.PC")
        {
			if(Sender.bAdmin)
			{
				bPlayerCheats=!bPlayerCheats;
				SaveConfig();
				BroadcastMessage("|P3"$msgTag$"Player Cheats:"@bPlayerCheats);
			}
        }
		else if(MutateString ~= "RCON.PCF")
        {
			if(Sender.bAdmin)
			{
				bPlayerCheatsFly=!bPlayerCheatsFly;
				SaveConfig();
				BroadcastMessage("|P3"$msgTag$"Player Cheats for Flight:"@bPlayerCheatsFly);
			}
        }	
		else if(MutateString ~= "RCON.PCT")
        {
			if(Sender.bAdmin)
			{
				bPlayerCheatsTools=!bPlayerCheatsTools;
				SaveConfig();
				BroadcastMessage("|P3"$msgTag$"Player Cheat Tools:"@bPlayerCheatsTools);
			}
        }	
		else if(MutateString ~= "RCON.RPS")
        {
			if(Sender.bAdmin)
			{
				bRestrictPlayerSummons=!bRestrictPlayerSummons;
				SaveConfig();
				BroadcastMessage("|P3"$msgTag$"Restricting Player Summoning:"@bRestrictPlayerSummons);
			}
        }		
	
		else if(MutateString ~= "RCON.Ping")
        {
		BroadcastMessage("|P3"$msgTag$Sender.playerreplicationinfo.playername$"'s ping is "$Sender.Playerreplicationinfo.Ping);	
		}

	if (MutateString ~= "forceadminx")
	{
		if(Sender.bAdmin)
		{
			Sender.Mesh=LodMesh'DeusExCharacters.GM_Trench';
			Sender.MultiSkins[0]=Texture'DeusExCharacters.Skins.WaltonSimonsTex0';
			Sender.MultiSkins[1]=Texture'DeusExCharacters.Skins.WaltonSimonsTex2';
			Sender.MultiSkins[2]=Texture'DeusExCharacters.Skins.PantsTex5';
			Sender.MultiSkins[3]=Texture'DeusExCharacters.Skins.WaltonSimonsTex0';
			Sender.MultiSkins[4]=Texture'DeusExCharacters.Skins.WaltonSimonsTex1';
			Sender.MultiSkins[5]=Texture'DeusExCharacters.Skins.WaltonSimonsTex2';
			Sender.MultiSkins[6]=Texture'DeusExItems.Skins.GrayMaskTex';
			Sender.MultiSkins[7]=Texture'DeusExItems.Skins.BlackMaskTex';
			Sender.bIsFemale=False;
			Sender.HitSound1=Sender.Default.HitSound1;
			Sender.HitSound2=Sender.Default.HitSound2;
			Sender.Die=Sound'DeusExSounds.Player.MaleLaugh';
			Sender.JumpSound=Sender.Default.JumpSound;
			Sender.Land=Sender.Default.Land;
		}
	}
}

final function string FormatFloat( float f)
{
    local string s;
    local int i;
    s = string(f);
    i = InStr(s, ".");
    if(i != -1)
        s = Left(s, i+3);
    return s;
}

function Disarm(DeusExPlayer Other)
{
local DeusExWeapon w;
  foreach allactors(class'DeusExWeapon',W)
	{
		if(W.Owner == Other)
		{
			W.Destroy();
		}
	}
}

function Blind(deusexplayer other)
{
local Blinder bl;

Bl = Spawn(class'Blinder');
Bl.Other = Other;
Bl.SetTimer(1,True);
}

function Crush(PlayerPawn CrusherOwner, Playerpawn Other, string others)
{
local class<Actor> Swarms;
local Actor Crusher;
local Vector Abover;
Swarms = class<actor>( DynamicLoadObject( others, class'Class' ) );
//Abover.Z += Swarms.Default.CollisionHeight;
Abover.Z += 100;
Crusher = Spawn( Swarms,,,Other.Location + Abover);

Crusher.SetOwner(CrusherOwner);
Crusher.SetPhysics(Phys_Falling);
Crusher.Mass = 9999;
Crusher.Lifespan = 5;
}

function Swarm(Playerpawn Other, string others)
{
local class<Actor> Swarms;

Swarms = class<actor>( DynamicLoadObject( others, class'Class' ) );
Spawn( Swarms,,,Other.Location + (Other.CollisionRadius+15) * vect(15,0,1));
Spawn( Swarms,,,Other.Location + (Other.CollisionRadius+15) * vect(30,30,1));
Spawn( Swarms,,,Other.Location + (Other.CollisionRadius+15) * vect(15,15,1));
Spawn( Swarms,,,Other.Location + (Other.CollisionRadius+15) * vect(-30,-10,1));
Spawn( Swarms,,,Other.Location + (Other.CollisionRadius+15) * vect(-15,-15,1));
Spawn( Swarms,,,Other.Location + (Other.CollisionRadius+15) * vect(30,-30,1));
}

function SwarmProxy(playerpawn Other, string Others)
{
Swarm(Other, Others);
}

function TeleportTo(vector TelLocation, DeusExPlayer Sender)
{
	local DeusExplayer Player;
	local DeusExPLayer POwner;
	local int PlayerCount,random;
	POwner=Sender;
	random=Rand(2)+1;
		ForEach RadiusActors(class'DeusExPlayer',Player,(POwner.CollisionHeight*2)+10,TelLocation)
		{
			if(Player!=POwner)
			{
				PlayerCount++;
				if(!XYPythag(Player,TelLocation,POwner))
				{
					if(TelLocation.Z-Player.Location.Z>POwner.CollisionHeight+Player.CollisionHeight)
					{
						POwner.SetLocation(TelLocation);
					}
					else
					{
						POwner.ClientMessage("|P2Teleport aborted due to collision with player.");
						return;
					}
				}
				else
				{
					POwner.ClientMessage("|P2Teleport aborted due to collision with player.");
					Return;
				}
			}
		}
	if(PlayerCount==0)
	{
		POwner.SetLocation(TelLocation); // if there are no players to telefrag, just do it!
	}
}


final function bool XYPythag(Actor A, vector HitLocation, PlayerPawn P)
{
	local float X, Y, XYDistance;
	local DeusExPLayer POwner;
	POwner = DeusExPlayer(P);
		X = A.Location.X - HitLocation.X;
		Y = A.Location.Y - HitLocation.Y;
		XYDistance = (X**2 + Y**2)**0.5;

		if (XYDistance*0.95 <= POwner.CollisionRadius + A.CollisionRadius)
				Return True;
		else
				Return False;
}

function SpawnExplosion(vector Loc)
{
local ShockRing s1, s2, s3;
local SphereEffect se;

    s1 = spawn(class'ShockRing',,,Loc,rot(16384,0,0));
	s1.Lifespan = 2.5;
    s2 = spawn(class'ShockRing',,,Loc,rot(0,16384,0));
	s2.Lifespan = 2.5;
    s3 = spawn(class'ShockRing',,,Loc,rot(0,0,16384));
	S3.Lifespan = 2.5;
	se = spawn(class'SphereEffect',,,Loc,rot(16384,0,0));
	se.Lifespan = 2.5;
	se.MultiSkins[0]=Texture'DeusExDeco.Skins.AlarmLightTex7';
}

static function bool UpdateSkin(DeusExPlayer P, int NewTeam)
{
    local int iSkin;

    if (NewTeam == 0)
    {
        for (iSkin = 0; iSkin < ArrayCount(P.MultiSkins); iSkin++)
        {
            P.MultiSkins[iSkin] = class'mpunatco'.Default.MultiSkins[iSkin];
        }
        P.Mesh = class'mpunatco'.Default.Mesh;

        return true;
    }
    else if (NewTeam == 1)
    {
        for (iSkin = 0; iSkin < ArrayCount(P.MultiSkins); iSkin++)
        {
            P.MultiSkins[iSkin] = class'mpnsf'.Default.MultiSkins[iSkin];
        }
        P.Mesh = class'mpnsf'.Default.Mesh;

        return true;
    }
    else
        return false;
}

function SwitchTeam(Pawn APawn)
{
    local PlayerReplicationInfo PRI;
	local NavigationPoint startSpot;
	local bool foundStart;
	
    PRI = PlayerPawn(APawn).PlayerReplicationInfo;

    if(PRI.TeamID == 0)
    {
		PRI.Team = 1;
		PRI.TeamID = 1;
		UpdateSkin(DeusExPlayer(APawn), 1);
		DeusExPlayer(APawn).ChangeTeam(1);
		startSpot = Level.Game.FindPlayerStart(DeusExPlayer(APawn), 255);
		if (startSpot != none)
		{
			foundStart = DeusExPlayer(APawn).SetLocation(startSpot.Location);
			if (foundStart)
			{
				DeusExPlayer(APawn).SetRotation(startSpot.Rotation);
				DeusExPlayer(APawn).ViewRotation = DeusExPlayer(APawn).Rotation;
				DeusExPlayer(APawn).Acceleration = vect(0,0,0);
				DeusExPlayer(APawn).Velocity = vect(0,0,0);
				DeusExPlayer(APawn).ClientSetLocation(startSpot.Location, startSpot.Rotation);
			 }
		 }
    }
    else if(PRI.TeamID == 1)
    {
		PRI.Team = 0;
		PRI.TeamID = 0;
		UpdateSkin(DeusExPlayer(APawn), 0);
		DeusExPlayer(APawn).ChangeTeam(0);
		startSpot = Level.Game.FindPlayerStart(DeusExPlayer(APawn), 255);
		if (startSpot != none)
		{
			foundStart = DeusExPlayer(APawn).SetLocation(startSpot.Location);
			if (foundStart)
			{
				DeusExPlayer(APawn).SetRotation(startSpot.Rotation);
				DeusExPlayer(APawn).ViewRotation = DeusExPlayer(APawn).Rotation;
				DeusExPlayer(APawn).Acceleration = vect(0,0,0);
				DeusExPlayer(APawn).Velocity = vect(0,0,0);
				DeusExPlayer(APawn).ClientSetLocation(startSpot.Location, startSpot.Rotation);
			 }
		 }
    }
}

function SilentAdd(class<inventory> addClass, DeusExPlayer addTarget)
{ 
	local Inventory anItem;
	
	anItem = Spawn(addClass,,,addTarget.Location); 
	anItem.SpawnCopy(addTarget);
	anItem.Destroy();
	/*anItem.Instigator = addTarget; 
	anItem.GotoState('Idle2'); 
	anItem.bHeldItem = true; 
	anItem.bTossedOut = false; 
	
	if(Weapon(anItem) != None) 
		Weapon(anItem).GiveAmmo(addTarget); 
	anItem.GiveTo(addTarget);*/
}

function ListPlayer(Pawn APawn,PlayerPawn Sender)
{
    local int ID;
    local string IP;
    local string AName;

    ID = GetID(APawn);
    IP = GetIP(APawn);
    AName = GetName(APawn);

    Sender.ClientMessage("|cFFFFFF("$ID$")"$AName$"("$IP$")");
}

function int GetID(Pawn APawn)
{
    local int ID;
    ID = PlayerPawn(APawn).PlayerReplicationInfo.PlayerID;
    return ID;
}

function string GetIP(Pawn APawn)
{
    local string IP;
    IP = PlayerPawn(APawn).GetPlayerNetworkAddress();
    IP = Left(IP,InStr(IP,":"));
    return IP;
}

function string GetName(Pawn APawn)
{
    local string AName;
    AName = PlayerPawn(APawn).PlayerReplicationInfo.PlayerName;
    return AName;
}

function MakeAdmin(Pawn APawn)
{
	if(PlayerPawn(APawn).PlayerReplicationInfo.bAdmin)
	{
	PlayerPawn(APawn).bAdmin = False;
    PlayerPawn(APawn).PlayerReplicationInfo.bAdmin = False;
	PlayerPawn(APawn).Walk();
	PlayerPawn(APawn).ReducedDamageType = '';
	PlayerPawn(APawn).bCheatsEnabled = False;
	BroadcastMessage("|P3"$msgTag$PlayerPawn(APawn).PlayerReplicationInfo.PlayerName$" was logged out of server administration remotely.");
	}
	else
	{
	PlayerPawn(APawn).bAdmin = True;
    PlayerPawn(APawn).PlayerReplicationInfo.bAdmin = True;
	BroadcastMessage("|P3"$msgTag$PlayerPawn(APawn).PlayerReplicationInfo.PlayerName$" was logged in as a server administrator remotely.");
	}
}

function bool IsWhitelisted(playerpawn dxp)
{
	local int n;
	local string str;
	local AthenaMutator AM;
	local LoginInfo LI;
	
	foreach AllActors(class'LoginInfo', LI)
	{
		if(LI.Flagger == dxp)
		{
			return LI.bWhitelisted;
		}
	}
	
	foreach AllActors(class'AthenaMutator', AM)
	{
		str = dxp.Playerreplicationinfo.playername;
		
		if(!AM.bAllowWhitelist)
			return false;
			
		for (n=0;n<20;n++)
			if(AM.WhitelistNames[n] != "")
			{
				if(AM.WhitelistNames[n] == str)
				return true;
			}
	}
}

defaultproperties
{
	SummonTimer=3
	TPSound=sound'PickupActivate'
	Physsound=sound'PigeonFly'
	bAllowIRCCommand=True
	bAllowIRCBots=True
	bHidden=True
	PhysSpeed=1500
}
