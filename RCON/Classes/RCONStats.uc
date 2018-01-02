class RCONStats extends Mutator config(RCON);

var() config bool          bEnabled;
var() config int CheckTime;
var config int HighestPlayerCount, HighestScore, HighestDeaths, HighestPing, HighestStreak;
var config string HighestScoreName, HighestDeathsName, HighestPingName, HighestStreakName;
var config string HighestScoreTime, HighestDeathsTime, HighestStreakTime, HighestPingTime, HighestPlayerCountTime;

function PostBeginPlay()
{
	super.PostBeginPlay();
    SetTimer(float(CheckTime), True);
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

function Timer()
{
    if (bEnabled == false) return;

	GetPlayerCount();
	GetScores();
	GetDeaths();
	GetPings();
	GetStreak();
	//StatTrack();
}

function GetPlayerCount()
{
	if ( Level.Game.NumPlayers > HighestPlayerCount )
	{
		BroadcastMessage("|P4NEW RECORD: Highest Player Count!");
		BroadcastMessage("|P4Previously: " $ string(HighestPlayerCount));
		BroadcastMessage("|P4New: " $ string(Level.Game.NumPlayers));
		HighestPlayerCount = Level.Game.NumPlayers;
		HighestPlayerCountTime = GetTime();
		SaveConfig();
	}
}

function GetScores()
{
local DeusExPlayer DXP;
	foreach AllActors(Class'DeusExPlayer',DXP)
	{
		if ( DXP.PlayerReplicationInfo.Score > HighestScore )
		{
			BroadcastMessage("|P4NEW RECORD: Highest Score!");
			BroadcastMessage("|P4Previously: " $ string(HighestScore)$" by "$HighestScoreName);
			BroadcastMessage("|P4New: " $int(DXP.PlayerReplicationInfo.Score)$" by "$DXP.PlayerReplicationInfo.PlayerName);
			HighestScore = DXP.PlayerReplicationInfo.Score;
			HighestScoreName = DXP.PlayerReplicationInfo.PlayerName;
			HighestScoreTime = GetTime();
			SaveConfig();			
		}
	}
}

function GetDeaths()
{
local DeusExPlayer DXP;
	foreach AllActors(Class'DeusExPlayer',DXP)
	{
		if ( DXP.PlayerReplicationInfo.Deaths > HighestDeaths )
		{
			BroadcastMessage("|P4NEW RECORD: Highest Deaths Count!");
			BroadcastMessage("|P4Previously: " $ string(HighestDeaths)$" by "$HighestDeathsName);
			BroadcastMessage("|P4New: " $ int(DXP.PlayerReplicationInfo.Deaths)$" by "$DXP.PlayerReplicationInfo.PlayerName);
			HighestDeaths = DXP.PlayerReplicationInfo.Deaths;
			HighestDeathsName = DXP.PlayerReplicationInfo.PlayerName;
			HighestDeathsTime = GetTime();
			SaveConfig();			
		}
	}
}

function GetStreak()
{
local DeusExPlayer DXP;
	foreach AllActors(Class'DeusExPlayer',DXP)
	{
		if ( DXP.PlayerReplicationInfo.Streak > HighestStreak )
		{
			BroadcastMessage("|P4NEW RECORD: Highest Streak Count!");
			BroadcastMessage("|P4Previously: " $ string(HighestStreak)$" by "$HighestStreakName);
			BroadcastMessage("|P4New: " $ int(DXP.PlayerReplicationInfo.Streak)$" by "$DXP.PlayerReplicationInfo.PlayerName);
			HighestStreak = DXP.PlayerReplicationInfo.Streak;
			HighestStreakName = DXP.PlayerReplicationInfo.PlayerName;
			HighestStreakTime = GetTime();
			SaveConfig();			
		}
	}
}

function GetPings()
{
local DeusExPlayer DXP;
	foreach AllActors(Class'DeusExPlayer',DXP)
	{
		if ( DXP.PlayerReplicationInfo.Ping > HighestPing )
		{
			BroadcastMessage("|P4NEW RECORD: Highest Ping Count!");
			BroadcastMessage("|P4Previously: " $ string(HighestPing)$" by "$HighestPingName);
			BroadcastMessage("|P4New: " $ DXP.PlayerReplicationInfo.Ping$" by "$DXP.PlayerReplicationInfo.PlayerName);
			HighestPing = DXP.PlayerReplicationInfo.Ping;
			HighestPingName = DXP.PlayerReplicationInfo.PlayerName;
			HighestPingTime = GetTime();
			SaveConfig();			
		}
	}
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

function Mutate(string MutateString, PlayerPawn Sender)
{
local int ID;
local float CT;
local string Part;
local Pawn APawn;
local string Text, TP;

		if(MutateString ~= "stat.enabled")
		{
			if(Sender.bAdmin)
			{
				if(bEnabled)
				{
					Text = "Admin: "$Sender.PlayerReplicationInfo.PlayerName$"("$Sender.PlayerReplicationInfo.PlayerID$") disabled RCON Stat Tracking ";
					PrintToAll(Text);
					bEnabled=False;
					SaveConfig();
				}
				else
				{
					Text = "Admin: "$Sender.PlayerReplicationInfo.PlayerName$"("$Sender.PlayerReplicationInfo.PlayerID$") enabled RCON Stat Tracking ";
					PrintToAll(Text);
					bEnabled=True;
					SaveConfig();
				}
			}
		}
		else if(MutateString ~= "stat.score")
		{
			BroadcastMessage("|P3Current Score Record: "$HighestScore$" by "$HighestScoreName);
			BroadcastMessage("|P3Achieved at"@HighestScoreTime);
		}
		else if(MutateString ~= "stat.deaths")
		{
			BroadcastMessage("|P3Current deaths Record: "$Highestdeaths$" by "$HighestdeathsName);
			BroadcastMessage("|P3Achieved at"@HighestdeathsTime);
		}
		else if(MutateString ~= "stat.streak")
		{
			BroadcastMessage("|P3Current streak Record: "$Higheststreak$" by "$HigheststreakName);
			BroadcastMessage("|P3Achieved at"@HigheststreakTime);
		}		
		else if(MutateString ~= "stat.ping")
		{
			BroadcastMessage("|P3Current ping Record: "$Highestping$" by "$HighestpingName);
			BroadcastMessage("|P3Achieved at"@HighestpingTime);
		}		
		else if(MutateString ~= "stat.players")
		{
			BroadcastMessage("|P3Current Players Record: "$Highestplayercount);
			BroadcastMessage("|P3Achieved at"@HighestplayercountTime);
		}				
		else if(left(MutateString,16) ~= "stat.CheckTimer ")
        {
            CT = int(Left(Right(MutateString, Len(MutateString) - 16),InStr(MutateString," ")));
							if(Sender.bAdmin)
							{
								Text = "Admin: "$Sender.PlayerReplicationInfo.PlayerName$"("$Sender.PlayerReplicationInfo.PlayerID$") changed Stats CheckTimer: "$CT;
								PrintToAll(Text);
								checkTime=CT;
								SaveConfig();
							}
		}
	

   	Super.Mutate(MutateString, Sender);
}

defaultproperties
{
CheckTime=10
bHidden=True
}