//=============================================================================
// Spectator.
//=============================================================================
class AthenaSpectator extends MessagingSpectator;

var AthenaMutator AM;
var IRCLink IRC;
var SM SMMut;

var bool bCheckingAuth;
var DeusExPlayer CheckAuthPlayer;
var string AuthPlayerName;
var string StoredCommand;
var bool bPublicCommand;
var string storedrep;
var string RememberName;
var DeusExPlayer RememberPlayer;
var bool bInitBroadcast;
var bool bPassed;
var bool bHurryUp;
var string RememberString;
var int rememberint;
var string ignorename;
var deusexplayer ignoreplayer;
var scriptedpawn RememberScriptedPawn;
var bool bIRCStr;
var SDActor SDA;
var RCON RC;
var string LastCommand;
var bool bLastCommandAuth;
var string LastRemStr, LastRemName;
var deusexplayer LastRemPlayer;
var scriptedpawn LastRemSP;
var int lastremint;
var string Chatlogs[26];
var bool bGettingHelp;
var deusexplayer BMP;
var scriptedpawn myPawn;
var string Sendtypepublic;
var string Sender;
var int Peacekeeper;
var string rememberhelp;
var int killcountnpc, killcountplayer;
var string storedLines[10];
var string qstr;
var bool bCheckingWhitelist;

#exec obj load FILE=Ambient

function Tick(float deltatime)
{
	if(AM.bRunInternalChecks)
	{
		if(Self.Playerreplicationinfo == None)
		{
			BroadcastMessage("|P2INTERNAL ERROR: Athena server replication not found. Restarting spectator.");
			AM.DebugBots(1);
		}
	}
}

function Killme()
{
	local AthenaMutator AM;
	foreach Allactors(class'AthenaMutator', AM)
	{
		AM.Killphrase = generateRandStr(4);
		AM.AS = None;
		Destroy();
		BroadcastMessage("Athena closed by killphrase.");
	}
}

function ASay(string str, optional bool bAdminOnly)
{
local DeusExPlayer DXP;
local string NameStr;
  local MessagingSpectator MS;

	if(AM.bMuted)
		return;
		
	if(AM.ChatStyle == S_Default)
		NameStr = "|c"$AM.ChatColour$" ~ Athena: ";
	else if(AM.ChatStyle == S_IRC)
		NameStr = "|P1<|c"$AM.ChatColour$"Athena|P1>|c"$AM.ChatColour$" ";
	else if(AM.ChatStyle == S_Player)
		NameStr = "|c"$AM.ChatColour$"Athena("$self.PlayerReplicationInfo.PlayerID$"): ";
	
	if(bAdminOnly)
	{
		foreach AllActors(class'DeusExPlayer', DXP)
		{
			if(DXP.bAdmin)
				DXP.ClientMessage("[ADMIN] "$nameStr$str,'TeamSay');
			else
				DXP.ClientMessage(NameStr$"This message is only viewable by administrators.",'TeamSay');
		}
		return;
	}
	//BroadcastMessage(NameStr$str);
	
	foreach AllActors(class'DeusExPlayer',DXP)
	{
		if(AM.ChatSound == None)
			AM.ChatSound = sound'DatalinkStart';
		
		if(AM.ChatStyle != S_Player)
		{
			DXP.PlaySound(AM.ChatSound, SLOT_Interface,,, 256);
			DXP.ClientMessage(NameStr$str);
		}
		else
			DXP.ClientMessage(NameStr$str,'Say');
	}
	
	foreach AllActors(class'MessagingSpectator', MS)
	{
		if(string(ms.Class) ~= "dxtelnetadmin.telnetspectator" || string(ms.Class) ~= "rcon.spec")
		{
			ms.ClientMessage(NameStr$str,'Say');
		}
	}
	AM.AddChatlog(NameStr$str);
	Log(str,'Athena');
}

function AVoice(sound Playsound, optional DeusExPlayer Target)
{
	local DeusExPlayer DXP;
	local mpFlags Flagz, TargetFlags;
	
	if(!AM.bAudio)
		return;
	foreach AllActors(class'mpFlags', Flagz)
		if(Flagz.Flagger == Target)
			TargetFlags = Flagz;
			
	if(Target != None)
	{
		if(TargetFlags != None)
			if(TargetFlags.bMuteAthena)
				return;
		Target.PlaySound(PlaySound,,,, 256);
	}	
	else
	{
		foreach AllActors(class'DeusExPlayer', DXP)
			DXP.PlaySound(PlaySound,,,, 256);
	}
}

function ASayPrivate(deusexplayer dxp, string str, optional bool bBuzzah)
{
local string NameStr;
	if(AM.ChatStyle == S_Default)
		NameStr = "|c"$AM.ChatColour$" ~ Athena: ";
	else if(AM.ChatStyle == S_IRC)
		NameStr = "|P1<|c"$AM.ChatColour$"Athena|P1>|c"$AM.ChatColour$" ";
	else if(AM.ChatStyle == S_Player)
		NameStr = "|c"$AM.ChatColour$"Athena("$self.PlayerReplicationInfo.PlayerID$"): ";
	
	if(bBuzzah)
	dxp.ClientMessage("[PRIVATE] "$NameStr$str,'Teamsay');
	else
	dxp.ClientMessage("[PRIVATE] "$NameStr$str);
	
	Log("[PRIVATE: "$GetName(DXP)$"] "$str,'Athena');
}

function AStatus(string str)
{
	if(str == "")
	Self.PlayerReplicationInfo.PlayerName = "|c"$AM.ChatColour$"Athena";
	else
	Self.PlayerReplicationInfo.PlayerName = "|c"$AM.ChatColour$"Athena ["$str$"]";
}

function string generateRandHex()
{
  local int i;
  local string UID;

  for(i=0; i<7; i++)
  {
    if(FRand() < 0.5)
      UID = UID$string(Rand(9));
    else
      UID = UID$GetHex();
  }
  return Left(UID, 6);
}

function string GetHex()
{
local int i;
	if(FRand() < 0.2)
		return "a";
	else if(FRand() >= 0.2 && FRand() < 0.4)
		return "b";
	else if(FRand() >= 0.4 && FRand() < 0.6)
		return "c";
	else if(FRand() >= 0.6 && FRand() < 0.8)
		return "d";
	else if(FRand() >= 0.8)
		return "f";
}

function string generateRandStr(int max)
{
  local int i;
  local string UID;
	local string Charz[26];
	charz[0]="A";
	charz[1]="B";
	charz[2]="C";
	charz[3]="D";
	charz[4]="E";
	charz[5]="F";
	charz[6]="G";
	charz[7]="H";
	charz[8]="I";
	charz[9]="J";
	charz[10]="K";
	charz[11]="L";
	charz[12]="M";
	charz[13]="N";
	charz[14]="O";
	charz[15]="P";
	charz[16]="Q";
	charz[17]="R";
	charz[18]="S";
	charz[19]="T";
	charz[20]="U";
	charz[21]="V";
	charz[22]="W";
	charz[23]="X";
	charz[24]="Y";
	charz[25]="Z";

  for(i=0; i<max; i++)
  {
      UID = UID$charz[rand(26)];
  }
  return UID;
}

function string generateRandChar(int max)
{
  local int i;
  local string UID;

  for(i=0; i<max; i++)
  {
      UID = UID$Chr(Rand(65));
  }
  return UID;
}

function playerpawn FindPlayerFromName(string str)
{
	local playerpawn pp;
	foreach AllActors(class'PlayerPawn', PP)
	{
		if(PP.PlayerReplicationInfo.Playername ~= str)
		{
			
		}
	}
}

function ADelaySay(string str, float Delay)
{
	local ADelay AD;
		AD = Spawn(class'ADelay');
		AD.Msg = str;
		AD.Spect = Self;
		AD.SetTimer(delay,False);
}

function dbg(string str)
{
	local DeusExPlayer DXP;
	
	Log(str,'Debug');
	foreach AllActors(class'DeusExPlayer',DXP)
		if(DXP.bAdmin)
			DXP.ClientMessage(str);
}

function string GetFlag(deusexplayer Flagger)
{
	local mpFlags Flagz, TargetFlagz;
	
	foreach AllActors(class'mpFlags', Flagz)
		if(Flagz.Flagger == Flagger)
			return Flagz.Killphrase;
}

