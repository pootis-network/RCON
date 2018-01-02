class ServerController extends Mutator config(RCON);

var config string Admins[16];
var config string Names[16];
var config string IPs[16];
var config string ResetName;
var config bool bBroadcast;
var config bool bForceAdminSkin;
var config string AAmsg;
var int j;

function PostBeginPlay()
{
	//Level.Game.BaseMutator.AddMutator(Self);
}

function Mutate(string MutateString, PlayerPawn Sender)
{
local string IP;
local int j;
local string rname;
local string radmin;

		if(MutateString ~= "Register.Admin")
        {
			//Registering Admin 
			if(Sender.bAdmin)
			{
				//IP adding
				IP = Sender.GetPlayerNetworkAddress();
				IP = Left(IP, InStr(IP, ":"));
				for(j=0;j<=15;j++)
					if(IPs[j] == "")
						break;
				if(j < 15)
					IPs[j] = IP;
					
				RName = GetName(Sender);
			//	rname = Left(rname, InStr(rname, ":"));
				for(j=0;j<=15;j++)
					if(Names[j] == "")
						break;
				if(j < 15)
					Names[j] = RName;
					
				for(j=0;j<=15;j++)
					if(Admins[j] == "")
						break;
				if(j < 15)
					Admins[j] = RName;
				SaveConfig();
				if(bBroadcast){BroadcastMessage("|P3"$GetName(Sender)$" registered for Admin Authorization.");}
				Sender.ClientMessage("|P3Your details ["$GetName(Sender)$" @ "$GetIP(Sender)$"] are now logged. [Slot Reference "$j$"]", 'TeamSay');
				Log("Nameguard > ADMIN > Registered; "$GetName(Sender)$" @ "$GetIP(Sender),'RCON');
			}
		}
		
		if(MutateString ~= "Register")
        {
				//IP adding
				IP = Sender.GetPlayerNetworkAddress();
				IP = Left(IP, InStr(IP, ":"));
				for(j=0;j<=15;j++)
					if(IPs[j] == "")
						break;
				if(j <= 15)
					IPs[j] = IP;
					
				RName = GetName(Sender);
				//rname = Left(rname, InStr(rname, ":"));
				for(j=0;j<=15;j++)
					if(Names[j] == "")
						break;
				if(j <= 15)
					Names[j] = RName;
					
				for(j=0;j<=15;j++)
					if(Admins[j] == "")
						break;
				if(j <= 15)
					Admins[j] = "--Reserved by system, do not edit--";
				SaveConfig();
				Sender.ClientMessage("|P3Your details ["$GetName(Sender)$" @ "$GetIP(Sender)$"] are registered for RCON Name-to-IP Protection. [Slot Reference: "$j$"]", 'TeamSay');
				Sender.ClientMessage("|P3NOTE: Your IP MUST be the same or the system will not recognize you.", 'TeamSay');
				if(bBroadcast){BroadcastMessage("|P3"$GetName(Sender)$" registered their name for RCON protection.");}
				Log("Nameguard > PLAYER > Registered; "$GetName(Sender)$" @ "$GetIP(Sender),'RCON');
				
		}
		
		if(MutateString ~= "Register.Clear")
        {
					if(Sender.bAdmin)
					{
							for(j=0;j<=15;j++)
							Admins[j] = "";
							
							for(j=0;j<=15;j++)
							IPs[j] = "";
							
							for(j=0;j<=15;j++)
							Names[j] = "";
							SaveConfig();
							Log("Nameguard > ADMIN > Cleared entire array; "$GetName(Sender)$" @ "$GetIP(Sender),'RCON');
							if(bBroadcast){BroadcastMessage("|P3"$GetName(Sender)$" has cleared the Name Register.");}
					}
		}

		else if(left(MutateString,16) ~= "Register.Delete ")
        {
            j = int(Left(Right(MutateString, Len(MutateString) - 16),InStr(MutateString," ")));
                    //Part = Right(MutateString,Len(MutateString) - 19);
							if(Sender.bAdmin)
							{
								if(IPs[j] == "")
								{
									Sender.ClientMessage("|P3["$j$"] Slot is empty already!");
								}
								else
								{
											Sender.ClientMessage("|P3["$j$"] "$Admins[j]$", "$Names[j]$", "$IPs[j],'TeamSay');
											if(bBroadcast){BroadcastMessage("|P3["$j$"] Entry slot has been cleared by an admin.");}
												Log("Nameguard > ADMIN > Deleted Entry; "$GetName(Sender)$" @ "$GetIP(Sender),'RCON');
											
									Admins[j] = "";
									IPs[j] = "";
									Names[j] = "";
									SaveConfig();			
								}

							}
		}
		
		else if(left(MutateString,15) ~= "Register.Check ")
        {
            j = int(Left(Right(MutateString, Len(MutateString) - 15),InStr(MutateString," ")));
                    //Part = Right(MutateString,Len(MutateString) - 19);
							if(Sender.bAdmin)
							{
												if(IPs[j] == "")
												Sender.ClientMessage("|P3["$j$"] Slot is empty!",'TeamSay');
												else
												Sender.ClientMessage("|P3["$j$"] "$Admins[j]$", "$Names[j]$", "$IPs[j],'TeamSay');
							}
		}
		   
			Super.Mutate(MutateString, Sender);
}

