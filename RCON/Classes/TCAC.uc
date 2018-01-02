class TCAC extends RCONActors config(RCON);

var DeusExPlayer 	_Player;
var int 		_Validation;
var int			_CurrentStep;
var bool		_bValidated;

var config bool		bBan;
var config bool 	bRangeBan;
var config bool    bCheckWeapons;
var config bool 	bCheckFrob;
var config bool 	bCheckGod;
var config bool 	bCheckFly;
var config bool 	bCheckInvis;
var config bool 	bEnforcePunish;

replication
{
  reliable if (Role == ROLE_Authority)
    _ValidateClientConsole, CheckPlayer, _Player;

  reliable if(ROLE < ROLE_Authority)
    _EndValidateConsole, LightPunishPlayer;
}

function _ValidateConsole(DeusExPlayer _NewOwner)
{
  _Player 	= _NewOwner;
  SetOwner(_NewOwner);
  SetTimer(3.0, True);
}

simulated function _ValidateClientConsole(int _ValidateNumber)
{
  _EndValidateConsole(_Player.Player.Console.Class, _ValidateNumber);
}

simulated function _EndValidateConsole(Class<Console> _Console, int _ValidateNumber)
{
  local bool _bPassed;

  _bPassed = False;
  if(_ValidateNumber == _Validation && _Console == Class'Engine.Console')
  {
    _bPassed = True;
    _Validation = Rand(50); 
  }

  if(_bPassed)
  {
    _bValidated = True;
  }
  else
  {
    if(_Player.PlayerReplicationInfo != None)
    {
      _PunishPlayer();
    }
  }
}

function Timer()
{
    CheckPlayer();
}

simulated function CheckPlayer()
{
  local bool _bPunish;
  local bool _bProceed;

  _bProceed = True;

   if(DeusExWeapon(_Player.inHand) != None)
  {
    if(DeusExWeapon(_Player.inHand).ShotTime != DeusExWeapon(_Player.inHand).Default.ShotTime && !(DeusExWeapon(_Player.inHand).AmmoName == Class'Ammo20mm' || DeusExWeapon(_Player.inHand).AmmoName == Class'AmmoRocketWP'))
    {
      if(WeaponAssaultGun(_Player.inHand) != None || WeaponGEPGun(_Player.inHand) != None)
      {
        if(!WeaponAssaultGun(_Player.inHand).bInstantHit)
        {
          _bProceed = False;
        }
      }
      if(_bProceed)
      {
        DeusExWeapon(_Player.inHand).ShotTime = DeusExWeapon(_Player.inHand).Default.ShotTime;
		_Player.ClientMessage("Anticheat has defaulted your modified weapon. Please do not cheat.");
        _bPunish = True;
      }
    }
    else if(WeaponEMPGrenade(_Player.inHand).ReloadCount != WeaponEMPGrenade(_Player.inHand).Default.ReloadCount)
    {
      WeaponEMPGrenade(_Player.inHand).ReloadCount = WeaponEMPGrenade(_Player.inHand).Default.ReloadCount;
	 		_Player.ClientMessage("Anticheat has defaulted your modified weapon. Please do not cheat.");
      _bPunish = True;
    }
    else if(WeaponGasGrenade(_Player.inHand).ReloadCount != WeaponGasGrenade(_Player.inHand).Default.ReloadCount)
    {
      WeaponGasGrenade(_Player.inHand).ReloadCount = WeaponGasGrenade(_Player.inHand).Default.ReloadCount;
	  		_Player.ClientMessage("Anticheat has defaulted your modified weapon. Please do not cheat.");
      _bPunish = True;
    }
    else if(WeaponLAM(_Player.inHand).ReloadCount != WeaponLAM(_Player.inHand).Default.ReloadCount)
    {
      WeaponLAM(_Player.inHand).ReloadCount = WeaponLAM(_Player.inHand).Default.ReloadCount;
	  		_Player.ClientMessage("Anticheat has defaulted your modified weapon. Please do not cheat.");
      _bPunish = True;
    }
  }
    _Player.MaxFrobDistance = _Player.Default.MaxFrobDistance;

			 if(_Player.ReducedDamageType == 'All' && _Player.InHand != None)
			 {
				_Player.PutInHand(None);
			 }
	
			if(_Player.IsInState('CheatFlying') && _Player.InHand != None)
			{
				_Player.PutInHand(None);
			}
	
			if(_Player.bHidden && _Player.InHand != None)
			{
				_Player.PutInHand(None);
			}
  if(_bPunish)
  {
	if(bEnforcePunish)
	{
    LightPunishPlayer();	
	}
  }
}

function LightPunishPlayer()
{
  local string _IP;

  if(Len(_Player.PlayerReplicationInfo.PlayerName) > 0)
  {
    _IP = Left(_Player.GetPlayerNetworkAddress(), InStr(_Player.GetPlayerNetworkAddress(), ":"));
    Log("CHEAT:"@_Player.PlayerReplicationInfo.PlayerName@"CHEATED. IP:"@_IP,'RCO');
    BroadCastMessage(_Player.PlayerReplicationInfo.PlayerName@"got kicked for cheating.");
    _Player.Destroy();
  }
  Destroy();
}

function _PunishPlayer()
{
  local string _Action;
  local int _i;
  local string _IP;

  if(Len(_Player.PlayerReplicationInfo.PlayerName) > 0)
  {
    _IP = Left(_Player.GetPlayerNetworkAddress(), InStr(_Player.GetPlayerNetworkAddress(), ":"));
    Log("CHEAT:"@_Player.PlayerReplicationInfo.PlayerName@". IP:"@_IP,'RCON');

    if(bBan)
    {
      _Action = "banned";
    }
    else
    {
      _Action = "kicked";
    }

    BroadCastMessage(_Player.PlayerReplicationInfo.PlayerName@"was"@_Action@"for cheating.");

    if(bBan)
    {
      if(Level.Game.CheckIPPolicy(_Player.GetPlayerNetworkAddress()))
      {
        if(bRangeBan)
        {
          _IP = Left(_IP, StrrChr(_IP, ".")+1)$"*";
        }
        Log("Adding IP Ban for:"@_IP);
        for(_i = 0; _i < 50; _i++)
        {
          if(Level.Game.IPPolicies[_i] == "")
          {
            break;
          }
        }
        if(_i < 50)
        {
          Level.Game.IPPolicies[_i] = "DENY,"$_IP;
        }
        Level.Game.SaveConfig();
      }
    }
    _Player.Destroy();
  }
  Destroy();
}

static final function int StrrChr(coerce string Haystack, coerce string Needle)
{
  local int Position;

  if(InStr(Haystack, Needle) == -1)
  {
    return -1;
  }

  while(InStr(Haystack, Needle) != -1)
  {
    Position = Position+InStr(Haystack, Needle)+1;
    Haystack = Right(Haystack, (Len(Haystack)-InStr(Haystack, Needle)-1));
  }
  return Position-1;
}

defaultproperties
{
}