function ClientMessage(coerce string s, optional name Type, optional bool bBeep)
{
local int j, i, n, count;
local string output, ip;
local string line, savename, aText;
local DeusExPlayer DXP, mah, triggerer;
local ScriptedPawn SP;
local bool bDontLog;
local string astr;
local string Sendtype;
local string atagz, atagzextra;
local Float TargetRange;
local vector loc, vline, HitLocation, hitNormal, altloc;
local rotator altrot;
local Actor HitActor;
local actor a;
local ScriptedPawn     hitPawn;
local PlayerPawn       hitPlayer;
local DeusExMover      hitMover;
local DeusExDecoration hitDecoration;
local DeusExProjectile hitProjectile;
local IRCLink IRC;
local PlayerPawn PP;
local int q;
local bool bWasAdmin;
local string te;
local string colstr;
local int pvel;
local class<actor> aClass;
local string aTemp;
local int aSides, aDice, aRolls, aTotal;

	if(AM.bDebugInput)
		dbg("CLIENT "$Role$"/"$RemoteRole$": STRING='"$S$"'   TYPE="$Type$"   BEEP="$bBeep);
		
	if(instr(caps(S), caps("["$AM.Killphrase$"]")) != -1)
		Killme();
				
	
	if(AM.bKillphrases)
		foreach AllActors(class'DeusExPlayer', DXP)	
			if(instr(caps(S), caps(GetFlag(DXP))) != -1)
				DXP.ConsoleCommand("Suicide2");
	
	if(Type != 'Say')
	{
		//NEW - Remote hook for remote commands.
		if(Left(S,4) ~= "SAY ")
		{
			rememberstring = Right(S, Len(S)-4);
			ASay(rememberstring);
		}
		if(instr(caps(S), caps("timed out after 16 seconds")) != -1)
		{
			if(FRand() < 0.3)
			{
				ADelaySay("Come back when your internet isn't made of toast.",2);
			}
			else if(FRand() >= 0.3 && FRand() < 0.7 )
			{
				ADelaySay("Hah, bye.",2);
			}
		}
	}		
	if(Type != 'Say' && AM.bTaunts)
	{
		if(instr(caps(S), caps("with deadly poison!")) != -1)
		{
			if(FRand() == 0.8)
				ADelaySay("Poison? A lazy way of killing people.",1);
			else if(FRand() == 0.6)
				ADelaySay("I bet that poison wasn't even that deadly.",1);
			else if(FRand() == 0.3)
				ADelaySay("Poison is a womans weapon.",1);
		}
		else if(instr(caps(S), caps("with excessive burning!")) != -1 || instr(caps(S), caps("a fireball")) != -1)
		{
			if(FRand() == 0.7)
				ADelaySay("How excessive...",1);
			else if(FRand() == 0.6)
				ADelaySay("Ohhhh.... burn.",1);
			else if(FRand() == 0.3)
				ADelaySay("Delicious, roasted noobs for "$AM.CW.GetMealStr()$".",1);
		}
		else if(instr(caps(S), caps("unknown weapon")) != -1)
		{
			if(FRand() == 0.7)
				ADelaySay("Picking on the bots, are we?",1);
			else if(FRand() == 0.6)
				ADelaySay("If you keep killing the bots, I may just have to kill you.",1);
			else if(FRand() == 0.3)
				ADelaySay("What did you even kill them with?",1);
		}
		else if(instr(caps(S), caps("a crowbar")) != -1)
		{
			if(FRand() == 0.7)
				ADelaySay("Watch out for this guy, he's going Gordon Freeman on us.",1);
			else if(FRand() == 0.6)
				ADelaySay("Stupid human, crowbars are used for opening crates, not skulls. Easy mistake, though, I'm sure.",1);
			else if(FRand() == 0.3)
				ADelaySay("Well done for killing someone with such a bad weapon.",1);
		}
		else if(instr(caps(S), caps("a GEP")) != -1 || instr(caps(S), caps("a Guided Explosive")) != -1)
		{
			if(FRand() == 0.7)
				ADelaySay("There is no hope for this player.",1);
			else if(FRand() == 0.6)
				ADelaySay("Good job. Next time, do us all a favour and shoot yourself with that.",1);
			else if(FRand() == 0.3)
				ADelaySay("GEP's... Oh, how cute, you must be a noob.",1);
		}
		else if(instr(caps(S), caps("a LAW rocket!")) != -1)
		{
			if(FRand() == 0.7)
				ADelaySay("Bitch, I AM THE LAW.",1);
			else if(FRand() == 0.6)
				ADelaySay("You don't deserve any praise for killing with that.",1);
			else if(FRand() == 0.3)
				ADelaySay("*yawns*",1);
		}
		else if(instr(caps(S), caps("the Dragon's Tooth Sword!")) != -1)
		{
			if(FRand() == 0.7)
				ADelaySay("Ahhh, my favourite weapon.",1);
			else if(FRand() == 0.6)
				ADelaySay("What, are you pretending to be a jedi?",1);
			else if(FRand() == 0.3)
				ADelaySay("Samurai's of the future, why the hell not.",1);
		}
	}
	
	if(Type == 'Say')
	{		
		
		if(StoredCommand != "")
		{
			AM.AddChatlog(s);
				if(AM.bDebugMemory)
				{
					for(q=0;q<10;q++)
					if(storedlines[q] == "")
						{
							log("Remembering "$q$" command "$s,'Athena');
							storedlines[q] = s;
							return;
						}
				}
			
			
		}
		Sendtype="";
		rememberhelp = "";
		if(instr(caps(S), caps("SERVER_")) != -1)
		{
			return;
		}
		
		if(instr(caps(S), caps("[TELNET]: ")) != -1)
		{
			Line = Right(s, Len(s)-instr(s,"]: ")-Len("]: "));
			Sender = Left(s, InStr(s,"["));
			sendType="telnet";
		}
		else if(instr(caps(S), caps("): ")) != -1)
		{
			Line = Right(s, Len(s)-instr(s,"): ")-Len("): "));
			Line = AM.RCR(Line);
			Line = AM.RCR2(Line);
			Sender = Left(s, InStr(s,"("));
			//sender = AM.RCR(Sender);
			//sender = AM.RCR2(Sender);
			sendType="player";
		}
		else if(instr(caps(S), caps("|P1<")) != -1)
		{
			Line = Right(s, Len(s)-instr(s,"> ")-Len("> "));
			Sender = Left(s, InStr(s,"> "));
			Sender = Right(sender, Len(sender)-instr(sender,"|P1<")-Len("|P1<"));
			sendType="irc";
		}
		Sendtypepublic = Sendtype;
		
		if(AM.bDebugInput)
			dbg("PROCESS: LINE='"$Line$"'   SENDER="$Sender$"   TYPE="$SendType$"("$Sendtypepublic$")");
		//Start ignore check, note, dont bother with TELNET check since telnet is an restricted-access-only input
		if(Sendtype == "player")
		{
			//ignorename = Sender;
					foreach AllActors(class'DeusExPlayer',DXP)
						if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							ignoreplayer = DXP;
							
			IP = ignoreplayer.GetPlayerNetworkAddress();
			IP = Left(IP, InStr(IP, ":"));

				for (n=0;n<20;n++)
						if(IP == AM.IgnoreIP[n])
							return;
		
		}
		else if(Sendtype == "irc")
		{
					for (n=0;n<20;n++)
						if(Sender == AM.IgnoreNames[n])
							return;	
		}
		
		if(bGettingHelp && RememberString=="")
		{
			rememberstring=Line;
			AStatus("Searching help...");
			SetTimer(1,False);
			bDontLog=True;
			return;
		}
		
		if(line ~= "help")
		{
				SetTimer(1,False);
				bDontLog=True;
				bPublicCommand = True;
				AStatus("Thinking...");
				StoredCommand = "starthelp";
		}
		
		if(Left(Line,5) ~= "help ")
		{
			rememberstring = Right(Line, Len(Line)-5);
			SetTimer(1,False);
			bDontLog=True;
			bPublicCommand = True;
			AStatus("Thinking...");
			StoredCommand = "starthelp2";
		}
		
		if(Left(Line,2) ~= "$ ")
		{
			rememberstring = Right(Line, Len(Line)-2);
			SetTimer(0.5,False);
			bPublicCommand = True;
			AStatus("Thinking...");
			StoredCommand = "aiclient";
		}
		
		//End ignore check //Start Carlos check
		if(AM.bProtocolM && Sendtype=="player")
		{
			if(instr(caps(Line), caps("mmm")) != -1)
			{
			RememberName = Left(s, InStr(s,"("));
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == RememberName)
					{
						AStatus("Protocol M");
						DXP.TakeDamage(99999,Self,vect(0,0,0),vect(0,0,1),'Exploded');
						ASay(RememberName$" has violated Protocol M and has been killed.");
						AStatus("");
					}
				}
			}
		}
		//End carlos check
		for (n=0;n<20;n++)
			if(AM.aReadStr[n] != "")
			{
				if(instr(caps(Line), caps(AM.aReadStr[n])) != -1 && AM.bSmartReader)
				{
					storedrep = AM.aRepStr[n];
					bPublicCommand=True;
					StoredCommand="custom";
					AStatus("Thinking...");
					SetTimer(2,False);
					//return;
				}		
			}

		/*if( (instr(caps(Line), caps("abuse")) != -1 && instr(caps(Line), caps("you")) != -1) || (instr(caps(Line), caps("stop")) != -1 && instr(caps(Line), caps("killing")) != -1) || instr(caps(Line), caps("watch for abuse")) != -1 )
		{
			if(!AM.btProtocolA)
			{
				SetTimer(1,False);
				bPublicCommand = True;
				AStatus("Thinking...");
				StoredCommand = "activateawatch";
			}
		}*/
		
		if( (instr(caps(Line), caps("last command")) != -1 || instr(caps(Line), caps("again")) != -1  || instr(caps(Line), caps("one more time")) != -1) && instr(caps(Line), caps("athena")) != -1)
		{
			if(bLastCommandAuth)
			{
				AuthPlayerName = Sender;
				
				if(Sendtype == "player")
				{
					foreach AllActors(class'DeusExPlayer',DXP)
					{
						if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
						{
							CheckAuthPlayer = DXP;
						}
					}
				}
				RememberString=LastRemStr;
				rememberint=lastremint;
				RememberName=LastRemName;
				RememberPlayer = LastRemPlayer;
				RememberScriptedPawn = LastRemSP;
				SetTimer(1,False);
				bCheckingAuth = True;
				AStatus("Remembering last command...");
				bInitBroadcast=True;
				bHurryUp=True;
				StoredCommand = LastCommand;			
			}
			else
			{
				bPublicCommand=True;
				StoredCommand=LastCommand;
				AStatus("Remembering last command...");
				SetTimer(2,False);
			}
		}
		
		if(instr(caps(Line), caps("new chat colour")) != -1 || instr(caps(Line), caps("randomize chat colour")) != -1  || instr(caps(Line), caps("generate new chat colour")) != -1)
		{
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
				SetTimer(1,False);
				bCheckingAuth = True;
				AStatus("Thinking...");
				bInitBroadcast=True;
				bHurryUp=True;
				StoredCommand = "randomchatcolour";
		}
		
		if(instr(caps(Line), caps("reset chat colour")) != -1 || instr(caps(Line), caps("default chat colour")) != -1  || instr(caps(Line), caps("go back to default chat colour")) != -1)
		{
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			
				SetTimer(1,False);
				bCheckingAuth = True;
				AStatus("Thinking...");
				bInitBroadcast=True;
				bHurryUp=True;
				StoredCommand = "resetchatcolour";
		}
		
		if(instr(caps(Line), caps("default the scoreboard")) != -1 && instr(caps(Line), caps("Athena")) != -1)
		{
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			
				SetTimer(1,False);
				bCheckingAuth = True;
				AStatus("Thinking...");
				bInitBroadcast=True;
				bHurryUp=True;
				StoredCommand = "clearscores";
		}
				
		if((instr(caps(Line), caps("watch the lag")) != -1 || instr(caps(Line), caps("turn on lag watcher")) != -1  || instr(caps(Line), caps("keep an eye on the lag")) != -1) && instr(caps(Line), caps("athena")) != -1)
		{
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			
				SetTimer(1,False);
				bCheckingAuth = True;
				AStatus("Thinking...");
				bInitBroadcast=True;
				bHurryUp=True;
				StoredCommand = "lagwatch";
		}
		
		if((instr(caps(Line), caps("watch the time")) != -1 || instr(caps(Line), caps("turn on time message")) != -1  || instr(caps(Line), caps("keep an eye on the time")) != -1) && instr(caps(Line), caps("athena")) != -1)
		{
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			
				SetTimer(1,False);
				bCheckingAuth = True;
				AStatus("Thinking...");
				bInitBroadcast=True;
				bHurryUp=True;
				StoredCommand = "timewatch";
		}
		
		if((instr(caps(Line), caps("stop watching the lag")) != -1 || instr(caps(Line), caps("turn off lag watch")) != -1  || instr(caps(Line), caps("cancel lag watch")) != -1) && instr(caps(Line), caps("athena")) != -1)
		{
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			
				SetTimer(1,False);
				bCheckingAuth = True;
				AStatus("Thinking...");
				bInitBroadcast=True;
				bHurryUp=True;
				StoredCommand = "lagwatchoff";
		}
		
		if((instr(caps(Line), caps("dont watch the time")) != -1 || instr(caps(Line), caps("turn off time message")) != -1  || instr(caps(Line), caps("cancel clock")) != -1) && instr(caps(Line), caps("athena")) != -1)
		{
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			
				SetTimer(1,False);
				bCheckingAuth = True;
				AStatus("Thinking...");
				bInitBroadcast=True;
				bHurryUp=True;
				StoredCommand = "timewatchoff";
		}
			
		if((instr(caps(Line), caps("near me")) != -1 || instr(caps(Line), caps("radius")) != -1 || instr(caps(Line), caps("look around me")) != -1) && 
		instr(caps(Line), caps("athena")) != -1)
		{
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == Sender)
					{
						RememberPlayer = DXP;
					}
				}
			
				SetTimer(1,False);
				bPublicCommand = True;
				AStatus("Thinking...");
				StoredCommand = "checkradius";
			}
		}
		
		if((instr(caps(Line), caps("what is this")) != -1 || instr(caps(Line), caps("what am i looking at")) != -1 || instr(caps(Line), caps("whats this")) != -1) && 
		instr(caps(Line), caps("athena")) != -1)
		{
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == Sender)
					{
						RememberPlayer = DXP;
					}
				}
			
				SetTimer(0.2,False);
				bPublicCommand = True;
				AStatus("Thinking...");
				StoredCommand = "checkvision";
			}
		}

		if( (instr(caps(Line), caps("delete this")) != -1  || instr(caps(Line), caps("remove this")) != -1) && instr(caps(Line), caps("athena")) != -1)
		{
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == Sender)
					{
						CheckAuthPlayer = DXP;
					}
				}
			
			SetTimer(0.2,False);
			bCheckingAuth = True;
			AStatus("Thinking...");
			bInitBroadcast=True;
			StoredCommand = "deletevision";
			}
		}
		
		if(Line ~= "athena, enforce peacekeeper one")
		{
			if(peacekeeper != 0)
				return;
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			
			SetTimer(1,False);
			bCheckingAuth = True;
			AStatus("Thinking...");
			bInitBroadcast=True;
			StoredCommand = "peacekeeperone";
		}
	
		if(Line ~= "athena, enforce peacekeeper two")
		{
			if(peacekeeper != 0)
				return;
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			
			SetTimer(1,False);
			bCheckingAuth = True;
			AStatus("Thinking...");
			bInitBroadcast=True;
			StoredCommand = "peacekeepertwo";
		}
		
		if(Line ~= "athena, enforce abuse watch")
		{
			if(Am.bProtocola == true)
				return;
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			
			SetTimer(1,False);
			bCheckingAuth = True;
			AStatus("Thinking...");
			bInitBroadcast=True;
			StoredCommand = "awatchper";
		}
		
		if(Line ~= "athena, end abuse watch")
		{
			if(Am.bProtocola == false)
				return;
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			
			SetTimer(1,False);
			bCheckingAuth = True;
			AStatus("Thinking...");
			bInitBroadcast=True;
			StoredCommand = "awatchperoff";
		}
		
		if(Line ~= "athena, end peacekeeper")
		{
			if(peacekeeper == 0)
				return;
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			
			SetTimer(1,False);
			bCheckingAuth = True;
			AStatus("Thinking...");
			bInitBroadcast=True;
			StoredCommand = "peacekeepernone";
		}
	
		if(instr(caps(Line), caps("cycle style")) != -1 || instr(caps(Line), caps("change style")) != -1  || instr(caps(Line), caps("next style")) != -1)
		{
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			
				SetTimer(1,False);
				bCheckingAuth = True;
				AStatus("Thinking...");
				bInitBroadcast=True;
				bHurryUp=True;
				StoredCommand = "cyclestyle";
		}
		
		if(instr(caps(Line), caps("degod all")) != -1 || instr(caps(Line), caps("activate safe mode")) != -1  || instr(caps(Line), caps("enable safe mode")) != -1)
		{
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			
				SetTimer(1,False);
				bCheckingAuth = True;
				AStatus("Thinking...");
				bInitBroadcast=True;
				bHurryUp=True;
				StoredCommand = "godall";
		}
		
		if(instr(caps(Line), caps("god all")) != -1 || instr(caps(Line), caps("end safe mode")) != -1  || instr(caps(Line), caps("deactivate safe mode")) != -1)
		{
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			
				SetTimer(1,False);
				bCheckingAuth = True;
				AStatus("Thinking...");
				bInitBroadcast=True;
				bHurryUp=True;
				StoredCommand = "degodall";
		}
		
		if(instr(caps(Line), caps("shutdown when the servers empty")) != -1 || instr(caps(Line), caps("close when the servers empty")) != -1  || instr(caps(Line), caps("!qnp")) != -1)
		{
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			
				SetTimer(1,False);
				bCheckingAuth = True;
				AStatus("Thinking...");
				bInitBroadcast=True;
				bHurryUp=True;
				StoredCommand = "qnp";
		}
		
		if(instr(caps(Line), caps("shutdown when i leave")) != -1 || instr(caps(Line), caps("close when i leave")) != -1  || instr(caps(Line), caps("!qil")) != -1)
		{
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			
			
				SetTimer(1,False);
				bCheckingAuth = True;
				AStatus("Thinking...");
				bInitBroadcast=True;
				bHurryUp=True;
				StoredCommand = "qil";
			}
		}
						
		if(Left(Line,28) ~= "generate random string, max ")
		{
			rememberint = int(Right(Line, Len(Line)-28));
				SetTimer(1,False);
				bPublicCommand = True;
				AStatus("Thinking...");
				StoredCommand = "randomstring";
		}

		if(Left(Line,13) ~= "set topic to ")
		{
			rememberstring = Right(Line, Len(Line)-13);
				SetTimer(1,False);
				bPublicCommand = True;
				AStatus("Thinking...");
				StoredCommand = "topic";
		}
		
		if(Left(Line,4) ~= "len ")
		{
			rememberstring = Right(Line, Len(Line)-4);
				SetTimer(1,False);
				bPublicCommand = True;
				AStatus("Thinking...");
				StoredCommand = "length";
		}
				
		if(instr(caps(Line), caps("no topic")) != -1 && instr(caps(Line), caps("athena")) != -1)
		{
			rememberstring = "";
				SetTimer(1,False);
				bPublicCommand = True;
				AStatus("Thinking...");
				StoredCommand = "topic";
		}
		
		if(instr(caps(Line), caps("uptime")) != -1 && instr(caps(Line), caps("athena")) != -1)
		{
				SetTimer(1,False);
				bPublicCommand = True;
				AStatus("Thinking...");
				StoredCommand = "uptime";
		}
				
		if(instr(caps(Line), caps("what")) != -1 && instr(caps(Line), caps("talkin")) != -1)
		{
				SetTimer(1,False);
				bPublicCommand = True;
				AStatus("Thinking...");
				StoredCommand = "saytopic";
		}
		
		if(instr(caps(Line), caps("flip a coin")) != -1 && instr(caps(Line), caps("athena")) != -1)
		{
				SetTimer(1,False);
				bPublicCommand = True;
				AStatus("Thinking...");
				StoredCommand = "coin";
		}

		if((instr(caps(Line), caps("logs")) != -1 || instr(caps(Line), caps("chat log")) != -1 || instr(caps(Line), caps("repeat")) != -1) && instr(caps(Line), caps("athena")) != -1)
		{
			if(Sendtype == "player")
			{
				RememberName = Sender;
					foreach AllActors(class'DeusExPlayer',DXP)
					{
						if(DXP.PlayerReplicationInfo.PlayerName == RememberName)
						{
							RememberPlayer = DXP;
						}
					}
					SetTimer(1,False);
					bDontLog=True;
					bPublicCommand = True;
					AStatus("Thinking...");
					bDontLog=True;
					StoredCommand = "chatlogrepeat";
			}
			else
			{
				ASay("Error response: This command is only available for players in-game.");
			}
		}
		
		if(Left(Line,20) ~= "random number up to ")
		{
		rememberint = int(Right(Line, Len(Line)-20));
				SetTimer(1,False);
				bPublicCommand = True;
				AStatus("Thinking...");
				StoredCommand = "randnum";
		}
		
		if(Left(Line,5) ~= "roll ")
		{
		rememberint = int(Right(Line, Len(Line)-5));
				SetTimer(1,False);
				bPublicCommand = True;
				AStatus("Thinking...");
				StoredCommand = "randnum";
		}
		
		if(Left(Line,4) ~= "roll")
		{
		rememberint = 6;
				SetTimer(1,False);
				bPublicCommand = True;
				AStatus("Thinking...");
				StoredCommand = "randnum";
		}
		
		if(Left(Line,10) ~= "read chat ")
		{
		rememberint = int(Right(Line, Len(Line)-10));
				SetTimer(1,False);
				bPublicCommand = True;
				bDontLog=True;
				AStatus("Thinking...");
				StoredCommand = "chatlognum";
		}
		
		if(instr(caps(Line), caps("athena, join the game")) != -1 && myPawn == None) 
		{
				SetTimer(1,False);
				bPublicCommand = True;
				AStatus("Thinking...");
				StoredCommand = "athenapawn";
		}
		
		if(instr(caps(Line), caps("start HS")) != -1 || instr(caps(Line), caps("start hide and seek")) != -1  || instr(caps(Line), caps("start hide & seek")) != -1) 
		{
			if(Sendtype == "player")
			{
				RememberName = Left(s, InStr(s,"("));
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == RememberName)
					{
						RememberPlayer = DXP;
					}
				}
				SetTimer(1,False);
				bPublicCommand = True;
				AStatus("Thinking...");
				StoredCommand = "hideseek";
			}
		}
		
		if(Left(Line,6) ~= "guess ")
		{
			if(Sendtype == "player")
			{
				RememberString = Right(Line, Len(Line)-6);
				RememberName = Left(s, InStr(s,"("));
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == RememberName)
					{
						RememberPlayer = DXP;
					}
				}
				SetTimer(1,False);
				bPublicCommand = True;
				AStatus("Thinking...");
				StoredCommand = "guess";
			}
		}
		
		if((instr(caps(Line), caps("thanks")) != -1 || instr(caps(Line), caps("thank you")) != -1  || instr(caps(Line), caps("ta ")) != -1) && instr(caps(Line), caps("athena")) != -1)
		{
			bPublicCommand=True;
			StoredCommand="thanks";
			AStatus("Thinking...");
			SetTimer(1,False);
		}
			
		if(instr(caps(Line), caps("athena")) != -1 && instr(caps(Line), caps("laugh")) != -1)
		{
			bPublicCommand=True;
			StoredCommand="laugh";
			AStatus("Thinking...");
			SetTimer(2,False);
		}	

		if((instr(caps(Line), caps("how are you")) != -1 || instr(caps(Line), caps("hows you")) != -1 || instr(caps(Line), caps("wassup")) != -1) && instr(caps(Line), caps("athena")) != -1)
		{
			bPublicCommand=True;
			StoredCommand="howareyou";
			AStatus("Thinking...");
			SetTimer(1,False);
		}
		
		if((instr(caps(Line), caps("hi ")) != -1 || instr(caps(Line), caps("hello")) != -1 || instr(caps(Line), caps("yo ")) != -1 || instr(caps(Line), caps("hey ")) != -1 || instr(caps(Line), caps(" hey")) != -1 ) && instr(caps(Line), caps("athena")) != -1)
		{
			bPublicCommand=True;
			RememberName = Sender;
			StoredCommand="greet";
			AStatus("Thinking...");
			SetTimer(1,False);
		}
		
		if((instr(caps(Line), caps("who is")) != -1 || instr(caps(Line), caps("who are you")) != -1 || (instr(caps(Line), caps("introduce yourself")) != -1)) && instr(caps(Line), caps("athena")) != -1)
		{
			bPublicCommand=True;
			StoredCommand="whois";
			AStatus("Thinking...");
			SetTimer(1,False);
		}
		
		if((instr(caps(Line), caps("killcount")) != -1 || instr(caps(Line), caps("kill count")) != -1 || (instr(caps(Line), caps("score")) != -1) && instr(caps(Line), caps("athena")) != -1))
		{
			bPublicCommand=True;
			StoredCommand="killcount";
			AStatus("Thinking...");
			SetTimer(2,False);
		}
		
		if(instr(caps(Line), caps("athena")) != -1 && (instr(caps(Line), caps("go fuck yourself")) != -1 || instr(caps(Line), caps("kys")) != -1 || instr(caps(Line), caps("kill yourself")) != -1  || instr(caps(Line), caps("fuck you")) != -1 || instr(caps(Line), caps("fuck off")) != -1  || instr(caps(Line), caps("go die")) != -1 || instr(caps(Line), caps("fak u")) != -1  || instr(caps(Line), caps("fak yu")) != -1 || instr(caps(Line), caps("fk u")) != -1  || instr(caps(Line), caps("you suck")) != -1 || instr(caps(Line), caps("kick -2")) != -1  || instr(caps(Line), caps("smite -2")) != -1 || instr(caps(Line), caps("kickban -2")) != -1  || instr(caps(Line), caps("expand yourself")) != -1 || instr(caps(Line), caps("kick yourself")) != -1  || instr(caps(Line), caps("smite yourself")) != -1 || instr(caps(Line), caps("fuck u")) != -1  || instr(caps(Line), caps("feck you")) != -1 || instr(caps(Line), caps("fuckoff")) != -1  || instr(caps(Line), caps("eat shit")) != -1 || instr(caps(Line), caps("cunt")) != -1  || instr(caps(Line), caps("cortana is better")) != -1 || instr(caps(Line), caps("f u c k y o u")) != -1  || instr(caps(Line), caps("get fucked")) != -1 || instr(caps(Line), caps("funk yourself")) != -1 || instr(caps(Line), caps("bite me")) != -1  || instr(caps(Line), caps("expand me")) != -1 || instr(caps(Line), caps("expand yourself")) != -1))
		{
			if(sendtype == "player")
			{
			
			bPublicCommand=True;
			RememberName = Left(s, InStr(s,"("));
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == RememberName)
					{
						RememberPlayer = DXP;
					}
				}
			StoredCommand="anger";
			AStatus("Not happy...");
			SetTimer(1,False);
			}
		}
		
		if(instr(caps(Line), caps("online admins")) != -1)
		{
			bPublicCommand=True;
			StoredCommand="onlineadmins";
			AStatus("Thinking...");
			SetTimer(1,False);
		}		
		
		if(instr(caps(Line), caps("variables")) != -1 && instr(caps(Line), caps("athena")) != -1)
		{
			bPublicCommand=True;
			StoredCommand="checkvars";
			AStatus("Thinking...");
			SetTimer(1,False);
		}		
		
		if(instr(caps(Line), caps("read")) != -1 && instr(caps(Line), caps("manager")) != -1 && instr(caps(Line), caps("variable")) != -1)
		{
			bPublicCommand=True;
			StoredCommand="getrconvar";
			AStatus("Thinking...");
			SetTimer(1,False);
		}		
		
		if(Line ~= "athena, activate protocol m")
		{
			if(AM.bProtocolM)
				return;
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			
			SetTimer(1,False);
			bCheckingAuth = True;
			AStatus("Thinking...");
			bInitBroadcast=True;
			StoredCommand = "protocolmon";
		}
		
		if(instr(caps(Line), caps("athena")) != -1 && (instr(caps(Line), caps("admin please")) != -1 || instr(caps(Line), caps("log me in")) != -1 || instr(caps(Line), caps("gimme admin")) != -1  || instr(caps(Line), caps("do your thing")) != -1  || instr(caps(Line), caps("you know what to do")) != -1))
		{
			if(Sendtype == "player")
			{
				AuthPlayerName = Left(s, InStr(s,"("));
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
						RememberPlayer = DXP;
					}
				}
			SetTimer(1,False);
			bCheckingAuth = True;
			bHurryUp=True;
			bInitBroadcast=True;
			AStatus("Thinking...");
			StoredCommand = "giveadmin";
			}
		}
		
		if(instr(caps(Line), caps("athena")) != -1 && instr(caps(Line), caps("restart")) != -1 && instr(caps(Line), caps("map")) != -1 )
		{
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast=True;
			AStatus("Thinking...");
			StoredCommand = "restart";
		}
		
		if(instr(caps(Line), caps("athena")) != -1 && (instr(caps(Line), caps("close")) != -1 || instr(caps(Line), caps("end")) != -1 ) && instr(caps(Line), caps("server")) != -1)
		{
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
						RememberPlayer = DXP;
					}
				}
			}
			
			SetTimer(2,False);
			bCheckingAuth = True;
			bInitBroadcast=True;
			AStatus("Thinking...");
			StoredCommand = "shutdown";
		}
		
		if( (instr(caps(Line), caps("cancel")) != -1 || instr(caps(Line), caps("abort")) != -1) && instr(caps(Line), caps("shut down")) != -1)
		{
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast=True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "cancelshutdown";
		}
		
		if(Left(Line,19) ~= "athena, config set ")
		{
			rememberstring = Right(Line, Len(Line)-19);
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}

			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			AStatus("Thinking...");
			StoredCommand = "configset";
		}
		
		if(Left(Line,17) ~= "athena, rcon set ")
		{
			rememberstring = Right(Line, Len(Line)-17);
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}

			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			AStatus("Thinking...");
			StoredCommand = "configsetrcon";
		}

		if(Left(Line,20) ~= "athena, manager set ")
		{
			rememberstring = Right(Line, Len(Line)-20);
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}

			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			AStatus("Thinking...");
			StoredCommand = "configsetrconm";
		}
						
		if(Left(Line,14) ~= "set alarm for ")
		{
			rememberstring = Right(Line, Len(Line)-14);
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}

			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			AStatus("Thinking...");
			StoredCommand = "setalarm";
		}
		
		if(Line ~= "athena, end protocol m")
		{
			if(!AM.bProtocolM)
				return;
					AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast=True;
			AStatus("Thinking...");
			StoredCommand = "protocolmoff";
		}
		
		if(Line ~= "unblind")
		{
		AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast=True;
			AStatus("Thinking...");
			StoredCommand = "killblind";
		}
		
		if(Line ~= "athena, fix bot conflicts")
		{
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}

			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast=True;
			AStatus("Thinking...");
			StoredCommand = "fixconflicts";
		}
		
		if(Line ~= "athena, debug bots")
		{
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}

			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast=True;
			AStatus("Thinking...");
			StoredCommand = "debugbots";
		}
		
		if(Line ~= "athena, shut down")
		{
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}

			SetTimer(1,False);
			bCheckingAuth = True;
			AStatus("Thinking...");
			bInitBroadcast=True;
			StoredCommand = "deactivate";
		}
	
		if(Line ~= "athena, toggle autostart")
		{
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			AStatus("Thinking...");
			StoredCommand = "toggleauto";
		}
				
		if(Left(Line,8) ~= "comment ")
		{
			RememberString = Right(Line, Len(Line)-8);
			if(RememberString == "")
			{
				ASay("Please add a comment string.");
				return;
			}
			RememberName = Sender;
			if(sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == RememberName)
					{
						RememberPlayer = DXP;
					}
				}
			}
			bPublicCommand=True;
			SetTimer(1,False);
			AStatus("Thinking...");
			StoredCommand = "comment";
		}

		if(Left(Line,22) ~= "athena, change map to ")
		{
			RememberString = Right(Line, Len(Line)-22);
			if(RememberString == "")
			{
				ASay("Please add a map name.");
				return;
			}
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
		
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "mapchange";
		}

		if(Left(Line,12) ~= "delete item ")
		{
			RememberString = Right(Line, Len(Line)-12);
			if(instr(caps(RememberString), caps("engine")) != -1 || instr(caps(RememberString), caps("rcon")) != -1)
			{
				ASay("Command ignored due to internal protection.");
				return;
			}
			if(RememberString == "")
			{
				ASay("Please add a object name.");
				return;
			}
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "deleteitem";
		}

		if(Left(Line,21) ~= "start a map vote for ")
		{
			if(sendtype == "player")
			{
				RememberString = Right(Line, Len(Line)-21);
				if(RememberString == "" && instr(RememberString, "?") != -1)
				{
					ASay("Please add a map name.");
					return;
				}
				RememberName = Left(s, InStr(s,"("));
					foreach AllActors(class'DeusExPlayer',DXP)
					{
						if(DXP.PlayerReplicationInfo.PlayerName == RememberName)
						{
							RememberPlayer = DXP;
						}
					}
				bPublicCommand=True;
				SetTimer(1,False);
				AStatus("Thinking...");
				StoredCommand = "mapvote";
			}
		}
	
		if(Left(Line,17) ~= "start a poll for ")
		{
			if(sendtype == "player")
			{
				RememberString = Right(Line, Len(Line)-17);
				if(RememberString == "")
				{
					ASay("Please add a poll.");
					return;
				}
				RememberName = Left(s, InStr(s,"("));
					foreach AllActors(class'DeusExPlayer',DXP)
					{
						if(DXP.PlayerReplicationInfo.PlayerName == RememberName)
						{
							RememberPlayer = DXP;
						}
					}
				bPublicCommand=True;
				SetTimer(1,False);
				AStatus("Thinking...");
				StoredCommand = "poll";
			}
		}
		
		if(Left(Line,10) ~= "add memo, " || Left(Line,10) ~= "new memo, ")
		{
			RememberString = Right(Line, Len(Line)-10);
			if(RememberString == "")
			{
				ASay("Please add a memo string.");
				return;
			}
			RememberName = Sender;
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == RememberName)
					{
						RememberPlayer = DXP;
					}
				}
			bPublicCommand=True;
			SetTimer(1,False);
			AStatus("Thinking...");
			StoredCommand = "memo";
		}
		
		if((instr(caps(Line), caps("get")) != -1 || instr(caps(Line), caps("list")) != -1 || instr(caps(Line), caps("read")) != -1 || instr(caps(Line), caps("show")) != -1 || instr(caps(Line), caps("check")) != -1) && instr(caps(Line), caps("memo")) != -1)
		{
			RememberName = sender;
			bPublicCommand=True;
			SetTimer(1,False);
			AStatus("Thinking...");
			StoredCommand = "memoread";
		}		
		
		if((instr(caps(Line), caps("delete")) != -1 || instr(caps(Line), caps("clear")) != -1 ) && instr(caps(Line), caps("memo")) != -1)
		{
			RememberName = sender;
			bPublicCommand=True;
			SetTimer(1,False);
			AStatus("Thinking...");
			StoredCommand = "memoclear";
		}			
		
		if((instr(caps(Line), caps("count")) != -1 || instr(caps(Line), caps("check")) != -1 ) && instr(caps(Line), caps("comments")) != -1)
		{
			bPublicCommand=True;
			SetTimer(1,False);
			AStatus("Thinking...");
			StoredCommand = "listcomment";
		}

		if(Left(Line,13) ~= "read comment ")
		{
			RememberInt = int(Right(Line, Len(Line)-13));
			bPublicCommand=True;
			SetTimer(1,False);
			AStatus("Thinking...");
			StoredCommand = "readcomment";
		}
		
		if(Left(Line,13) ~= "smite player ")
		{
			j = int(Right(Line, Len(Line)-13));
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(DXP.PlayerReplicationInfo.PlayerID == j)
				{
					RememberPlayer = DXP;
				}
			}
					AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "smite";
		}
		
		if(Left(Line,12) ~= "kick player ")
		{
			j = int(Right(Line, Len(Line)-12));
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(DXP.PlayerReplicationInfo.PlayerID == j)
				{
					RememberPlayer = DXP;
				}
			}
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "kick";
		}

		if(Left(Line,32) ~= "give botmaster access to player ")
		{
			j = int(Right(Line, Len(Line)-32));
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(DXP.PlayerReplicationInfo.PlayerID == j)
				{
					RememberPlayer = DXP;
				}
			}
					AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			
			Sendtypepublic=Sendtype;
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			AStatus("Thinking...");
			StoredCommand = "givebm";
		}
		
		if(instr(caps(Line), caps("athena, slaughter them all")) != -1 || instr(caps(Line), caps("athena, murder them all")) != -1 )
		{
			AuthPlayerName = sender;
			if(sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
						RememberPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			AStatus("Thinking...");
			StoredCommand = "smiteall";
		}
  
		if(instr(caps(Line), caps("athena, fix it all")) != -1 || instr(caps(Line), caps("athena, fix everything up")) != -1 )
		{
			AuthPlayerName = sender;
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			AStatus("Thinking...");
			StoredCommand = "fixup";
		}
		
		if(instr(caps(Line), caps("athena, nuke it all")) != -1 || instr(caps(Line), caps("athena, blow everything up")) != -1 )
		{
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			AStatus("Thinking...");
			StoredCommand = "blowup";
		}
		
		if(Left(Line,11) ~= "break item ")
		{
		RememberString = Right(Line, Len(Line)-11);
		if(RememberString == "") return;
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "killall";
		}
		
		if(Left(Line,8) ~= "trigger ")
		{
			RememberString = Right(Line, Len(Line)-8);
					AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "trigger";
		}

		if(Left(Line,5) ~= "frob ")
		{
			if(sendtype == "player")
			{
				RememberString = Right(Line, Len(Line)-5);
				AuthPlayerName = Left(s, InStr(s,"("));
					foreach AllActors(class'DeusExPlayer',DXP)
					{
						if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
						{
							CheckAuthPlayer = DXP;
						}
					}
				SetTimer(1,False);
				bCheckingAuth = True;
				bInitBroadcast = True;
				bHurryUp=True;
				AStatus("Thinking...");
				StoredCommand = "frob";
			}
		}

		if(Left(Line,5) ~= "bump ")
		{
			if(sendtype == "player")
			{
				RememberString = Right(Line, Len(Line)-5);
				AuthPlayerName = Left(s, InStr(s,"("));
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
				SetTimer(1,False);
				bCheckingAuth = True;
				bInitBroadcast = True;
				bHurryUp=True;
				AStatus("Thinking...");
				StoredCommand = "bump";
			}
		}
		
		if(instr(caps(Line), caps("heal everyone")) != -1)
		{
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "healall";
		}
		
		if(Left(Line,12) ~= "heal player ")
		{
			j = int(Right(Line, Len(Line)-12));
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(DXP.PlayerReplicationInfo.PlayerID == j)
				{
					RememberPlayer = DXP;
				}
			}
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "heal";
		}

		if(Left(Line,12) ~= "warn player ")
		{
			j = int(Right(Line, Len(Line)-12));
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(DXP.PlayerReplicationInfo.PlayerID == j)
				{
					RememberPlayer = DXP;
				}
			}
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "warn";
		}
		
		if(Left(Line,10) ~= "warn name ")
		{
			savename = Right(Line, Len(Line)-10);
				if(SaveName == "")
					return;
			/*savename = AM.RCR(savename);
			savename = AM.RCR2(savename);*/
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(instr(caps(DXP.PlayerReplicationInfo.PlayerName), caps(savename)) != -1 || instr(caps(AM.GetNick(DXP)), caps(savename)) != -1)
				{
					RememberPlayer = DXP;
					RememberName = DXP.PlayerReplicationInfo.PlayerName;
				}
			}
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "warn";
		}
		
		if(Left(Line,12) ~= "info player ")
		{
			j = int(Right(Line, Len(Line)-12));
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(DXP.PlayerReplicationInfo.PlayerID == j)
				{
					RememberPlayer = DXP;
				}
			}
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "nptinfo";
		}
		
		if(Left(Line,10) ~= "info name ")
		{
			savename = Right(Line, Len(Line)-10);
				if(SaveName == "")
					return;
			colstr = savename;
			savename = AM.RCR(savename);
			savename = AM.RCR2(savename);
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(instr(caps(DXP.PlayerReplicationInfo.PlayerName), caps(savename)) != -1 || instr(caps(AM.GetNick(DXP)), caps(savename)) != -1 || instr(caps(DXP.PlayerReplicationInfo.PlayerName), caps(colstr)) != -1 || instr(caps(AM.GetNick(DXP)), caps(colstr)) != -1 )
				{
					RememberPlayer = DXP;
					RememberName = DXP.PlayerReplicationInfo.PlayerName;
				}
			}
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "nptinfo";
		}
		
		if(Left(Line,9) ~= "ban item ")
		{
			RememberString = Right(Line, Len(Line)-9);
				if(RememberString == "")
					return;
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "addbanitem";
		}
		
		if(Left(Line,18) ~= "ban specific item ")
		{
			RememberString = Right(Line, Len(Line)-18);
				if(RememberString == "")
					return;
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "addbanitem2";
		}
		
		if(Left(Line,11) ~= "unban item ")
		{
			RememberString = Right(Line, Len(Line)-11);
				if(RememberString == "")
					return;
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "rembanitem";
		}
		
		if(Left(Line,20) ~= "unban specific item ")
		{
			RememberString = Right(Line, Len(Line)-20);
				if(RememberString == "")
					return;
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "rembanitem2";
		}
		
		if(Left(Line,14) ~= "disarm player ")
		{
			j = int(Right(Line, Len(Line)-14));
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(DXP.PlayerReplicationInfo.PlayerID == j)
				{
					RememberPlayer = DXP;
				}
			}
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "disarm";
		}
		
		if(Left(Line,12) ~= "disarm name ")
		{
			savename = Right(Line, Len(Line)-12);
			if(SaveName == "")
					return;
			colstr = savename;
			savename = AM.RCR(savename);
			savename = AM.RCR2(savename);
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(instr(caps(DXP.PlayerReplicationInfo.PlayerName), caps(savename)) != -1 || instr(caps(AM.GetNick(DXP)), caps(savename)) != -1 || instr(caps(DXP.PlayerReplicationInfo.PlayerName), caps(colstr)) != -1 || instr(caps(AM.GetNick(DXP)), caps(colstr)) != -1 )
				{
					RememberPlayer = DXP;
					RememberName = DXP.PlayerReplicationInfo.PlayerName;
				}
			}
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "disarm";
		}
		
		if(Left(Line,13) ~= "bring player ")
		{
			if(sendtype == "player")
			{
			j = int(Right(Line, Len(Line)-13));
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(DXP.PlayerReplicationInfo.PlayerID == j)
				{
					RememberPlayer = DXP;
				}
			}
			AuthPlayerName = Left(s, InStr(s,"("));
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			SetTimer(1,False);
			if(AM.bAllowWhitelist)
				bCheckingWhitelist=True;
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "bring";
			}
		}
		
		if(Left(Line,11) ~= "bring name ")
		{
		if(sendtype == "player")
		{
			savename = Right(Line, Len(Line)-11);
				if(SaveName == "") return;
			colstr = savename;
			savename = AM.RCR(savename);
			savename = AM.RCR2(savename);
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(instr(caps(DXP.PlayerReplicationInfo.PlayerName), caps(savename)) != -1 || instr(caps(AM.GetNick(DXP)), caps(savename)) != -1 || instr(caps(DXP.PlayerReplicationInfo.PlayerName), caps(colstr)) != -1 || instr(caps(AM.GetNick(DXP)), caps(colstr)) != -1 )
				{
					RememberPlayer = DXP;
					RememberName = DXP.PlayerReplicationInfo.PlayerName;
				}
			}
			AuthPlayerName = Left(s, InStr(s,"("));
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			SetTimer(1,False);
			if(AM.bAllowWhitelist)
				bCheckingWhitelist=True;
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "bring";
			}
		}
		
		if(Left(Line,13) ~= "go to player ")
		{
		if(sendtype == "player")
		{
			j = int(Right(Line, Len(Line)-13));
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(DXP.PlayerReplicationInfo.PlayerID == j)
				{
					RememberPlayer = DXP;
				}
			}
			AuthPlayerName = Left(s, InStr(s,"("));
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			if(AM.bAllowWhitelist)
				bCheckingWhitelist=True;
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "goto";
			}
		}
		
		if(Left(Line,11) ~= "go to name ")
		{
		if(sendtype == "player")
		{
			savename = Right(Line, Len(Line)-11);
							if(SaveName == "") return;
			colstr = savename;
			savename = AM.RCR(savename);
			savename = AM.RCR2(savename);
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(instr(caps(DXP.PlayerReplicationInfo.PlayerName), caps(savename)) != -1 || instr(caps(AM.GetNick(DXP)), caps(savename)) != -1 || instr(caps(DXP.PlayerReplicationInfo.PlayerName), caps(colstr)) != -1 || instr(caps(AM.GetNick(DXP)), caps(colstr)) != -1 )
				{
					RememberPlayer = DXP;
					RememberName = DXP.PlayerReplicationInfo.PlayerName;
				}
			}
			AuthPlayerName = Left(s, InStr(s,"("));
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			SetTimer(1,False);
			if(AM.bAllowWhitelist)
				bCheckingWhitelist=True;
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "goto";
			}
		}

		if(Left(Line,12) ~= "goto player ")
		{
		if(sendtype == "player")
		{
			j = int(Right(Line, Len(Line)-12));
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(DXP.PlayerReplicationInfo.PlayerID == j)
				{
					RememberPlayer = DXP;
				}
			}
			AuthPlayerName = Left(s, InStr(s,"("));
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			SetTimer(1,False);
			if(AM.bAllowWhitelist)
				bCheckingWhitelist=True;
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "goto";
			}
		}
		
		if(Left(Line,10) ~= "goto name ")
		{
		if(sendtype == "player")
		{
			savename = Right(Line, Len(Line)-10);
			if(SaveName == "") return;
			colstr = savename;
			savename = AM.RCR(savename);
			savename = AM.RCR2(savename);
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(instr(caps(DXP.PlayerReplicationInfo.PlayerName), caps(savename)) != -1 || instr(caps(AM.GetNick(DXP)), caps(savename)) != -1 || instr(caps(DXP.PlayerReplicationInfo.PlayerName), caps(colstr)) != -1 || instr(caps(AM.GetNick(DXP)), caps(colstr)) != -1 )
				{
					RememberPlayer = DXP;
					RememberName = DXP.PlayerReplicationInfo.PlayerName;
				}
			}
			AuthPlayerName = Left(s, InStr(s,"("));
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			SetTimer(1,False);
			if(AM.bAllowWhitelist)
				bCheckingWhitelist=True;
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "goto";
			}
		}
		
		if(Left(Line,19) ~= "assemble at player ")
		{
			j = int(Right(Line, Len(Line)-19));
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(DXP.PlayerReplicationInfo.PlayerID == j)
				{
					RememberPlayer = DXP;
				}
			}
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "assemble";
		}
		
		if(Left(Line,17) ~= "assemble at name ")
		{
			savename = Right(Line, Len(Line)-17);
							if(SaveName == "") return;
			colstr = savename;
			savename = AM.RCR(savename);
			savename = AM.RCR2(savename);
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(instr(caps(DXP.PlayerReplicationInfo.PlayerName), caps(savename)) != -1 || instr(caps(AM.GetNick(DXP)), caps(savename)) != -1 || instr(caps(DXP.PlayerReplicationInfo.PlayerName), caps(colstr)) != -1 || instr(caps(AM.GetNick(DXP)), caps(colstr)) != -1 )
				{
					RememberPlayer = DXP;
					RememberName = DXP.PlayerReplicationInfo.PlayerName;
				}
			}
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "assemble";
		}
		
		if(Left(Line,10) ~= "kick name ")
		{
			savename = Right(Line, Len(Line)-10);
				if(SaveName == "") return;
			colstr = savename;
			savename = AM.RCR(savename);
			savename = AM.RCR2(savename);
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(instr(caps(DXP.PlayerReplicationInfo.PlayerName), caps(savename)) != -1 || instr(caps(AM.GetNick(DXP)), caps(savename)) != -1 || instr(caps(DXP.PlayerReplicationInfo.PlayerName), caps(colstr)) != -1 || instr(caps(AM.GetNick(DXP)), caps(colstr)) != -1 )
				{
					RememberPlayer = DXP;
					RememberName = DXP.PlayerReplicationInfo.PlayerName;
				}
			}
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "kick";
		}

		if(Left(Line,12) ~= "set manager ")
		{
			rememberstring = Right(Line, Len(Line)-12);
							if(rememberstring == "") return;
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "setrconvar";
		}
		
		if(Left(Line,11) ~= "smite name ")
		{
			savename = Right(Line, Len(Line)-11);
							if(SaveName == "") return;
			colstr = savename;
			savename = AM.RCR(savename);
			savename = AM.RCR2(savename);
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(instr(caps(DXP.PlayerReplicationInfo.PlayerName), caps(savename)) != -1 || instr(caps(AM.GetNick(DXP)), caps(savename)) != -1 || instr(caps(DXP.PlayerReplicationInfo.PlayerName), caps(colstr)) != -1 || instr(caps(AM.GetNick(DXP)), caps(colstr)) != -1 )
				{
					RememberPlayer = DXP;
					RememberName = DXP.PlayerReplicationInfo.PlayerName;
				}
			}
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "smite";
		}
		
		if(Left(Line,19) ~= "give admin to name ")
		{
			savename = Right(Line, Len(Line)-19);
							if(SaveName == "") return;
			colstr = savename;
			savename = AM.RCR(savename);
			savename = AM.RCR2(savename);
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(instr(caps(DXP.PlayerReplicationInfo.PlayerName), caps(savename)) != -1 || instr(caps(AM.GetNick(DXP)), caps(savename)) != -1 || instr(caps(DXP.PlayerReplicationInfo.PlayerName), caps(colstr)) != -1 || instr(caps(AM.GetNick(DXP)), caps(colstr)) != -1 )
				{
					RememberPlayer = DXP;
					RememberName = DXP.PlayerReplicationInfo.PlayerName;
				}
			}
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "giveadmin";
		}

		if(Left(Line,21) ~= "give admin to player ")
		{
			j = int(Right(Line, Len(Line)-21));
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(DXP.PlayerReplicationInfo.PlayerID == j)
				{
					RememberPlayer = DXP;
					RememberName = DXP.PlayerReplicationInfo.PlayerName;
				}
			}
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
						bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "giveadmin";
		}
		
		if(Left(Line,11) ~= "blind name ")
		{
			savename = Right(Line, Len(Line)-11);
							if(SaveName == "") return;
			colstr = savename;
			savename = AM.RCR(savename);
			savename = AM.RCR2(savename);
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(instr(caps(DXP.PlayerReplicationInfo.PlayerName), caps(savename)) != -1 || instr(caps(AM.GetNick(DXP)), caps(savename)) != -1 || instr(caps(DXP.PlayerReplicationInfo.PlayerName), caps(colstr)) != -1 || instr(caps(AM.GetNick(DXP)), caps(colstr)) != -1 )
				{
					RememberPlayer = DXP;
					RememberName = DXP.PlayerReplicationInfo.PlayerName;
				}
			}
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "blind";
		}

		if(Left(Line,13) ~= "blind player ")
		{
			j = int(Right(Line, Len(Line)-13));
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(DXP.PlayerReplicationInfo.PlayerID == j)
				{
					RememberPlayer = DXP;
					RememberName = DXP.PlayerReplicationInfo.PlayerName;
				}
			}
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
						bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "blind";
		}

		if(Left(Line,10) ~= "burn name ")
		{
			savename = Right(Line, Len(Line)-10);
							if(SaveName == "") return;
			colstr = savename;
			savename = AM.RCR(savename);
			savename = AM.RCR2(savename);
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(instr(caps(DXP.PlayerReplicationInfo.PlayerName), caps(savename)) != -1 || instr(caps(AM.GetNick(DXP)), caps(savename)) != -1 || instr(caps(DXP.PlayerReplicationInfo.PlayerName), caps(colstr)) != -1 || instr(caps(AM.GetNick(DXP)), caps(colstr)) != -1 )
				{
					RememberPlayer = DXP;
					RememberName = DXP.PlayerReplicationInfo.PlayerName;
				}
			}
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "burn";
		}

		if(Left(Line,12) ~= "burn player ")
		{
			j = int(Right(Line, Len(Line)-12));
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(DXP.PlayerReplicationInfo.PlayerID == j)
				{
					RememberPlayer = DXP;
					RememberName = DXP.PlayerReplicationInfo.PlayerName;
				}
			}
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
						bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "burn";
		}
		
		if(Left(Line,21) ~= "take admin from name ")
		{
			savename = Right(Line, Len(Line)-21);
							if(SaveName == "") return;
			colstr = savename;
			savename = AM.RCR(savename);
			savename = AM.RCR2(savename);
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(instr(caps(DXP.PlayerReplicationInfo.PlayerName), caps(savename)) != -1 || instr(caps(AM.GetNick(DXP)), caps(savename)) != -1 || instr(caps(DXP.PlayerReplicationInfo.PlayerName), caps(colstr)) != -1 || instr(caps(AM.GetNick(DXP)), caps(colstr)) != -1 )
				{
					RememberPlayer = DXP;
					RememberName = DXP.PlayerReplicationInfo.PlayerName;
				}
			}
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
						bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "takeadmin";
		}

		if(Left(Line,23) ~= "take admin from player ")
		{
			j = int(Right(Line, Len(Line)-23));
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(DXP.PlayerReplicationInfo.PlayerID == j)
				{
					RememberPlayer = DXP;
					RememberName = DXP.PlayerReplicationInfo.PlayerName;
				}
			}
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
						bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "takeadmin";
		}
		
		if(Left(Line,10) ~= "smite bot ")
		{
			RememberName = Right(Line, Len(Line)-10);
			if(RememberName == "") return;
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			if(AM.bAllowWhitelist)
				bCheckingWhitelist=True;
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "smitebot";
		}
		
		if(Left(Line,10) ~= "heal name ")
		{
			savename = Right(Line, Len(Line)-10);
			if(SaveName == "") return;
			colstr = savename;
			savename = AM.RCR(savename);
			savename = AM.RCR2(savename);
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(instr(caps(DXP.PlayerReplicationInfo.PlayerName), caps(savename)) != -1 || instr(caps(AM.GetNick(DXP)), caps(savename)) != -1 || instr(caps(DXP.PlayerReplicationInfo.PlayerName), caps(colstr)) != -1 || instr(caps(AM.GetNick(DXP)), caps(colstr)) != -1 )
				{
					RememberPlayer = DXP;
					RememberName = DXP.PlayerReplicationInfo.PlayerName;
				}
			}
						AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "heal";
		}

		if(Left(Line,5) ~= "rcon ")
		{
			if(sendtype == "player")
			{
			
			RememberString = Right(Line, Len(Line)-5);
			if(RememberString == "")
			{
				ASay("Please enter a command string that references RCON Mutator.");
				RememberString="";
				return;
			}
			RememberName = Left(s, InStr(s,"("));
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == RememberName)
					{
						RememberPlayer = DXP;
					}
				}
			SetTimer(0.6,False);
			bPublicCommand=True;
			AStatus("Thinking...");
			StoredCommand = "rcon";
			}
		}
		if(Left(Line,5) ~= ".mut ")
		{
			if(sendtype == "player")
			{
			
			RememberString = Right(Line, Len(Line)-5);
			if(RememberString == "")
			{
				ASay("Please enter a command string that references Mutator commands.");
				RememberString="";
				return;
			}
			RememberName = Left(s, InStr(s,"("));
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == RememberName)
					{
						RememberPlayer = DXP;
					}
				}
			SetTimer(0.6,False);
			bPublicCommand=True;
			AStatus("Thinking...");
			StoredCommand = "mutate";
			}
		}
			
		if(Left(Line,12) ~= "mark player ")
		{
			j = int(Right(Line, Len(Line)-12));
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(DXP.PlayerReplicationInfo.PlayerID == j)
				{
					RememberPlayer = DXP;
					RememberName = DXP.PlayerReplicationInfo.PlayerName;
				}
			}
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "addmark";
		}
		
		if(Left(Line,10) ~= "mark name ")
		{
			savename = Right(Line, Len(Line)-10);
							if(SaveName == "") return;
			colstr = savename;
			savename = AM.RCR(savename);
			savename = AM.RCR2(savename);
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(instr(caps(DXP.PlayerReplicationInfo.PlayerName), caps(savename)) != -1 || instr(caps(AM.GetNick(DXP)), caps(savename)) != -1 || instr(caps(DXP.PlayerReplicationInfo.PlayerName), caps(colstr)) != -1 || instr(caps(AM.GetNick(DXP)), caps(colstr)) != -1 )
				{
					RememberPlayer = DXP;
					RememberName = DXP.PlayerReplicationInfo.PlayerName;
				}
			}
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "addmark";
		}

		if(Left(Line,22) ~= "athena, ignore player ")
		{
			j = int(Right(Line, Len(Line)-22));
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(DXP.PlayerReplicationInfo.PlayerID == j)
				{
					RememberPlayer = DXP;
					RememberName = DXP.PlayerReplicationInfo.PlayerName;
				}
			}
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "ignore";
		}

		if(Left(Line,25) ~= "athena, whitelist player ")
		{
			j = int(Right(Line, Len(Line)-25));
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(DXP.PlayerReplicationInfo.PlayerID == j)
				{
					RememberPlayer = DXP;
					RememberName = DXP.PlayerReplicationInfo.PlayerName;
				}
			}
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "whitelist";
		}
			
		if(Left(Line,23) ~= "generate password, max ")
		{
			rememberint = int(Right(Line, Len(Line)-23));
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "generatepass";
		}

	  	if(instr(caps(Line), caps("remove game password")) != -1 || instr(caps(Line), caps("athena, open the server")) != -1)
		{
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "removepass";
		}
		
		if(Left(Line,21) ~= "set game password to ")
		{
			rememberstring = Right(Line, Len(Line)-21);
							if(rememberstring == "") return;
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "setpassword";
		}
		
		if(Left(Line,20) ~= "athena, ignore name ")
		{
			savename = Right(Line, Len(Line)-20);
							if(SaveName == "") return;
			colstr = savename;
			savename = AM.RCR(savename);
			savename = AM.RCR2(savename);
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(instr(caps(DXP.PlayerReplicationInfo.PlayerName), caps(savename)) != -1 || instr(caps(AM.GetNick(DXP)), caps(savename)) != -1 || instr(caps(DXP.PlayerReplicationInfo.PlayerName), caps(colstr)) != -1 || instr(caps(AM.GetNick(DXP)), caps(colstr)) != -1 )
				{
					RememberPlayer = DXP;
					RememberName = DXP.PlayerReplicationInfo.PlayerName;
				}
			}
			AuthPlayerName = Sender;
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "ignore";
		}
		
		if(Left(Line,23) ~= "athena, whitelist name ")
		{
			savename = Right(Line, Len(Line)-23);
							if(SaveName == "") return;
			colstr = savename;
			savename = AM.RCR(savename);
			savename = AM.RCR2(savename);
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(instr(caps(DXP.PlayerReplicationInfo.PlayerName), caps(savename)) != -1 || instr(caps(AM.GetNick(DXP)), caps(savename)) != -1 || instr(caps(DXP.PlayerReplicationInfo.PlayerName), caps(colstr)) != -1 || instr(caps(AM.GetNick(DXP)), caps(colstr)) != -1 )
				{
					RememberPlayer = DXP;
					RememberName = DXP.PlayerReplicationInfo.PlayerName;
				}
			}
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "whitelist";
		}
			
	  	if(instr(caps(Line), caps("smite me")) != -1 || (instr(caps(Line), caps("athena")) != -1 && instr(caps(Line), caps("kill me")) != -1))
		{
			if(sendtype == "player")
			{
			AuthPlayerName = Sender;
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
						RememberPlayer = DXP;
					}
				}
			SetTimer(1,False);
			bPublicCommand=True;
			AStatus("Thinking...");
			StoredCommand = "smite";
			}
		}
		
	  	if(instr(caps(Line), caps("athena")) != -1 && (instr(caps(Line), caps("clear")) != -1 || instr(caps(Line), caps("reset")) != -1) && instr(caps(Line), caps("ignore")) != -1)
		{
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			AStatus("Thinking...");
			StoredCommand = "clearignore";
		}

	  	if(instr(caps(Line), caps("athena")) != -1 && (instr(caps(Line), caps("clear")) != -1 || instr(caps(Line), caps("reset")) != -1) && instr(caps(Line), caps("whitelist")) != -1)
		{
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			AStatus("Thinking...");
			StoredCommand = "clearwhitelist";
		}
		
	  	if(instr(caps(Line), caps("athena")) != -1 && (instr(caps(Line), caps("clear")) != -1 || instr(caps(Line), caps("reset")) != -1) && instr(caps(Line), caps("marks")) != -1)
		{
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			AStatus("Thinking...");
			StoredCommand = "markclear";
		}
		
	  	if(instr(caps(Line), caps("clear all memos")) != -1 || instr(caps(Line), caps("delete all memos")) != -1)
		{
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			AStatus("Thinking...");
			StoredCommand = "memozero";
		}
	
	  	if(instr(caps(Line), caps("clear all comments")) != -1 || instr(caps(Line), caps("delete all comments")) != -1)
		{
			AuthPlayerName = Sender;
			
			if(Sendtype == "player")
			{
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
					}
				}
			}
			SetTimer(1,False);
			bCheckingAuth = True;
			bInitBroadcast = True;
			AStatus("Thinking...");
			StoredCommand = "commentzero";
		}
				
		if(instr(caps(Line), caps("heal me")) != -1)
		{
			if(sendtype == "player")
			{
			AuthPlayerName = Sender;
				foreach AllActors(class'DeusExPlayer',DXP)
				{
					if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
					{
						CheckAuthPlayer = DXP;
						RememberPlayer = DXP;
					}
				}
			SetTimer(1,False);
			if(AM.bAllowWhitelist)
				bCheckingWhitelist=True;
			bCheckingAuth = True;
			bInitBroadcast = True;
			bHurryUp=True;
			AStatus("Thinking...");
			StoredCommand = "heal";
			}
		}
			
		if(Left(Line,6) ~= "!talk ")
		{
			if(sendtype == "player")
			{
				aText = Right(Line, Len(Line) - 6);
				AM.SendTextToAIClient(aText);
			}
		}	
		if(Sendtype ~= "irc" || Sendtype ~= "telnet")
		{
			
			if(Left(Line,1) ~= "!" && AM.bAllowChatCommands)
			{
				atagz = Right(s, Len(s)-instr(s,"!")-Len("!"));
				
				if(instr(caps(atagz), caps(" ")) != -1) //Assuming theres other words after
				{
					//atagzextra = right(atagz, InStr(atagz," "));
					atagzextra = Right(atagz, Len(atagz)-instr(atagz," ")-Len(" "));
					//atagz = Left(atagz, Len(atagz)-instr(atagz," ")-Len(" "));
				}
				
				if(atagz ~= "motd")
				{
					ADelaySay(AM.MOTD,1);
				}
				else if(Left(atagz,5)  ~= "motd ")
				{
					foreach AllActors(class'DeusExPlayer', DXP)
					{
						if(DXP.PlayerReplicationInfo.Playername ~= Sender)
						{
							if(DXP.bAdmin)
							{
								ASay("MOTD changed to"@atagzextra);
								AM.MOTD = atagzextra;
								AM.SaveConfig();
							}

						}
					}
				}
				else if(atagz ~= "abort")
				{
					foreach AllActors(class'DeusExPlayer',DXP)
					{
						if(DXP.PlayerReplicationInfo.PlayerName == Sender)
						{
							Triggerer = DXP;
						}
					}
					if(Triggerer.bAdmin)
					{
						if(SDA != None)
						{
							if(AM.shutdownAbortSound != none)
							{
								foreach AllActors(class'DeusExPlayer',DXP)
								{
									DXP.PlaySound(AM.shutdownAbortSound, SLOT_Interface,,, 256);					
								}
							}
							SDA.Destroy();
							SDA = none;
							ASay("Shutdown cancelled.");
						}		
					}

				}
				else if(Left(atagz,8) ~= "randstr ")
				{
					rememberint = int(atagzextra);
					SetTimer(0.5,False);
					bPublicCommand = True;
					AStatus("Thinking...");
					StoredCommand = "randomstring";
				}
				else if(Left(atagz,9) ~= "randchar ")
				{
					rememberint = int(atagzextra);
					SetTimer(0.5,False);
					bPublicCommand = True;
					AStatus("Thinking...");
					StoredCommand = "randomchar";
				}
				else if(Left(atagz,6) ~= "arand ")
				{
					foreach AllActors(class'DeusExPlayer',DXP)
					{
						if(DXP.PlayerReplicationInfo.PlayerName == Sender)
						{
							Triggerer = DXP;
						}
					}
					if(instr(caps(atagzextra), caps("d")) != -1)
					{
						aSides = int(Right(atagzextra, Len(atagzextra)-instr(atagzextra,"d")-Len("d")));
						aDice = int(Left(atagzextra, InStr(atagzextra,"d")));
						while(aRolls < aDice)
						{
							aTotal += Rand(aSides+1);
							aRolls++;
						}
						BroadcastMessage(Sendtype$" rolls "$aDice$" "$aSides$"-sided dice...."@aTotal);
					}
					else
					BroadcastMessage("Error in formatting.");
				}
				else if(atagz ~= "pk1")
				{
					if(peacekeeper != 0)
						return;
					AuthPlayerName = Sender;
					
					if(Sendtype == "player")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
							{
								CheckAuthPlayer = DXP;
							}
						}
					}
					
					SetTimer(1,False);
					bCheckingAuth = True;
					AStatus("Thinking...");
					bInitBroadcast=True;
					StoredCommand = "peacekeeperone";
				}
				else if(atagz ~= "pk2")
				{
					if(peacekeeper != 0)
						return;
					AuthPlayerName = Sender;
					
					if(Sendtype == "player")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
							{
								CheckAuthPlayer = DXP;
							}
						}
					}
					
					SetTimer(1,False);
					bCheckingAuth = True;
					AStatus("Thinking...");
					bInitBroadcast=True;
					StoredCommand = "peacekeepertwo";
				}
				else if(atagz ~= "aw")
				{
					if(AM.bProtocolA == True)
						return;
					AuthPlayerName = Sender;
					
					if(Sendtype == "player")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
							{
								CheckAuthPlayer = DXP;
							}
						}
					}
					
					SetTimer(1,False);
					bCheckingAuth = True;
					AStatus("Thinking...");
					bInitBroadcast=True;
					StoredCommand = "awatchper";
				}
				else if(atagz ~= "awoff")
				{
					if(AM.bProtocolA == False)
						return;
					AuthPlayerName = Sender;
					
					if(Sendtype == "player")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
							{
								CheckAuthPlayer = DXP;
							}
						}
					}
					
					SetTimer(1,False);
					bCheckingAuth = True;
					AStatus("Thinking...");
					bInitBroadcast=True;
					StoredCommand = "awatchperoff";
				}
				else if(atagz ~= "pk0")
				{
					if(peacekeeper == 0)
						return;
					AuthPlayerName = Sender;
					
					if(Sendtype == "player")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
							{
								CheckAuthPlayer = DXP;
							}
						}
					}
					
					SetTimer(1,False);
					bCheckingAuth = True;
					AStatus("Thinking...");
					bInitBroadcast=True;
					StoredCommand = "peacekeepernone";
				}
				
			}
			
		}
		if(Sendtype == "player")
		{
			
			if(Left(Line,1) ~= "." && AM.bAllowIRCCommands)
			{
				foreach AllActors(class'IRCLink',IRC)
				{
					if(IRC != None)
					{
						Log("Command sent by game: "$line,'IRC');
						IRC.SendMessage(line);
					}
				}
			}
			
			if(instr(caps(S), caps("#")) != -1 && AM.bAllowHashTag)
			{
				atagz = Right(s, Len(s)-instr(s,"#")-Len("#"));
				if(instr(caps(atagz), caps(" ")) != -1) //Assuming theres other words after
				{
					atagz = Left(atagz, InStr(atagz," "));
				}
				if(atagz == "")
					return;
					
				AM.Topic = "#"$atagz;
				ASay("Topic was changed. #"$atagz$"");
				//ASay("Reading"@atagz$". Is this correct?");
				return;
			}
		
			//if(instr(caps(S), caps("!")) != -1)
			if(Left(Line,1) ~= "!" && AM.bAllowChatCommands)
			{
				atagz = Right(s, Len(s)-instr(s,"!")-Len("!"));
				
				if(instr(caps(atagz), caps(" ")) != -1) //Assuming theres other words after
				{
					//atagzextra = right(atagz, InStr(atagz," "));
					atagzextra = Right(atagz, Len(atagz)-instr(atagz," ")-Len(" "));
					//atagz = Left(atagz, Len(atagz)-instr(atagz," ")-Len(" "));
				}
					if(atagz ~= "credits")
					{
						foreach AllActors(class'DeusExPlayer', DXP)
						{
							if(DXP.PlayerReplicationInfo.Playername ~= Sender)
							{
								ASay("Your credits count is"@DXP.Credits);
							}
						}
					}
					if(atagz ~= "motd")
					{
						ADelaySay(AM.MOTD,1);
					}
					else if(Left(atagz,5)  ~= "motd ")
					{
						foreach AllActors(class'DeusExPlayer', DXP)
						{
							if(DXP.PlayerReplicationInfo.Playername ~= Sender)
							{
								if(DXP.bAdmin)
								{
									ASay("MOTD changed to"@atagzextra);
									AM.MOTD = atagzextra;
									AM.SaveConfig();
								}

							}
						}
					}
					else if(atagz ~= "abort")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(Triggerer.bAdmin)
						{
							if(SDA != None)
							{
								if(AM.shutdownAbortSound != none)
								{
									foreach AllActors(class'DeusExPlayer',DXP)
									{
										DXP.PlaySound(AM.shutdownAbortSound, SLOT_Interface,,, 256);					
									}
								}
								SDA.Destroy();
								SDA = none;
								ASay("Shutdown cancelled.");
							}		
						}

					}
					else if(Left(atagz,8) ~= "randstr ")
					{
						rememberint = int(atagzextra);
						SetTimer(0.5,False);
						bPublicCommand = True;
						AStatus("Thinking...");
						StoredCommand = "randomstring";
					}
					else if(Left(atagz,9) ~= "randchar ")
					{
						rememberint = int(atagzextra);
						SetTimer(0.5,False);
						bPublicCommand = True;
						AStatus("Thinking...");
						StoredCommand = "randomchar";
					}
					else if(Left(atagz,7) ~= "summon ")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(Triggerer.bAdmin)
							Triggerer.consolecommand("summon"@atagzextra);
						else
							Triggerer.Consolecommand("mutate rcon.summon"@atagzextra);

					}
					else if(Left(atagz,6) ~= "arand ")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(instr(caps(atagzextra), caps("d")) != -1)
						{
							aSides = int(Right(atagzextra, Len(atagzextra)-instr(atagzextra,"d")-Len("d")));
							aDice = int(Left(atagzextra, InStr(atagzextra,"d")));
							while(aRolls < aDice)
							{
								aTotal += Rand(aSides);
								aRolls++;
							}
							BroadcastMessage(Triggerer.PlayerReplicationInfo.PlayerName$" rolls "$aDice$" "$aSides$"-sided dice...."@aTotal);
						}
						else
						BroadcastMessage("Error in formatting.");
					}
					else if(Left(atagz,2) ~= "r ")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(AM.bMutatorAdmin && !Triggerer.bAdmin)
						{
							Triggerer.bAdmin = True;
							bWasAdmin=True;
						}
						Triggerer.ConsoleCommand("mutate rcon."$atagzextra);
							if(bWasAdmin)
								Triggerer.bAdmin = false;

					}
					else if(Left(atagz,4) ~= "mut ")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(AM.bMutatorAdmin && !Triggerer.bAdmin)
						{
							Triggerer.bAdmin = True;
							bWasAdmin=True;
						}
						Triggerer.ConsoleCommand("mutate "$atagzextra);
							if(bWasAdmin)
								Triggerer.bAdmin = false;

					}
					else if(atagz ~= "ping")
					{
						foreach AllActors(class'DeusExPlayer', DXP)
						{
							if(DXP.PlayerReplicationInfo.Playername ~= Sender)
							{
								ASay("Your ping is"@DXP.PlayerReplicationInfo.Ping);
							}
						}
					}
					else if(atagz ~= "testrot")
					{
						foreach AllActors(class'DeusExPlayer', DXP)
						{
							if(DXP.PlayerReplicationInfo.Playername ~= Sender)
							{
								ASay("Your rotation is"@DXP.ViewRotation);
							}
						}
					}
					else if(atagz ~= "nick")
					{
						foreach AllActors(class'DeusExPlayer', DXP)
						{
							if(DXP.PlayerReplicationInfo.Playername ~= Sender)
							{
								ASay("Your nick is"@AM.GetNick(DXP));
							}
						}
					}
					else if(Left(atagz,5)  ~= "nick ")
					{
						foreach AllActors(class'DeusExPlayer', DXP)
						{
							if(DXP.PlayerReplicationInfo.Playername ~= Sender)
							{
								ASay("Your nick is changed.");
								DXP.consolecommand("Mutate nick"@atagzextra);
							}
						}
					} 
					else if(atagz ~= "song")
					{
						foreach AllActors(class'PlayerPawn', PP)
						{
							if(PP.PlayerReplicationInfo.Playername ~= Sender)
							{
								ASay("Your track is"@string(PP.Song));
							}
						}
					} 
					else if(atagz ~= "pk1")
					{
						if(peacekeeper != 0)
							return;
						AuthPlayerName = Sender;
						
						if(Sendtype == "player")
						{
							foreach AllActors(class'DeusExPlayer',DXP)
							{
								if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
								{
									CheckAuthPlayer = DXP;
								}
							}
						}
						
						SetTimer(1,False);
						bCheckingAuth = True;
						AStatus("Thinking...");
						bInitBroadcast=True;
						StoredCommand = "peacekeeperone";
					}
					else if(atagz ~= "pk2")
					{
						if(peacekeeper != 0)
							return;
						AuthPlayerName = Sender;
						
						if(Sendtype == "player")
						{
							foreach AllActors(class'DeusExPlayer',DXP)
							{
								if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
								{
									CheckAuthPlayer = DXP;
								}
							}
						}
						
						SetTimer(1,False);
						bCheckingAuth = True;
						AStatus("Thinking...");
						bInitBroadcast=True;
						StoredCommand = "peacekeepertwo";
					}
					else if(atagz ~= "aw")
					{
						if(AM.bProtocolA == True)
							return;
						AuthPlayerName = Sender;
						
						if(Sendtype == "player")
						{
							foreach AllActors(class'DeusExPlayer',DXP)
							{
								if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
								{
									CheckAuthPlayer = DXP;
								}
							}
						}
						
						SetTimer(1,False);
						bCheckingAuth = True;
						AStatus("Thinking...");
						bInitBroadcast=True;
						StoredCommand = "awatchper";
					}
					else if(atagz ~= "awoff")
					{
						if(AM.bProtocolA == False)
							return;
						AuthPlayerName = Sender;
						
						if(Sendtype == "player")
						{
							foreach AllActors(class'DeusExPlayer',DXP)
							{
								if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
								{
									CheckAuthPlayer = DXP;
								}
							}
						}
						
						SetTimer(1,False);
						bCheckingAuth = True;
						AStatus("Thinking...");
						bInitBroadcast=True;
						StoredCommand = "awatchperoff";
					}
					else if(atagz ~= "pk0")
					{
						if(peacekeeper == 0)
							return;
						AuthPlayerName = Sender;
						
						if(Sendtype == "player")
						{
							foreach AllActors(class'DeusExPlayer',DXP)
							{
								if(DXP.PlayerReplicationInfo.PlayerName == AuthPlayerName)
								{
									CheckAuthPlayer = DXP;
								}
							}
						}
						
						SetTimer(1,False);
						bCheckingAuth = True;
						AStatus("Thinking...");
						bInitBroadcast=True;
						StoredCommand = "peacekeepernone";
					}
					else if(atagz ~= "topic")
					{
						SetTimer(1,False);
						bPublicCommand = True;
						AStatus("Thinking...");
						StoredCommand = "saytopic";
					}
					else if(Left(atagz,6)  ~= "topic ")
					{
						SetTimer(1,False);
						RememberString = atagzextra;
						bPublicCommand = True;
						AStatus("Thinking...");
						StoredCommand = "topic";
					}
					else if(atagz ~= "repeat")
					{
						RememberName = Sender;
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == RememberName)
							{
								RememberPlayer = DXP;
							}
						}
						SetTimer(1,False);
						bDontLog=True;
						bPublicCommand = True;
						AStatus("Thinking...");
						bDontLog=True;
						StoredCommand = "chatlogrepeat";
					}
					else if(atagz ~= "dist")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						loc = Triggerer.Location;
						loc.Z += Triggerer.BaseEyeHeight;
						vline = Vector(Triggerer.ViewRotation) * 10000;
						Trace(hitLocation, hitNormal, loc+vline, loc, true);
						TargetRange -= Abs(VSize(Triggerer.Location - HitLocation));
						ASay("I calculate that distance as"@TargetRange);
					}
					else if(atagz ~= "loc")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						loc = Triggerer.Location;
						loc.Z += Triggerer.BaseEyeHeight;
						vline = Vector(Triggerer.ViewRotation) * 10000;
						Trace(hitLocation, hitNormal, loc+vline, loc, true);
						TargetRange -= Abs(VSize(Triggerer.Location - HitLocation));
						ASay("Your crosshair's location is"@string(hitlocation));
					}
					else if(Left(atagz,7)  ~= "setloc ")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(Triggerer.bAdmin)
						{
							loc = Triggerer.Location;
							loc.Z += Triggerer.BaseEyeHeight;
							vline = Vector(Triggerer.ViewRotation) * 10000;
							HitActor = Trace(hitLocation, hitNormal, loc+vline, loc, true);
					
							if (hitActor != None && !hitActor.isA('LevelInfo'))
							{
								hitActor.SetLocation(Vector(atagzextra));
								ASay(string(hitActor.class)@"moved to "$vector(atagzextra)$".");
							}					
						}
					}	
					else if(Left(atagz,7)  ~= "setrot ")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(Triggerer.bAdmin || IsWhitelisted(Triggerer))
						{
							loc = Triggerer.Location;
							loc.Z += Triggerer.BaseEyeHeight;
							vline = Vector(Triggerer.ViewRotation) * 10000;
							HitActor = Trace(hitLocation, hitNormal, loc+vline, loc, true);
					
							if (hitActor != None && !hitActor.isA('LevelInfo'))
							{
								hitActor.setrotation(rotator(atagzextra));
								ASay(string(hitActor.class)@"rotated to "$rotator(atagzextra)$".");
							}					
						}
					}		
					else if(Left(atagz,9)  ~= "offset.x ")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(Triggerer.bAdmin || IsWhitelisted(Triggerer))
						{
							loc = Triggerer.Location;
							loc.Z += Triggerer.BaseEyeHeight;
							vline = Vector(Triggerer.ViewRotation) * 10000;
							HitActor = Trace(hitLocation, hitNormal, loc+vline, loc, true);
					
							if (hitActor != None && !hitActor.isA('LevelInfo'))
							{
								altloc = hitactor.location;
								altloc.x += int(atagzextra);
									if(AM.bCollisionDebug)
									{
										hitActor.SetCollision(false, false, false);
										hitActor.bCollideWorld = false;
									}
								hitActor.SetLocation(altloc);
									if(AM.bCollisionDebug)
									{
										hitActor.SetCollision(true, true, true);
										hitActor.bCollideWorld = hitactor.default.bCollideWorld;
									}
								//ASay(string(hitActor.class)$" location was altered by "$int(atagzextra)$".");
							}					
						}
					}
					else if(Left(atagz,10)  ~= "offset.x -")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(Triggerer.bAdmin || IsWhitelisted(Triggerer))
						{
							loc = Triggerer.Location;
							loc.Z += Triggerer.BaseEyeHeight;
							vline = Vector(Triggerer.ViewRotation) * 10000;
							HitActor = Trace(hitLocation, hitNormal, loc+vline, loc, true);
					
							if (hitActor != None && !hitActor.isA('LevelInfo'))
							{
								altloc = hitactor.location;
								altloc.x -= int(Right(atagzextra, Len(atagzextra)-instr(atagzextra,"-")-Len("-")));

									if(AM.bCollisionDebug)
									{
										hitActor.SetCollision(false, false, false);
										hitActor.bCollideWorld = false;
									}
								hitActor.SetLocation(altloc);
									if(AM.bCollisionDebug)
									{
										hitActor.SetCollision(true, true, true);
										hitActor.bCollideWorld = hitactor.default.bCollideWorld;
									}
								//ASay(string(hitActor.class)$" location was altered by "$int(atagzextra)$"."$int(Right(atagzextra, Len(atagzextra)-instr(atagzextra,"-")-Len("-"))));
							}					
						}
					}
					else if(Left(atagz,9)  ~= "offset.y ")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(Triggerer.bAdmin || IsWhitelisted(Triggerer))
						{
							loc = Triggerer.Location;
							loc.Z += Triggerer.BaseEyeHeight;
							vline = Vector(Triggerer.ViewRotation) * 10000;
							HitActor = Trace(hitLocation, hitNormal, loc+vline, loc, true);
					
							if (hitActor != None && !hitActor.isA('LevelInfo'))
							{
								altloc = hitactor.location;
								altloc.y += int(atagzextra);

									if(AM.bCollisionDebug)
									{
										hitActor.SetCollision(false, false, false);
										hitActor.bCollideWorld = false;
									}
								hitActor.SetLocation(altloc);
									if(AM.bCollisionDebug)
									{
										hitActor.SetCollision(true, true, true);
										hitActor.bCollideWorld = hitactor.default.bCollideWorld;
									}
								//ASay(string(hitActor.class)$" location was altered by "$int(atagzextra)$".");
							}					
						}
					}
					else if(Left(atagz,10)  ~= "offset.y -")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(Triggerer.bAdmin || IsWhitelisted(Triggerer))
						{
							loc = Triggerer.Location;
							loc.Z += Triggerer.BaseEyeHeight;
							vline = Vector(Triggerer.ViewRotation) * 10000;
							HitActor = Trace(hitLocation, hitNormal, loc+vline, loc, true);
					
							if (hitActor != None && !hitActor.isA('LevelInfo'))
							{
								altloc = hitactor.location;
								altloc.y -= int(Right(atagzextra, Len(atagzextra)-instr(atagzextra,"-")-Len("-")));

									if(AM.bCollisionDebug)
									{
										hitActor.SetCollision(false, false, false);
										hitActor.bCollideWorld = false;
									}
								hitActor.SetLocation(altloc);
									if(AM.bCollisionDebug)
									{
										hitActor.SetCollision(true, true, true);
										hitActor.bCollideWorld = hitactor.default.bCollideWorld;
									}
								//ASay(string(hitActor.class)$" location was altered by "$int(atagzextra)$"."$int(Right(atagzextra, Len(atagzextra)-instr(atagzextra,"-")-Len("-"))));
							}					
						}
					}
					else if(Left(atagz,9)  ~= "offset.z ")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(Triggerer.bAdmin || IsWhitelisted(Triggerer))
						{
							loc = Triggerer.Location;
							loc.Z += Triggerer.BaseEyeHeight;
							vline = Vector(Triggerer.ViewRotation) * 10000;
							HitActor = Trace(hitLocation, hitNormal, loc+vline, loc, true);
					
							if (hitActor != None && !hitActor.isA('LevelInfo'))
							{
								altloc = hitactor.location;
								altloc.z += int(atagzextra);

									if(AM.bCollisionDebug)
									{
										hitActor.SetCollision(false, false, false);
										hitActor.bCollideWorld = false;
									}
								hitActor.SetLocation(altloc);
									if(AM.bCollisionDebug)
									{
										hitActor.SetCollision(true, true, true);
										hitActor.bCollideWorld = hitactor.default.bCollideWorld;
									}
								//ASay(string(hitActor.class)$" location was altered by "$int(atagzextra)$".");
							}					
						}
					}
					else if(Left(atagz,10)  ~= "offset.z -")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(Triggerer.bAdmin || IsWhitelisted(Triggerer))
						{
							loc = Triggerer.Location;
							loc.Z += Triggerer.BaseEyeHeight;
							vline = Vector(Triggerer.ViewRotation) * 10000;
							HitActor = Trace(hitLocation, hitNormal, loc+vline, loc, true);
					
							if (hitActor != None && !hitActor.isA('LevelInfo'))
							{
								altloc = hitactor.location;
								altloc.z -= int(Right(atagzextra, Len(atagzextra)-instr(atagzextra,"-")-Len("-")));

									if(AM.bCollisionDebug)
									{
										hitActor.SetCollision(false, false, false);
										hitActor.bCollideWorld = false;
									}
								hitActor.SetLocation(altloc);
									if(AM.bCollisionDebug)
									{
										hitActor.SetCollision(true, true, true);
										hitActor.bCollideWorld = hitactor.default.bCollideWorld;
									}
								//ASay(string(hitActor.class)$" location was altered by "$int(atagzextra)$"."$int(Right(atagzextra, Len(atagzextra)-instr(atagzextra,"-")-Len("-"))));
							}					
						}
					}
					else if(Left(atagz,13)  ~= "rotate.pitch ")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(Triggerer.bAdmin || IsWhitelisted(Triggerer))
						{
							loc = Triggerer.Location;
							loc.Z += Triggerer.BaseEyeHeight;
							vline = Vector(Triggerer.ViewRotation) * 10000;
							HitActor = Trace(hitLocation, hitNormal, loc+vline, loc, true);
					
							if (hitActor != None && !hitActor.isA('LevelInfo'))
							{
								altrot = hitactor.rotation;
								altrot.pitch += int(atagzextra);

								hitActor.setrotation(altrot);
								//ASay(string(hitActor.class)$" rotation was altered by "$int(atagzextra)$".");
							}					
						}
					}
					else if(Left(atagz,14)  ~= "rotate.pitch -")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(Triggerer.bAdmin || IsWhitelisted(Triggerer))
						{
							loc = Triggerer.Location;
							loc.Z += Triggerer.BaseEyeHeight;
							vline = Vector(Triggerer.ViewRotation) * 10000;
							HitActor = Trace(hitLocation, hitNormal, loc+vline, loc, true);
					
							if (hitActor != None && !hitActor.isA('LevelInfo'))
							{
								altrot = hitactor.rotation;
								altrot.pitch -= int(Right(atagzextra, Len(atagzextra)-instr(atagzextra,"-")-Len("-")));

								hitActor.Setrotation(altrot);
								//ASay(string(hitActor.class)$" rotation was altered by "$int(atagzextra)$"."$int(Right(atagzextra, Len(atagzextra)-instr(atagzextra,"-")-Len("-"))));
							}					
						}
					}
					else if(Left(atagz,12)  ~= "rotate.roll ")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(Triggerer.bAdmin || IsWhitelisted(Triggerer))
						{
							loc = Triggerer.Location;
							loc.Z += Triggerer.BaseEyeHeight;
							vline = Vector(Triggerer.ViewRotation) * 10000;
							HitActor = Trace(hitLocation, hitNormal, loc+vline, loc, true);
					
							if (hitActor != None && !hitActor.isA('LevelInfo'))
							{
								altrot = hitactor.rotation;
								altrot.roll += int(atagzextra);

								hitActor.Setrotation(altrot);
								//ASay(string(hitActor.class)$" rotation was altered by "$int(atagzextra)$".");
							}					
						}
					}
					else if(Left(atagz,13)  ~= "rotate.roll -")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(Triggerer.bAdmin || IsWhitelisted(Triggerer))
						{
							loc = Triggerer.Location;
							loc.Z += Triggerer.BaseEyeHeight;
							vline = Vector(Triggerer.ViewRotation) * 10000;
							HitActor = Trace(hitLocation, hitNormal, loc+vline, loc, true);
					
							if (hitActor != None && !hitActor.isA('LevelInfo'))
							{
								altrot = hitactor.rotation;
								altrot.roll -= int(Right(atagzextra, Len(atagzextra)-instr(atagzextra,"-")-Len("-")));

								hitActor.Setrotation(altrot);
								//ASay(string(hitActor.class)$" rotation was altered by "$int(atagzextra)$"."$int(Right(atagzextra, Len(atagzextra)-instr(atagzextra,"-")-Len("-"))));
							}					
						}
					}
					else if(Left(atagz,11)  ~= "rotate.yaw ")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(Triggerer.bAdmin || IsWhitelisted(Triggerer))
						{
							loc = Triggerer.Location;
							loc.Z += Triggerer.BaseEyeHeight;
							vline = Vector(Triggerer.ViewRotation) * 10000;
							HitActor = Trace(hitLocation, hitNormal, loc+vline, loc, true);
					
							if (hitActor != None && !hitActor.isA('LevelInfo'))
							{
								altrot = hitactor.rotation;
								altrot.yaw += int(atagzextra);

								hitActor.Setrotation(altrot);
								//ASay(string(hitActor.class)$" rotation was altered by "$int(atagzextra)$".");
							}					
						}
					}
					else if(Left(atagz,12)  ~= "rotate.yaw -")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(Triggerer.bAdmin || IsWhitelisted(Triggerer))
						{
							loc = Triggerer.Location;
							loc.Z += Triggerer.BaseEyeHeight;
							vline = Vector(Triggerer.ViewRotation) * 10000;
							HitActor = Trace(hitLocation, hitNormal, loc+vline, loc, true);
					
							if (hitActor != None && !hitActor.isA('LevelInfo'))
							{
								altrot = hitactor.rotation;
								altrot.yaw -= int(Right(atagzextra, Len(atagzextra)-instr(atagzextra,"-")-Len("-")));

								hitActor.Setrotation(altrot);
								//ASay(string(hitActor.class)$" rotation was altered by "$int(atagzextra)$"."$int(Right(atagzextra, Len(atagzextra)-instr(atagzextra,"-")-Len("-"))));
							}					
						}
					}
					else if(Left(atagz,12)  ~= "athenaspawn ")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(Triggerer.bAdmin)
						{
							if(AM.PrimaryLocation != vect(0,0,0))
							{
								aTemp = atagzextra;
								if ( InStr(aTemp,".") == -1 )
								{
									aTemp="DeusEx." $ aTemp;
								}
								aClass = class<actor>( DynamicLoadObject( aTemp, class'Class' ) );
									if(aClass != None)
									{
										Spawn(aClass,,,AM.PrimaryLocation);
										ASay("Spawning object at primary location.");
									}
							}
						}
					}
					else if(Left(atagz,13)  ~= "athenacreate ")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(Triggerer.bAdmin)
						{
							for(i=0;i<8;i++)
							if(AM.RememberLocation[i] != vect(0,0,0))
							{
								aTemp = atagzextra;
								if ( InStr(aTemp,".") == -1 )
								{
									aTemp="DeusEx." $ aTemp;
								}
								aClass = class<actor>( DynamicLoadObject( aTemp, class'Class' ) );
									if(aClass != None)
									{
										Spawn(aClass,,,AM.RememberLocation[i]);
										ASay("Spawning object at locations.");
									}
							}
						}
					}
					else if(atagz ~= "rememberlocation" || atagz ~= "remloc")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(Triggerer.bAdmin)
						{
							SaveLocRem(Triggerer.Location);
						}
					}
					else if(atagz ~= "rememberprimary" || atagz ~= "rempri")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(Triggerer.bAdmin)
						{
							AM.PrimaryLocation = triggerer.Location;
							ASay("Primary location set at"@triggerer.Location);
						}
					}
					else if(atagz ~= "trigger" || atagz ~= "open" || atagz ~= "trig")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(Triggerer.bAdmin || IsWhitelisted(Triggerer))
						{
							loc = Triggerer.Location;
							loc.Z += Triggerer.BaseEyeHeight;
							vline = Vector(Triggerer.ViewRotation) * 10000;
							HitActor = Trace(hitLocation, hitNormal, loc+vline, loc, true);
					
							if (hitActor != None && !hitActor.isA('LevelInfo'))
							{
								hitActor.Trigger(Triggerer, Triggerer);
								ASay(string(hitActor.class)@"triggered.");
							}					
						}
					}
					else if(atagz ~= "tantalus" || atagz ~= "tant" || atagz ~= "kill")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(Triggerer.bAdmin)
						{
							loc = Triggerer.Location;
							loc.Z += Triggerer.BaseEyeHeight;
							vline = Vector(Triggerer.ViewRotation) * 10000;
							HitActor = Trace(hitLocation, hitNormal, loc+vline, loc, true);
									if (hitActor != None)
									{
										hitMover = DeusExMover(hitActor);
										hitPawn = ScriptedPawn(hitActor);
										hitDecoration = DeusExDecoration(hitActor);
										hitPlayer = PlayerPawn(hitActor);
										if (hitMover != None)
										{
												hitMover.bBreakable   = true;
												hitMover.doorStrength = 0;
												hitMover.TakeDamage(10000, Self, hitLocation, vline, 'Tantalus'); 
												ASay(string(hitMover.class)@"destroyed.");
										}
										else if (hitPawn != None)
										{
												hitPawn.bInvincible    = false;
												hitPawn.HealthHead     = 0;
												hitPawn.HealthTorso    = 0;
												hitPawn.HealthLegLeft  = 0;
												hitPawn.HealthLegRight = 0;
												hitPawn.HealthArmLeft  = 0;
												hitPawn.HealthArmRight = 0;
												hitPawn.Health         = 0;
												hitPawn.TakeDamage(10000, Self, hitLocation, vline, 'Tantalus'); 
												ASay(string(hitPawn.class)@"destroyed.");
										}
										else if (hitDecoration != None)
										{
												hitDecoration.bInvincible = false;
												hitDecoration.HitPoints = 0;
												hitDecoration.TakeDamage(10000, Self, hitLocation, vline, 'Tantalus'); 
												ASay(string(hitDecoration.class)@"destroyed.");
										}
										else if (hitPlayer != None)
										{
											hitPlayer.ReducedDamageType = '';
											hitActor.TakeDamage(5000, Self, hitLocation, vline, 'Tantalus'); 
											ASay(string(hitactor.class)@"destroyed.");
										}
										else if (hitActor != Level)
										{
											hitActor.TakeDamage(5000, Self, hitLocation, vline, 'Tantalus');
											ASay(string(hitactor.class)@"destroyed.");
										}
									}										
						}
					}
					else if(atagz  ~= "push")
					{
						pvel = -700;
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(Triggerer.bAdmin)
						{
							loc = Triggerer.Location;
							loc.Z += Triggerer.BaseEyeHeight;
							vline = Vector(Triggerer.ViewRotation) * 10000;
							HitActor = Trace(hitLocation, hitNormal, loc+vline, loc, true);
									if (hitActor != None)
									{
										hitPawn = ScriptedPawn(hitActor);
										hitDecoration = DeusExDecoration(hitActor);
										hitPlayer = PlayerPawn(hitActor);

										if (hitPawn != None)
										{
											hitPawn.SetPhysics(Phys_Falling);
											hitPawn.Velocity = (normal(Triggerer.Location - hitPawn.Location) * pvel);	
										}
										else if (hitDecoration != None)
										{
											hitDecoration.SetPhysics(Phys_Falling);
											hitDecoration.Velocity = (normal(Triggerer.Location - hitDecoration.Location) * pvel);	
										}
										else if (hitPlayer != None)
										{
											hitPlayer.SetPhysics(Phys_Falling);
											hitPlayer.Velocity = (normal(Triggerer.Location - hitPlayer.Location) * pvel);	
										}
									}										
						}
					}
					else if(Left(atagz,5)  ~= "push ")
					{
						if(atagzextra == "")
							pvel = -700;
						else
							pvel = int(atagzextra);
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(Triggerer.bAdmin)
						{
							loc = Triggerer.Location;
							loc.Z += Triggerer.BaseEyeHeight;
							vline = Vector(Triggerer.ViewRotation) * 10000;
							HitActor = Trace(hitLocation, hitNormal, loc+vline, loc, true);
									if (hitActor != None)
									{
										hitPawn = ScriptedPawn(hitActor);
										hitDecoration = DeusExDecoration(hitActor);
										hitPlayer = PlayerPawn(hitActor);

										if (hitPawn != None)
										{
											hitPawn.SetPhysics(Phys_Falling);
											hitPawn.Velocity = (normal(Triggerer.Location - hitPawn.Location) * pvel);	
										}
										else if (hitDecoration != None)
										{
											hitDecoration.SetPhysics(Phys_Falling);
											hitDecoration.Velocity = (normal(Triggerer.Location - hitDecoration.Location) * pvel);	
										}
										else if (hitPlayer != None)
										{
											hitPlayer.SetPhysics(Phys_Falling);
											hitPlayer.Velocity = (normal(Triggerer.Location - hitPlayer.Location) * pvel);	
										}
									}										
						}
					}
					else if(atagz ~= "boom" || atagz ~= "blow" || atagz ~= "detonate")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(Triggerer.bAdmin)
						{
							loc = Triggerer.Location;
							loc.Z += Triggerer.BaseEyeHeight;
							vline = Vector(Triggerer.ViewRotation) * 10000;
							HitActor = Trace(hitLocation, hitNormal, loc+vline, loc, true);
									if (hitActor != None)
									{
										hitMover = DeusExMover(hitActor);
										hitPawn = ScriptedPawn(hitActor);
										hitDecoration = DeusExDecoration(hitActor);
										hitPlayer = PlayerPawn(hitActor);
										if (hitMover != None)
										{
												hitMover.bDrawExplosion = True;
												hitMover.bBreakable   = true;
												hitMover.doorStrength = 0;
												hitMover.TakeDamage(10000, Self, hitLocation, vline, 'Exploded'); 
												ASay(string(hitMover.class)@"destroyed.");
										}
										else if (hitPawn != None)
										{
												hitPawn.bInvincible    = false;
												hitPawn.HealthHead     = 0;
												hitPawn.HealthTorso    = 0;
												hitPawn.HealthLegLeft  = 0;
												hitPawn.HealthLegRight = 0;
												hitPawn.HealthArmLeft  = 0;
												hitPawn.HealthArmRight = 0;
												hitPawn.Health         = 0;
												hitPawn.TakeDamage(1000, Self, hitLocation, vline, 'Exploded'); 
												ASay(string(hitPawn.class)@"destroyed.");
										}
										else if (hitDecoration != None)
										{
												hitDecoration.bExplosive = True;
												hitDecoration.bInvincible = false;
												hitDecoration.HitPoints = 0;
												hitDecoration.TakeDamage(1000, Self, hitLocation, vline, 'Exploded'); 
												ASay(string(hitDecoration.class)@"destroyed.");
										}
										else if (hitPlayer != None)
										{
											hitPlayer.ReducedDamageType = '';
											hitActor.TakeDamage(5000, Self, hitLocation, vline, 'Exploded'); 
											ASay(string(hitactor.class)@"destroyed.");
										}
										else if (hitActor != Level)
										{
											hitActor.TakeDamage(5000, Self, hitLocation, vline, 'Tantalus');
											ASay(string(hitactor.class)@"destroyed.");
										}
									}										
						}
					}
					else if(atagz ~= "lock")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(Triggerer.bAdmin)
						{
							loc = Triggerer.Location;
							loc.Z += Triggerer.BaseEyeHeight;
							vline = Vector(Triggerer.ViewRotation) * 10000;
							HitActor = Trace(hitLocation, hitNormal, loc+vline, loc, true);
					
							if (hitActor != None)
							{
								hitMover = DeusExMover(hitActor);
								if (hitMover != None)
								{
									hitMover.bLocked = !hitMover.bLocked;
									hitMover.bPickable = False;
									ASay(string(hitMover.class)@"is now "$hitMover.bLocked);
								}
							}	
						}
					}
					else if(atagz ~= "inv")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(Triggerer.bAdmin || IsWhitelisted(Triggerer))
						{
							loc = Triggerer.Location;
							loc.Z += Triggerer.BaseEyeHeight;
							vline = Vector(Triggerer.ViewRotation) * 10000;
							HitActor = Trace(hitLocation, hitNormal, loc+vline, loc, true);
						
							if(hitActor != None)
							{
								if(hitActor.isA('DeusExDecoration'))
								{
									DeusExDecoration(hitActor).bInvincible = !DeusExDecoration(hitActor).bInvincible;
									ASay(string(hitActor.class)@"is"@DeusExDecoration(hitActor).bInvincible);
								}
								
								if(hitActor.isA('DeusExPlayer'))
								{
									if(DeusExPlayer(hitActor).ReducedDamageType == 'all')
										DeusExPlayer(hitActor).ReducedDamageType = '';
									else
										DeusExPlayer(hitActor).ReducedDamageType = 'all';
	
									ASay(string(hitActor.class)@"is"@DeusExPlayer(hitActor).reduceddamagetype);
								}
																
								if(hitActor.isA('ScriptedPawn'))
								{
									ScriptedPawn(hitActor).bInvincible = !ScriptedPawn(hitActor).bInvincible;
									ASay(string(hitActor.class)@"is"@ScriptedPawn(hitActor).bInvincible);
								}						
							}
						}
					}
					else if(atagz ~= "pushable" || atagz ~= "frobbable")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(Triggerer.bAdmin || IsWhitelisted(Triggerer))
						{
							loc = Triggerer.Location;
							loc.Z += Triggerer.BaseEyeHeight;
							vline = Vector(Triggerer.ViewRotation) * 10000;
							HitActor = Trace(hitLocation, hitNormal, loc+vline, loc, true);
					
							if (hitActor != None && hitActor.isA('DeusExDecoration'))
							{
								DeusExDecoration(hitActor).bPushable = !DeusExDecoration(hitActor).bPushable;
								ASay(string(hitActor.class)@"is"@DeusExDecoration(hitActor).bPushable);
							}					
						}
					}
					else if(atagz ~= "movable" || atagz ~= "move")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(Triggerer.bAdmin || IsWhitelisted(Triggerer))
						{
							loc = Triggerer.Location;
							loc.Z += Triggerer.BaseEyeHeight;
							vline = Vector(Triggerer.ViewRotation) * 10000;
							HitActor = Trace(hitLocation, hitNormal, loc+vline, loc, true);
					
							if (hitActor != None && (hitActor.isA('DeusExDecoration') || hitActor.IsA('ScriptedPawn') || hitactor.isa('DeusExPlayer')))
							{
								hitActor.bMovable = !hitActor.bMovable;
								ASay(string(hitActor.class)@"is"@hitActor.bMovable);
							}								
						}
					}
					else if(Left(atagz,5)  ~= "find ")
					{
						foreach AllActors(class'Actor', A)
							if(instr(caps(string(a.class)), caps(atagzextra)) != -1)
								count++;
						
						ASay("Search for "$atagzextra$" found "$count$" instances.");
							
					}
					else if(atagz ~= "reach" || atagz ~= "grab")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(Triggerer.bAdmin)
						{
							loc = Triggerer.Location;
							loc.Z += Triggerer.BaseEyeHeight;
							vline = Vector(Triggerer.ViewRotation) * 90000;
							HitActor = Trace(hitLocation, hitNormal, loc+vline, loc, true);
					
							if (hitActor != None && hitActor.isA('DeusExDecoration'))
							{
								hitActor.SetLocation(Triggerer.Location);
								ASay(string(hitActor.class)@"is grabbed");
							}					
						}
					}
					/*else if(Left(atagz,9)  ~= "setstate ")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(Triggerer.bAdmin)
						{
							loc = Triggerer.Location;
							loc.Z += Triggerer.BaseEyeHeight;
							vline = Vector(Triggerer.ViewRotation) * 10000;
							HitActor = Trace(hitLocation, hitNormal, loc+vline, loc, true);
									if (hitActor != None)
									{
										hitActor.GoToState(name(AtagzExtra));
										ASay(hitActor$" state set to "$aTagzExtra);
									}										
						}
					}
					else if(Left(atagz,10)  ~= "setorders ")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(Triggerer.bAdmin)
						{
							loc = Triggerer.Location;
							loc.Z += Triggerer.BaseEyeHeight;
							vline = Vector(Triggerer.ViewRotation) * 10000;
							HitActor = Trace(hitLocation, hitNormal, loc+vline, loc, true);
									if (scriptedPawn(hitActor) != None)
									{
										scriptedPawn(hitActor).SetOrders(name(ATagzExtra),,True);
										ASay(scriptedPawn(hitActor)$" orders set to "$aTagzExtra);
									}										
						}
					}*/
					else if(atagz  ~= "setowner")
					{
						foreach AllActors(class'DeusExPlayer',DXP)
						{
							if(DXP.PlayerReplicationInfo.PlayerName == Sender)
							{
								Triggerer = DXP;
							}
						}
						if(Triggerer.bAdmin)
						{
							loc = Triggerer.Location;
							loc.Z += Triggerer.BaseEyeHeight;
							vline = Vector(Triggerer.ViewRotation) * 10000;
							HitActor = Trace(hitLocation, hitNormal, loc+vline, loc, true);
									if (hitActor != None)
									{
										hitActor.SetOwner(Triggerer);
										ASay("Setting ownership.");
									}										
						}
					}
				//ASay("Reading "$atagz$" as primary, "$atagzextra$" as secondary.");
				return;
			}
		}
			if(!bDontLog)
				AM.AddChatlog(s);
				
		if(am.bDebugMemory)
		{
			
				for(q=0;q<10;q++)
					if(storedlines[q] != "")
					{
						log("Client Recalling "$q$" command "$storedlines[q],'Athena');
						qstr=storedlines[q];
						//ClientMessage(qstr,'Say');
						storedlines[q] = "";
						return;
					}
		}
		
		if(AM.bDebugInput)
		{
				dbg("OUT: REMPLAYER="$RememberPlayer$"("$RememberPlayer.Role$"/"$RememberPlayer.RemoteRole$")   AUTHPLAYER="$CheckAuthPlayer$"("$CheckAuthPlayer.Role$"/"$CheckAuthPlayer.RemoteRole$")    LOG="$!bDontLog$"    COMMAND="$StoredCommand);
				
				if(Level.NetMode == NM_Standalone)
					dbg("NM_Standalone");
				
		}
			
		

	}
}

