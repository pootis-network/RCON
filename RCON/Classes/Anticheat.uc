class Anticheat extends Mutator config(RCON);

var PlayerReplicationInfo PRI;
var DeusExPlayer p;
var config bool AC17GrenadeJump;
var config float ACCheckTime;

function ModifyPlayer(Pawn P)
{
  local TCAC TCAC;
  local DeusExPlayer _Player;
  _Player = DeusExPlayer(P);
  if(_Player != None)
  {
    if(!_FindActor(_Player))
    {
      TCAC = Spawn(Class'TCAC');
      if(TCAC != None)
      {
	    TCAC._Player = _Player;
		TCAC.SetOwner(_Player);
        TCAC.SetTimer(ACCheckTime,True);
		Log("Attached anticheat to player.");
      }
    }
  }

	if( _Player.MaxFrobDistance != _Player.Default.MaxFrobDistance)
	{
		    _Player.MaxFrobDistance = _Player.Default.MaxFrobDistance;
	}
  Super.ModifyPlayer(P);
}

function bool _FindActor(DeusExPlayer _Player)
{
  local TCAC TCAC;
  ForEach AllActors(class'TCAC', TCAC)
  {
    if(TCAC != None)
    {
      if(TCAC._Player == _Player)
      {
        return True;
      }
    }
  }
  return False;
}

function Tick(float Deltatime)
{
local ThrownProjectile Proj;
local DeusExPlayer P;
	
	if(AC17GrenadeJump)
	{
		foreach AllActors(class'ThrownProjectile',proj)
		{
			//if(proj.IsInState('flying'))
			if(proj.bArmed)
				Proj.bBlockPlayers=False;
			else
				Proj.bBlockPlayers=True;
		}
	}
}

defaultproperties
{
}