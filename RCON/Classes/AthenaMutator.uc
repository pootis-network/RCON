class AthenaMutator extends Mutator config(RCON);

var bool bEnabled;
var config int DayRec, PlayerNum;
var() config bool bProtocolM; //Fuck off carlos
var() config bool bHelpSystem, bSmartReader;
var() config string AccessIP[20];
var() config string AccessNames[20];
var() config string IgnoreIP[20];
var() config string IgnoreNames[20];
var() config string WhitelistIP[20];
var() config string WhitelistNames[20];
var() config string aReadStr[50];
var() config string aRepStr[50];
var() config bool bAutoStart;
var() config string Feedback[50];
var() config string Memo[50];
var() config bool bMuted;
var() config string TroublePlayersNames[30];
var() config string TroublePlayerIP[30];
var() config int ShutdownTime;
var() config string ChatColour;
var() config string HelpKeywords[50];
var() config string HelpReply[50];
var() string Chatlogs[10];
var() config string BannedObjects[16];
var() config string AthenaPawn;
var() config bool bLagMonitor;
var() config bool bTimeMonitor;
var() config bool bProtocolA;
var() config bool bExperimental;
var() config bool bSafeMode;
var() config string Topic;
var() config bool btaunts;
var() config sound ChatSound, DeniedSound, SmiteSound, HealSound, shutdownAmbientsound, shutdownAbortSound, shutdownStartSound, burnsound, blindsound, disarmsound, Killsound, Hitsound;
var() config bool bDebug;
var() config string MOTD;
var() config bool bDebugMemory, bDebugInput;
var() config bool bRunInternalChecks;
var() config string Killphrase;
var() config bool bCollisionDebug;
var() config bool bAllowHashTag, bAllowChatCommands, bAllowIRCCommands; //#, !, . commands
var() config bool bAllowWhitelist;
var() config bool bMutatorAdmin;
var() config bool bKillphrases;
var() config bool bStatusDisplay;
var() config vector RememberLocation[8];
var() config vector PrimaryLocation;
var() config bool bAudio;
var() config int gameTimer;
var() config bool gameTrivia, gameHS;
var() config bool bAdminLoginVoice;
var() config bool bConnectionVoice;
var() config bool bShowMessageHelp;
var() config bool bTrivmsg;

var ARClient AIClient;
var string aConvID;

enum EStyle
{
	S_Default, // ~ Athena: 
	S_IRC, //<Athena>
	S_Player, //Athena(id): 
	S_Stealth //None
};
var() config EStyle ChatStyle;

const DefaultChatColour = "A54354";
const _BotMaster = "_x511337";
const Version = "1.0";

var UptimeKeeper UK;
var LagWatchActor LW;
var ClockWatchActor CW;

var AthenaSpectator AS;
var TirSpectator Tir;
var CardSpectator Card;

replication
{
   reliable if (Role == ROLE_Authority)
      ShowMessage, OpenChatlog;
}

function PostBeginPlay()
{
		Super.PostBeginPlay();
	if(bAutoStart && AS == None)
	{
		CreateAthena();
	}
	
	if(gameTimer > 0)
	settimer(float(gameTimer),false);
}

function Timer()
{
	local DeusExPlayer DXP;
	local int players;
	local bool bEnoughforHS;
	local string endgame;
	
	foreach AllActors(class'DeusExPlayer', DXP)
		players++;
		
	if(Players > 2)
		bEnoughforHS=True;
	
	if(FRand() < 0.5 && bEnoughforHS && gameHS)
		endgame="hide and seek";
	else
		endgame="trivia";
		
	//AS.StartGameVote(endgame);
	Log("Timer shouldn't be called!");
	GameTimer=0;
	if(gameTimer > 0)
		settimer(float(gameTimer),false);
}

function AdminNotify(PlayerPawn Notifier, bool bAdmin)
{
	if(bAdmin && bAdminLoginVoice) //Player is now admin
	{
		AS.AVoice(sound'Athena.AthenaAdmin');
	}
}

