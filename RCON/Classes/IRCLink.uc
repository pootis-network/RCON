//=============================================================================
// Link.
//=============================================================================
class IRCLink extends TCPLink config (IRC);

var config string Server;
var config string Channel;
var config string Username;
var config int Port;
var config string OpUsernames[10];
var config string iPrefix;
var config int iMode;
var bool bBeating;
var config bool bAcceptingCommands;
var bool bGodAccess;
var config bool bJoinTimer;
var config bool bMasterDebug;
var config bool bParts, bQuits, bJoins, bActions, bModes;
var config bool bClientMode;
var config bool bAutoClientMode;
var string JoinChannel;
var bool bErrord;
var float fHeartbeat, fReconDelay;
var AthenaSpectator AS;
var AthenaMutator AM;
var config bool bDebugRep, bDebug;
var config bool bLogAll;
var config bool bIRCClientLogs;
var config string GSCURL, GSCARG;

function CodeBase _CodeBase()
{
	return Spawn(class'CodeBase');
}

/*replication
{
reliable if(ROLE < ROLE_Authority) 
 RemoteCommand;
 reliable if(ROLE == ROLE_Authority) 
 RemoteCommandX;
}*/

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
		else if (Level.NetMode != NM_Standalone)
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
		_Spec.PlayerReplicationInfo.PlayerID = Level.game.CurrentID++;
		_Spec.GameReplicationInfo = Level.Game.GameReplicationInfo;

		BroadcastMessage( _Spec.PlayerReplicationInfo.PlayerName$Level.Game.EnteredMessage, false );
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

function SendMessage(string s)
{
local int i, fnew;
local string output;
local string line, newnick;

/*while(inStr(caps(s), caps("|p")) != -1) //WAS IF
	{
		i = InStr(caps(s), caps("|p"));
		while (i != -1) {	
			Output = Output $ Left(s, i) $ "";
			s = Mid(s, i + 3);	
			i = InStr(caps(s), caps("|p"));
		}
		s = Output $ s;
	}
		
	while(inStr(caps(s), caps("|C")) != -1)
	{
		i = InStr(caps(s), caps("|C"));
		while (i != -1) {	
			Output = Output $ Left(s, i) $ "";
			s = Mid(s, i + 8);	
			i = inStr(caps(s), caps("|C"));
		}
		s = Output $ s;
	}*/
	/*if(bClientMode)
	{
    Line = Right(s, Len(s)-instr(s,"): ")-Len("): "));
	 newnick = Left(s, InStr(s,"("));
	 SendCommand("NICK "$newnick);
	  SendCommand("PRIVMSG"@Channel@":"$Line);
	}*/
	line = RCR(s);
	line = RCR2(line);
	line = FormatNames(line);
	  SendCommand("PRIVMSG"@Channel@":"$line);
	  return;
}

function string FormatNames(string S)
{
	local string imsg, iname;
	
	if(instr(caps(S), caps("): ")) != -1)
	{
		imsg = Right(s, Len(s)-instr(s,"): ")-Len("): "));
		iname =  Left(s, InStr(s,"("));
		return "[ "$iname$" ] "$imsg;
	}
}

