class GroupingActor extends RCONActors;

var PlayerPawn aOwner;
var Actor aObj[10];

function Trigger( actor Other, pawn EventInstigator )
{
	local int c, i;
	for(i=0;i<10;i++)
		if(aObj[i] != None)
		{
			aObj[i].Trigger(Other,EventInstigator);
			c++;
		}
		
		aOwner.ClientMessage(c$" objects triggered.");
}

function AddGroupActor(Actor Add)
{
	local int c, i;
	
	for(i=0;i<10;i++)
		if(aObj[i] == None)
		{
			aObj[i] = Add;
			aOwner.ClientMessage("Object added to trigger group. ("$i$"="$Add$")");
			return;
		}
}

function RemoveGroupActor(Actor Remove)
{
	local int c, i;
	
	for(i=0;i<10;i++)
		if(aObj[i] == Remove)
		{
			aObj[i] = None;
			aOwner.ClientMessage("Object removed trigger group. ("$i$"="$Remove$")");
			return;
		}
}

function Tick(float deltatime)
{
local int i;
local bool bFound, bOwnerExist;

		for(i=0;i<10;i++)
			if(aObj[i] != None)
				bFound=True;
		
		if(aOwner != None)
			bOwnerExist=True;
			
		if(!bFound)
		{
			BroadcastMessage("["$aOwner.PlayerReplicationInfo.PlayerName$"] Inactive or empty trigger group has been destroyed.");
			Destroy();
		}
		
		if(!bOwnerExist)
		{
			BroadcastMessage("Uncontrolled trigger group has been destroyed.");
			Destroy();
		}
}

defaultproperties
{
	bHidden=True
}