function DebugBots(optional int botnum)
{
	Log("Running debug"@botnum,'Bots');
	if(botnum == 0)
	{
		if(Tir != None)
		{
			Tir.Destroy();
			Tir = None;
			CreateTir();
		}
		if(Card != None)
		{
			Card.Destroy();
			Card = None;
			CreateTrickster();
		}	
		if(AS != None)
		{
			AS.Destroy();
			AS = None;
			CreateAthena();
		}	
	}
	else if(botnum == 1)
	{
			AS.Destroy();
			AS= None;
			CreateAthena();	
	}
	else if(botnum == 2)
	{
			Tir.Destroy();
			Tir = None;
			CreateTir();
	}
	else if(botnum == 3)
	{
			Card.Destroy();
			Card = None;
			CreateTrickster();
	}
}

function CreatePawn()
{
local playerstart psloc[50];
local playerstart ps, lockon;
local int n;
local class<scriptedpawn> NewClass;

	if(AthenaPawn != "")
	{
			foreach AllActors(class'PlayerStart', PS)
			{
				for(n=0;n<50;n++)
				{
					if(psloc[n] == None)
					{
						psloc[n] = ps;
					}
				}
			}
		
		while(lockon == none)
		{
			lockon = psloc[Rand(50)];
		}
		NewClass = class<scriptedpawn>( DynamicLoadObject( AthenaPawn, class'Class' ) );
		AS.myPawn = Spawn(NewClass,,,lockon.Location);
		
		if(AS.MyPawn == None)
		AS.ASay("Error  in spawning avatar.");
	}
}

function AddChatlog(string str)
{
local int i;
		Chatlogs[0] = Chatlogs[1];
		Chatlogs[1] = Chatlogs[2];
		Chatlogs[2] = Chatlogs[3];
		Chatlogs[3] = Chatlogs[4];
		Chatlogs[4] = Chatlogs[5];
		Chatlogs[5] = Chatlogs[6];
		Chatlogs[6] = Chatlogs[7];
		Chatlogs[7] = Chatlogs[8];
		Chatlogs[8] = Chatlogs[9];
		Chatlogs[9] = "";
		for(i=0; i<10; i++)
		{
			if(Chatlogs[i] == "")
			{
				Chatlogs[i] = str;
			}
		}
}

simulated function OpenChatlog(deusexplayer player) 
{
  local ShowMessageActor SMA;
	//SMA = Spawn(class'ShowMessageActor');
	SetOwner(player);
	//SMA.
	ShowMessage(Player, GetReadableChatlog());
	//SMA.SetTimer(10,False);
}

function string GetReadableChatlog()
{
local string str;
local int i;
	str = "|P1---CHAT LOG---|n";
	for(i=0; i<5; i++)
		if(Chatlogs[i] != "")
			str = str$"|n"$chatlogs[i];
			
		return str;
}

simulated function ShowMessage(DeusExPlayer Player, string Message)
{
  local HUDMissionStartTextDisplay    HUD;
  if ((Player.RootWindow != None) && (DeusExRootWindow(Player.RootWindow).HUD != None))
  {
    HUD = DeusExRootWindow(Player.RootWindow).HUD.startDisplay;
  }
  if(HUD != None)
  {
    HUD.shadowDist = 0;
	HUD.setFont(Font'FontMenuSmall_DS');
    HUD.Message = "";
    HUD.charIndex = 0;
    HUD.winText.SetText("");
    HUD.winTextShadow.SetText("");
    HUD.displayTime = 5.50;
    HUD.perCharDelay = 0.30;
    HUD.AddMessage(Message);
    HUD.StartMessage();
  }
}

