class ADelay extends RCONActors;
var string msg;
var AthenaSpectator spect;
function Timer()
{
	spect.ASay(msg);
	Destroy();
}
defaultproperties
{
}
