//======================================
// RPGHandler, formerly MoneyHandler
//======================================
class RPGHandler extends Mutator config(PartyStuff);

var config int standardLowest, standardHighest;
var config bool bEnabled;
var config int DeathPenalty;
var config bool bDebug;
var bool bSkillGame, bAugGame;
var int rpgAugGain, rpgSkillgain;
var DeusExPlayer RPGPlayers[16];
var int GainedEXP[16];
var int CurrentLevel[16];
var config int AugsPerLevel;
var Accounts ac;

function PostBeginPlay()
{
	local Accounts acc;
	
	foreach AllActors(class'Accounts',Acc)
		if(acc != None)
			ac = acc;
	Log("Setting up RPG system...", 'RPG');
//rpgAugGain = DeusExMPGame(Level.Game).AugsPerKill;
//	rpgSkillgain = DeusExMPGame(Level.Game).SkillsPerKill;
	Log("VARIABLE SET: AugsPerLevel: "$AugsPerLevel, 'RPG');
	//Log("VARIABLE SET: rpgSkillgain: "$rpgSkillgain, 'RPG');
	DeusExMPGame(Level.Game).SkillsAvail   = 0;
    DeusExMPGame(Level.Game).SkillsTotal   = 0;
    DeusExMPGame(Level.Game).SkillsPerKill = 0;
    DeusExMPGame(Level.Game).InitialAugs   = 0;
    DeusExMPGame(Level.Game).AugsPerKill   = 0;
	Log("Turning off standard DXMP aug/skill settings...", 'RPG');
	if(AugsPerLevel > 0)
	{
		bAugGame=True;
			Log("Aug game active.", 'RPG');
	}
	
	if(rpgSkillgain > 0)
	{
		//bSkillGame=True;
			Log("Skill game active [Not implemented, does nothing", 'RPG');
	}
}

function ScoreKill(Pawn Killer, Pawn Other)
{
	local DeusExPlayer OP;
	local DeusExPlayer KP;
	local int i;
	local int k;
	local int outputCredits;	
	local int j, e;
	local string killname;
	
	if(Killer.IsA('DeusExPlayer'))
	{
		KP = DeusExPlayer(Killer);
		if(DeusExPlayer(Other) != None)
		{
			OP = DeusExPlayer(Other);

				GiveEXP(KP, RandRange(70,95));
				if(OP.Credits > 0)
				{
					KP.Credits += OP.Credits;
					KP.ClientMessage("You took "$OP.Credits$" off of"@OP.PlayerReplicationInfo.PlayerName$"'s corpse.");
				}
				else
				{
					KP.ClientMessage("You searched"@OP.PlayerReplicationInfo.PlayerName$"'s corpse but found no money.");
				}
		}
        if(scriptedPawn(Other) != None)
        {
			KP.PlayerReplicationInfo.Score+=1;
			KP.PlayerReplicationInfo.Streak+=1;
			
			if(KP.InHand != None)
			{
			BroadcastMessage(KP.PlayerReplicationInfo.PlayerName$" killed "$ScriptedPawn(Other).FamiliarName$" with "$KP.inHand.ItemArticle@KP.inHand.ItemName$"!");
			}
			else
			{
			BroadcastMessage(KP.PlayerReplicationInfo.PlayerName$" killed "$ScriptedPawn(Other).FamiliarName$"!");
			}
			 if( !ScriptedPawn(Other).IsA('Animal') )
			 {
				if(int(ScriptedPawn(Other).GetPropertyText("scoreCredits")) > 0)
					j = int(ScriptedPawn(Other).GetPropertyText("scoreCredits"));
				
				if(int(ScriptedPawn(Other).GetPropertyText("scoreEXP")) > 0)
					e = int(ScriptedPawn(Other).GetPropertyText("scoreEXP"));
				
				if(bDebug)
					log("Property: scoreCredits: "@j@" - scoreEXP:"@e);
				if(j > 0)
				{
					KP.Credits += j;
					outputCredits = j;
					e += RandRange(10,20);
					GiveEXP(KP, e);
				}
				else
				{
					outputCredits = RandRange(standardLowest, standardHighest);
					KP.Credits += outputCredits;
					GiveEXP(KP, RandRange(10,20));
				}
				if(outputCredits > 0)
					KP.ClientMessage("Earned "$outputCredits$" from"@ScriptedPawn(Other).FamiliarName);
				else
					KP.ClientMessage(ScriptedPawn(Other).FamiliarName$" has no credits...");		
			 }
		}
	}
	super.ScoreKill(Killer, Other);
}

