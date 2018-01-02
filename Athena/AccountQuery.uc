// Replication system for account query display
//============================
class AccountQuery extends Actor;

var PlayerPawn Flagger;
var string pname, LinkedAccount;
var bool bRestrict;
var Accounts ac;
var bool bWhitelisted;
var bool bFirst;

replication
{
     reliable if (Role == ROLE_Authority)
        cMenuLogin;//, cMenuRegister;//, currentMode;

     reliable if (Role < ROLE_Authority)
        bCheckLogin, addaccount, login, logout;//setSize, createBox;
}

simulated final function cMenuLogin()
{
	local DeusExPlayer _Player;
	local DeusExRootWindow _root;
	local tcDTD _boxWindow;
	_Player = DeusExPlayer(Owner);
	//log("Called cMenuLogin for"@_Player.playerreplicationinfo.playername );
	if(_Player != None)
	{
		//_Player.InitRootWindow();
		_root = DeusExRootWindow(_Player.rootWindow);
		if(_root != None)
		{
			_boxWindow = tcDTD(_root.InvokeUIScreen(Class'tcDTD', True));
			if(_boxWindow != None)
			{
				_boxWindow._windowOwner = _Player;
				_boxWindow.Ac = Ac;
				_boxWindow.Mastah = Self;
				_boxWindow.ctusername = ctusername;
				_boxWindow.ctskin = ctskin;
				_boxWindow.ctdescription = ctdescription;
				//_boxWindow.CreateMenuLabel(10, 95, ac.MOTDx, _boxWindow.winClient);
			}
		}
	}
}

simulated function bool AddAccount(DeusExPlayer P, string Username, string Password)
{
	return ac.AddAccount(p,username,password);
	//	Log("Here");
	//flagger.ClientMessage("Here");
}

simulated function bool Login(DeusExPlayer P, string Username, string Password)
{
	return ac.Login(p,Username,Password);
	//	Log("Here");
	//flagger.ClientMessage("Here");
}

simulated function bool Logout(DeusExPlayer P)
{
	return ac.Logout(p);
//	Log("Here");
	//flagger.ClientMessage("Here");
}

simulated function bCheckLogin(DeusExPlayer p)
{
	ac.bCheckLogin(p);
}

function timer()
{
	local int i;
	
	if(!bFirst)
	{
		SetOwner(flagger);
		cMenuLogin();
		bFirst=True;
		SetTimer(10,True);
			if(ac.bForceLogin)
				Flagger.ClientMessage("|P2Login is required. Closing the menu without logging in will disconnect you.");
			else
				Flagger.ClientMessage("|P4Login is optional but will give access to new features.");
	}
	else
	{
		if(Flagger == None)
		{
			if(AC.bDebug)
				log("Deleting due to no player.");
			Destroy();
		}
		if(Flagger.PlayerReplicationInfo.PlayerName == "")
		{
			if(AC.bDebug)
				log("Deleting due to no player name..");
			Destroy();
		}

		if(AC.bDebug)
			log("Sending update.");
		Ac.Update(LinkedAccount, flagger);

	}
}

defaultproperties
{
	bHidden=True
	bRestrict=True
	RemoteRole=2
    NetPriority=1.50
}