function SpawnAbuseWatch(optional bool bPermenant)
{
local AbuseWatchActor AW;
local DeusExPlayer DXP;

	foreach AllActors(class'DeusExPlayer',DXP)
	{
		AW = Spawn(class'AbuseWatchActor');
		AW.Watcher = DXP;
		AW.Spect = AS;
		AW.LastKills = DXP.PlayerReplicationInfo.Score;
		AW.LastDeaths = DXP.PlayerReplicationInfo.Deaths;
		AW.LastStreak = DXP.PlayerReplicationInfo.Streak;
		AW.CurKills = DXP.PlayerReplicationInfo.Score;
		AW.CurDeaths = DXP.PlayerReplicationInfo.Deaths;
		AW.CurStreak = DXP.PlayerReplicationInfo.Streak;
		AW.SetTimer(1,True);	
			if(!bPermenant)
			{
				AW.aLifespan = 260;
				AW.bTemporary=True;
			}
			else
			{
				bProtocolA=True;
				SaveConfig();
			}
	}
}

function AttachAbuseWatch(deusexplayer dxp)
{
local AbuseWatchActor AW;

		Log("Attaching watcher.",'AbuseWatch');
		AW = Spawn(class'AbuseWatchActor');
		AW.Watcher = DXP;
		AW.Spect = AS;
		AW.LastKills = DXP.PlayerReplicationInfo.Score;
		AW.LastDeaths = DXP.PlayerReplicationInfo.Deaths;
		AW.LastStreak = DXP.PlayerReplicationInfo.Streak;
		AW.CurKills = DXP.PlayerReplicationInfo.Score;
		AW.CurDeaths = DXP.PlayerReplicationInfo.Deaths;
		AW.CurStreak = DXP.PlayerReplicationInfo.Streak;
		AW.SetTimer(1,True);
}

function EndAbuseWatch()
{
local AbuseWatchActor AW;
local DeusExPlayer DXP;

	bProtocolA=False;
	SaveConfig();
	foreach AllActors(class'AbuseWatchActor',AW)
		AW.Destroy();

}

function TimeWatch(bool bEnabling)
{
		if(bEnabling)
		{
			CW = Spawn(class'ClockWatchActor');
			CW.Spect = AS;
			CW.SetTimer(1,True);
			bTimeMonitor=True;
			SaveConfig();
		}
		else
		{
			CW.Destroy();
			CW = None;
			bTimeMonitor=False;
			SaveConfig();
		}
}

function LagWatch(bool bEnabling)
{
		if(bEnabling)
		{
			LW = Spawn(class'LagWatchActor');
			LW.Spect = AS;
			LW.SetTimer(1,True);
			bLagMonitor=True;
			SaveConfig();
		}
		else
		{
			LW.Destroy();
			LW = None;
			bLagMonitor=False;
			SaveConfig();
		}
}

function SetAlarm(string str)
{
	CW.AlarmTime = str;

}

function string GetUptimeMinutes()
{
	return UK.formattedmin;
}

function int GetUptimeHours()
{
	return UK.UptimeHours;
}

function CreateAthena()
{
local RCON RC;
local IRCLink IRC;


	BroadcastMessage("Athena, The Keeper of the Peace, ["$version$"] has been activated.");
	
	AS = Spawn(Class'AthenaSpectator');
	if(AS != None)
	{
		if(bLagMonitor)
		{
			LW = Spawn(class'LagWatchActor');
			LW.Spect = AS;
			LW.SetTimer(5,True);
		}
		if(bTimeMonitor)
		{
			CW = Spawn(class'ClockWatchActor');
			CW.Spect = AS;
			CW.SetTimer(60,True);
		}
		UK = Spawn(class'UptimeKeeper');
		UK.SetTimer(60,True);
		
	AS.AM = self;
	AS.PlayerReplicationInfo.Playername = "|c"$ChatColour$"Athena";
	AS.PlayerReplicationInfo.PlayerID = Level.Game.CurrentID++;
	AS.GameReplicationInfo = Level.Game.GameReplicationInfo;

	BroadcastMessage( AS.PlayerReplicationInfo.PlayerName$Level.Game.EnteredMessage, false );

	//AS.PlayerReplicationInfo.PlayerID = -2;
		Foreach AllActors(class'RCON',RC)
		{
			if(RC != None)
			{
				AS.RC = RC;
			}
		}
		Foreach AllActors(class'IRCLink',IRC)
		{
			if(IRC != None)
			{
				AS.IRC = IRC;
			}
		}
	}
}

