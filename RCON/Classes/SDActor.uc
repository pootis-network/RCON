class SDActor extends RCONActors;

var AthenaSpectator Spec;
var int counter;

function Timer()
{
	Counter--;
	if(Counter == 15 || Counter == 10 || Counter <= 5)
	Spec.ASay("Shutdown in "$Counter$" seconds.");
	
	if(Counter==0)
	{
		ConsoleCommand("quit");
	}
}

defaultproperties
{
}
