class RSTimer extends RCONActors;

var RCON CallbackMut;


function Timer()
{
	CallbackMut.bPlayerSummoning=True;
	BroadcastMessage("Player Summoning time-out ended.");
	Destroy();
}

defaultproperties
{
bHidden=True
}