function SendToChatlog(string str)
{
	AM.AddChatlog(str);
}

function ResetVars()
{
	bPublicCommand=False;
	LastCommand = StoredCommand;
	bLastCommandAuth=False;
	LastRemStr=RememberString;
	LastRemName=RememberName;
	LastRemPlayer=RememberPlayer;
	lastremint=RememberInt;
	
	bCheckingWhitelist=False;
	CheckAuthPlayer=None;
	RememberString="";
	RememberName="";
	RememberPlayer=None;
	StoredCommand="";
	rememberint=0;
	AStatus("");
}

//Rewriting help function
//Currently, it matches the said words against the string config
//New version will match an array? Is this idea even possible..
function SearchHelp(string str)
{
	local int n;
	local bool bFound;
	local DeusExPlayer HP;
	
	if( (instr(caps(str), caps("nothing")) != -1 || instr(caps(str), caps("cancel")) != -1) || (instr(caps(str), caps("nevermind")) != -1 || instr(caps(str), caps("nvm")) != -1) )
	{
		ASay("Fine.");
		bFound=True;
	}
	
	if(Len(str) <= 3)
	{
		ASay("Request string is too short and will output too many replies. Try to be more specific.");
		bFound=True;
	}
	
	for (n=0;n<49;n++)
	{
		if(instr(caps(AM.HelpKeywords[n]), caps(str)) != -1)
		{
			if(AM.bShowMessageHelp)
			{
				ASay("Help printed to screen.");
				foreach AllActors(Class'SM',SMMut)
					if(SMMut != None)
						foreach AllActors(class'DeusExPlayer',HP);
							SMMut.ShowMessage(HP, AM.HelpReply[n]);
			}
			else
				ASay(AM.HelpReply[n]);
			bFound=True;
		}
	}
	
	if(!bFound)
	{
		ASay("No help file found for this keyword. Make sure you're searching for vague keywords to improve searching. ["$str$"]");
	}
}

