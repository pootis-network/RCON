class RCONProxy extends Nephthys.NephthysProxy config(RCON);

var(Proxy) config bool bBroadcastPreLogin;
var(Proxy) config string PreLoginBroadcast;

function BroadcastMessageB(string BMPlayers, string BMAdmins)
{
local DeusExPlayer P;
	foreach AllActors(class'DeusExPlayer',P)
	{
		if(P.bAdmin)
		P.ClientMessage(BMAdmins);
		else
		P.ClientMessage(BMPlayers);
	}
}

event PreLogin( string Addr, string RequestURL, string Names, out string Error )
{
	local AthenaSpectator AS;
			
		foreach AllActors(class'AthenaSpectator', AS)
			AS.AVoice(sound'Athena.AthenaNewPlayer');
			
BroadcastMessage("|P3A new player is connecting!");
}

event ConnectionDropped( string Addr, string Name, string Names )
{
	BroadcastMessageB("|P3A connecting player has been disconnected.", "|P2A connecting player has been disconnected. ("$Names$")");
}

event ConnectionKicked( string Addr, string RequestURL, string Names )
{
	BroadcastMessage("|P2A player was kicked by Nephthys. ("$Names$")");
}

defaultproperties
{
bHidden=True
}
