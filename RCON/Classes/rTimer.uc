class rTimer extends RCONActors;

var int Start;
var bool bCountdown;
var int Cur;
var AthenaSpectator AS;

function Timer()
{
local string formattedmin;

	if(bCountdown)
	{
		Cur--;
		
		if(Cur <= 0)
		{
			Destroy();
		}
	}
	else
	{
		Cur++;
		if(Cur <= 5 || cur == 10 || cur == 15 || cur == 20 || cur == 30 || cur == 40 || cur == 50 || cur == 60 || cur == 70 || cur == 80 || cur == 90)
	}
}

defaultproperties
{
}
