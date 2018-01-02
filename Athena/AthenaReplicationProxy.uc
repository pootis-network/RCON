// Stores Login data
//============================
class AthenaReplicationProxy extends Actor;

var PlayerPawn Flagger;

replication
{
     reliable if (Role == ROLE_Authority)
        cMenuAth;//, cMenuRegister;//, currentMode;

    // reliable if (Role < ROLE_Authority)
    //    restartathena, pm, remotesay;//setSize, createBox;
}

simulated final function cMenuAth()
{
	local DeusExPlayer _Player;
	local DeusExRootWindow _root;
	local MenuAthena _boxWindow;
	_Player = DeusExPlayer(Owner);
	//log("Called cMenuLogin for"@_Player.playerreplicationinfo.playername );
	if(_Player != None)
	{
		//_Player.InitRootWindow();
		_root = DeusExRootWindow(_Player.rootWindow);
		if(_root != None)
		{
			_boxWindow = MenuLogin(_root.InvokeUIScreen(Class'MenuAthena', True));
			if(_boxWindow != None)
			{
				_boxWindow._windowOwner = _Player;
				_boxWindow.Am = Am;
				_boxWindow.Mastah = Self;
				//_boxWindow.CreateMenuLabel(10, 95, ac.MOTDx, _boxWindow.winClient);
			}
		}
	}
}


/*function timer()
{
SetOwner(flagger);
cMenuLogin();
	if(ac.bForceLogin)
		Flagger.ClientMessage("|P2Login is required. Closing the menu without logging in will disconnect you.");
	else
		Flagger.ClientMessage("|P4Login is optional but will give access to new features.");
}*/

function string GetName(PlayerPawn P)
{
	return P.PlayerReplicationInfo.PlayerName;
}

defaultproperties
{
	bHidden=True
	bRestrict=True
	    RemoteRole=2
    NetPriority=1.50
}
