class AbuseWatchActor extends RCONActors;
var AthenaSpectator Spect;
var int aLifespan;
var DeusExPlayer Watcher;
var int LastKills, LastDeaths, LastStreak;
var int CurKills, CurDeaths, CurStreak;
var bool bTemporary;
var int kDif, dDif, sDif;
var int secondsran;
var int minutesran;
var bool bRan1, bRan2, bRan3, bRan4;

function Timer()
{

local DeusExWeapon DEW;

	if(bTemporary)
		aLifespan--;
		
	secondsran++;
	
	CurKills = Watcher.PlayerReplicationInfo.Score;
	CurDeaths = Watcher.PlayerReplicationInfo.Deaths;
	CurStreak = Watcher.PlayerReplicationInfo.Streak;
	
	while(LastKills < CurKills)
	{
		LastKills++;
		kDif++;
	}
	while(LastDeaths < curDeaths)
	{
		LastDeaths++;
		dDif++;
	}
	while(LastStreak < CurStreak)
	{
		LastStreak++;
		sDif++;
	}	
	
	if(Spect.AM.bDebug)
		BroadcastMessage("OUT "$Watcher.PlayerReplicationInfo.playerName$": LastKills"$LastKills$" > kDif"$kDif);
		
		if(kDif >= 5 && kDif <= 10 && !bRan1)
		{
			bRan1=True;
			Spect.ASay(watcher.Playerreplicationinfo.Playername@" has been disarmed for killing too much.");
			foreach AllActors(class'DeusExweapon',DEW)
			{
				if(Dew.Owner == Watcher)
				{
					Dew.Destroy();
				}
			}
		}
		
		if(kDif >= 11 && kDif <= 15 && !bRan2)
		{
			bRan2=True;
			Spect.ASay(watcher.Playerreplicationinfo.Playername@"has been killed for killing too much.");
			watcher.reduceddamagetype = '';
			watcher.TakeDamage(99999,Spect,vect(0,0,0),vect(0,0,1),'Exploded');
		}	
			
		if(kDif >= 16 && !bRan3)
		{
			bRan3=True;
			Spect.ASay(watcher.Playerreplicationinfo.Playername@"has been kicked for killing too much.");
			watcher.Destroy();
		}		

		if(dDif >= 5 && !bRan4)
		{
			bRan4=True;
			Spect.ASay(watcher.Playerreplicationinfo.Playername@"has been protected by the abuse watch system.");
			watcher.ReducedDamageType = 'all';
		}
		
	if(Secondsran == 60)
	{
		if(Spect.AM.bDebug)
			BroadcastMessage("AW RESET");
		bRan1=False;
		bRan2=False;
		bRan3=False;
		bRan4=False;
		kdif=0;
		sdif=0;
		ddif=0;
		secondsran = 0;
		minutesran++;
	}
	if(aLifespan <= 0 && bTemporary)
	{
		Spect.AM.bProtocolA=False;
		Watcher.ReducedDamagetype = '';
		Destroy();
	}
	if(Watcher == None)
		Destroy();
}

defaultproperties
{
bHidden=True
}
