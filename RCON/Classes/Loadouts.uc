class Loadouts extends Mutator config(RCON);

//0 Random
//1 Assault: ARifle, Nanosword, Autoshotgun
//2 Engineer: Autoshotgun, Nanosword, Pistol, LAM, EMP
//3 Sniper: Sawedoff, Nano, Sniper
//4 Assassin: Crossbow, Shurikens, Nano, Gas Grenade
//5 Addaptive: ARifle, Nanosword, Sniper
var DeusExPlayer LoadoutPlayer[16];
var int LoadoutNum[16];
var config bool bEnabled;

function PostBeginPlay()
{
local DeusExWeapon DEW;
super.PostBeginPlay();
	if(bEnabled)
	{
		foreach AllActors(class'DeusExWeapon', DEW)
		{
			DEW.bHidden=True;
		}
	}
}

function ModifyPlayer(Pawn Other)
{
	local int x;
	local int k;
	local int i;
	local int m;
	local DeusExPlayer P;
	local string str;
		
	super.ModifyPlayer(Other);
	P = DeusExPlayer(Other);
	
	if(!bEnabled)
		return;
	if(LoadoutPlayer[P.PlayerReplicationInfo.PlayerID] == None)
	{
		P.ClientMessage("No loadout set. Use |P2Mutate SetLoad <number 0-5>");
		GiveLoadout(P,0);
		return;
	}
	else
	{
		GiveLoadout(P,LoadoutNum[P.PlayerReplicationInfo.PlayerID]);
	}
}

function Mutate(string MutateString, PlayerPawn Sender)
{
local int ID;
local float CT;
local string Part;
local Pawn APawn;
local string Text, TP;
local DeusExWeapon DEW;

		if(MutateString ~= "LoadoutsOn" && !bEnabled && Sender.bAdmin)
		{
			BroadcastMessage("Loadouts Enabled");
			bEnabled=True;
				foreach AllActors(class'DeusExWeapon', DEW)
				{
					if(DEW.Owner == None)
						DEW.bHidden=True;
				}
		}
		if(MutateString ~= "LoadoutsOff" && bEnabled && Sender.bAdmin)
		{
			BroadcastMessage("Loadouts Disabled");
			bEnabled=False;
				foreach AllActors(class'DeusExWeapon', DEW)
				{
					DEW.bHidden=False;
				}
		}
		
		if(left(MutateString,8) ~= "SetLoad ")
        {
            CT = int(Left(Right(MutateString, Len(MutateString) - 8),InStr(MutateString," ")));
			if(CT == 0) Part = "~ Random";
			else if(CT == 1) Part = "~ Assault";
			else if(CT == 2) Part = "~ Engineer";
			else if(CT == 3) Part = "~ Sniper";
			else if(CT == 4) Part = "~ Assassin";
			else if(CT == 5) Part = "~ Addaptive";
			else 
			{
				Part = "Invalid selection";
				CT = 0;
			}
			LoadoutPlayer[Sender.PlayerReplicationInfo.PlayerID] = DeusExPlayer(Sender);
			LoadoutNum[Sender.PlayerReplicationInfo.PlayerID]  = CT;
			Sender.ClientMessage("Loadout"@CT@Part);
		}
	

   	Super.Mutate(MutateString, Sender);
}

function GiveLoadout(DeusExPlayer DXP, int LoadoutNum)
{
local inventory inv;

	if(LoadoutNum == 0)
		LoadoutNum = RandRange(1,5);
	if(LoadoutNum == 1)
	{
		inv=Spawn(class'WeaponAssaultgun');
		Inv.Frob(DXP,None);	  
		Inventory.bInObjectBelt = True;
		inv.Destroy();
	
		inv=Spawn(class'WeaponNanosword');
		Inv.Frob(DXP,None);	  
		Inventory.bInObjectBelt = True;
		inv.Destroy();
		
		inv=Spawn(class'WeaponAssaultShotgun');
		Inv.Frob(DXP,None);	  
		Inventory.bInObjectBelt = True;
		inv.Destroy();
	}
	
	if(LoadoutNum == 2)
	{
		inv=Spawn(class'WeaponFlamethrower');
		Inv.Frob(DXP,None);	  
		Inventory.bInObjectBelt = True;
		inv.Destroy();
	
		inv=Spawn(class'WeaponNanosword');
		Inv.Frob(DXP,None);	  
		Inventory.bInObjectBelt = True;
		inv.Destroy();
		
		inv=Spawn(class'WeaponPistol');
		Inv.Frob(DXP,None);	  
		Inventory.bInObjectBelt = True;
		inv.Destroy();

		inv=Spawn(class'WeaponLAM');
		Inv.Frob(DXP,None);	  
		Inventory.bInObjectBelt = True;
		inv.Destroy();

		inv=Spawn(class'WeaponEMPGrenade');
		Inv.Frob(DXP,None);	  
		Inventory.bInObjectBelt = True;
		inv.Destroy();
	}
	
	if(LoadoutNum == 3)
	{
		inv=Spawn(class'WeaponRifle');
		Inv.Frob(DXP,None);	  
		Inventory.bInObjectBelt = True;
		inv.Destroy();
	
		inv=Spawn(class'WeaponNanosword');
		Inv.Frob(DXP,None);	  
		Inventory.bInObjectBelt = True;
		inv.Destroy();
		
		inv=Spawn(class'WeaponSawedoffShotgun');
		Inv.Frob(DXP,None);	  
		Inventory.bInObjectBelt = True;
		inv.Destroy();
	}
	
	if(LoadoutNum == 4)
	{
		inv=Spawn(class'WeaponMiniCrossbow');
		Inv.Frob(DXP,None);	  
		Inventory.bInObjectBelt = True;
		inv.Destroy();
	
		inv=Spawn(class'WeaponNanosword');
		Inv.Frob(DXP,None);	  
		Inventory.bInObjectBelt = True;
		inv.Destroy();
		
		inv=Spawn(class'WeaponShuriken');
		Inv.Frob(DXP,None);	  
		Inventory.bInObjectBelt = True;
		inv.Destroy();

		inv=Spawn(class'WeaponGasGrenade');
		Inv.Frob(DXP,None);	  
		Inventory.bInObjectBelt = True;
		inv.Destroy();
	}
	
	if(LoadoutNum == 5)
	{
		inv=Spawn(class'WeaponAssaultgun');
		Inv.Frob(DXP,None);	  
		Inventory.bInObjectBelt = True;
		inv.Destroy();
	
		inv=Spawn(class'WeaponNanosword');
		Inv.Frob(DXP,None);	  
		Inventory.bInObjectBelt = True;
		inv.Destroy();
		
		inv=Spawn(class'WeaponRifle');
		Inv.Frob(DXP,None);	  
		Inventory.bInObjectBelt = True;
		inv.Destroy();

		inv=Spawn(class'WeaponLAM');
		Inv.Frob(DXP,None);	  
		Inventory.bInObjectBelt = True;
		inv.Destroy();
	}
}

defaultproperties
{
bHidden=True
}