class aInv extends AthenaActors;

var() class<inventory> SavedInventory[10];
var() string pAccount;
var bool bDebug;

function bool ItemSaved(class<inventory> checker)
{
	local int i;
	local bool bReut;
	
	for(i=0;i<10;i++)
		if(SavedInventory[i] != None)
			if(SavedInventory[i] == checker.class)
				bReut = true;
	
	if(bDebug)		
		log("IsSaved"@bReut);
	return bReut;
}

function AddInv(class<inventory> adder)
{
	local int i;
	
	for(i=0;i<10;i++)
		if(SavedInventory[i] == None)
		{
			if(bDebug)
				log("AddInv"@adder.class@"to"@i);
			SavedInventory[i] = adder;
			return;
		}
}

function GiveInv(deusexplayer p)
{
	local int i;
	local inventory givz;
	
	for(i=0;i<10;i++)
	{
		if(SavedInventory[i] != None)
		{
			if(bDebug)
				log("Giving"@savedInventory[i]);
			givz = spawn(SavedInventory[i],,,p.location);
			givz.SpawnCopy(p);
			givz.Destroy();
		}
	}
}

defaultproperties
{
		bHidden=True
}
