// Stores Login data
//============================
class LoginInfo extends AthenaActors;

var PlayerPawn Flagger;
var string pname, LinkedAccount;
var bool bRestrict;
var Accounts ac;
var bool bWhitelisted;
var bool bFirst;
var string motdstr;
var class<inventory> SavedInventory[10];
//NEW: RPG Stuff
var int CurrentLevel, GainedEXP;
var aInv LinkedStorage;
var bool bDebug;

replication
{
     reliable if (Role == ROLE_Authority)
        cMenuLogin, aAlert;//, cMenuRegister;//, currentMode;

     reliable if (Role < ROLE_Authority)
        bCheckLogin, addaccount, login, logout;//setSize, createBox;
}

simulated final function cMenuLogin()
{
	local DeusExPlayer _Player;
	local DeusExRootWindow _root;
	local MenuLogin _boxWindow;
	_Player = DeusExPlayer(Owner);
	//log("Called cMenuLogin for"@_Player.playerreplicationinfo.playername );
	if(_Player != None)
	{
		//_Player.InitRootWindow();
		_root = DeusExRootWindow(_Player.rootWindow);
		if(_root != None)
		{
			_boxWindow = MenuLogin(_root.InvokeUIScreen(Class'MenuLogin', True));
			if(_boxWindow != None)
			{
				_boxWindow._windowOwner = _Player;
				_boxWindow.Ac = Ac;
				_boxWindow.Mastah = Self;
				//_boxWindow.SetMOTD(alertmsg);
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

simulated function bool Login(DeusExPlayer P, string Username, string Password, bool bLoadLoc)
{
	return ac.Login(p,Username,Password, bLoadLoc);
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
	local int invi, i;
	local inventory inv;
	local DeusExWeapon WP;
	local DeusExPickup DP;
	
	if(Flagger == None && AC == None)
		return;
		
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
			Destroy();

		if(Flagger.PlayerReplicationInfo.PlayerName == "")
			Destroy();

		if(LinkedAccount == "")
			return;
			
		if(AC.bDebug)
			log("Sending update.");
		Ac.Update(LinkedAccount, flagger, self);
		
		for(invi=0;invi<10;invi++)
		{
			LinkedStorage.SavedInventory[invi] = None;
		}
		
		foreach AllActors(class'DeusExweapon',WP)
		{
			if((WP != None) && (WP.Owner == Flagger))
			{
					if(!LinkedStorage.ItemSaved(WP.class) && WP.itemname != "Citizen card" && inv.itemname != "Credits")
					{
						if(bDebug)
							log("Saving"@WP.class);
						//LinkedStorage.SavedInventory[invi] = WP.class;
						LinkedStorage.AddInv(wp.class);
						//return;
					}
			}
		}
		
		foreach AllActors(class'DeusExPickup',DP)
		{
			if((DP != None) && (DP.Owner == Flagger))
			{
				if(!LinkedStorage.ItemSaved(DP.class))
				{
						if(bDebug)
							log("Saving"@DP.class);
						//LinkedStorage.SavedInventory[invi] = DP.class;
						LinkedStorage.AddInv(DP.class);
						//return;
				}				
			}
		}					
	}
}

simulated final function aAlert(string title, string msg)
{
	local DeusExPlayer _Player;
	local DeusExRootWindow _root;
	local MenuAAlert _boxWindow;
	_Player = DeusExPlayer(Owner);
	//log("Called cMenuLogin for"@_Player.playerreplicationinfo.playername );
	if(_Player != None)
	{
		//_Player.InitRootWindow();
		_root = DeusExRootWindow(_Player.rootWindow);
		if(_root != None)
		{
			_boxWindow = MenuAAlert(_root.InvokeUIScreen(Class'MenuAAlert', True));
			if(_boxWindow != None)
			{
				_boxWindow.crt(title, msg);
				//_boxWindow.ClientWidth = len(msg);
			}
		}
	}
}

defaultproperties
{
	bHidden=True
	bRestrict=True
	RemoteRole=2
    NetPriority=1.50
}