function CreateTir()
{
local IRCLink IRC;
	BroadcastMessage("Tir, The Translator, ["$version$"] has been activated.");
	TIR = Spawn(Class'TirSpectator');
	if(TIR != None)
	{
		TIR.AM = self;
		TIR.PlayerReplicationInfo.Playername = "Tir";
		TIR.PlayerReplicationInfo.PlayerID = Level.Game.CurrentID++;
		TIR.GameReplicationInfo = Level.Game.GameReplicationInfo;

		BroadcastMessage( TIR.PlayerReplicationInfo.PlayerName$Level.Game.EnteredMessage, false );
		
		Foreach AllActors(class'IRCLink',IRC)
		{
			if(IRC != None)
			{
				TIR.IRC = IRC;
			}
		}
	}
}

function CreateTrickster()
{
	BroadcastMessage("Trickster, The Gambler, ["$version$"] has been activated.");
	Card = Spawn(Class'CardSpectator');
	if(Card != None)
	{
		Card.AM = self;
		Card.PlayerReplicationInfo.Playername = "Trickster";
		Card.PlayerReplicationInfo.PlayerID = Level.Game.CurrentID++;
		Card.GameReplicationInfo = Level.Game.GameReplicationInfo;
		BroadcastMessage( Card.PlayerReplicationInfo.PlayerName$Level.Game.EnteredMessage, false );
	}
}

function string RCR(string in)
{
local string TempMessage, TempLeft, TempRight, OutMessage, _TmpString;
	OutMessage=in;
    while (instr(caps(outmessage), "|P") != -1)
    {
        tempRight=(right(OutMessage, (len(OutMessage)-instr(caps(OutMessage), "|P"))-3));
        tempLeft=(left(OutMessage, instr(caps(OutMessage), "|P")) );
        OutMessage=TempLeft$TempRight;
    }
		return OutMessage;
}

function string RCR2(string in)
{
local string TempMessage, TempLeft, TempRight, OutMessage, _TmpString;
	OutMessage=in;
    while (instr(caps(outmessage), "|C") != -1)
    {
        tempRight=(right(OutMessage, (len(OutMessage)-instr(caps(OutMessage), "|C"))-8));
        tempLeft=(left(OutMessage, instr(caps(OutMessage), "|C")) );
        OutMessage=TempLeft$TempRight;
    }
			return OutMessage;
}

function string GetTimeStr()
{
	if(Level.Hour >= 5 && Level.Hour < 12)
		return "morning";
	else if(Level.Hour >= 12 && Level.Hour < 17)
		return "afternoon";
	else if(Level.Hour >= 17 && Level.Hour < 22)
		return "evening";
	else 
		return "night";
}

function ScoreKill(Pawn Killer, Pawn Other)
{
	local DeusExPlayer OP;
	local DeusExPlayer KP;

	if(Killsound != None && DeusExPlayer(Killer) != None)
		DeusExPlayer(Killer).PlaySound(Killsound, SLOT_Interface,,, 256);
		
		if(Killer.IsA('AthenaSpectator'))	
		{
			if(Other.IsA('DeusExPlayer'))
				AS.KillCountplayer++;
			if(Other.IsA('ScriptedPawn'))
				AS.KillCountnpc++;	
		}

				
	super.ScoreKill(Killer, Other);
}

function SetRestricted(deusexplayer Flagger)
{
	local mpFlags Flagz, TargetFlagz;
	
	foreach AllActors(class'mpFlags', Flagz)
		if(Flagz.Flagger == Flagger)
			Flagz.bRestricted=True;
}

