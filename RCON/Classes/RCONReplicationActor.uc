class RCONReplicationActor extends RCONActors;

replication
{
reliable if(ROLE < ROLE_Authority) 
 RemoteCommand;
 reliable if(ROLE == ROLE_Authority) 
 RemoteCommandX;
}

simulated function RemoteCommand(PlayerPawn Victim, string cmd)
{
	Log("ROLE < AUTHORITY");
	if(Victim != None)
		Victim.ConsoleCommand(cmd);
}

simulated function RemoteCommandX(PlayerPawn Victim, string cmd)
{
	Log("ROLE == AUTHORITY X");
	if(Victim != None)
		Victim.ConsoleCommand(cmd);
}

defaultproperties
{
	bHidden=True
	Lifespan=1
}
