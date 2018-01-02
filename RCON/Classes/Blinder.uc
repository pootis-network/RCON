class Blinder extends RCONActors;

var DeusExPlayer Other;

function Timer()
{
Other.ClientFlash(1,Vect(20000,20000,20000));
Other.IncreaseClientFlashLength(2.0);
}