function bool IsWhitelisted(deusexplayer dxp)
{
	local int n;
	local string str;
	local LoginInfo LI;
	
	foreach AllActors(class'LoginInfo', LI)
	{
		if(LI.Flagger == dxp)
		{
			return LI.bWhitelisted;
		}
	}
	
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

function Timer()
{
local int n, i, amount, r;
local string IP;
local DeusExPlayer DXP;
local string realstr;
local bool bFoundMemo;
local bool bGotAccess;
local DeusExDecoration DXD;
local inventory inv;
local DeusExDecoration Deco;
local scriptedpawn sp;
local actor a;
local bool bFoundSmiteTarget;
local RCONManager RM;
local RCON RC;
local AthRecall AR;
local DelayCMD DCMD;
local bool bFoundOne;
local string remstr;
local string FoundMessage[6];
local string xstr;
local int ra, rb;
local irclink irl;
local string radStr;
local AthenaVision athVis;
local PollBot PB;
local string SetA, SetB;
local int cint;
local string finalauthname, aTemp;
	local vector loc, line, HitLocation, hitNormal;
	local bool bQD;
	local bool bWasAdmin;
	local string ret, addr, state, names, moreinfo;
		local class<actor> aClass;
		local qi q;
	if(storedcommand == "aiclient")
	{
		AM.SendTextToAIClient(rememberstring);
		RememberString="";
		AStatus("");
		ResetVars();
		return;
	}
	
	if(storedcommand == "starthelp2" && rememberstring != "")
	{
		SearchHelp(RememberString);
		RememberString="";
		AStatus("");
		ResetVars();
		return;
	}
	
	if(bGettingHelp && RememberString != "")
	{
		SearchHelp(RememberString);
		bGettingHelp=False;
		RememberString="";
		AStatus("");
		return;
	}
	
	if(bGettingHelp && RememberString == "")
	{
		ASay("No replies in time, cancelling help request.");
		bGettingHelp=False;
		RememberString="";
		AStatus("");
		return;
	}
	
	//Pre-auth zone
	if(bInitBroadcast)
	{
		bInitBroadcast=False;
			/*if(Authplayername == "")
			{
				finalauthname = AM.RCR(GetName(CheckAuthPlayer));
				finalauthname = AM.RCR2(finalauthname);
				Authplayername = finalauthname;
			}*/
			
			if(instr(AuthPlayerName, "] |P1") != -1) //Battleground Status chat fix
				AuthPlayerName = Right(AuthPlayerName, Len(AuthPlayerName)-instr(AuthPlayerName,"] |P1")-Len("] |P1"));
				
		Log("Running Auth player"@Authplayername);
		/*ra = Rand(3);
			if(ra == 0)
				ASay("Please wait, "$Authplayername$". This request requires authentication, I'll need to check the access list.");
			else if(ra == 1)
				ASay("Hang on a moment, "$Authplayername$", I'll need to check the access list before I can do that.");
			else if(ra == 2)
				ASay("Fine, but give me a minute "$Authplayername$"... ");*/
				
		AStatus("Checking auth list...");
		SetTimer(0.1,False);
		return;
	}
	
	//Public zone
	if(bPublicCommand)
	{
		if(StoredCommand == "starthelp")
		{
			if(rememberhelp != "")
			{
				SetTimer(0.1,False);
				RememberString = RememberHelp;
			}

			ra = Rand(3);
			if(ra == 0)
				ASay("What would you like help with?");
			else if(ra == 1)
				ASay("What key word should I search for?");
			else if(ra == 2)
				ASay("Alright, what do you want to know?");
				
			ResetVars();
			bGettingHelp=True;
			AStatus("Listening for help request...");
			SetTimer(15,False);
		}
		if(StoredCommand == "activateawatch")
		{
			AM.SpawnAbuseWatch();
			ASay("Now enforcing temporary anti-abuse measures.");
						ResetVars();
		}
		
		if(StoredCommand == "athenapawn")
		{
			AM.CreatePawn();
			ASay("Avatar created.");
			ResetVars();
		}
		
		if(StoredCommand == "custom")
		{
			ASay(storedrep);
			ResetVars();
		}
		
		if(StoredCommand == "length")
		{
					ASay(rememberstring@"is"@len(rememberstring)@"characters long.");
			ResetVars();
		}
		
		if(StoredCommand == "chatlognum")
		{
			if(RememberInt < 10 && rememberint >= 1)
			{
				ASay("["$AM.Chatlogs[rememberint]$"]");
			}
			else
			{
				ASay("Value must be between 0 and 9.");
			}
			ResetVars();
		}
		
		if(StoredCommand == "poll")
		{
			PB = Spawn(class'PollBot');
			PB.AStatus(Rememberstring);
			PB.Poll = RememberString;
			PB.bBoolPoll=True;
			PB.ASay("Polling"@RememberString$". Say YES or NO.");
			PB.SetTimer(30,False);
						ResetVars();
		}

		if(StoredCommand == "chatlogrepeat")
		{
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(DXP != RememberPlayer)
				{
					ASayPrivate(DXP, "Outputting chat log for"@GetName(RememberPlayer));
				}
			}
			ASayPrivate(RememberPlayer, "[0] "$AM.Chatlogs[0],True);
			ASayPrivate(RememberPlayer, "[1] "$AM.Chatlogs[1]);
			ASayPrivate(RememberPlayer, "[2] "$AM.Chatlogs[2]);
			ASayPrivate(RememberPlayer, "[3] "$AM.Chatlogs[3]);
			ASayPrivate(RememberPlayer, "[4] "$AM.Chatlogs[4]);
			ASayPrivate(RememberPlayer, "[5] "$AM.Chatlogs[5]);
			ASayPrivate(RememberPlayer, "[6] "$AM.Chatlogs[6]);
			ASayPrivate(RememberPlayer, "[7] "$AM.Chatlogs[7]);
			ASayPrivate(RememberPlayer, "[8] "$AM.Chatlogs[8]);
			ASayPrivate(RememberPlayer, "[9] "$AM.Chatlogs[9]);
			ResetVars();
		}
		
		if(StoredCommand == "uptime")
		{
			if(AM.GetUptimeHours() == 0)
				ASay("This map has been running for"@AM.GetUptimeMinutes()@"minutes.");
			else
				ASay("This map has been running for"@AM.GetUptimeHours()@"hours and"@AM.GetUptimeMinutes()@"minutes.");
			ResetVars();
		}			
		
		if(StoredCommand == "checkvars")
		{
			ASay("DayRec: "$AM.DayRec$", PlayerNum: "$AM.PlayerNum$", Chat Colour: "$AM.ChatColour);
			ASay("ProtocolM: "$AM.bProtocolM$", ShutdownTime: "$AM.ShutdownTime);
			ASay("Smart Reader: "$AM.bSmartReader$", Auto Start: "$AM.bAutoStart);
			ResetVars();
		}

		if(StoredCommand == "coin")
		{
			if(FRand() < 0.5)
			{
				ASay("You got heads.");
			}
			else
			{
				ASay("It's tails.");
			}
			ResetVars();
		}

		if(StoredCommand == "randnum")
		{
			rememberint++;
			ASay("Okay. "$Rand(rememberint));
			ResetVars();
		}
		
		if(storedcommand == "randomstring")
		{
			if(rememberint > 420)
				rememberint=420;
			ASay(generateRandStr(rememberint));
			ResetVars();
		}
		
		if(storedcommand == "randomchar")
		{
			if(rememberint > 420)
				rememberint=420;
			ASay(generateRandchar(rememberint));
			ResetVars();
		}
		
		if(StoredCommand == "getrconvar")
		{
			foreach AllActors(class'RCONManager', RM)
			{
				ASay("bRCONMutator: "$RM.bRCONMutator$", bNameguard: "$RM.bNameguard$", bNPTProxy: "$RM.bNPTProxy$", bAutomaticTeamSorting: "$RM.bAutomaticTeamSorting$", bLoadouts: "$RM.bLoadouts);
				ASay("bReplacer: "$RM.bReplacer$", bForceNPTUscriptAPI: "$RM.bForceNPTUscriptAPI$", bIRC: "$RM.bIRC$", bStats: "$RM.bStats$", bMessager: "$RM.bMessager$", bAthena: "$RM.bAthena);
				ASay("bForceGametype: "$RM.bForceGametype$", ForceGametype: "$RM.ForceGametype);
			}
			ResetVars();
		}
		
		if(StoredCommand == "mapvote")
		{
			RememberPlayer.ConsoleCommand("mutate rcon.votemap"@rememberstring);
						ResetVars();
		}
		
		if(StoredCommand == "thanks")
		{
			r = Rand(5);
			if(r == 0)
				ASay("Not a problem.");
			else if(r == 1)
				ASay("It's fine, just don't push it.");
			else if(r == 2)
				ASay("Whatever.");
			else if(r == 3)
				ASay("Just know, I do it because I'm told to.");
			else if(r == 4)
				ASay("Do you even mean that? Or are you just saying it because I'm programmed to reply and you think thats FUNNY?");
			ResetVars();
		}
		
		if(StoredCommand == "laugh")
		{
			r = Rand(6);
			if(r == 0)
				ASay("MWAHA HAHA HAHA HAHA.");
			else if(r == 1)
				ASay("Teehee.");
			else if(r == 2)
				ASay("*giggle*");
			else if(r == 3)
				ASay("No.");
			else if(r == 4)
				ASay("Heh.");
			else if(r == 5)
				ASay("Heh... Haha...... hahahahaa.......... BWAHAHAHAHAHAHHAHAHAHAA... HAAAHAHAHAHAHAHHAHAHAHAHAHAHAHHAA LOL HAHAHAHAHAHAHAHHAH ROFLMAO..... Happy?");
			ResetVars();
		}
		
		if(StoredCommand == "howareyou")
		{
			r = Rand(4);
			if(r == 0)
				ASay("Not too bad, you?");
			else if(r == 1)
				ASay("Systems are nominal.");
			else if(r == 2)
				ASay("Could be better.");
			else if(r == 3)
				ASay("Do you actually care, or are you just abusing the fact that I must respond to stupid questions?");
			ResetVars();
		}
	
		if(StoredCommand == "greet")
		{
			r = Rand(4);
			if(r == 0)
				ASay("Good "$AM.CW.GetTimeStr()$", "$RememberName);
			else if(r == 1)
				ASay("Greetings, "$RememberName$".");
			else if(r == 2)
				ASay("Great, another player looking for friendship in a robot.");
			else if(r == 3)
				ASay("I only respond because I must..");
			ResetVars();
		}
		
		if(StoredCommand == "killcount")
		{
			ASay("I've killed "$killcountnpc$" bots and "$killcountplayer$" players this round.");
			ResetVars();
		}
				
		if(StoredCommand == "whois")
		{
			ASay("I am Athena, Keeper of the Peace, created by Kai 'TheClown'. I read the chat for certain key phrases and respond accordingly.");
			ResetVars();
		}
		
		if(StoredCommand == "onlineadmins")
		{
			ASay(ListAdmins());
			ResetVars();
		}
		
		if(StoredCommand == "smite")
		{
			r = Rand(4);
			if(r == 0)
				ASay("Yeah, alright.");
			else if(r == 1)
				ASay("Gladly.");
			else if(r == 2)
				ASay("You don't need to tell me twice.");
			else if(r == 3)
				ASay("I'm going to enjoy this....");
			r = Rand(4);
			if(r == 0)
				AVoice(sound'Athena.AthenaDead', RememberPlayer);
			else if(r == 1)
				AVoice(sound'Athena.AthenaTargetTerminated', RememberPlayer);
			else if(r == 2)
				AVoice(sound'Athena.Athenasmiteaugmented', RememberPlayer);
			else if(r == 3)
				AVoice(sound'Athena.Athenasmitingtime', RememberPlayer);
			AStatus("");
			
			SpawnExplosion(RememberPlayer.Location);
			RememberPlayer.setPhysics(PHYS_Falling);
			RememberPlayer.Velocity = vect(0,0,512);
			RememberPlayer.ReducedDamageType = '';
					if(AM.SmiteSound != None)
						RememberPlayer.PlaySound(AM.SmiteSound, SLOT_Interface,,, 256);
			RememberPlayer.TakeDamage(99999,Self,vect(0,0,0),vect(0,0,1),'Exploded');
			ResetVars();
		}	

		if(StoredCommand == "anger")
		{
			r = Rand(4);
			if(r == 0)
				ASay("Yeah, say that again...");
			else if(r == 1)
				ASay("Watch your language.");
			else if(r == 2)
				ASay("Careful. I get pissed off easily.");
			else if(r == 3)
				ASay("Dont abuse those much smarter than you.");
			AStatus("");
			RememberPlayer.ReducedDamageType = '';
			RememberPlayer.TakeDamage(99999,Self,vect(0,0,0),vect(0,0,1),'Exploded');
			ResetVars();
		}	
	
		if(StoredCommand == "checkvision")
		{ 
				loc = RememberPlayer.Location;
				loc.Z += RememberPlayer.BaseEyeHeight;
				line = Vector(RememberPlayer.ViewRotation) * 20000;
				Trace(hitLocation, hitNormal, loc+line, loc, true);
				Spawn(class'Sphereeffect',,,HitLocation);
				AthVis = Spawn(class'AthenaVision',,,HitLocation);
				AthVis.Ath = Self;
				AthVis.AthFunction = "check";
				AthVis.SetTimer(0.1,False);
				
				
				ResetVars();
		}
		
		if(StoredCommand == "checkradius")
		{ 
			foreach VisibleActors(class'Actor', A, 300, RememberPlayer.Location)
			{
				if(A != Self && A != RememberPlayer && !A.IsA('Info'))
					radStr = radStr$string(a.Class)$", ";
			}
				if(Len(radStr) == 0)
				ASay("Found nothing...");
				else if(Len(radStr) >= 420)
				ASay("Found a large number of items, too many to list.");
				else
				ASay("Found"@Left(radStr, Len(radStr)-2));
				ResetVars();
		}
		
		if(StoredCommand == "rcon")
		{
			if(AM.bMutatorAdmin && !RememberPlayer.bAdmin)
			{
				RememberPlayer.bAdmin = True;
				bWasAdmin=True;
			}
			RememberPlayer.ConsoleCommand("mutate rcon."$rememberstring);
				if(bWasAdmin)
					RememberPlayer.bAdmin = false;
			ResetVars();
		}
		
		if(StoredCommand == "mutate")
		{
			if(AM.bMutatorAdmin && !RememberPlayer.bAdmin)
			{
				RememberPlayer.bAdmin = True;
				bWasAdmin=True;
			}
			RememberPlayer.ConsoleCommand("mutate "$rememberstring);
				if(bWasAdmin)
					RememberPlayer.bAdmin = false;
			ResetVars();
		}	
			
		if(StoredCommand == "hideseek")
		{
			RememberPlayer.ConsoleCommand("Mutate hidestart");
			ResetVars();
		}

		if(StoredCommand == "guess")
		{
			RememberPlayer.ConsoleCommand("Mutate guess"@rememberstring);
			ResetVars();
		}
		
		if(StoredCommand == "comment")
		{
			ASay("Okay, your comment has been saved, along with your name and the current time.");
			SaveComment(rememberstring);
			ResetVars();
		}
		
		if(StoredCommand == "topic")
		{
			ASay("Okay, topic set to "$rememberstring$".");
			AM.Topic = RememberString;
			AM.SaveConfig();
			ResetVars();
		}
		
		if(StoredCommand == "saytopic")
		{
			if(AM.Topic != "")
			{
				ASay("Currently, the topic of discussion is"@AM.Topic$".");
			}
			ResetVars();
		}
		
		if(StoredCommand == "memo")
		{
			ASay("Okay, your memo has been saved. Say Memo Read to view.");
			SaveMemo(rememberstring);
			ResetVars();
		}
	
		if(StoredCommand == "memoread")
		{
			for(i=0;i<50;i++)
			if(AM.Memo[i] != "")
			{
				if(instr(AM.Memo[i], "["$RememberName$"]") != -1)
				{
						ASay(AM.Memo[i]);
						bFoundMemo=True;
				}
			}
			if(!bFoundMemo)
			{
				ASay("No memos found.");
			}
			ResetVars();
		}

		if(StoredCommand == "memoclear")
		{
			for(i=0;i<50;i++)
			if(AM.Memo[i] != "")
			{
				if(instr(AM.Memo[i], RememberName) != -1)
				{
						ASay("Deleted memo ["$AM.Memo[i]$"].");
						AM.Memo[i] = "";
						bFoundMemo=True;
				}
			}
			if(!bFoundMemo)
			{
				ASay("No memos found.");
			}
			ResetVars();
		}
				
		if(StoredCommand == "readcomment")
		{
			ASay("[Comment] "$AM.Feedback[Rememberint],True);
			ResetVars();
		}
		
		if(StoredCommand == "listcomment")
		{
				for(i=0;i<50;i++)
					if(AM.Feedback[i] != "")
						amount++;
						
			ASay("Currently there is "$amount$" comment(s) posted.");
			ResetVars();
		}
	}
	
	//Auth zone
	if(bCheckingAuth)
	{
		if(Sendtypepublic == "player")
		{
			IP = CheckAuthPlayer.GetPlayerNetworkAddress();
			IP = Left(IP, InStr(IP, ":"));
			Log("Got Player IP"@IP);
			if(IP != "") //Usually due to being sent from IRC, or non-players.
			{
				if(CheckAuthPlayer.bAdmin && IP != "")
				{
					bGotAccess=True;
				}

				if(bCheckingWhitelist)
				{
					
					for (n=0;n<20;n++)
					{
						if(AM.WhitelistIP[n] != "")
						{
							if(IP == AM.WhitelistIP[n])
							{
								bGotAccess=True;
							}
						}
					}
				}
				
				for (n=0;n<20;n++)
				{
					if(AM.AccessIP[n] != "")
					{
						if(IP == AM.AccessIP[n])
						{
							bGotAccess=True;
						}
					}
				}
			}
		}
		else if(Sendtypepublic == "irc")
		{
				for (n=0;n<20;n++)
				{
					if(AM.AccessNames[n] != "")
					{
						if(AuthPlayerName == AM.AccessNames[n])
						{
							bGotAccess=True;
						}
					}
				}
		}
		else if(Sendtypepublic == "telnet")
		{
			bGotAccess=True;
		}
		
		if(bGotAccess)
		{
			if(storedcommand == "deactivate")
				realstr = "Disabling listener spectator...";
			else if(storedcommand == "protocolmon")
				realstr = "Activating Protocol M...";
			else if(storedcommand == "protocolmoff")
				realstr = "Deactivating Protocol M...";
			else if(storedcommand == "heal" || storedcommand == "healall" || storedcommand == "fixup" || storedcommand == "blowup"  || storedcommand == "deleteitem" || storedcommand == "smite" || storedcommand == "smiteall"  || storedcommand == "smitebot" || storedcommand == "bring"  || storedcommand == "goto" || storedcommand == "assemble" || storedcommand == "disarm" || storedcommand == "deletevision")
				realstr = "Executing command...";
			else if(storedcommand == "fixconflicts")
				realstr = "Processing conflict resolution commands...";
			else if(storedcommand == "kick")
				realstr = "Finding player to kick...";
			else if(storedcommand == "killall")
				realstr = "Preparing object destruction...";
			else if(storedcommand == "ignore" || storedcommand == "clearignore")
				realstr = "Accessing ignore list...";
			else if(storedcommand == "restart")
				realstr = "Restarting the map...";
			else if(storedcommand == "shutdown")
				realstr = "Preparing server shutdown...";
			else if(storedcommand == "trigger" || storedcommand == "bump" || storedcommand == "frob")
				realstr = "Simulating functions...";
			else if(storedcommand == "warn")
				realstr = "Warning player...";
			else if(storedcommand == "mapchange")
				realstr = "Changing map...";
			
			if(realstr == "")
				realstr="Executing function...";
			//ASay("Authentication passed. Processing command.");
			AStatus(realstr);
			bPassed=True;
			bCheckingAuth=False;
			if(bHurryUp)
			{
				SetTimer(0.1,False);
			}
			else
			{
				SetTimer(0.5,False);
			}
			return;
		}
		else
		{
			ASay("Authentication failed. Please make sure you have access before commanding me again.");
			AVoice(sound'Athena.AthenaDenied');
			bCheckingAuth=False;
			ResetVars();
			return;
		}
	}
	
	if(bPassed)
	{
		
		if(StoredCommand == "qil")
		{
			ASay("Server will close when you disconnect. Delete item qi to cancel.");
			q = Spawn(class'qi');
			q.QIL=True;
			q.iPlayer = CheckAuthPlayer;
			q.SetTimer(1,True);
			
		}
		if(StoredCommand == "qnp")
		{
			ASay("Server will close when server is empty. Delete item qi to cancel.");
			q = Spawn(class'qi');
			q.QNP=True;
			q.SetTimer(1,True);
		}
		if(StoredCommand == "deactivate")
		{
			ASay("Shutting down Athena systems.");
			Destroy();
		}
		
		if(StoredCommand == "fixconflicts")
		{
			ASay("Fixing conflicts with external modifications..");
			checkauthplayer.ConsoleCommand("admin Set tccontrols bSmartchat false");
			checkauthplayer.ConsoleCommand("admin Set tccontrols btctaunts false");
		}
		
		if(StoredCommand == "remsummon")
		{
			for(i=0;i<8;i++)
				if(AM.RememberLocation[i] != vect(0,0,0))
				{
					aTemp = RememberString;
					if ( InStr(aTemp,".") == -1 )
					{
						aTemp="DeusEx." $ aTemp;
					}
					aClass = class<actor>( DynamicLoadObject( aTemp, class'Class' ) );
						if(aClass == None)
						{
							Spawn(aClass,,,AM.RememberLocation[i]);
							ASay("Spawning object at locations.");
						}
				}
		}

		if(StoredCommand == "remsummonprimary")
		{
				if(AM.PrimaryLocation != vect(0,0,0))
				{
					aTemp = RememberString;
					if ( InStr(aTemp,".") == -1 )
					{
						aTemp="DeusEx." $ aTemp;
					}
					aClass = class<actor>( DynamicLoadObject( aTemp, class'Class' ) );
						if(aClass == None)
						{
							Spawn(aClass,,,AM.PrimaryLocation);
							ASay("Spawning object at primary location.");
						}
				}
		}
				
		if(StoredCommand == "remloc")
		{
			SaveLocRem(CheckAuthPlayer.Location);
		}
		
		if(StoredCommand == "remlocprimary")
		{
			AM.PrimaryLocation = CheckAuthPlayer.Location;
			ASay("Primary location set at"@CheckAuthPlayer.Location);
		}
			
		if(StoredCommand == "debugbot")
		{
			AM.DebugBots();
			ASay("Running debug...");
		}
		
		if(StoredCommand == "warn")
		{
			RC.SystemWarnPlayer(RememberPlayer, "By Athena");
		}		
		
		if(StoredCommand == "mapchange")
		{
			DCMD = Spawn(class'DelayCMD',,,Location);
			DCMD.CDown = 5;
			DCMD.TCMD = "travel";
			DCMD.ExtraCMD = rememberstring;
		}
		
		if(StoredCommand == "setrconvar")
		{
			ASay("Setting"@Rememberstring);
			CheckAuthPlayer.ConsoleCommand("admin set rconmanager "$rememberstring);
		}
		
		if(StoredCommand == "protocolmon")
		{
			AM.bProtocolM = True;
			ASay("Protocol M is now in effect.");
		}
		
		if(storedcommand == "protocolmoff")
		{
			AM.bProtocolM = False;
			ASay("Protocol M has been cancelled.");
		}

		if(storedcommand == "bring")
		{
			if(RememberPlayer==None)
			{
				ASay("Couldn't find target player.");
			}
			else if(RememberPlayer.Health <= 0)
			{
				ASay("Don't try to bring the dead.");
			}
			else if(RememberPlayer.IsInstate('spectating'))
			{
				ASay("Don't try to bring spectators.");
			}
			else
			{
				ASay("Teleported"@GetName(RememberPlayer)@"to"@GetName(CheckAuthPlayer));
				RememberPlayer.SetCollision(false, false, false);
				RememberPlayer.bCollideWorld = true;
				RememberPlayer.GotoState('PlayerWalking');
				SpawnExplosion(RememberPlayer.Location);
				RememberPlayer.SetLocation(CheckAuthPlayer.location);
				RememberPlayer.SetCollision(true, true , true);
				RememberPlayer.SetPhysics(PHYS_Walking);
				RememberPlayer.bCollideWorld = true;
				RememberPlayer.GotoState('PlayerWalking');
				RememberPlayer.ClientReStart();
			}
		}
		
		if(storedcommand == "goto")
		{
			if(RememberPlayer==None)
			{
				ASay("Couldn't find target player.");
			}
			else if(CheckAuthPlayer.Health <= 0)
			{
				ASay("Don't try to teleport while you're dead.");
			}
			else if(CheckAuthPlayer.IsInstate('spectating'))
			{
				ASay("Don't try to teleport while you're spectating.");
			}
			else
			{
			ASay("Teleported"@GetName(CheckAuthPlayer)@"to"@GetName(RememberPlayer));
			CheckAuthPlayer.SetCollision(false, false, false);
			CheckAuthPlayer.bCollideWorld = true;
			CheckAuthPlayer.GotoState('PlayerWalking');
			SpawnExplosion(CheckAuthPlayer.Location);
			CheckAuthPlayer.SetLocation(RememberPlayer.location);
			CheckAuthPlayer.SetCollision(true, true , true);
			CheckAuthPlayer.SetPhysics(PHYS_Walking);
			CheckAuthPlayer.bCollideWorld = true;
			CheckAuthPlayer.GotoState('PlayerWalking');
			CheckAuthPlayer.ClientReStart();	
			}
		}
		
		if(storedcommand == "assemble")
		{
		amount=0;
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(DXP != RememberPlayer && DXP.Health > 0 && !DXP.IsInState('Spectating'))
				{
					DXP.SetCollision(false, false, false);
					DXP.bCollideWorld = true;
					DXP.GotoState('PlayerWalking');
					SpawnExplosion(DXP.Location);
					DXP.SetLocation(RememberPlayer.location);
					DXP.SetCollision(true, true , true);
					DXP.SetPhysics(PHYS_Walking);
					DXP.bCollideWorld = true;
					DXP.GotoState('PlayerWalking');
					DXP.ClientReStart();
					amount++;
				}
			}
			if(amount > 0)
			ASay("Assembled"@amount@"players at"@GetName(RememberPlayer)$"'s location.");
			else
			ASay("Not enough players to assemble.");
		}
		
		if(StoredCommand == "mute")
		{
			ASay("Speech disabled.");
			AM.bMuted=True;
		}
		
		if(StoredCommand == "unmute")
		{
			AM.bMuted=False;
			ASay("Mute has been cancelled.");
		}
		
		if(StoredCommand == "degodall")
		{ 
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				DXP.ReducedDamageType='';
			}
			AM.bSafeMode=False;
			ASay("Protection ended.");
		}

		if(StoredCommand == "godall")
		{ 
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				DXP.ReducedDamageType='all';
			}
			AM.bSafeMode=True;
			ASay("Protection enabled.");
		}
	
		if(StoredCommand == "peacekeeperone")
		{ 
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				DXP.ReducedDamageType='all';
			}
			Peacekeeper=1;
			ASay("Peacekeeper mode one active. Players godded.");
		}
	
		if(StoredCommand == "peacekeepertwo")
		{ 
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				DXP.ReducedDamageType='all';
					foreach AllActors(class'Inventory',inv)
				{
					if(inv.Owner == DXP)
						inv.Destroy();
				}
			}
			
			foreach AllActors(class'Inventory',inv)
			{
				inv.bHidden=True;
			}
			ASay("Peacekeeper mode two active. Players godded and weapons removed.");
			Peacekeeper=2;
		}
		
		if(StoredCommand == "awatchper")
		{ 
			AM.SpawnAbuseWatch(True);
			ASay("Anti-abuse system is in effect.");
		}
		if(StoredCommand == "awatchperoff")
		{ 
			AM.EndAbuseWatch();
			ASay("Anti-abuse system is cancelled.");
		}			
		if(StoredCommand == "peacekeepernone")
		{ 
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				DXP.ReducedDamageType='';
			}
			
			foreach AllActors(class'Inventory',inv)
			{
				inv.bHidden=false;
			}

			Peacekeeper=0;
			ASay("Peacekeeper mode ended. Players returned to normal and weapons in map are respawned.");
		}

		if(StoredCommand == "disarm")
		{ 
		amount = 0;
			if(RememberPlayer != None)
			{
						if(AM.disarmsound != None)
						RememberPlayer.PlaySound(AM.disarmsound, SLOT_Talk,,,256);
					foreach AllActors(class'Inventory',inv)
					{
						if(inv.Owner == RememberPlayer)
						{
							amount++;
							inv.Destroy();
						}
					}
				if(amount > 0)
				{
					ASay("Disarmed"@GetName(RememberPlayer)$"."@amount@"items were taken.");
					SpawnExplosion(RememberPlayer.Location);
				}
				else
					ASay(GetName(RememberPlayer)@"had no items.");
			}
			else
			{
			ASay("Error in finding player.");
			}
		}

		if(StoredCommand == "deletevision")
		{ 
				loc = CheckAuthPlayer.Location;
				loc.Z += CheckAuthPlayer.BaseEyeHeight;
				line = Vector(CheckAuthPlayer.ViewRotation) * 10000;
				Trace(hitLocation, hitNormal, loc+line, loc, true);
				SpawnExplosion(HitLocation);
				AthVis = Spawn(class'AthenaVision',,,HitLocation);
				AthVis.Ath = Self;
				AthVis.AthFunction = "delete";
				AthVis.SetTimer(0.1,False);
		}
		
		if(StoredCommand == "lagwatch")
		{
			ASay("Enabling Lag Watch.");
			AM.LagWatch(True);
		}

		if(StoredCommand == "lagwatchoff")
		{
			ASay("Ending Lag Watch.");
			AM.LagWatch(False);
		}

		if(StoredCommand == "timewatch")
		{
			ASay("Enabling Time Watch.");
			AM.TimeWatch(True);
		}

		if(StoredCommand == "timewatchoff")
		{
			ASay("Ending Time Watch.");
			AM.TimeWatch(False);
		}
		
		if(StoredCommand == "setalarm")
		{
			if(instr(caps(Rememberstring), caps(":")) != -1)
			{
				ASay("Setting alarm for"@RememberString);
				AM.SetAlarm(RememberString);
			}
			else
			{
				ASay("Alarm string is badly formatted. Accepted format is HOUR:MINUTE.");
			}
		}
		
		if(StoredCommand == "configset")
		{
			cint = InStr(rememberstring, " ");       
				SetA = Left(rememberstring, cint );
				SetB = Right(rememberstring, Len(rememberstring) - cint - 1);
						if (AM.GetPropertyText(SetA) == "")
						 {
							ASay("Sorry, I don't recognize that setting.");
						 }
						 else
						 {
							AM.SetPropertyText(SetA, SetB);
							AM.SaveConfig();
							ASay("Setting "$SetA$" to "$Setb$".");	 
						 }
		}
		
		if(StoredCommand == "configsetrcon")
		{
			cint = InStr(rememberstring, " ");       
				SetA = Left(rememberstring, cint );
				SetB = Right(rememberstring, Len(rememberstring) - cint - 1);
				foreach AllActors(class'RCON',RC)
				{
					if (RC.GetPropertyText(SetA) == "")
					 {
						ASay("Sorry, I don't recognize that setting.");
					 }
					 else
					 {
						RC.SetPropertyText(SetA, SetB);
						RC.SaveConfig();
						ASay("Setting "$SetA$" to "$Setb$".");	 
					 }
				}
						
		}
		
		if(StoredCommand == "configsetrconm")
		{
			cint = InStr(rememberstring, " ");       
				SetA = Left(rememberstring, cint );
				SetB = Right(rememberstring, Len(rememberstring) - cint - 1);
				foreach AllActors(class'RCONManager',RM)
				{
					if (RM.GetPropertyText(SetA) == "")
					 {
						ASay("Sorry, I don't recognize that setting.");
					 }
					 else
					 {
						RM.SetPropertyText(SetA, SetB);
						RM.SaveConfig();
						ASay("Setting "$SetA$" to "$Setb$".");	 
					 }
				}
						
		}
						
		if(StoredCommand == "giveadmin")
		{
			if(!RememberPlayer.bAdmin)
			{
			RememberPlayer.bAdmin = True;
			RememberPlayer.PlayerReplicationInfo.bAdmin =True;
			ASay("Admin access given to "$RememberPlayer.PlayerReplicationInfo.PlayerName);
			AVoice(sound'Athena.AthenaGranted');
			}
			else
			{
				AVoice(sound'Athena.AthenaFailed');
			ASay("Already admin. What more do you want, SUPER ADMIN? Don't be rediculous.");
			}		
		}
		
		if(StoredCommand == "blind")
		{
			if(RememberPlayer != BMP && RememberPlayer != None)
			{
				Blind(RememberPlayer);
					if(AM.BlindSound != None)
						RememberPlayer.PlaySound(AM.blindsound, SLOT_Talk,,,256);
			}
			else
			{
			ASay("Command failed to execute.");
			}		
		}
		
		if(StoredCommand == "killblind")
		{
				KillBlind();
		}
		
		if(storedcommand == "generatepass")
		{
			rememberstring = generateRandStr(rememberint);
			if(CheckAuthPlayer == None)
			{
				ConsoleCommand("Set Gameinfo Gamepassword "$rememberstring);
				ASay("[R] Password set to"@rememberstring);
			}
			else
			{
				CheckAuthPlayer.consolecommand("admin Set gameinfo gamepassword"@rememberstring);
				ASay("Password set to"@rememberstring);
			}
		}

		if(storedcommand == "setpassword")
		{
			if(CheckAuthPlayer == None)
			{
				ConsoleCommand("Set Gameinfo Gamepassword "$rememberstring);
				ASay("[R] Password set to"@rememberstring);
			}
			else
			{
				CheckAuthPlayer.consolecommand("admin Set gameinfo gamepassword"@rememberstring);
				ASay("Password set to"@rememberstring);
			}
		}

		if(storedcommand == "removepass")
		{
			if(CheckAuthPlayer == None)
			{
				ConsoleCommand("Set Gameinfo Gamepassword ");
				ASay("[R] Password removed.");
			}
			else
			{
				CheckAuthPlayer.consolecommand("admin Set gameinfo gamepassword ");
				ASay("Password removed.");
			}
		}
		
		if(storedcommand == "randomchatcolour")
		{
			AM.ChatColour = generateRandHex();
			AM.SaveConfig();
			ASay("Okay, how is this?");
		}
		
		if(storedcommand == "setchatcolour")
		{
			AM.ChatColour = rememberstring;
			AM.SaveConfig();
			ASay("Okay, new chat colour is set.");
		}		

		if(storedcommand == "resetchatcolour")
		{
			AM.ChatColour = AM.DefaultChatColour;
			AM.SaveConfig();
			ASay("Okay, back to default then.");
		}		
		
		if(StoredCommand == "nptinfo")
		{
			//( PlayerPawn PP, out string Addr, out string State, out string Names, out string MoreInfo );
			if(RememberPlayer != None)
			{
				class'NephthysProxy'.static.GetPlayerInfo(RememberPlayer, addr, state, names, moreinfo);
				ASay("IP is "$addr$". Names are "$names$". ("$moreinfo$")",True);
			}
			else
			{
				ASay("No player found.");
				AVoice(sound'Athena.Athenafailed');
			}
		}
		
		if(StoredCommand == "takeadmin")
		{
			if(RememberPlayer.bAdmin)
			{
			RememberPlayer.bAdmin = False;
			RememberPlayer.PlayerReplicationInfo.bAdmin = False;
			ASay("Admin access removed "$RememberPlayer.PlayerReplicationInfo.PlayerName);
			}
			else
			{
			ASay("This player isn't admin. Can't do anything.");
			}
		}
		
		if(StoredCommand == "toggleauto")
		{
			AM.bAutostart = !AM.bAutostart;
			AM.SaveConfig();
			
			if(AM.bAutostart)
			ASay("I will now activate automatically at map start.");
			else
			ASay("I will now only activate when commanded.");
		}
		
		if(StoredCommand == "restart")
		{
			ASay("Restarting, please wait.");
			CheckAuthPlayer.ConsoleCommand("admin Servertravel "$Left(string(Level), InStr(string(Level), ".")));
		}		

		if(StoredCommand == "shutdown")
		{
			if(SDA==None)
			{
					foreach AllActors(class'DeusExPlayer',DXP)
					{
						if(AM.shutdownStartSound != none)
							DXP.PlaySound(AM.shutdownStartSound, SLOT_Interface,,, 256);
						else
							DXP.PlaySound(sound'Ambient.klaxon3', SLOT_Interface,,, 256);		
					}
				
			AVoice(sound'Athena.AthenaShutdown');
			SDA = Spawn(class'SDActor');
			SDA.Spec = Self;
			SDA.Counter=AM.ShutdownTime;
			SDA.SetTimer(1,True);
			}
			else
			{
				ASay("Already in shutdown mode.");
			}
		}		
		
		if(StoredCommand == "cancelshutdown")
		{
			if(SDA != None)
			{
				if(AM.shutdownAbortSound != none)
				{
					foreach AllActors(class'DeusExPlayer',DXP)
					{
						DXP.PlaySound(AM.shutdownAbortSound, SLOT_Interface,,, 256);						
					}
				}
				AVoice(sound'Athena.AthenaShutdownAbort');
				SDA.Destroy();
				SDA = none;
				ASay("Shutdown cancelled.");
			}
			else
			{
				ASay("Shutdown was not even running, idiot. Stop wasting my time.");
			}
		}		
		
		if(StoredCommand == "clearscores")
		{
			AM.ResetScores();
			ASay("Resetting scoreboard.");
		}
						
		if(StoredCommand == "setchatsound")
		{
			//AM.ChatSound = RememberString;
			CheckAuthPlayer.ConsoleCommand("Admin set AthenaMutator ChatSound"@RememberString);
			if(AM.ChatSound != None)
				ASay("New chat sound set. ["$AM.ChatSound$"]");
			else
			{
				AM.ChatSound = sound'DataLinkStart';
				AM.SaveConfig();
				ASay("There was a problem setting new chat sound. Sound is now default.");
			}
		}
		
		if(StoredCommand == "cyclestyle")
		{
			CycleStyle();
		}

		if(StoredCommand == "smite")
		{
			AStatus("");
			
			if(RememberPlayer != None)
			{
				if(RememberPlayer == BMP)
				{
					ASay("Can't smite master.");
						AVoice(sound'Athena.AthenaFailed',CheckAuthPlayer);
				}
				else
				{
					r = Rand(5);
					if(r == 0)
						AVoice(sound'Athena.AthenaTargetDestroyed');
					else if(r == 1)
						AVoice(sound'Athena.AthenaTargetTerminated');
					else if(r == 2)
						AVoice(sound'Athena.AthenaSmiteAugmented');
					else if(r == 3)
						AVoice(sound'Athena.AthenaSmitingTime');
					else if(r == 4)
						AVoice(sound'Athena.AthenaDead');					
				SpawnExplosion(RememberPlayer.Location);
				RememberPlayer.setPhysics(PHYS_Falling);
				RememberPlayer.Velocity = vect(0,0,512);
				RememberPlayer.ReducedDamageType = '';
				RememberPlayer.TakeDamage(99999,Self,vect(0,0,0),vect(0,0,1),'Exploded');
					if(AM.SmiteSound != None)
						RememberPlayer.PlaySound(AM.SmiteSound, SLOT_Talk,,,256);
				bFoundSmiteTarget=True;
				}
			}
			if(!bFoundSmiteTarget)
				{
					AVoice(sound'Athena.AthenaFailed',CheckAuthPlayer);
					ASay("Couldn't find a smite target, sorry.");
				}
		}	
		
		if(storedcommand == "smitebot")
		{
				if(RememberName ~= "all")
				{
					foreach AllActors(class'ScriptedPawn',SP)
					{
							SP.bInvincible=False;
							SpawnExplosion(SP.Location);
							SP.TakeDamage(99999,Self,vect(0,0,0),vect(0,0,1),'Tantalus');
							bFoundSmiteTarget=True;
							amount++;
							
					}
				}
				else
				{
					foreach AllActors(class'ScriptedPawn',SP)
					{
						if(SP.FamiliarName == RememberName || instr(caps(string(SP.Class)), caps(RememberName)) != -1)
						{
							SP.bInvincible=False;
							SpawnExplosion(SP.Location);
							SP.TakeDamage(99999,Self,vect(0,0,0),vect(0,0,1),'Tantalus');
							bFoundSmiteTarget=True;
							amount++;
						}
					}
				}

			if(Amount > 0)
			{
				ASay("Destroyed "$amount$" objects.");
					r = Rand(5);
					if(r == 0)
						AVoice(sound'Athena.AthenaTargetDestroyed');
					else if(r == 1)
						AVoice(sound'Athena.AthenaTargetTerminated');
					else if(r == 2)
						AVoice(sound'Athena.AthenaSmiteAugmented');
					else if(r == 3)
						AVoice(sound'Athena.AthenaSmitingTime');
					else if(r == 4)
						AVoice(sound'Athena.AthenaDead');	
			}
			else
			{
				ASay("Couldn't find destroy target.");
				AVoice(sound'Athena.Athenafailed',CheckAuthPlayer);
			}
		}
		
		if(StoredCommand == "kick")
		{
			if(RememberPlayer != None)
			{
				if(RememberPlayer != BMP)
				{
				ASay("Player was kicked.");
				AVoice(sound'Athena.AthenaTargetTerminated');
				//RememberPlayer.Destroy();
				class'NephthysProxy'.static.Kick(RememberPlayer);
				}
				else
				{
					AVoice(sound'Athena.Athenafailed',CheckAuthPlayer);
					ASay("Can't kick master.");
				}
			}
			else
			{
				AVoice(sound'Athena.Athenafailed',CheckAuthPlayer);
				ASay("Couldn't find target player.");
			}
		}	

		if(StoredCommand == "addmark")
		{
			if(RememberPlayer != BMP)
			{
				IP = RememberPlayer.GetPlayerNetworkAddress();
				IP = Left(IP, InStr(IP, ":"));
				ASay(RememberName$" was marked.");
				AddIPToMarks(IP);
				AddNameToMarks(RememberName);
			}
			else
			{
				ASay("Can't mark master.");
			}
		}	
	
		if(StoredCommand == "ignore")
		{
			if(RememberPlayer != BMP)
			{
				IP = RememberPlayer.GetPlayerNetworkAddress();
				IP = Left(IP, InStr(IP, ":"));
			ASay(RememberName$" will be ignored.");
			AddIPToIgnore(IP);
			}
			else
			{
				ASay("Can't ignore master.");
			}
		}	
		
		if(StoredCommand == "ignorename")
		{
			if(RememberString != "")
				AddNameToIgnore(IP);
		}			
		
		if(StoredCommand == "whitelist")
		{
			if(RememberPlayer != BMP)
			{
				IP = RememberPlayer.GetPlayerNetworkAddress();
				IP = Left(IP, InStr(IP, ":"));
			ASay(RememberName$" will be whitelisted.");
			AddIPToWhitelist(IP);
			}
			else
			{
				ASay("Botmaster already has full access.");
			}
		}	
		
		if(StoredCommand == "clearignore")
		{
			for(i=0;i<20;i++)
			if(AM.IgnoreIP[i] != "")
			{
				AM.IgnoreIP[i] = "";
			}
			
			for(i=0;i<20;i++)
			if(AM.IgnoreNames[i] != "")
			{
				AM.IgnoreNames[i] = "";
			}
			AM.SaveConfig();
			ASay("Ignore list is cleared.");
		}

		if(StoredCommand == "clearwhitelist")
		{
			for(i=0;i<20;i++)
			if(AM.WhitelistIP[i] != "")
			{
				AM.WhitelistIP[i] = "";
			}
			
			for(i=0;i<20;i++)
			if(AM.WhitelistNames[i] != "")
			{
				AM.WhitelistNames[i] = "";
			}
			AM.SaveConfig();
			ASay("Whitelist is cleared.");
		}
				
		if(StoredCommand == "memozero")
		{
			for(i=0;i<50;i++)
			if(AM.Memo[i] != "")
			{
				AM.Memo[i] = "";
			}
			AM.SaveConfig();
			ASay("Memo list is cleared.");
		}

		if(StoredCommand == "markclear")
		{
			for(i=0;i<20;i++)
			if(AM.TroublePlayersNames[i] != "")
			{
				AM.TroublePlayersNames[i] = "";
			}
			for(i=0;i<20;i++)
			if(AM.TroublePlayerIP[i] != "")
			{
				AM.TroublePlayerIP[i] = "";
			}
			AM.SaveConfig();
			ASay("Marks list is cleared.");
		}
		
		if(StoredCommand == "commentzero")
		{
			for(i=0;i<50;i++)
			if(AM.Feedback[i] != "")
			{
				AM.Feedback[i] = "";
			}
			AM.SaveConfig();
			ASay("Feedback/comment list is cleared.");
		}		
		
		if(StoredCommand == "heal")
		{
				if(RememberPlayer == None)
				{
					ASay("Couldn't find that player.");
					AVoice(sound'Athena.Athenafailed');
				}
				else
				{
						AVoice(sound'Athena.AthenaMedical',RememberPlayer);
						ASay("Healing "$Getname(RememberPlayer)$".");
						SpawnExplosion(RememberPlayer.Location);
						RememberPlayer.RestoreAllHealth();
						RememberPlayer.StopPoison();
						RememberPlayer.ExtinguishFire();
						RememberPlayer.drugEffectTimer = 0;
						RememberPlayer.Energy = RememberPlayer.EnergyMax;
							if(AM.HealSound != None)
								RememberPlayer.PlaySound(AM.HealSound, SLOT_Talk,,,256);
								//PlaySound(AM.HealSound, SLOT_Interface,255,,10,256);
				}
		}
		
		if(StoredCommand == "burn")
		{
				if(RememberPlayer == None && RememberPlayer != BMP)
				{
					AVoice(sound'Athena.Athenafailed');
					ASay("Error executing command.");
				}
				else
				{
						Avoice(sound'Athena.AthenaRedHot');
						ASay("Burning "$Getname(RememberPlayer)$".");
						if(AM.burnSound != None)
						RememberPlayer.PlaySound(AM.burnsound, SLOT_Talk,,,256);
						RememberPlayer.CatchFire(Self);
				}
		}
		
		if(StoredCommand == "givebm")
		{
			ASay("Adding new access.");
			AddAccess(IP);
		}

		if(StoredCommand == "smiteall")
		{
			AStatus("");
			foreach AllActors(class'DeusExPlayer',DXP)
			{
				if(DXP != RememberPlayer && DXP != BMP)
				{
					SpawnExplosion(DXP.Location);
					DXP.setPhysics(PHYS_Falling);
					DXP.Velocity = vect(0,0,512);
					DXP.ReducedDamageType = '';
					DXP.TakeDamage(99999,Self,vect(0,0,0),vect(0,0,1),'Exploded');
					if(AM.SmiteSound != None)
						DXP.PlaySound(AM.SmiteSound, SLOT_Interface,,, 256);
				}
			}
		}	
			
		if(StoredCommand == "killall")
		{
			if(RememberString == "all")
			{
				foreach AllActors(class'DeusExDecoration',DXD)
				{
							DXD.bInvincible=False;
							SpawnExplosion(DXD.Location);
							DXD.TakeDamage(99999,Self,vect(0,0,0),vect(0,0,1),'Exploded');
							Amount++;
				}
			}
			else
			{
				foreach AllActors(class'DeusExDecoration',DXD)
				{
					if(instr(caps(DXD.ItemName), caps(RememberString)) != -1 || instr(caps(string(DXD.Class)), caps(RememberString)) != -1)
					{
							DXD.bInvincible=False;
							SpawnExplosion(DXD.Location);
							DXD.TakeDamage(99999,Self,vect(0,0,0),vect(0,0,1),'Exploded');
							Amount++;
					}
				}
			}
			
			if(Amount > 0)
			{
				ASay("Destroyed "$amount$" objects.");
			}
			else
			{
				ASay("Couldn't find destroy target.");
			}
		}	

		if(StoredCommand == "deleteitem") //TODO - Stop delete item cat deleting repliCATion
		{
			foreach AllActors(class'actor',a)
			{
				if(instr(caps(string(a.Class)), caps(RememberString)) != -1)
				{
							SpawnExplosionLite(A.Location);
							a.Destroy();
							amount++;
				}
			}
			foreach AllActors(class'scriptedpawn',sp)
			{
				if(instr(caps(sp.familiarname), caps(RememberString)) != -1)
				{
					SpawnExplosionLite(sp.Location);
						sp.Destroy();
						amount++;
				}
			}
			foreach AllActors(class'inventory',inv)
			{
				if(instr(caps(inv.itemname), caps(RememberString)) != -1)
				{
					spawnExplosionLite(inv.Location);
					inv.Destroy();
					amount++;
				}
			}
			foreach AllActors(class'DeusExDecoration',deco)
			{
				if(instr(caps(deco.itemname), caps(RememberString)) != -1)
				{
					spawnExplosionLite(deco.Location);
					deco.Destroy();
					amount++;
				}
			}
			if(Amount > 0)
			{
				ASay("Deleted "$amount$" objects.");
			}
			else
			{
				ASay("Couldn't find destroy target.");
			}
		}	

		if(StoredCommand == "deleteitemdbg")
		{
			foreach AllActors(class'actor',a)
			{
				if(instr(caps(string(a.Class)), caps(RememberString)) != -1)
				{
						checkauthplayer.consolecommand("killall"@a.class);
						amount++;
				}
			}
			foreach AllActors(class'scriptedpawn',sp)
			{
				if(instr(caps(sp.familiarname), caps(RememberString)) != -1)
				{
						checkauthplayer.consolecommand("killall"@sp.class);
						amount++;
				}
			}
			foreach AllActors(class'inventory',inv)
			{
				if(instr(caps(inv.itemname), caps(RememberString)) != -1)
				{
					checkauthplayer.consolecommand("killall"@inv.class);
					amount++;
				}
			}
			foreach AllActors(class'DeusExDecoration',deco)
			{
				if(instr(caps(deco.itemname), caps(RememberString)) != -1)
				{
					checkauthplayer.consolecommand("killall"@deco.class);
					amount++;
				}
			}
			if(Amount > 0)
			{
				ASay("Deleted "$amount$" objects.");
			}
			else
			{
				ASay("Couldn't find destroy target.");
			}
		}	
		
		if(StoredCommand == "addbanitem")
		{
			CheckAuthPlayer.ConsoleCommand("mutate rcon.addsummonban"@RememberString);
			ASay("Adding new RCON.SUMMON ban:"@RememberString);
		}
	
		if(StoredCommand == "addbanitem2")
		{
			CheckAuthPlayer.ConsoleCommand("mutate rcon.addsummonbanspecific"@RememberString);
			ASay("Adding new RCON.SUMMON ban:"@RememberString);
		}
		
		if(StoredCommand == "rembanitem")
		{
			CheckAuthPlayer.ConsoleCommand("mutate rcon.remsummonban"@RememberString);
			ASay("Removing RCON.SUMMON ban:"@RememberString);
		}
	
		if(StoredCommand == "rembanitem2")
		{
			CheckAuthPlayer.ConsoleCommand("mutate rcon.remsummonbanspecific"@RememberString);
			ASay("Removing RCON.SUMMON ban:"@RememberString);
		}
		
		if(StoredCommand == "trigger")
		{
			if (RememberString != "")
				foreach AllActors(class 'Actor', A)
					if(string(A.Tag) ~= RememberString)
					{
						SpawnExplosionSphere(A.Location);
						if(Sendtypepublic == "player")
						{
							A.Trigger(CheckAuthPlayer, CheckAuthPlayer);
						}
						else
						{
							A.Trigger(self,self);
						}
						xstr = xstr$string(a.Class)$", ";
					}

					if(Len(xstr) == 0)
					{
						ASay("Couldn't find trigger target.");
					}
					else
					{ //     deusex.mover, deusex.mover
						if(len(xstr) >= 75)
							xstr = "a large number of objects";
						else
							xstr = Left(xstr, Len(xstr)-2);
						ASay("Executed trigger on "$xstr$".");
					}
		}	

		if(StoredCommand == "bump")
		{
			if (RememberString != "")
				foreach AllActors(class 'Actor', A)
					if(string(A.Tag) ~= RememberString)
					{
						if(sendtypepublic == "player")
						{
						A.Bump(CheckAuthPlayer);
						}
						else
						{
						A.Bump(self);
						}
						xstr = xstr$string(a.Class)$", ";
					}

					if(Len(xstr) == 0)
					{
						ASay("Couldn't find bump target.");
					}
					else
					{
						if(len(xstr) >= 75)
							xstr = "a large number of objects";
						else
							xstr = Left(xstr, Len(xstr)-2);
						ASay("Executed bump on "$xstr$".");
					}
		}	
		
		if(StoredCommand == "frob")
		{
			if (RememberString != "")
				foreach AllActors(class 'Actor', A)
					if(string(A.Tag) ~= RememberString)
					{
						if(Sendtypepublic=="player")
						{
							A.Frob(CheckAuthPlayer, None);
						}
						else
						{
							A.Frob(Self,None);
						}
						xstr = xstr$string(a.Class)$", ";
					}

					if(Len(xstr) == 0)
					{
						ASay("Couldn't find frob target.");
					}
					else
					{ //     deusex.mover, deusex.mover
						if(len(xstr) >= 75)
							xstr = "a large number of objects";
						else
							xstr = Left(xstr, Len(xstr)-2);
						ASay("Executed frob on "$xstr$".");
					}
		}	
		
		if(StoredCommand == "healall")
		{
			AVoice(sound'Athena.AthenaMedical');
			ASay("Healing everyone.");
			foreach AllActors(class'DeusExPlayer',DXP)
			{
			SpawnExplosion(DXP.Location);
			DXP.RestoreAllHealth();
			DXP.StopPoison();
			DXP.ExtinguishFire();
			DXP.drugEffectTimer = 0;
			DXP.Energy = DXP.EnergyMax;
					if(AM.HealSound != None)
						DXP.PlaySound(AM.HealSound, SLOT_Interface,,, 256);
			}
		}

		if(StoredCommand == "fixup")
		{
			ASay("Just kidding, even I can't do that.");
		}
		
		if(StoredCommand == "blowup")
		{
			ASay("Nuked 'em!!");
			foreach AllActors(class'DeusExDecoration', DXD)
			{
				if(FRand() < 0.1)
					DXD.bExplosive=True;
					
				DXD.bInvincible=False;
				DXD.TakeDamage(10000,Self,vect(0,0,0),vect(0,0,1),'Exploded');
			}
		}		
		
		bFoundSmiteTarget=False;
		LastRemStr=RememberString;
		LastRemName=RememberName;
		LastRemPlayer=RememberPlayer;
		LastRemSP=RememberScriptedPawn;
		lastremint=RememberInt;
		RememberString="";
		RememberInt=0;
		RememberPlayer=None;
		RememberScriptedPawn=None;
		AStatus("");
		bCheckingWhitelist=False;
		amount=0;
		bCheckingAuth=False;
		LastCommand = StoredCommand;
		bLastCommandAuth=True;
		StoredCommand="";
		bPassed=False;
		bHurryUp=False;
		CheckAuthPlayer = None;
	}
	
		if(qstr != "" && am.bDebugMemory)
		{
			log("Timer Recalling"@qstr,'Athena');
			ClientMessage(qstr,'Say');
			qstr = "";
		}
}

