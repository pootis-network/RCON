class AthenaVision extends RCONActors;

var AthenaSpectator Ath;
var string AthFunction;

function Timer()
{
local Actor A;
local string Foundz;
local int amount;
local string final;

	if(AthFunction == "delete")
	{
		foreach VisibleActors(class'Actor', a, 50)
		{
			if (!A.IsA('Info') && !A.IsA('Mover') && !A.IsA('AthenaVision') && !A.IsA('Effects'))
			{
				A.Destroy();
				Foundz = Foundz$String(A.Class)$", ";
			}
		}
		if(len(foundz) > 420)
		foundz = "objects [...]";
		if(Foundz != "")
			Ath.ASay("Deleted "$Left(Foundz, Len(Foundz)-2));
		else
			Ath.ASay("Nothing found.");
	}

	if(AthFunction == "check")
	{
		foreach VisibleActors(class'Actor', a, 50)
		{
			if (!A.IsA('Info') && !A.IsA('AthenaVision') && !A.IsA('Effects'))
			{
				if(A.isA('inventory'))
				{
					Ath.ASay("Inventory,"@Inventory(A).ItemName);
					Ath.ASay("Class is"@string(A.Class));
					amount++;
				}
				if(A.IsA('ScriptedPawn'))
				{
					Ath.ASay("Scripted pawn,"@ScriptedPawn(A).FamiliarName$ "(Health="$ScriptedPawn(A).Health$")");
					Ath.ASay("Class is "$string(A.Class));
					amount++;
				}
				else if(A.IsA('PlayerPawn'))
				{
					Ath.ASay("Human,"@PlayerPawn(A).PlayerReplicationInfo.PlayerName$" (Health: "$PlayerPawn(A).Health$")");
						if(PlayerPawn(A).ReducedDamagetype == 'all')
							Ath.ASay("Player is invincible.");
						if(PlayerPawn(A).PlayerReplicationInfo.bAdmin)
							Ath.ASay("Player is an administrator.");
											amount++;
				}	
				else if(A.IsA('DeusExDecoration'))
				{
					Ath.ASay("Decoration,"@DeusExDecoration(A).ItemName$" Class is "$string(DeusExDecoration(A).class)$"(Hitpoints="$DeusExDecoration(A).HitPoints$") [Tag="$string(DeusExDecoration(A).Tag)$" : Event="$string(DeusExDecoration(A).Event)$"]");
							Ath.ASay("Mass="@DeusExDecoration(a).Mass);
						if(DeusExDecoration(a).bExplosive)
							Ath.ASay("Object is explosive.");
											amount++;
				}			
				else if(A.IsA('Mover'))
				{
					Ath.ASay("Mover,"@string(Mover(A).Class)$" [Tag="$string(Mover(A).Tag)$"]");
									amount++;
				}
			}
		}

		if(amount == 0)
			Ath.ASay("Nothing found or object was not recognized.");
	}
	
	Destroy();
}

defaultproperties
{
}