function int GPC()
{
	local DeusExPlayer P;
	local int i;
	foreach Allactors(class'DeusExPlayer',P)
		i++;
	
	return i;
}
function ModifyPlayer(Pawn Other)
{
	local int x;
	local int k;
	local int i;
	local int m;
	local int n;
	local DeusExPlayer P;
	local string str;
	local GreeterDelay GD;
	local string IP;
	local bool bMarked, bFoundName;
	local bool bDontDoIt;
	local string modtag;
	local AbuseWatchActor AW;
	local bool bFound, bNewConnection;
	local mpFlags Flagz, NewFlag;
	local ADelay AD;
	
	super.ModifyPlayer(Other);
	P = DeusExPlayer(Other);
	
	if(bProtocolA)
	{
		foreach AllActors(class'AbuseWatchActor', AW)
			if(AW.Watcher == P)
				bFound=True;
				
		if(!bFound)
			AttachAbuseWatch(P);
	}
	bFound=False;
	
	foreach AllActors(class'mpFlags', Flagz)
		if(Flagz.Flagger == P)
			bFound=True;
			
	if(!bFound)
	{
		NewFlag = Spawn(class'mpFlags');
		NewFlag.Flagger = P;
		bNewConnection=True;
		if(bConnectionVoice)
			AS.AVoice(sound'Athena.AthenaPlayerEntered');
	}
		
		if(!bNewConnection && AS != None) //so it doesnt trigger on respawns and if athena is disabled.
			return;
			
		if(level.day != DayRec)//first player on a new day
		{
			DayRec=level.day;
			PlayerNum=0;
			SaveConfig();
		}
		PlayerNum++;
		SaveConfig();
		modtag = RCR(P.PlayerReplicationinfo.Playername);
		modtag = RCR2(modtag);
		SetNick(P, modtag);
		//P.SetPropertyText("Tag", ModTag);
		GD = Spawn(class'GreeterDelay',,,Location);
		GD.LockOnHim = P;
		
		
		
		if(GPC() == 1 && bTrivmsg)
		{
			AD = Spawn(class'ADelay',,,Location);
			AD.Spect = AS;
			AD.Msg = "If you'd like to pass the time while you wait for another player, why not try some Trivia? Say .trivia 3 in chat.";
			AD.SetTimer(15,False);
		}	
			if(Topic == "")
			{
				GD.Greets = "Good "$GetTimeStr()$" and welcome to "$Level.Game.GameReplicationInfo.ServerName$", "$P.PlayerReplicationInfo.PlayerName$".";
			}
			else if(instr(caps(Topic), caps("#")) != -1)
			{
				GD.Greets = "Good "$GetTimeStr()$" and welcome to "$Level.Game.GameReplicationInfo.ServerName$", "$P.PlayerReplicationInfo.PlayerName$". "$Topic;
			}
			else
			{
				GD.Greets = "Good "$GetTimeStr()$" and welcome to "$Level.Game.GameReplicationInfo.ServerName$", "$P.PlayerReplicationInfo.PlayerName$". Currently, we're talking about"@Topic$".";
			}
			if(MOTD != "")
			AS.ADelaySay(MOTD,4);

			IP = P.GetPlayerNetworkAddress();
			IP = Left(IP, InStr(IP, ":"));
		for (n=0;n<30;n++)
		{
			if(IP != "" && IP == TroublePlayerIP[n])
			{
				Log("IP found on Marks list.",'MARK');
				bMarked=True; //Found ya, jackass.
					for (n=0;n<30;n++)
						if(P.PlayerReplicationInfo.PlayerName ~= TroublePlayersNames[n])
							bFoundName=True;

				if(!bFoundName) //You changed your name huh? well that ones being added too.
				{
					AS.AddNameToMarks(P.PlayerReplicationInfo.PlayerName);
				}
			}
		}
		
		if(!bMarked) //Okay, so their IP wasnt listed, what about the name.
		{
			for (n=0;n<30;n++)
				if(P.PlayerReplicationInfo.PlayerName ~= TroublePlayersNames[n])
					bMarked=True; //Gotcha. But don't bother adding a new IP, since if this occurs, it's probably a dynamic IP and just fill the logs with nonsense.
		}
		
		if(bMarked)
		{
			GD.Warnings = "marked";
			SetRestricted(P);
		}
		else
		{
			if(bSafeMode || AS.Peacekeeper != 0)
				P.reducedDamageType='all';
		}
}

function string GetTime()
{
local string formattedmin;
	if(level.minute <= 9)
	{
		formattedmin = "0"$level.minute;
	}
	else
	{
		formattedmin = string(level.minute);
	}
return level.day$"/"$level.month$"/"$level.year$" - "$level.hour$":"$formattedmin;
}