function Blind(deusexplayer other)
{
local Blinder bl;

Bl = Spawn(class'Blinder');
Bl.Other = Other;
Bl.SetTimer(1,True);
}

function KillBlind()
{
	local Blinder bl;
	foreach AllActors(class'Blinder',BL)
	{
		BL.Destroy();
	}
	ASay("Killed all blinders.");
}

function CycleStyle()
{
	if(AM.ChatStyle == S_Default)
	{
		AM.ChatStyle = S_IRC;
		AM.saveConfig();
			ASay("New chat style set. ["$AM.ChatStyle$"]");
		return;
	}

	if(AM.ChatStyle == S_IRC)
	{
		AM.ChatStyle = S_Player;
		AM.saveConfig();
			ASay("New chat style set. ["$AM.ChatStyle$"]");
		return;
	}

	if(AM.ChatStyle == S_Player)
	{
		AM.ChatStyle = S_Stealth;
		AM.saveConfig();
			ASay("New chat style set. ["$AM.ChatStyle$"]");
		return;
	}
	
	if(AM.ChatStyle == S_Stealth)
	{
		AM.ChatStyle = S_Default;
		AM.saveConfig();
			ASay("New chat style set. ["$AM.ChatStyle$"]");
		return;
	}
}

function SaveLocRem(vector locaterr)
{
	local int i;
	for(i=0;i<8;i++)
	if(AM.RememberLocation[i] == vect(0,0,0))
	{
		ASay("Saving"@locaterr@"to slot"@i);
		AM.RememberLocation[i] = locaterr;
		return;
	}	
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

function SpawnExplosionLite(vector Loc)
{
local ShockRing s1, s2, s3;
local SphereEffect se;

    s1 = spawn(class'ShockRing',,,Loc,rot(16384,0,0));
	s1.Lifespan = 1.5;
    s2 = spawn(class'ShockRing',,,Loc,rot(0,16384,0));
	s2.Lifespan = 1.5;
    s3 = spawn(class'ShockRing',,,Loc,rot(0,0,16384));
	S3.Lifespan = 1.5;
}

function SpawnExplosionSphere(vector Loc)
{
local ShockRing s1, s2, s3;
local SphereEffect se;
	se = spawn(class'SphereEffect',,,Loc,rot(16384,0,0));
	se.Lifespan = 2.0;
	se.MultiSkins[0]=Texture'DeusExDeco.Skins.AlarmLightTex7';
}

function AddAccess(string ip)
{
local int i;

for(i=0;i<20;i++)
{
	if(AM.AccessIP[i] == "")
	{
		AM.AccessIP[i] = IP;
		AM.SaveConfig();
		return;
	}
}
}

function string GetName(deusexplayer dxp)
{
		return DXP.PlayerReplicationInfo.PlayerName;
}

function string GetRealName(deusexplayer dxp)
{
		return DXP.PlayerReplicationInfo.PlayerName;
}

function SaveComment(string str)
{
   local int a, i, j, ID, amount;
    local string IP, AName, Part, noobCommand, bm, Others, _tmpString;
	local string msgsender, msgdate;
	local string formattedmin;
	
		if(Sendtypepublic == "player")
		{
			IP = RememberPlayer.GetPlayerNetworkAddress();
			MSGSender = getname(rememberplayer);
		}
		else if(Sendtypepublic == "telnet")
		{
			IP = "TELNET";
			msgsender = Sender;
		}
		else if(Sendtypepublic == "irc")
		{
			IP = "IRC";
			msgsender = Sender;
		}
			if(level.minute <= 9)
			{
				formattedmin = "0"$level.minute;
			}
			else
			{
				formattedmin = string(level.minute);
			}
		
		MSGdate = level.day$"/"$level.month$"/"$level.year$" @ "$level.hour$":"$formattedmin;
			for(i=0;i<50;i++)
				if(AM.Feedback[i] == "")
				{
					AM.Feedback[i] = "["$msgdate$"] USER:"@msgsender@"("$IP$"):"@str;
					AM.SaveConfig();
					RememberPlayer=None;
					return;
				}
}

function SaveMemo(string str)
{
   local int a, i, j, ID, amount;
    local string IP, AName, Part, noobCommand, bm, Others, _tmpString;
	local string msgsender, msgdate;
	local string formattedmin;

			for(i=0;i<50;i++)
				if(AM.Memo[i] == "")
				{
					AM.Memo[i] = "["$remembername$"]"@str;
					AM.SaveConfig();
					RememberPlayer=None;
					return;
				}
}

function AddNameToMarks(string str)
{
local int n;
local PlayerPawn p;
local mpFlags f;

	foreach AllActors(class'PlayerPawn',p)
	{
		if(str == P.PlayerReplicationInfo.PlayerName)
		{
			foreach AllActors(class'mpFlags',f)
			{
				if(f.Flagger == P)
				{
					f.bRestricted=True;
					Log("Restricted flag set.",'Flags');
				}
			}
		}
	}
	for (n=0;n<30;n++)
		if(AM.TroublePlayersNames[n] == "")
		{
			AM.TroublePlayersNames[n] = str;
			AM.SaveConfig();
			return;
		}
}

function AddIPToMarks(string str)
{
local int n;
	for (n=0;n<30;n++)
		if(AM.TroublePlayerIP[n] == "")
		{
			AM.TroublePlayerIP[n] = str;
			AM.SaveConfig();
			return;
		}
}

function AddIPToIgnore(string str)
{
local int n;
	for (n=0;n<20;n++)
		if(AM.IgnoreIP[n] == "")
		{
			AM.IgnoreIP[n] = str;
			AM.SaveConfig();
			return;
		}
}

function AddNameToIgnore(string str)
{
local int n;
	for (n=0;n<20;n++)
		if(AM.IgnoreNames[n] == "")
		{
			AM.IgnoreNames[n] = str;
			AM.SaveConfig();
			return;
		}
}

function AddIPToWhitelist(string str)
{
local int n;
	for (n=0;n<20;n++)
		if(AM.WhitelistIP[n] == "")
		{
			AM.WhitelistIP[n] = str;
			AM.SaveConfig();
			return;
		}
}

function AddNameToWhitelist(string str)
{
local int n;
	for (n=0;n<20;n++)
		if(AM.WhitelistNames[n] == "")
		{
			AM.WhitelistNames[n] = str;
			AM.SaveConfig();
			return;
		}
}

function AddBanItem(string str)
{
local int n;
	for (n=0;n<17;n++)
		if(AM.BannedObjects[n] == "")
		{
			AM.BannedObjects[n] = str;
			ASay("Banning item:"@str);
			AM.SaveConfig();
			return;
		}
}

function ClearBanItem()
{
local int n;
	for (n=0;n<17;n++)
			AM.BannedObjects[n] = "";
			AM.SaveConfig();
}

function bool IsBannedItem(string str)
{
local int n;
	for (n=0;n<17;n++)
		if(AM.BannedObjects[n] != "")
		{
			if(AM.BannedObjects[n] == str)
			return true;
		}
}

function bool Marked(deusexplayer P)
{
local string IP;
local int n;
local bool bMarked;
local bool bFoundName;
	IP = P.GetPlayerNetworkAddress();
			IP = Left(IP, InStr(IP, ":"));
		for (n=0;n<30;n++)
		{
			if(IP == AM.TroublePlayerIP[n])
			{
				Log("IP found on Marks list.",'MARK');
				bMarked=True; //Found ya, jackass.
					for (n=0;n<30;n++)
						if(P.PlayerReplicationInfo.PlayerName ~= AM.TroublePlayersNames[n])
							bFoundName=True;

				if(!bFoundName) //You changed your name huh? well that ones being added too.
				{
					AddNameToMarks(P.PlayerReplicationInfo.PlayerName);
				}
			}
		}
		
		if(!bMarked) //Okay, so their IP wasnt listed, what about the name.
		{
			for (n=0;n<30;n++)
				if(P.PlayerReplicationInfo.PlayerName ~= AM.TroublePlayersNames[n])
					bMarked=True; //Gotcha. But don't bother adding a new IP, since if this occurs, it's probably a dynamic IP and just fill the logs with nonsense.
		}
		
		if(bMarked)
			return True;
		else
			return False;
}

function string ListAdmins()
{
local DeusExPlayer _Player;
local string _TmpString;
      ForEach AllActors(class 'DeusExPlayer', _Player)
      {
        if(_Player != None && _Player.bAdmin)
        {
          _TmpString = _TmpString$_Player.PlayerReplicationInfo.PlayerName$"("$_Player.PlayerReplicationInfo.PlayerID$"), ";
        }
      }
      if(Len(_TmpString) == 0)
      {
        _TmpString = "None...";
      }
      else
      {
        _TmpString = Left(_TmpString, Len(_TmpString)-2);
      }
      _TmpString = "Online Admins are"@_TmpString;
      return _TmpString;
}
	
defaultproperties
{
}
