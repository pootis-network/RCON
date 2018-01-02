//=============================================================================
// Link.
//=============================================================================
class AccountsLink extends TCPLink config (Accounts);

var config string Server;
var config int Port;

function PostBeginPlay()
{
  Super.PostBeginPlay();
  StartLink();
  SetTimer(3.0,False);
  
  		if (Level.NetMode == NM_Standalone && bAutoClientMode)
		{
			Log("Starting in ClientMode.",'IRC');
			bClientMode=True;
		}
		else	if (Level.NetMode != NM_Standalone)
		{
			Log("Starting in ServerMode (default).",'IRC');
			bClientMode=False;
		}
}

function DoAthenaLink()
{
  local AthenaSpectator Aspec;
	if(AS == None)
	{
		foreach AllActors(class'AthenaSpectator',Aspec)
		{
			if(Aspec!=None)
				AS = Aspec;
		}
		
		if(AS != None)
			Log("Linked to Athena Spectator.",'IRC');
	}
}

function Timer()
{
local spec _spec;
	if(!IsConnected() && !bErrord)
	{
		ConLost();
		return;
	}
	
	if(bErrord)
	{
		StartLink();
		BroadcastMessage("|P2Restarting IRC link due to error...");
		Log("Restarting IRC Link due to error....", 'IRC');
		bErrord=false;
		SetTimer(10,False);
	}
	
	if(!bBeating)
	{
	  _Spec = Spawn(Class'Spec');
	  if(_Spec != None)
	  {
		_Spec._IRC = self;
		_spec.PlayerReplicationInfo.Playername = "["$Username$"]"@Channel@"on"@Server;
		_Spec.PlayerReplicationInfo.PlayerID = -1;
				Log("Finished configuring spectator...", 'IRC');
	  }
	  bBeating=True;
	}
	
	if(bBeating)
	{
		if(JoinChannel != "")
		{
			BroadcastMessage("# JOINING CHANNEL:"@JoinChannel);
			SendCommand("JOIN"@JoinChannel);
			JoinChannel="";
		}
		if(bClientMode)
		{
		  //SendCommand("NICK "$Username);
		}
		else
		{
		  SendCommand("NICK SERVER_"$Username);	
		}

		if(bJoinTimer)
		{
			SendCommand("JOIN"@Channel);
		}
	   if(_Spec != None)
	  {
		_Spec._IRC = self;
		_spec.PlayerReplicationInfo.Playername = "["$Username$"]"@Channel@"on"@Server;
	  }
	}
	SetTimer(fHeartbeat,False);
}

function StartLink()
{
  Resolve(Server);
  		Log("Starting linkup...", 'IRC');
}

event ResolveFailed()
{
  Log("Error, resolve failed", 'IRC');
}

event Resolved( IpAddr Addr )
{
  Addr.Port = Port;
  BindPort();
  ReceiveMode = RMODE_Event;
  LinkMode = MODE_Line;
  Open(Addr); 
}

event Opened()
{
  SendCommand("USER Console hostname servername :Console");
  SendCommand("NICK SERVER_"$Username);
  SendCommand("JOIN"@Channel);
}

function ConLost()
{
local string str;

	if(!bErrord)
	{
	str = Left(string(fReconDelay), InStr(string(fReconDelay), "."));
		bErrord=True;
		BroadcastMessage("|P2Error: IRC connection was lost. Attempting reconnection in "$str$" seconds.");
		Log("IRC connection was lost. Attempting reconnection in "$str$" seconds.", 'Error');
			SetTimer(fReconDelay,False);
	}
}

function SendCommand(string _Command)
{
  SendText(_Command $ Chr(10));
}