function DestroyLink()
{
		SendText("QUIT :Closed");
		Destroy();
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


/* To add a message check for;
 * :irc.x2x.cc 404 SERVER_Playground #deusbork :Cannot send to channel
 * :Kaiz0r!~kaiz0r@deus.ex.machina TOPIC #deusbork :Testing random IRC commands
 */
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
local bool bDontLog;
local ARClient ARC;
local AthenaMutator AMR;
local GenericSiteQuery GSC;
local CodeBase _CB;
local RCONManager RMAN;

//local RCONReplicatorActor REPL;
			//local string OldLine;
	bIsOp=False;
	bGodAccess=False;
	
	if(instr(Line, "VERSION") != -1)
	{
		SendCommand("VERSION DeusEx IRC Link by Kaiz0r");
		Log("VERSION  -  Deus Ex IRC Link by Kaiz0r",'IRC');
	}
		
	if(instr(Line, "PING :") != -1)
	{
		SendCommand("PONG :"$Right(Line, Len(Line)-instr(line,":")-Len(":")));
		Log("PING - "$Right(Line, Len(Line)-instr(line,":")-Len(":")),'IRC');
		bDontLog=True;
		return;
	}
		


  Line = Left(Line,Len(Line)-2);
  _Original = Line;
	if(bLogAll)
		Log(Line);
	if(bMasterDebug)
		BroadcastMessage(Line);
  		
   /* if(instr(Line, "001 "$Username$" ") != -1 || instr(Line, "002 "$Username$" ") != -1 || instr(Line, "003 "$Username$" ") != -1 || instr(Line, "004 "$Username$" ") != -1 || instr(Line, "005 "$Username$" ") != -1 || instr(Line, "451 "$Username$" ") != -1)
	{
		Line = Right(_Original, Len(_Original)-instr(_Original," "$Username$" ")-Len(" "$Username$" "));
	//	Line = Left(Line, InStr(Line,":"));
		_Sender = Server;
		//SendToGame("|P2[SERVICES] |P5<|P1"$_Sender$"|P5>|P1 "$line);
		Log("SERVICES - "$_Sender@line, 'IRC');
		bDontLog=True;
		return;
	}

    if(instr(Line, "001 SERVER_"$Username$" :") != -1 
    || instr(Line, "002 SERVER_"$Username$" :") != -1 
    || instr(Line, "003 SERVER_"$Username$" :") != -1 
    || instr(Line, "004 SERVER_"$Username$" :") != -1 
    || instr(Line, "005 SERVER_"$Username$" :") != -1 
    || instr(Line, "451 SERVER_"$Username$" :") != -1)
	{
		Line = Right(_Original, Len(_Original)-instr(_Original," SERVER_"$Username$" :")-Len(" SERVER_"$Username$" :"));
		//Line = Left(Line, InStr(s,":"));
		//Line = Left(Line, InStr(Line,":"));
		_Sender = Server;
		//SendToGame("|P2[SERVICES] |P5<|P1"$_Sender$"|P5>|P1 "$line);
		Log("SERVICES - "$_Sender@line, 'IRC');
		bDontLog=True;
				return;
	}

	for(i=256;i<377;i++)
    {
		if(instr(Line, i$" SERVER_"$Username$" :") != -1)
		{
			Line = Right(_Original, Len(_Original)-instr(_Original,i$" SERVER_"$Username$" :")-Len(i$" SERVER_"$Username$" :"));
			//Line = Left(Line, InStr(Line,":"));
			_Sender = Server;
		//	SendToGame("|P2[SERVICES] |P5<|P1"$_Sender$"|P5>|P1 "$line);
			Log("SERVICES - "$_Sender@line, 'IRC');
			bDontLog=True;
			return;
		}
	}
			
	for(i=256;i<377;i++)
    {
		if(instr(Line, i$" "$Username$" :") != -1)
		{
			Line = Right(_Original, Len(_Original)-instr(_Original,i$" "$Username$" :")-Len(i$" "$Username$" :"));
			//Line = Left(Line, InStr(Line,":"));
			_Sender = Server;
		//	SendToGame("|P2[SERVICES] |P5<|P1"$_Sender$"|P5>|P1 "$line);
			Log("SERVICES - "$_Sender@line, 'IRC');
			bDontLog=True;
					return;
		}
	}*/
	if(instr(Line, "PRIVMSG"@Username$" :") != -1)
	{
		Line = Right(_Original, Len(_Original)-instr(_Original,"PRIVMSG"@Username$" :")-Len("PRIVMSG"@Username$" :"));
		//Line = Left(Line, InStr(Line,":"));
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
			bDontLog=True;
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
				Log(channel$": "$_Sender$": The GamePassword has been changed via IRC to "$line, 'IRC');
			BroadcastMessage(channel$": "$_Sender$": |P3The GamePassword has been changed via IRC to "$line);
			}
			else
			{
				Log(channel$": "$_Sender$": The GamePassword has been removed via IRC.", 'IRC');
			BroadcastMessage(channel$": "$_Sender$": |P3The GamePassword has been removed via IRC.");
			}
		return;
		}
	}
	
	if(Left(Line,5) ~= "!pass")
    {
		if(bIsOp)
		{
			ConsoleCommand("Set Gameinfo Gamepassword ");
			BroadcastMessage(channel$": "$_Sender$": |P3The GamePassword has been removed via IRC.");
			Log(channel$": "$_Sender$": The GamePassword has been removed via IRC.", 'IRC');
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
					bDontLog=True;
			Log(loglinez, 'IRC');
		Line = "|P1<"$_Sender$">"@Line;
		//if(len(line) < 420)
			SendToGame(Line);	
			
		//SendToGame("|P2[>>] |P5<|P1"$_Sender$"|P5>|P1 "$line);
		Log("DIRECT - "$_Sender@line, 'IRC');
		bDontLog=True;
				return;
	}
		
	if(instr(Line, "PRIVMSG SERVER_"$Username$" :") != -1)
	{
		Line = Right(_Original, Len(_Original)-instr(_Original,"PRIVMSG SERVER_"$Username$" :")-Len("PRIVMSG SERVER_"$Username$" :"));
		//Line = Left(Line, InStr(Line,":"));
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
			bDontLog=True;
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
				Log(channel$": "$_Sender$": The GamePassword has been changed via IRC to "$line, 'IRC');
			BroadcastMessage(channel$": "$_Sender$": |P3The GamePassword has been changed via IRC to "$line);
			}
			else
			{
				Log(channel$": "$_Sender$": The GamePassword has been removed via IRC.", 'IRC');
			BroadcastMessage(channel$": "$_Sender$": |P3The GamePassword has been removed via IRC.");
			}
		return;
		}
	}
	
	if(Left(Line,5) ~= "!pass")
    {
		if(bIsOp)
		{
			ConsoleCommand("Set Gameinfo Gamepassword ");
			BroadcastMessage(channel$": "$_Sender$": |P3The GamePassword has been removed via IRC.");
			Log(channel$": "$_Sender$": The GamePassword has been removed via IRC.", 'IRC');
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
	//browse("botlibre.com", "/rest/api/form-chat?user=DiscordUser&password=dxmp2017&instance=19852766&message="$Text$"&application=6164811714561807251", 80, 5);
	if(Left(Line,5) ~= "!spl ")
	{
		line = Right(Line, Len(Line)-5);
		line = _CodeBase().Split(line, "<msg>", "</msg>");
		log(line);
		return;
	}
	
	if(Left(Line,5) ~= "!gpf ")
	{
		line = Right(Line, Len(Line)-5);
		Log(_CodeBase().GetPlayerFromID(int(line)).PlayerReplicationInfo.PlayerName);
		//log(line);
		return;
	}
	
	if(Line ~= "!spawngsc")
	{
		Spawn(class'GenericSiteQuery');
		Log("GSC created.");
		return;
	}
	
	if(Line ~= "!update")
	{
		foreach AllActors(class'RCONManager', RMAN)
			RMAN.UpdateCheck();
	}
	
	if(Line ~= "!gsc")
	{
		line = Right(Line, Len(Line)-5);
		foreach AllActors(class'GenericSiteQuery', GSC)
			GSC.browse(GSCURL, GSCARG, 80, 5);
		return;
	}
	
	if(Line ~= "!ac")
	{
		foreach AllActors(class'AthenaMutator', AMR)
		{
			if(AMR.AIClient == None)
			{
				AMR.InitAIClient();
				BroadcastMessage("AI Client opened via IRC.");
			}
			else
			{
				AMR.CloseAIClient();
				BroadcastMessage("AI Client closed via IRC.");
			}
		}
	}
	
	if(Left(Line,2) ~= "$ ")
    {
		line = Right(Line, Len(Line)-2);

		foreach AllActors(class'AthenaMutator', AMR)
		{
			AMR.SendTextToAIClient(line);
		}
			
		//return;
	}
	
	if(Left(Line,6) ~= "!talk ")
    {
		line = Right(Line, Len(Line)-6);

		foreach AllActors(class'AthenaMutator', AMR)
		{
			AMR.SendTextToAIClient(line);
		}
			
		//return;
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
					bDontLog=True;
			Log(loglinez, 'IRC');
		Line = "|P1<"$_Sender$">"@Line;
		//if(len(line) < 420)
			SendToGame(Line);	
			
		//SendToGame("|P2[>>] |P5<|P1"$_Sender$"|P5>|P1 "$line);
		Log("DIRECT - "$_Sender@line, 'IRC');
		bDontLog=True;
				return;
	}
//:Kaiz0r!~kaiz0r@deus.ex.machina TOPIC #deusbork :Testing random IRC commands
	 if(instr(Line, "TOPIC "$channel$" :") != -1)
	{
    Line = Right(_Original, Len(_Original)-instr(_Original,"TOPIC "$channel$" :")-Len("TOPIC "$channel$" :"));
  //  Line = Left(Line, InStr(Line,":"));
 _Sender = Left(_Original, InStr(_Original,"!"));
    _Sender = Right(_Sender, Len(_Sender)-1);
		SendToGame("|P1"$_Sender$" changes topic to: "$line);
		Log(_Sender$" changes topic to: "$line, 'IRC');
		bDontLog=True;
				return;
	}
	
	 if(instr(Line, "404 SERVER_"$Username$" "$channel$" :") != -1)
	{
    Line = Right(_Original, Len(_Original)-instr(_Original,"404 SERVER_"$Username$" "$channel$" :")-Len("404 SERVER_"$Username$" "$channel$" :"));
  //  Line = Left(Line, InStr(Line,":"));
	 _Sender = Server;
		SendToGame("|P2[ERROR] |P5<|P1"$_Sender$"|P5>|P1 "$line);
		Log("ERROR - "$_Sender@line, 'IRC');
		bDontLog=True;
				return;
	}
	
	 if(instr(Line, "404 "$Username$" "$channel$" :") != -1)
	{
    Line = Right(_Original, Len(_Original)-instr(_Original,"404 "$Username$" "$channel$" :")-Len("404 SERVER_"$Username$" "$channel$" :"));
  //  Line = Left(Line, InStr(Line,":"));
	 _Sender = Server;
		SendToGame("|P2[ERROR] |P5<|P1"$_Sender$"|P5>|P1 "$line);
		Log("ERROR - "$_Sender@line, 'IRC');
		bDontLog=True;
				return;
	}
		
    if(instr(Line, "NOTICE * :") != -1)
	{
    Line = Right(_Original, Len(_Original)-instr(_Original,"NOTICE * :")-Len("NOTICE * :"));
  //  Line = Left(Line, InStr(Line,":"));
	 _Sender = Server;
		SendToGame("|P2[NOTICE] |P5<|P1"$_Sender$"|P5>|P1 "$line);
		Log("NOTICE - "$_Sender@line, 'IRC');
		bDontLog=True;
				return;
	}
				
    if(instr(Line, "NOTICE "$Username$" :") != -1)
  {
    Line = Right(_Original, Len(_Original)-instr(_Original,"NOTICE "$Username$" :")-Len("NOTICE "$Username$" :"));
  //  Line = Left(Line, InStr(Line,":"));
	 _Sender = Server;
	SendToGame("|P2[NOTICE] |P5<|P1"$_Sender$"|P5>|P1 "$line);
		Log("NOTICE - "$_Sender@line, 'IRC');
		bDontLog=True;
				return;
	}
	
    if(instr(Line, "NOTICE SERVER_"$Username$" :") != -1)
  {
    Line = Right(_Original, Len(_Original)-instr(_Original,"NOTICE SERVER_"$Username$" :")-Len("NOTICE SERVER_"$Username$" :"));
   // Line = Left(Line, InStr(Line,":"));
	 _Sender = Server;
	SendToGame("|P2[NOTICE] |P5<|P1"$_Sender$"|P5>|P1 "$line);
		Log("NOTICE - "$_Sender@line, 'IRC');
		bDontLog=True;
				return;
	}
			
    if(instr(Line, "ACTION ") != -1 && bActions)
  {
    Line = Right(_Original, Len(_Original)-instr(_Original,"ACTION ")-Len("ACTION "));
	 _Sender = Left(_Original, InStr(_Original,"!"));
    _Sender = Right(_Sender, Len(_Sender)-1);
	SendToGame("|P4"$_Sender@line);
		Log(_Sender@line, 'IRC');
		bDontLog=True;
	return;
	}
	
    if(instr(Line, "MODE"@Channel) != -1 && bModes)
  {
    Line = Right(_Original, Len(_Original)-instr(_Original,"MODE"@Channel)-Len("MODE"@Channel));
	 _Sender = Left(_Original, InStr(_Original,"!"));
    _Sender = Right(_Sender, Len(_Sender)-1);
	SendToGame("|P4["$channel$"] "$_Sender$" sets mode: "$line);
	Log(_Sender$" ["$channel$"] sets mode: "$line, 'IRC');
	bDontLog=True;
	}
    
    if(instr(Line, "NICK :") != -1)
  {
    Line = Right(_Original, Len(_Original)-instr(_Original,"NICK :")-Len("NICK :"));
	 _Sender = Left(_Original, InStr(_Original,"!"));
    _Sender = Right(_Sender, Len(_Sender)-1);
	SendToGame("|P4"$_Sender$" is now known as "$Line$". ["$Channel$"]");
	Log(_Sender$" is now known as "$Line$". ["$Channel$"]", 'IRC');
	bDontLog=True;
	}	
	
    if(instr(Line, "PART"@Channel) != -1 && bParts)
  {
    Line = Right(_Original, Len(_Original)-instr(_Original,"PART"@Channel)-Len("PART"@Channel));
	 _Sender = Left(_Original, InStr(_Original,"!"));
    _Sender = Right(_Sender, Len(_Sender)-1);
	SendToGame("|P4"$_Sender$" left the room. ["$Channel$"]");
	Log(_Sender$" left the room. ["$Channel$"]", 'IRC');
	bDontLog=True;
	}
	
    if(instr(Line, "JOIN :"$Channel) != -1 && bJoins)
  {
    Line = Right(_Original, Len(_Original)-instr(_Original,"JOIN :"$Channel)-Len("JOIN :"$Channel));
	 _Sender = Left(_Original, InStr(_Original,"!"));
    _Sender = Right(_Sender, Len(_Sender)-1);
	SendToGame("|P4"$_Sender$" joined the room. ["$Channel$"]");
	Log(_Sender$" joined the room. ["$Channel$"]", 'IRC');
	bDontLog=True;
	}
	
	if(instr(Line, "QUIT :") != -1 && bQuits)
  {
    Line = Right(_Original, Len(_Original)-instr(_Original,"QUIT :")-Len("QUIT :"));
	 _Sender = Left(_Original, InStr(_Original,"!"));
    _Sender = Right(_Sender, Len(_Sender)-1);
	SendToGame("|P4"$_Sender$" left the room. ("$Line$") ["$Channel$"]");
	Log(_Sender$" left the room. ("$Line$") ["$Channel$"]", 'IRC');
	bDontLog=True;
	}
	
  if(instr(Line, "PRIVMSG"@Channel@":") != -1)
  {
    Line = Right(_Original, Len(_Original)-instr(_Original,"PRIVMSG"@Channel@":")-Len("PRIVMSG"@Channel@":"));
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
			bDontLog=True;
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

	if(Left(Line,5) ~= "!spl ")
	{
		line = Right(Line, Len(Line)-5);
		line = _CodeBase().Split(line, "<msg>", "</msg>");
		log(line);
		return;
	}
	
	if(Left(Line,5) ~= "!gpf ")
	{
		line = Right(Line, Len(Line)-5);
		Log(_CodeBase().GetPlayerFromID(int(line)).PlayerReplicationInfo.PlayerName);
		//log(line);
		return;
	}
	
	if(Line ~= "!spawngsc")
	{
		Spawn(class'GenericSiteQuery');
		Log("GSC created.");
		return;
	}
	
	if(Line ~= "!gsc")
	{
		line = Right(Line, Len(Line)-5);
		foreach AllActors(class'GenericSiteQuery', GSC)
			GSC.browse(GSCURL, GSCARG, 80, 5);
		
		return;
	}
	
	if(Line ~= "!update")
	{
		foreach AllActors(class'RCONManager', RMAN)
			RMAN.UpdateCheck();
	}	
	
	if(Line ~= "!ac")
	{
		foreach AllActors(class'AthenaMutator', AMR)
		{
			if(AMR.AIClient == None)
			{
				AMR.InitAIClient();
				BroadcastMessage("AI Client opened via IRC.");
			}
			else
			{
				AMR.CloseAIClient();
				BroadcastMessage("AI Client closed via IRC.");
			}
		}
	}
	
	if(Left(Line,6) ~= "!talk ")
    {
		line = Right(Line, Len(Line)-6);
		foreach AllActors(class'AthenaMutator', AMR)
		{
			AMR.SendTextToAIClient(line);
		}
		//return;
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
				Log(channel$": "$_Sender$": The GamePassword has been changed via IRC to "$line, 'IRC');
			BroadcastMessage(channel$": "$_Sender$": |P3The GamePassword has been changed via IRC to "$line);
			}
			else
			{
				Log(channel$": "$_Sender$": The GamePassword has been removed via IRC.", 'IRC');
			BroadcastMessage(channel$": "$_Sender$": |P3The GamePassword has been removed via IRC.");
			}
		return;
		}
	}
	
	if(Left(Line,5) ~= "!pass")
    {
		if(bIsOp)
		{
			ConsoleCommand("Set Gameinfo Gamepassword ");
			BroadcastMessage(channel$": "$_Sender$": |P3The GamePassword has been removed via IRC.");
			Log(channel$": "$_Sender$": The GamePassword has been removed via IRC.", 'IRC');
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
					bDontLog=True;
			Log(loglinez, 'IRC');
		Line = "|P1<"$_Sender$">"@Line;
		//if(len(line) < 420)
			SendToGame(Line);	
  }
  
  if(!bDontLog && bIRCClientLogs)
	Log(_Original);

	if(bDebug)
		Log(_Original);
}

defaultproperties
{
	bIRCClientLogs=True
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