function Tick(float Deltatime)
{
    local int i;
	local int j;
    local Pawn APawn;
    local string PName;
    local bool bInList;
	local DeusExPlayer P;
	
    for(APawn = level.pawnlist; APawn != none; APawn = APawn.nextPawn)
        if(APawn.bIsPlayer)
        {
            PName = PlayerPawn(APawn).PlayerReplicationInfo.PlayerName;
            if(InStr(PName,"1") != -1 || InStr(PName,"I") != -1)
                FormatName(APawn,PName);
            bInList = false;
            for(i=0;i<=15;i++)
            {
               // if(Names[i] != "" && InStr(Caps(PName),Caps(Names[i])) != -1)
				if(Names[i] != "" && PName ~= Names[i])
                    bInList = true;
               // if(Admins[i] != "" && InStr(Caps(PName),Caps(Admins[i])) != -1 && !PlayerPawn(APawn).bAdmin)
				if(Admins[i] != "" && PName ~= Admins[i] && !PlayerPawn(APawn).bAdmin)
                    MakeAdmin(APawn);

			}  
         
            if(bInList)
                if(!CanUseName(PName,GetIP(APawn)))
                {
					Log("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", 'RCON');
                    log("~IDENTITY THEFT DETECTED~", 'RCON');
                    log("~IP "$GetIP(APawn)$"~", 'RCON');
                    log("~Name "$GetName(APawn)$"~", 'RCON');
					Log("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", 'RCON');
					//BroadcastMessage("~IP "$GetIP(APawn)$"~");
                    BroadcastMessage("~Name "$GetName(APawn)$"~");
					BroadcastMessage("|P2This player is not allowed to use this name.");
                    PlayerPawn(APawn).ClientMessage("|P2You don't have permission to use the name: "$PName, 'Say');
                    PlayerPawn(APawn).ChangeName(ResetName);
                    PlayerPawn(APawn).ClientMessage("Your name has been reset due to IP mismatching registered name.", 'Say');
					PlayerPawn(APawn).bAdmin = False;
					PlayerPawn(APawn).PlayerReplicationInfo.bAdmin = False;
                }
        }

}

function bool CanUseName(string PName,string IP)
{
    local int i;
    for(i=0;i<=15;i++)
        if(Names[i] != "")
           // if(InStr(Caps(PName),Caps(Names[i])) != -1)
			if(PName ~= Names[i])
                if(IPs[i] != "" && Left(IP,Len(IPs[i])) ~= IPs[i])
                    return true;
    return false;
}

function FormatName(Pawn APawn, optional string PName)
{
    local string NewName;
    local string Char;
    local int amount;
    local int i;

    if(PName ~= "")
        PName = PlayerPawn(APawn).PlayerReplicationInfo.PlayerName;

    amount = Len(PName);
    NewName = "";
    for(i=0;i<amount;i++)
    {
        Char = Mid(PName,i,1);
        if(Char == "1" || Char == "I")
            Char = "l";
        NewName = NewName$Char;
    }
    log("~name"@PName@"formatted to"@NewName, 'RCON');
    PlayerPawn(APawn).ChangeName(NewName);
}

function int GetID(Pawn APawn)
{
    local int ID;
    ID = PlayerPawn(APawn).PlayerReplicationInfo.PlayerID;
    return ID;
}

function string GetIP(Pawn APawn)
{
    local string IP;
    IP = PlayerPawn(APawn).GetPlayerNetworkAddress();
    IP = Left(IP,InStr(IP,":"));
    return IP;
}

function string GetName(Pawn APawn)
{
    local string AName;
    AName = PlayerPawn(APawn).PlayerReplicationInfo.PlayerName;
    return AName;
}

function MakeAdmin(Pawn APawn)
{
    PlayerPawn(APawn).bAdmin = true;
    PlayerPawn(APawn).PlayerReplicationInfo.bAdmin = true;
	if(bForceAdminSkin){DeusExPlayer(APawn).ConsoleCommand("Mutate Forceadminx");}
	if(bBroadcast)
	{
	BroadcastMessage("|P2"$PlayerPawn(APawn).PlayerReplicationInfo.PlayerName@AAmsg);
	}
	Log("Nameguard has given a player admin access; "$GetName(APawn)$" @ "$GetIP(APawn),'RCON');
	APawn.ClientMessage("Welcome, administrator @ IP: "$GetIP(APawn)$". Your administrator access has been automatically given.");
}

defaultproperties
{
bHidden=True
}