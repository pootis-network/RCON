class RPGAugger extends AthenaActors;

var DeusExPlayer DXP;
var int AugsToGive;

function Timer()
{
	if(DXP != None)
		DXP.GrantAugs(AugsToGive);
	
	Destroy();
}

defaultproperties
{
		bHidden=True
}