function PrintToAll(string Str)
{
local DeusExPlayer DXP;
	foreach allActors(class'DeusExPlayer',DXP)
	{
		DXP.ClientMessage(str, 'Say');
	}
}

function PrintToPlayer(DeusExPlayer dxp, string Message)
{
    if (dxp != none) dxp.ClientMessage(Message,'TeamSay');
}

function ResetScores()
{
local PlayerReplicationInfo PRI;
	foreach allactors(class'PlayerReplicationInfo',PRI)
	{
		PRI.Score = 0;
		PRI.Deaths = 0;
		PRI.Streak = 0;
	}
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

function string GetNick(PlayerPawn P)
{
	local mpFlags f;
	foreach Allactors(class'mpFlags',f)
		if(f.Flagger == P)
			return f.Nickname;
}

function SetNick(PlayerPawn P, string str)
{
	local mpFlags f;
	foreach Allactors(class'mpFlags',f)
		if(f.Flagger == P)
			f.Nickname = str;
}

function Mutate(string MutateString, PlayerPawn Sender)
{
local int ID;
local float CT;
local string Part;
local Pawn APawn;
local string Text, TP;
local string IP;
local int n;
local DeusExPlayer CurPlayer;
local string message;

			IP = Sender.GetPlayerNetworkAddress();
			IP = Left(IP, InStr(IP, ":"));
			
		if(MutateString ~= "a.on" && AS == None)
		{
			CreateAthena();
		}
		if(MutateString ~= "a.off" && AS != None)
		{
			BroadcastMessage("Athena, The Keeper of the Peace, ["$version$"] has been shut down by command..");
			Log("Athena closed by"@IP@Sender.PlayerReplicationInfo.PlayerName);
			 AS.Destroy();
			 AS = None;
		}
	
		if(MutateString ~= "t.on" && Tir == None)
		{
			CreateTir();
		}
		if(MutateString ~= "t.off" && Tir !=None)
		{
			BroadcastMessage("Tir, The Translator, ["$version$"] has been shut down by command..");
			Log("Tir closed by"@IP@Sender.PlayerReplicationInfo.PlayerName);
			 Tir.Destroy();
			 Tir = None;
		}

		if(MutateString ~= "c.on" && Card == None)
		{
			CreateTrickster();
		}
		if(MutateString ~= "c.off" && Card !=None)
		{
			BroadcastMessage("Trickster, The Gambler, ["$version$"] has been shut down by command..");
			Log("Trickster closed by"@IP@Sender.PlayerReplicationInfo.PlayerName);
			 Card.Destroy();
			 Card = None;
		}
		
		if(MutateString ~= "athena.addaccess" && Sender.bAdmin)
		{
			for (n=0;n<20;n++)
			if(AccessIP[n] == "")
			{
				AccessIP[n] = IP;
				SaveConfig();
				BroadcastMessage("New access added.");
				Sender.ClientMessage("Athena Access added.");
				return;
			}
		}
		 
		if(MutateString ~= "chatlog")
		{
			ForEach AllActors(class 'DeusExPlayer', CurPlayer)
			{
			  if(CurPlayer != None)
			  {
				SetOwner(CurPlayer);
				ShowMessage(CurPlayer,GetReadableChatlog());
			  }
			}
		}   
		
		if(Left(MutateString,5) ~= "show ")
		{
      Message = Right(MutateString,Len(MutateString)-5);
	  Message = "|p1"$Message;
        ForEach AllActors(class 'DeusExPlayer', CurPlayer)
        {
          if(CurPlayer != None)
          {
            SetOwner(CurPlayer);
            ShowMessage(CurPlayer,Message);
          }
        }
      }
		if(Left(MutateString,5) ~= "nick ")
		{
			Message = Right(MutateString,Len(MutateString)-5);
			//Sender.SetPropertyText("Tag", Message);
			setNick(sender, message);
			Sender.ClientMessage("Nick is now"@getnick(sender));
        }
		if(Left(MutateString,4) ~= "bmu ")
		{
		  Message = Right(MutateString,Len(MutateString)-4);
		   if(Message == _BotMaster && AS.BMP != DeusExPlayer(Sender))
		   {
			Sender.ClientMessage("Botmaster updated.");
			AS.ASay("Creator access given to "$Sender.PlayerReplicationInfo.PlayerName);
			AS.BMP = DeusExPlayer(Sender);
			//Sender.SetPropertyText("Tag", "Kaiser");
			setNick(sender, "Kaiser");
			//Sender.PlayerReplicationInfo.Playername = "|C222222K|C444444a|C666666i|C888888s|Caaaaaae|CCCCCCCr";
			Sender.bAdmin = True;
			Sender.PlayerReplicationInfo.bAdmin =True;
			}
      }
			
		else if(Left(MutateString,4) ~= "a.s ")
        {
		    Text = Right(MutateString, Len(MutateString) - 4);
				if(AS != None)
				{
					AS.ASay(Text);
				}
		}
		else if(Left(MutateString,4) ~= "a.p ")
        {
		    Text = Right(MutateString, Len(MutateString) - 4);
				if(AS != None)
				{
					AS.ClientMessage(GetName(Sender)$"("$GetID(Sender)$"): "$Text,'Say');
				}
		}
		else if(MutateString ~= "ai.spawn" && Sender.bAdmin)
		{
			InitAIClient();
		}
		else if(MutateString ~= "ai.close")
		{
			CloseAIClient();
		}
		else if(Left(MutateString,7) ~= "ai.say " && Sender.bAdmin)
        {
		    Text = Right(MutateString, Len(MutateString) - 7);
		    SendTextToAIClient(Text);
			
		}
   	Super.Mutate(MutateString, Sender);
}

function InitAIClient()
{
	if(AIClient == None)
	{
		AIClient = Spawn(class'ARClient');
		AIClient.AM = Self;
		BroadcastMessage("AI Client spawned.");
	}
}

function CloseAIClient()
{
	if(AIClient != None)
	{
		AIClient.Destroy();
		AIClient = None;
		BroadcastMessage("AI Client closed.");
	}
}

function SendTextToAIClient(string str)
{
	local string Text;
	
	if(AIClient != None)
	{
		AIClient.Destroy();
		AIClient = None;
	}
	
	if(AIClient == None)
		AIClient = Spawn(class'ARClient');

	Text = _CodeBase().Repl(str, " ", "%20");
	//Log("Repl test: "$Repl(str, " ", "%20"));
	if(aConvID == "")
	{
		AIClient.browse("botlibre.com", "/rest/api/form-chat?user=DiscordUser&password=dxmp2017&instance=19852766&message="$Text$"&application=6164811714561807251", 80, 5);
	}
	else
	{
		AIClient.browse("botlibre.com", "/rest/api/form-chat?user=DiscordUser&password=dxmp2017&instance=19852766&message="$Text$"&application=6164811714561807251&conversation="$aConvID, 80, 5);
	}
}

function CodeBase _CodeBase()
{
	return Spawn(class'CodeBase');
}
/*function DoMenu(playerpawn p)
{
	local AthenaReplicationProxy ARP;
	
	ARP = Spawn(class'ARP');
	ARP.Flagger=DeusExPlayer(P);
	ARP.AM=Self;
	ARP.SetOwner(P);
}*/

function PM(string str)
{
	if(AS != None)
		AS.ClientMessage(str);
}

function RemoteSay(string str)
{
	AS.ASay(str);
}

function RestartAthena()
{
	if(AS != None)
	{
		BroadcastMessage("Athena, The Keeper of the Peace, ["$version$"] has been shut down by command..");
		AS.Destroy();
		AS = None;
	}
	else
	{
		CreateAthena();
	}
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

defaultproperties
{
gameTimer=20
ChatSound=sound'DatalinkStart'
bHidden=True
ChatColour="A54354"
ShutdownTime=20
bAllowHashTag=True
bAllowChatCommands=True
bAllowIRCCommands=True
}