function GiveEXP(PlayerPawn RPGPlayer, int EXPGain)
{
local int j;
local int Needed;
local logininfo log, inf;
	local Accounts acc;
	
	if(ac == None)
		foreach AllActors(class'Accounts',Acc)
			if(acc != None)
				ac = acc;
				
foreach AllActors(class'LoginInfo',inf)
	if(inf.Flagger == RPGPlayer)
		{
					if(EXPGain == -1) //Special used for instant level
					{
						EXPGain = 100 * inf.CurrentLevel;
					}
					
					inf.GainedEXP += EXPGain;
					RPGPlayer.ClientMessage("|P7[LEVEL"@inf.CurrentLevel$"] Gained "$EXPGain$" EXP. Currently "$inf.GainedEXP$"/"$100 * inf.CurrentLevel);
						if(inf.GainedEXP >= 100 * inf.CurrentLevel)
						{
							if(bAugGame)
							{
								DeusExPlayer(RPGPlayer).GrantAugs(AugsPerLevel);
							}
							if(bSkillGame)
							{
								DeusExPlayer(RPGPlayer).SkillPointsAdd(rpgSkillgain);
							}
							inf.GainedEXP -= 100 * inf.CurrentLevel;
							inf.CurrentLevel++;
							BroadcastMessage("|P7"$RPGPlayer.PlayerReplicationInfo.PlayerName$" is now level"@inf.CurrentLevel);
							DeusExPlayer(RPGPlayer).RestoreAllHealth();
							DeusExPlayer(RPGPlayer).StopPoison();
							DeusExPlayer(RPGPlayer).ExtinguishFire();
							DeusExPlayer(RPGPlayer).Energy = DeusExPlayer(RPGPlayer).EnergyMax;
							DeusExPlayer(RPGPlayer).drugEffectTimer = 0;
							//GainedEXP[j] = 0;
						}
					return;
		}
}

function ModifyPlayer(Pawn Other)
{
	local int x;
	local int k;
	local int i;
	local int m;
	local DeusExPlayer P;
	local int j;
	local RPGAugger Augger;
	local Inventory inv;
local logininfo log, inf;

	super.ModifyPlayer(Other);
	p = DeusExPlayer(Other);
	

foreach AllActors(class'LoginInfo',inf)
	if(inf.Flagger == P)
	{
		if(inf.CurrentLevel > 1)
		{
			inf.CurrentLevel -= DeathPenalty;
			BroadcastMessage("|P2"$p.PlayerReplicationInfo.PlayerName@"is reduced to level"@inf.CurrentLevel$"!");
		}
		
	//	if(bSkillGame)
		//	p.SkillPointsAdd(rpgSkillgain * (inf.CurrentLevel - 1));
		if(bAugGame)
		{
			//Adding a roundabout way of trying to give augs since this didnt work..
			Augger = Spawn(class'rpgAugger',,,Location);
			Augger.DXP = P;
			Augger.AugsToGive = inf.CurrentLevel - 1;
			Augger.SetTimer(1,False);
		}

	inf.GainedEXP = 0;
	return;
	}
}

defaultproperties
{
     standardHighest=300
	 DeathPenalty=1
	 bEnabled=True
	 bHidden=True
}
