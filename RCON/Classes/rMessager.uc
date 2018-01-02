class rMessager extends RCONActors config (RCON);

enum MsgMode
{
    MODE_Sequential,
    MODE_Random,
    MODE_Disabled
};
var config MsgMode Mode;
var config string Text[30], NoHighStreaker, NoHighKiller, NoStreak, NoKills;
var config bool AddLogMessage, MessageWhenNoPlayers;
var string Text_DB[30], LastMessage;
var DeusExPlayer Player;
var config byte Delay;
var byte oldDelay;
var int i,n;
var deusexplayer HighKillPlayer, HighStreakPlayer;
var bool HavePlayer, NeedNewMessage;
var IRCLink myIRC;
var RCONStats Stats;

function prebeginplay()
{
local IRCLink IRC;
local RCONStats RStats;
    log("+=================",'Messager');
    Log("|Starting the mutator...",'Messager');
    log("+=================",'Messager');
    Settimer(float(Delay),true);
    oldDelay=Delay;
				foreach AllActors(class'IRCLink',IRC)
				{
					if(IRC != None)
					{
						myIRC = IRC;
						Log("IRC link found.",'Messager');
					}
				}
		
				foreach AllActors(class'RCONStats',RStats)
				{
					if(RStats != None)
					{
						Stats = RStats;
						Log("RCON STats found.",'Messager');
					}
				}
    super.PreBeginPlay();
}

function tick (float v)
{
    if (Delay!=oldDelay)
    {
        oldDelay=Delay;
        settimer(Delay,true);
    }
    super.tick(v);
}

function GetHighStreaker()
{
    local DeusExPlayer Player;
    foreach allactors(class'deusexplayer',Player)
    {
        if (Player.PlayerReplicationInfo.Streak>0)
        {
            if (HighStreakPlayer!=None)
            {
                if (Player.PlayerReplicationInfo.Streak>HighStreakPlayer.PlayerReplicationInfo.Streak)
                    {
                        HighStreakPlayer=Player;
                    }
            }
            else
                HighStreakPlayer=Player;
            havePlayer=true;
        }
    }
}

function GetHighKiller()
{
    local deusexplayer Player;
    foreach allactors(class'deusexplayer',Player)
    {
        if (Player.PlayerReplicationInfo.Score>0)
        {
            if (HighKillPlayer!=None)
            {
                if (Player.PlayerReplicationInfo.Score>HighKillPlayer.PlayerReplicationInfo.Score)
                    {
                        HighKillPlayer=Player;
                    }
            }
            else
                HighKillPlayer=Player;
            havePlayer=true;
        }
    }
}