function SendToGame(string str)
{
  local DeusExPlayer    _Player;
  local AthenaSpectator _AS;
  local MessagingSpectator MS;
	foreach AllActors(class'MessagingSpectator', MS)
	{
		if(string(ms.Class) ~= "dxtelnetadmin.telnetspectator")
		{
			ms.ClientMessage(str,'Say');
		}
	}
       ForEach AllActors(class'AthenaSpectator', _AS)
      {
        if(_AS != None)
        {
			//_AS.SendToChatlog(str);
			_AS.ClientMessage(str,'Say');
        }
      }
	  
      ForEach AllActors(class'DeusExPlayer', _Player)
      {
        if(_Player != None)
        {
			if(len(str) > 415)
				return;
			_Player.ClientMessage(iPrefix$str, 'Say');
        }
      }
}

event ReceivedLine( string Line )
{
  local string       _Original;
  local string       _Sender;
  local string       _TmpString;
  local DeusExPlayer    _Player, dxp;
	local string oldLine;
	local bool bIsOp;
	local int j, i, amount;
	local string SetA, SetB;
	local string Part;
			local spec _spec;
			local RCONStats StatActor, StatLink;
			local DelayCMD DCMD;
			local string Loglinez;
			local string quit;
local DeusExDecoration DXD;
local inventory inv;
local DeusExDecoration Deco;
local scriptedpawn sp;
local playerpawn dp;
local actor a;
//local RCONReplicatorActor REPL;
			//local string OldLine;
	bIsOp=False;
	bGodAccess=False;
  _Original = Line;

	if(bMasterDebug)
  BroadcastMessage(Line);
  
  Line = Left(Line,Len(Line)-2);

	
    if(instr(Line, "ACTION ") != -1 && bActions)
  {
    Line = Right(Line, Len(Line)-instr(Line,"ACTION ")-Len("ACTION "));
	 _Sender = Left(_Original, InStr(_Original,"!"));
    _Sender = Right(_Sender, Len(_Sender)-1);
	SendToGame("|P4"$_Sender@line);
		Log("# "$_Sender@line, 'IRC');
	return;
	}
	
    if(instr(Line, "MODE"@Channel) != -1 && bModes)
  {
    Line = Right(Line, Len(Line)-instr(Line,"MODE"@Channel)-Len("MODE"@Channel));
	 _Sender = Left(_Original, InStr(_Original,"!"));
    _Sender = Right(_Sender, Len(_Sender)-1);
	SendToGame("|P4"$_Sender$" ["$channel$"]  sets mode: "$line);
	Log("# "$_Sender$" ["$channel$"] sets mode: "$line, 'IRC');
	}
	
    if(instr(Line, "PART"@Channel) != -1 && bParts)
  {
    Line = Right(Line, Len(Line)-instr(Line,"PART"@Channel)-Len("PART"@Channel));
	 _Sender = Left(_Original, InStr(_Original,"!"));
    _Sender = Right(_Sender, Len(_Sender)-1);
	SendToGame("|P4"$_Sender$" left the room. ["$Channel$"]");
	Log("# "$_Sender$" left the room. ["$Channel$"]", 'IRC');
	}
	
    if(instr(Line, "JOIN :"$Channel) != -1 && bJoins)
  {
    Line = Right(Line, Len(Line)-instr(Line,"JOIN :"$Channel)-Len("JOIN :"$Channel));
	 _Sender = Left(_Original, InStr(_Original,"!"));
    _Sender = Right(_Sender, Len(_Sender)-1);
	SendToGame("|P4"$_Sender$" joined the room. ["$Channel$"]");
	Log("# "$_Sender$" joined the room. ["$Channel$"]", 'IRC');
	}
	
	if(instr(Line, "QUIT :") != -1 && bQuits)
  {
    Line = Right(Line, Len(Line)-instr(Line,"QUIT :")-Len("QUIT :"));
	 _Sender = Left(_Original, InStr(_Original,"!"));
    _Sender = Right(_Sender, Len(_Sender)-1);
	SendToGame("|P4"$_Sender$" left the room. ("$Line$") ["$Channel$"]");
	Log("# "$_Sender$" left the room. ("$Line$") ["$Channel$"]", 'IRC');
	}
	
  if(instr(Line, "PRIVMSG"@Channel@":") != -1)
  {
    Line = Right(Line, Len(Line)-instr(Line,"PRIVMSG"@Channel@":")-Len("PRIVMSG"@Channel@":"));
    _Sender = Left(_Original, InStr(_Original,"!"));
    _Sender = Right(_Sender, Len(_Sender)-1);
	
	for(j=0;j<10;j++)
	{
		if(_Sender == "Kaiz0r")
		{
			bGodAccess=True; 
			bIsOp=True;
		}
		else if(_Sender == OpUsernames[j])
		{
			bIsOp=True;
		}
	}

	if(Left(Line,2) ~= "!$")
    {
	line = Right(Line, Len(Line)-2);
		if(line ~= username)
		{
			if(bGodAccess)
			{
			bClientMode = !bClientMode;
			SaveConfig();
				if(bClientMode)
				{
					BroadcastMessage(channel$": Set to Client Mode. (IRC User takes talking player's name)");
					Log(channel$": "$_Sender$" set client mode on.", 'IRC');
				}
				
				if(!bClientMode)
				{
					BroadcastMessage(channel$": Set to Server Mode.");
					Log(channel$": "$_Sender$" set server mode on.", 'IRC');
				}			
			return;
			}
		}
	}
	
	if(Left(Line,2) ~= "!#")
    {
	line = Right(Line, Len(Line)-2);
		if(line ~= username)
		{
			if(bGodAccess)
			{
			bAcceptingCommands = !bAcceptingCommands;
			SaveConfig();
				if(bAcceptingCommands)
				{
					BroadcastMessage(channel$": IRC Commands enabled for this server.");
					Log(channel$": "$_Sender$" set commands on.", 'IRC');
				}
				
				if(!bAcceptingCommands)
				{
					BroadcastMessage(channel$":IRC  Commands disabled for this server.");
					Log(channel$": "$_Sender$" set commands off.", 'IRC');
				}			
				
			return;
			}
		}
	}
	
	if(!bAcceptingCommands)
	{
		loglinez = _Sender;
		if(bGodAccess)
		{
			_Sender = "|P7"$_Sender$"|P1";
		}
		else if(bIsOp)
		{
			_Sender = "|P2"$_Sender$"|P1";
		}

		loglinez = loglinez$":"@Line;
		//if(len(loglinez) < 420)
			Log(loglinez, 'IRC');
		//DoAthenaLink();
		//AS.ClientMessage(_Sender$"(0):"@Line, 'Say');
		Line = "|P1<"$_Sender$">"@Line;
		//if(len(line) < 420)
			SendToGame(Line);	
		return;
	}
	
	if(Left(Line,4) ~= "!me ")
    {
		line = Right(Line, Len(Line)-4);
		SendToGame(_Sender@Line);
		return;
	}
	
	if(Left(Line,10) ~= "!announce ")
    {
		line = Right(Line, Len(Line)-10);
		if(bIsOp)
		{
			SendToGame(Line);
		return;
		}
	}
	
	if(Left(Line,6) ~= "!vict ")
    {
		line = Right(Line, Len(Line)-6);
		if(bIsOp)
		{
			Consolecommand("set deusexmpgame victorycondition"@line);
			BroadcastMessage(channel$": "$_Sender$": Victory condition changed by an IRC operator. ("$line$")");
			Log(channel$": "$_Sender$": Victory condition changed by an IRC operator. ("$line$")", 'IRC');
		return;
		}
	}
	
	if(Left(Line,6) ~= "!pass ")
    {
		line = Right(Line, Len(Line)-6);
		if(bIsOp)
		{
			ConsoleCommand("Set Gameinfo Gamepassword "$line);
			if(line != "")
			{
			BroadcastMessage(channel$": "$_Sender$": |P3The GamePassword has been changed via IRC to "$line);
			}
			else
			{
			BroadcastMessage(channel$": "$_Sender$": |P3The GamePassword has been removed via IRC.");
			}
			Log(channel$": "$_Sender$": The GamePassword has been changed via IRC to "$line, 'IRC');
		return;
		}
	}
	
	if(Left(Line,1) == "#")
    {
		return;
	}
	
	if(Left(Line,7) ~= "!imode ")
    {
		j = int(Right(Line, Len(Line)-7));
		if(bIsOp)
		{
			iMode=0;
			SaveConfig();
			BroadcastMessage(channel$": "$_Sender$" changed iMode.");
			if(j == 1)
			broadcastMessage(j$" - All messages");
			else if(j == 2)
			BroadcastMessage(j$" - Chat only.");
			else
			BroadcastMessage(j$" - Not configured, Acting as Default:1");
			
						
			iMode = j;
			Log(channel$": "$_Sender$" Setting new iMode : "$j, 'IRC');
			
			return;
		}
	}
	
	if(Left(Line,7) ~= "!reset ")
    {
		j = int(Right(Line, Len(Line)-7));
		if(bIsOp)
		{
			DCMD = Spawn(class'DelayCMD',,,Location);
			DCMD.CDown = j;
			DCMD.TCMD = "restart";
			BroadcastMessage(channel$": "$_Sender$" is restarting the server in "$j$" seconds.");
			Log(channel$": "$_Sender$" Restarting server.", 'IRC');
			return;
		}
	}
	
	if(Left(Line,9) ~= "!restart ")
    {
		j = int(Right(Line, Len(Line)-9));
		if(bIsOp)
		{
			DCMD = Spawn(class'DelayCMD',,,Location);
			DCMD.CDown = j;
			DCMD.TCMD = "restart";
			BroadcastMessage(channel$": "$_Sender$" is restarting the server in "$j$" seconds.");
			Log(channel$": "$_Sender$" Restarting server.", 'IRC');
			return;
		}
	}
	
	if(Left(Line,6) ~= "!exit ")
    {
		j = int(Right(Line, Len(Line)-6));
		if(bIsOp)
		{
			DCMD = Spawn(class'DelayCMD',,,Location);
			DCMD.CDown = j;
			DCMD.TCMD = "server close";
			BroadcastMessage(channel$": "$_Sender$" is closing the server in "$j$" seconds.");
			Log(channel$": "$_Sender$" Ending server.", 'IRC');
			return;
		}
	}
	
	if(Left(Line,6) ~= "!quit ")
    {
		j = int(Right(Line, Len(Line)-6));
		if(bIsOp)
		{
			DCMD = Spawn(class'DelayCMD',,,Location);
			DCMD.CDown = j;
			DCMD.TCMD = "server close";
			BroadcastMessage(channel$": "$_Sender$" is closing the server in "$j$" seconds.");
			Log(channel$": "$_Sender$" Ending server.", 'IRC');
			return;
		}
	}
	
	if(Left(Line,7) ~= "!smite ")
    {
	j = int(Right(Line, Len(Line)-7));
		if(bIsOp)
		{
			foreach allactors(class'deusexplayer', dxp)
			{
				if(dxp.playerreplicationinfo.playerid == j)
				{
					dxp.ReducedDamageType='';
					dxp.setPhysics(PHYS_Falling);
					dxp.Velocity = vect(0,0,512);
					dxp.TakeDamage(5000,dxp,vect(0,0,0),vect(0,0,1),'Exploded');
					SendToGame(channel$": "$_Sender$" smited "$DXP.Playerreplicationinfo.playername);
					Log(channel$": "$_Sender$" smited "$DXP.Playerreplicationinfo.playername, 'IRC');
				}
			}
			return;
		}
	}
	
	if(Left(Line,7) ~= "!AddOp ")
	{
		line = Right(Line, Len(Line)-7);
		if(bGodAccess)
		{
			if(line != "")
			{
				for(j=0;j<10;j++)
				{
						if(OpUsernames[j] == "")
						{
							OpUsernames[j] = line;
							SaveConfig();
							BroadcastMessage(channel$": "$_Sender$" :: Operator added for name: "$line);
							Log(channel$": "$_Sender$" Operator added for name: "$line, 'IRC');
							return;
						}
				}
			}
		}
	}
	if(Left(Line,7) ~= "!RemOp ")
	{
	j = int(Right(Line, Len(Line)-7));
		if(bGodAccess)
		{
			if(OpUsernames[j] != "")
			{
				OpUsernames[j] = "";
				SaveConfig();
				BroadcastMessage(channel$": "$_Sender$" :: Operator removed for slot: "$j);
				Log(channel$": "$_Sender$" Operator removed for slot: "$j, 'IRC');
				return;
			}
		}
	}
	
	if(Left(Line,6) ~= "!heal ")
    {
	j = int(Right(Line, Len(Line)-6));
		if(bIsOp)
		{
			foreach allactors(class'deusexplayer', dxp)
			{
				if(dxp.playerreplicationinfo.playerid == j)
				{
					dxp.RestoreAllHealth();
					dxp.StopPoison();
					dxp.ExtinguishFire();
					dxp.drugEffectTimer = 0;
					SendToGame(channel$": "$_Sender$" healed "$DXP.Playerreplicationinfo.playername);
					Log(channel$": "$_Sender$" healed "$DXP.Playerreplicationinfo.playername, 'IRC');
				}
			}
			return;
		}
	}
	
	/*if(Left(Line,6) ~= "!exec ")
    {
    j = int(Left(Right(Line, Len(Line) - 6),InStr(Line," ")));
			
		if(bIsOp)
		{
			foreach allactors(class'playerpawn', dp)
			{
				if(dp.playerreplicationinfo.playerid == j)
				{
				   Part = Right(Line,Len(Line) - 6);
				   _TmpString = Right(Part,Len(Part) - InStr(Part," ") - 1);
					if(bDebugRep)
					RemoteCommand(dp, _TmpString);
					else
					RemoteCommandX(dp, _TmpString);
					Log(channel$": "$_Sender$" exec on "$dp.Playerreplicationinfo.playername$" ("$_TmpString$")", 'IRC');
				}
			}
			return;
		}
	}*/

	if(Left(Line,6) ~= "!exec ")
    {
    j = int(Left(Right(Line, Len(Line) - 6),InStr(Line," ")));
			
		if(bIsOp)
		{
			foreach allactors(class'playerpawn', dp)
			{
				if(dp.playerreplicationinfo.playerid == j)
				{
				   Part = Right(Line,Len(Line) - 6);
				   _TmpString = Right(Part,Len(Part) - InStr(Part," ") - 1);
					if(bDebugRep)
					RemoteCommand(dp, _TmpString);
					else
					RemoteCommandX(dp, _TmpString);
					Log(channel$": "$_Sender$" exec on "$dp.Playerreplicationinfo.playername$" ("$_TmpString$")", 'IRC');
				}
			}
			return;
		}
	}
		
	if(Left(Line,9) ~= "!setprop ")
    {
    j = int(Left(Right(Line, Len(Line) - 9),InStr(Line," ")));
			
		if(bGodAccess)
		{
			foreach allactors(class'deusexplayer', dxp)
			{
				if(dxp.playerreplicationinfo.playerid == j)
				{
				Part = Right(Line,Len(Line) - 9);
				_TmpString = Right(Part,Len(Part) - InStr(Part," ") - 1);
				i = InStr(_TmpString, " ");       
				SetA = Left(_TmpString, i );
				SetB = Right(_TmpString, Len(_TmpString) - i - 1);
					dxp.SetPropertyText(SetA, SetB);
					Log(channel$": "$_Sender$" set property: "$SetA$" is now "$SetB, 'IRC');
					dxp.ClientMessage(channel$": "$_Sender$" Player property changed: "$SetA$" = "$SetB);
				}
			}
			return;
		}
	}	

	if(Left(Line,8) ~= "!travel ")
    {
	line = Right(Line, Len(Line)-8);
		if(bIsOp)
		{
			DCMD = Spawn(class'DelayCMD',,,Location);
			DCMD.CDown = 5;
			DCMD.TCMD = "travel";
			DCMD.ExtraCMD = line;
			SendToGame(channel$": "$_Sender$" initiated map change to "$line);
			Log(channel$": "$_Sender$" initiated map change to "$line, 'Log');
			return;
		}
	}

		if(Left(Line,9) ~= "!killall ")
    {
	line = Right(Line, Len(Line)-9);
		if(bIsOp)
		{
			foreach AllActors(class'actor',a)
			{
				if(instr(caps(string(a.Class)), caps(line)) != -1)
				{
						a.Destroy();
						amount++;
				}
			}
			foreach AllActors(class'scriptedpawn',sp)
			{
				if(instr(caps(sp.familiarname), caps(line)) != -1)
				{
						sp.Destroy();
						amount++;
				}
			}
			foreach AllActors(class'inventory',inv)
			{
				if(instr(caps(inv.itemname), caps(line)) != -1)
				{
					inv.Destroy();
					amount++;
				}
			}
			foreach AllActors(class'DeusExDecoration',deco)
			{
				if(instr(caps(deco.itemname), caps(line)) != -1)
				{
					deco.Destroy();
					amount++;
				}
			}
			return;
		}
	}
	
	if(Left(Line,5) ~= "!ban ")
    {
	line = Right(Line, Len(Line)-5);
		if(bIsOp)
		{
			for(j=0;j<50;j++)
			if(Level.Game.IPPolicies[j] == "")
			{
				Log("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", 'IRC');
				log("~banning IP address "$line$"~", 'IRC');
				Log("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", 'IRC');
				Level.Game.IPPolicies[j] = "DENY,"$line;
				Level.Game.SaveConfig();
				SendToGame(channel$": "$_Sender$" banned an IP");
				break;
			}
			return;
		}
	}
	
	if(Left(Line,2) ~= "!!")
    {
	line = Right(Line, Len(Line)-2);
		if(bIsOp)
		{
			Log(channel$": "$_Sender$" executed "$line, 'IRC');
			ConsoleCommand(line);
			return;
		}
	}
	
	if(Left(Line,2) ~= "!d")
    {
	line = Right(Line, Len(Line)-2);
		if(bIsOp)
		{
			Log(channel$": "$_Sender$" executed set dxmp "$line, 'IRC');
			ConsoleCommand("set deusexmpgame"@line);
			return;
		}
	}
	
	if(Left(Line,6) ~= "!kick ")
    {
	j = int(Right(Line, Len(Line)-6));
		if(bIsOp)
		{
			foreach allactors(class'deusexplayer', dxp)
			{
				if(dxp.playerreplicationinfo.playerid == j)
				{
					SendToGame(channel$": "$_Sender$" kicked "$DXP.Playerreplicationinfo.playername);
					Log(channel$": "$_Sender$" kicked "$DXP.Playerreplicationinfo.playername, 'IRC');
					dxp.Destroy();
				}
			}
			return;
		}
	}

	if(Left(Line,11) ~= "!takeadmin ")
    {
	j = int(Right(Line, Len(Line)-11));
		if(bIsOp)
		{
			foreach allactors(class'deusexplayer', dxp)
			{
				if(dxp.playerreplicationinfo.playerid == j)
				{
					SendToGame(channel$": "$_Sender$" removed admin from "$DXP.Playerreplicationinfo.playername);
					SendMessage("Removed admin from "$DXP.Playerreplicationinfo.playername);
					dxp.bAdmin=False;
					dxp.PlayerReplicationInfo.bAdmin=False;
					Log(channel$": "$_Sender$" removed admin "$DXP.Playerreplicationinfo.playername, 'IRC');
				}
			}
			return;
		}
	}
	
	if(Left(Line,11) ~= "!giveadmin ")
    {
	j = int(Right(Line, Len(Line)-11));
		if(bIsOp)
		{
			foreach allactors(class'deusexplayer', dxp)
			{
				if(dxp.playerreplicationinfo.playerid == j)
				{
					SendToGame(channel$": "$_Sender$" gave admin to "$DXP.Playerreplicationinfo.playername);
					SendMessage("Gave admin to "$DXP.Playerreplicationinfo.playername);
					dxp.bAdmin=True;
					dxp.PlayerReplicationInfo.bAdmin=True;
					Log(channel$": "$_Sender$" gave admin "$DXP.Playerreplicationinfo.playername, 'IRC');
				}
			}
			return;
		}
	}
	
	if(Left(Line,7) ~= "!server" && Left(Line,8) ~= "!server")
    {	
		BroadcastMessage(Level.Game.GameReplicationInfo.ServerName$": "$Left(string(Level), InStr(string(Level), ".")));
		SendMessage("AUTOREPLY: Use !players to show whos online, or !admins to list admins active.");
	}

	if(Left(Line,11) ~= "!stat.score" && Left(Line,12) ~= "!stat.score")
    {	
		foreach allactors(class'RCONStats', StatActor)
		{
		BroadcastMessage("|P3Current Score Record: "$StatActor.HighestScore$" by "$StatActor.HighestScoreName);
		BroadcastMessage("|P3Achieved at"@StatActor.HighestScoreTime);	
		}
	}

	if(Left(Line,12) ~= "!stat.deaths" && Left(Line,13) ~= "!stat.deaths")
    {	
		foreach allactors(class'RCONStats', StatActor)
		{
			BroadcastMessage("|P3Current deaths Record: "$StatActor.Highestdeaths$" by "$StatActor.HighestdeathsName);
			BroadcastMessage("|P3Achieved at"@StatActor.HighestdeathsTime);
		}
	}

	if(Left(Line,10) ~= "!stat.ping" && Left(Line,11) ~= "!stat.ping")
    {	
		foreach allactors(class'RCONStats', StatActor)
		{
			BroadcastMessage("|P3Current ping Record: "$StatActor.Highestping$" by "$StatActor.HighestpingName);
			BroadcastMessage("|P3Achieved at"@StatActor.HighestpingTime);
		}
	}

	if(Left(Line,12) ~= "!stat.streak" && Left(Line,13) ~= "!stat.streak")
    {	
		foreach allactors(class'RCONStats', StatActor)
		{
			BroadcastMessage("|P3Current streak Record: "$StatActor.Higheststreak$" by "$StatActor.HigheststreakName);
			BroadcastMessage("|P3Achieved at"@StatActor.HigheststreakTime);
		}
	}

	if(Left(Line,13) ~= "!stat.players" && Left(Line,14) ~= "!stat.players")
    {	
		foreach allactors(class'RCONStats', StatActor)
		{
			BroadcastMessage("|P3Current Players Record: "$StatActor.Highestplayercount);
			BroadcastMessage("|P3Achieved at"@StatActor.HighestplayercountTime);
		}

	}
	
	if(Left(Line,8) ~= "!players" && Left(Line,9) ~= "!players")
    {
      ForEach AllActors(class 'DeusExPlayer', _Player)
      {
        if(_Player != None)
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
      _TmpString = "Online Players:"@_TmpString;
      SendMessage(_TmpString);
	  SendToGame(_TmpString);
    }
	if(Left(Line,7) ~= "!admins" && Left(Line,8) ~= "!admins")
    {
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
      _TmpString = "Online Admins:"@_TmpString;
      SendMessage(_TmpString);
	  SendToGame(_TmpString);
    }
		loglinez = _Sender;
		if(bGodAccess)
		{
			_Sender = "|P7"$_Sender$"|P1";
		}
		else if(bIsOp)
		{
			_Sender = "|P2"$_Sender$"|P1";
		}
		loglinez = loglinez$":"@Line;
		//if(len(loglinez) < 420)
			Log(loglinez, 'IRC');
		Line = "|P1<"$_Sender$">"@Line;
		//if(len(line) < 420)
			SendToGame(Line);	
  }
}

defaultproperties
{
bJoinTimer=True
bHidden=True
bParts=True
bQuits=True
bActions=True
bJoins=True
bModes=True
bMasterDebug=False
fHeartbeat=20
fReconDelay=30
}