function string CheckMetaTags (string inputstring)
{
    local string TempMessage, TempLeft, TempRight, OutMessage, _TmpString;
    local string iHour, iMinute, iDay, iMonth, iYear, AmPm;
    local deusexplayer Player, _Player;
	local IRCLink IRL;
	
    //get the time and do string manipulations based on digits.
    AMPM="AM";     //we'll change this string only if its later than 11am.
    if (Level.Hour>=12)
    {
        iHour=string(Level.Hour-12);
        AmPm="PM";
    }
    else
        iHour=string(level.Hour);

    if (Level.Hour==0 || Level.Hour==12)
    {
        iHour="12";
    }
    if (Level.Minute<10)
    {
        iMinute="0"$string(level.Minute);
    }
    else iMinute=string(level.minute);

    //get the date
    iDay=string(level.Day);
    iYear=string(Level.Year);
    iMonth=string(level.Month);

    OutMessage=InputString;

    if (instr(caps(OutMessage), "<HIGHSTATSCHECK>") != -1)
    {
        GetHighStreaker();
        GetHighKiller();
        if (((instr(caps(OutMessage), "<HIGHSTREAKNAME>") != -1) && HighStreakPlayer==none) ||
        ((instr(caps(OutMessage), "<HIGHKILLNAME>") != -1) && HighKillPlayer==None) ||
        ((instr(caps(OutMessage), "<HIGHSTREAK>") != -1) && HighStreakPlayer==None) ||
        ((instr(caps(OutMessage), "<HIGHSTREAKNAME>") != -1) && HighKillPlayer==none))
            {
               NeedNewMessage=True;
               return "";
            }
    }
	
    while (instr(caps(OutMessage), "<HIGHSTREAKNAME>") != -1)
    {
        tempRight=(right(OutMessage, (len(OutMessage)-instr(caps(OutMessage), "<HIGHSTREAKNAME>"))-16));
        HavePlayer=false;
        HighStreakPlayer=None;
        GetHighStreaker();
        if (havePlayer && HighStreakPlayer!= None)
            tempLeft=(left(OutMessage, instr(caps(OutMessage), "<HIGHSTREAKNAME>"))$HighStreakPlayer.PlayerReplicationInfo.PlayerName);
        else
            tempLeft=(left(OutMessage, instr(caps(OutMessage), "<HIGHSTREAKNAME>"))$NoHighStreaker);
        OutMessage=TempLeft$TempRight;
    }

    while (instr(caps(OutMessage), "<HIGHKILLNAME>") != -1)
    {
        tempRight=(right(OutMessage, (len(OutMessage)-instr(caps(OutMessage), "<HIGHKILLNAME>"))-14));
        haveplayer=false;
        HighKillPlayer=None;
        GetHighKiller();
        if (havePlayer && HighKillPlayer!= None)
            tempLeft=(left(OutMessage, instr(caps(OutMessage), "<HIGHKILLNAME>"))$HighKillPlayer.PlayerReplicationInfo.PlayerName);
        else
            tempLeft=(left(OutMessage, instr(caps(OutMessage), "<HIGHKILLNAME>"))$NoHighKiller);
        OutMessage=TempLeft$TempRight;
    }

    while (instr(caps(OutMessage), "<HIGHSTREAK>") != -1)
    {
        tempRight=(right(OutMessage, (len(OutMessage)-instr(caps(OutMessage), "<HIGHSTREAK>"))-12));
        haveplayer=false;
        HighStreakPlayer=None;
        GetHighStreaker();
        if (haveplayer && HighStreakPlayer!= none)
            tempLeft=(left(OutMessage, instr(caps(OutMessage), "<HIGHSTREAK>"))$int(HighStreakPlayer.PlayerReplicationInfo.Streak));
        else
            tempLeft=(left(OutMessage, instr(caps(OutMessage), "<HIGHSTREAK>"))$NoStreak);
        OutMessage=TempLeft$TempRight;
    }

    while (instr(caps(OutMessage), "<HIGHKILLS>") != -1)
    {
        tempRight=(right(OutMessage, (len(OutMessage)-instr(caps(OutMessage), "<HIGHKILLS>"))-12));
        haveplayer=false;
        HighKillPlayer=None;
        GetHighKiller();
        if (HavePlayer && HighKillPlayer!= none)
            tempLeft=(left(OutMessage, instr(caps(OutMessage), "<HIGHKILLS>"))$Int(HighKillPlayer.PlayerReplicationInfo.Score));
        else
            tempLeft=(left(OutMessage, instr(caps(OutMessage), "<HIGHKILLS>"))$NoKills);
        OutMessage=TempLeft$TempRight;
    }

    while (instr(caps(OutMessage), "<TIME>") != -1)
    {
        tempRight=(right(OutMessage, (len(OutMessage)-instr(caps(OutMessage), "<TIME>"))-6));
        tempLeft=(left(OutMessage, instr(caps(OutMessage), "<TIME>"))$iHour$":"$iMinute$AmPm);
        OutMessage=TempLeft$TempRight;
    }

    while (instr(caps(OutMessage), "<SERVERNAME>") != -1)
    {
        tempRight=(right(OutMessage, (len(OutMessage)-instr(caps(OutMessage), "<SERVERNAME>"))-12));
        tempLeft=(left(OutMessage, instr(caps(OutMessage), "<SERVERNAME>"))$Level.Game.GameReplicationInfo.ServerName);
        OutMessage=TempLeft$TempRight;
    }

    while (instr(caps(OutMessage), "<ADMINNAME>") != -1)
    {
        tempRight=(right(OutMessage, (len(OutMessage)-instr(caps(OutMessage), "<ADMINNAME>"))-11));
        tempLeft=(left(OutMessage, instr(caps(OutMessage), "<ADMINNAME>"))$Level.Game.GameReplicationInfo.AdminName);
        OutMessage=TempLeft$TempRight;
    }

    while (instr(caps(OutMessage), "<ADMINEMAIL>") != -1)
    {
        tempRight=(right(OutMessage, (len(OutMessage)-instr(caps(OutMessage), "<ADMINEMAIL>"))-12));
        tempLeft=(left(OutMessage, instr(caps(OutMessage), "<ADMINEMAIL>"))$Level.Game.GameReplicationInfo.AdminEmail);
        OutMessage=TempLeft$TempRight;
    }

    while (instr(caps(OutMessage), "<DAY>") != -1)
    {
        tempRight=(right(OutMessage, (len(OutMessage)-instr(caps(OutMessage), "<DAY>"))-5));
        tempLeft=(left(OutMessage, instr(caps(OutMessage), "<DAY>"))$iDay);
        OutMessage=TempLeft$TempRight;
    }

    while (instr(caps(OutMessage), "<MONTH>") != -1)
    {
        tempRight=(right(OutMessage, (len(OutMessage)-instr(caps(OutMessage), "<MONTH>"))-7));
        tempLeft=(left(OutMessage, instr(caps(OutMessage), "<MONTH>"))$iMonth);
        OutMessage=TempLeft$TempRight;
    }

    while (instr(caps(OutMessage), "<YEAR>") != -1)
    {
        tempRight=(right(OutMessage, (len(OutMessage)-instr(caps(OutMessage), "<YEAR>"))-6));
        tempLeft=(left(OutMessage, instr(caps(OutMessage), "<YEAR>"))$iyear);
        OutMessage=TempLeft$TempRight;
    }

    while (instr(caps(OutMessage), "<CURPLAYERS>") != -1)
    {
        tempRight=(right(OutMessage, (len(OutMessage)-instr(caps(OutMessage), "<CURPLAYERS>"))-12));
        tempLeft=(left(OutMessage, instr(Caps(OutMessage), "<CURPLAYERS>"))$Level.Game.NumPlayers);
        OutMessage=TempLeft$TempRight;
    }

    while (instr(caps(OutMessage), "<MAXPLAYERS>") != -1)
    {
        tempRight=(right(OutMessage, (len(OutMessage)-instr(caps(OutMessage), "<MAXPLAYERS>"))-12));
        tempLeft=(left(OutMessage, instr(Caps(OutMessage), "<MAXPLAYERS>"))$Level.Game.MaxPlayers);
        OutMessage=TempLeft$TempRight;
    }
	
    while (instr(caps(OutMessage), "<IRC_STATUS>") != -1)
    {
			if(myIRC == None)
			{
				foreach AllActors(class'IRCLink',IRL)
				{
					if(IRL != None)
					{
						myIRC = IRL;
					}
				}
			}
        tempRight=(right(OutMessage, (len(OutMessage)-instr(caps(OutMessage), "<IRC_STATUS>"))-12));
		if(myIRC != None)
        tempLeft=(left(OutMessage, instr(Caps(OutMessage), "<IRC_STATUS>"))$"|P4ONLINE");
		else
		tempLeft=(left(OutMessage, instr(Caps(OutMessage), "<IRC_STATUS>"))$"|P2OFFLINE");
        OutMessage=TempLeft$TempRight;
    }
	    
	while (instr(caps(OutMessage), "<IRC_SERVER>") != -1)
    {
			if(myIRC == None)
			{
				foreach AllActors(class'IRCLink',IRL)
				{
					if(IRL != None)
					{
						myIRC = IRL;
					}
				}
			}
        tempRight=(right(OutMessage, (len(OutMessage)-instr(caps(OutMessage), "<IRC_SERVER>"))-12));
		if(myIRC != None)
        tempLeft=(left(OutMessage, instr(Caps(OutMessage), "<IRC_SERVER>"))$myIRC.Server);
		else
		tempLeft=(left(OutMessage, instr(Caps(OutMessage), "<IRC_SERVER>"))$"|P2OFFLINE");
        OutMessage=TempLeft$TempRight;
    }
	
	while (instr(caps(OutMessage), "<IRC_USERNAME>") != -1)
    {
			if(myIRC == None)
			{
				foreach AllActors(class'IRCLink',IRL)
				{
					if(IRL != None)
					{
						myIRC = IRL;
					}
				}
			}
        tempRight=(right(OutMessage, (len(OutMessage)-instr(caps(OutMessage), "<IRC_USERNAME>"))-14));
		if(myIRC != None)
        tempLeft=(left(OutMessage, instr(Caps(OutMessage), "<IRC_USERNAME>"))$myIRC.Username);
		else
		tempLeft=(left(OutMessage, instr(Caps(OutMessage), "<IRC_USERNAME>"))$"|P2OFFLINE");
        OutMessage=TempLeft$TempRight;
    }

	while (instr(caps(OutMessage), "<IRC_CHANNEL>") != -1)
    {
			if(myIRC == None)
			{
				foreach AllActors(class'IRCLink',IRL)
				{
					if(IRL != None)
					{
						myIRC = IRL;
					}
				}
			}
        tempRight=(right(OutMessage, (len(OutMessage)-instr(caps(OutMessage), "<IRC_CHANNEL>"))-13));
		if(myIRC != None)
        tempLeft=(left(OutMessage, instr(Caps(OutMessage), "<IRC_CHANNEL>"))$myIRC.Channel);
		else
		tempLeft=(left(OutMessage, instr(Caps(OutMessage), "<IRC_CHANNEL>"))$"|P2OFFLINE");
        OutMessage=TempLeft$TempRight;
    }
	
	while (instr(caps(OutMessage), "<ONLINE_ADMINS>") != -1)
    {
        tempRight=(right(OutMessage, (len(OutMessage)-instr(caps(OutMessage), "<ONLINE_ADMINS>"))-15));
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
        tempLeft=(left(OutMessage, instr(Caps(OutMessage), "<ONLINE_ADMINS>"))$Left(_TmpString, Len(_TmpString)-2));

        OutMessage=TempLeft$TempRight;
    }	

	while (instr(caps(OutMessage), "<STATS_PLAYERS>") != -1)
    {
        tempRight=(right(OutMessage, (len(OutMessage)-instr(caps(OutMessage), "<STATS_PLAYERS>"))-15));
		if(Stats != None)
        tempLeft=(left(OutMessage, instr(Caps(OutMessage), "<STATS_PLAYERS>"))$Stats.HighestPlayerCount$" reached at "$Stats.HighestPlayerCountTime);
		else
		tempLeft=(left(OutMessage, instr(Caps(OutMessage), "<STATS_PLAYERS>"))$"|P2MISSING MUTATOR");
        OutMessage=TempLeft$TempRight;
    }
	
	while (instr(caps(OutMessage), "<STATS_KILLS>") != -1)
    {
        tempRight=(right(OutMessage, (len(OutMessage)-instr(caps(OutMessage), "<STATS_KILLS>"))-13));
		if(Stats != None)
        tempLeft=(left(OutMessage, instr(Caps(OutMessage), "<STATS_KILLS>"))$Stats.HighestScoreName$" scored "$Stats.HighestScore);
		else
		tempLeft=(left(OutMessage, instr(Caps(OutMessage), "<STATS_KILLS>"))$"|P2MISSING MUTATOR");
        OutMessage=TempLeft$TempRight;
    }

	while (instr(caps(OutMessage), "<STATS_DEATHS>") != -1)
    {
        tempRight=(right(OutMessage, (len(OutMessage)-instr(caps(OutMessage), "<STATS_DEATHS>"))-14));
		if(Stats != None)
        tempLeft=(left(OutMessage, instr(Caps(OutMessage), "<STATS_DEATHS>"))$Stats.HighestDeaths$" from "$Stats.HighestDeathsName);
		else
		tempLeft=(left(OutMessage, instr(Caps(OutMessage), "<STATS_DEATHS>"))$"|P2MISSING MUTATOR");
        OutMessage=TempLeft$TempRight;
    }
	
    return OutMessage;
}

function timer()
{
    local int n2;
    local string Message;
    if (!MessageWhenNoPlayers && Level.Game.NumPlayers==0)
        return;
    for (n=0;n<30;n++)
    {
        if (Text[n]!="")
        {                     //this makes a database of all the text strings
            Text_DB[n2]=Text[n];  //to use later on so we don't get empty messages
            n2++;
        }
    }
    if (Mode==MODE_Sequential)
    {
        newmessage:
        if (i>(n2-1))   //-1 to get rid of empty message bug.
            i=0;
        Message=CheckMetaTags(Text_DB[i]);
        if (NeedNewMessage)
        {
            NeedNewMessage=False;
            i++;
            goto NewMessage;
        }
        if (AddLogMessage)
            log(Message,'Messager');
        BeepPlayers(Message);
        i++;
    }
    else if (Mode==MODE_Random)
    {
        newmessage2:
        i=rand(n2);
        Message=CheckMetaTags(Text_DB[i]);
        if (NeedNewMessage || (Message==LastMessage))
        {
            NeedNewMessage=False;
            goto NewMessage2;
        }
        LastMessage=Message;
        if (AddLogMessage)
            log(Message,'Messager');
        BeepPlayers(Message);
    }
}

function BeepPlayers(string str)
{
local DeusExPlayer pl;
	foreach AllActors(class'DeusExPlayer',pl)
		pl.ClientMessage(str);
}

defaultproperties
{
    bhidden=true
    Mode=MODE_Sequential
    AddLogMessage=true
    NoHighStreaker="No One"
    NoHighKiller="No One"
    NoKills="No Kills"
    NoStreak="No Streak"
}
