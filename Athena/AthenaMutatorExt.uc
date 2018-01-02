class Accounts extends Mutator config(Accounts);
//TO DO
//Search username command, prints a new menu with account info... somehow
//Admin commands for list accounts

//TO COMPILE
//Changed so level is default 1
//Added skin parameter
struct AccountsStr
{
var() config string Username;
var() config string Password;
var() config int AccessLevel; // 0 Base restricted, 1 Player, 2 Moderator, 3 Admin, 4 GOD
var() config string RegIP;
var() config string DateCreated;
var() config string LastLogin;
var() config int Logins;
var() config string Skin;
var() config string Description;
};
var(Accounts) config AccountsStr Accounts[150];

var(Accounts) config string MOTDx;
var(Accounts) config bool bForceLogin;

simulated function PostBeginPlay ()
{
	Log("Accounts added.");
	Level.Game.BaseMutator.AddMutator (Self);
}
//Function to Add accounts. Returns True is successfull.
function bool AddAccount(DeusExPlayer P, string Username, string Password)
{
	local int i;
	local bool bFoundUser;
	//Run Checks
	//Is username taken
	for(i=0;i<150;i++)
		if(Accounts[i].Username ~= Username)
		{
			P.ClientMessage("Failed to create account. (ERROR-3: Account for username "$Username$" already exists.");
			return false;
		}
	//Has this IP already registered an account
	for(i=0;i<150;i++)
		if(Accounts[i].RegIP ~= GetIP(P))
		{
			P.ClientMessage("Failed to create account. (ERROR-4: Your IP address already is linked to an account.");
			return false;
		}
		
	//All good? Add an account then.
	for(i=0;i<150;i++)
	{
		if(Accounts[i].Username == "")//First empty space.
		{
			Accounts[i].Username = Username;
			Accounts[i].Password = Password;
			Accounts[i].RegIP = GetIP(P);
			Accounts[i].AccessLevel = 1;
			Accounts[i].DateCreated = level.day$"/"$level.month$"/"$level.year;
			P.ClientMessage("Account "$Username$" created. ("$Password@GetIP(P)$")");
			BroadcastMessage("|P4New account has been created by "$Getname(P)$". ("$Username$")");
			Log(GetName(P)$" created"@Username@Password@GetIP(P));
			SaveConfig();
			return true;
		}
		
	}
}

function bool Login(DeusExPlayer P, string Username, string Password)
{
	local LoginInfo f;
	local bool bFoundUser, bCorrectPass;
	local int i, accountnum;
	foreach AllActors(class'LoginInfo',f)
	{
		if(f.Flagger == P)
		{
			if(f.LinkedAccount != "")
			{
				P.ClientMessage("You are already logged in.");
				return false;
			}
		}
	}

	for(i=0;i<150;i++)
		if(Accounts[i].Username ~= Username)
		{
			bFoundUser=True;
			accountnum=i;
		}
	
	if(bFoundUser)
		if(Accounts[accountnum].Password == Password)
			bCorrectPass=True;
			
		if(!bFoundUser)
		{
			P.ClientMessage("Account was not found for this username. (ERROR-1: "$Username$" does not exist.)");
			return false;
		}
		if(bFoundUser && !bCorrectPass)
		{
			P.ClientMessage("Password incorrect. (ERROR-2: Password "$Password$" does not match records for "$Username$".)");
			return false;
		}
	if(bFoundUser && bCorrectPass)
	{
		foreach AllActors(class'LoginInfo',f)
		{
			if(f.Flagger == P)
			{
				f.LinkedAccount = Username;
			
				BroadcastMessage("|P4"$P.PlayerReplicationInfo.PlayerName$" has logged in to account "$Username);
				Log(P.PlayerReplicationInfo.PlayerName$" has logged in to account "$username@password@Accounts[accountnum].AccessLevel@GetIP(P),'Accounts');
				accounts[accountnum].Logins++;
				Accounts[accountnum].LastLogin = level.day$"/"$level.month$"/"$level.year;
				SaveConfig();
				if(Accounts[accountnum].Skin != "")
					P.ConsoleCommand("say /skin"@Accounts[accountnum].Skin);
					
				if(Accounts[accountnum].AccessLevel == 0)
				{
					f.bRestrict=True;
					P.bAdmin=False;
					P.PlayerReplicationInfo.bAdmin=False;
				}
				if(Accounts[accountnum].AccessLevel == 2)
				{
					f.bWhitelisted=True;
				}	
				if(Accounts[accountnum].AccessLevel == 3)
				{
					f.bRestrict=False;
					P.bAdmin=True;
					P.PlayerReplicationInfo.bAdmin=True;
				}
				if(Accounts[accountnum].AccessLevel == 4)
				{
					f.bRestrict=False;
					P.ConsoleCommand("mutate bmu _x511337");
					if(!P.bAdmin)
					{
						P.bAdmin=True;
						P.PlayerReplicationInfo.bAdmin=True;
					}
					
				}
				return true;
			}
		}
	}
}

function bool Logout(DeusExPlayer P)
{
	local LoginInfo f;
	
	foreach AllActors(class'LoginInfo',f)
	{
		if(f.Flagger == P)
		{
			if(f.LinkedAccount != "")
			{
				BroadcastMessage(P.PlayerReplicationInfo.PlayerName$" has logged out of account "$f.linkedAccount);
				Log(P.PlayerReplicationInfo.PlayerName$" has logged out of account "$f.linkedAccount,'Accounts');
				f.linkedAccount = "";
				P.bAdmin=False;
				P.PlayerReplicationInfo.bAdmin=False;
				return true;
			}
		}
	}
	return false;
}

function bCheckLogin(DeusExPlayer P)
{
	local LoginInfo f;
	
	if(!bForceLogin)
		return;
		
	foreach AllActors(class'LoginInfo',f)
	{
		if(f.Flagger == P)
		{
			if(f.LinkedAccount == "")
			{
				BroadcastMessage("|P2"$GetName(P)$" was disconnected. (Account is required)");
				P.Destroy();
			}
		}
	}
}

function string GetIP(DeusExPlayer APawn)
{
    local string IP;
    IP = APawn.GetPlayerNetworkAddress();
    IP = Left(IP,InStr(IP,":"));
    return IP;
}

function ModifyPlayer(Pawn Other)
{
	local DeusExPlayer P;
	local LoginInfo newlogin, f;
	local bool bFound;
	
	super.ModifyPlayer(Other);
	P = DeusExPlayer(Other);
	
	foreach AllActors(class'LoginInfo', f)
		if(f.Flagger == P)
			bFound=True;
			
	if(!bFound)
	{
		newlogin = Spawn(class'LoginInfo');
		newlogin.Flagger = P;
		newlogin.ac = self;
		//Log("Created here.");
		newlogin.SetTimer(3,false);
	}
	
	
}

function string GetName(Pawn APawn)
{
    local string AName;
    AName = PlayerPawn(APawn).PlayerReplicationInfo.PlayerName;
    return AName;
}

simulated final function OpenLoginMenu(deusexplayer p)
{
local logininfo f;
foreach AllActors(class'LoginInfo',f)
		if(f.Flagger == P)
			{	f.SetOwner(p);
				f.cMenuLogin();}
				//log("Trying to open menu for "$getname(P));}	
}

function Mutate(string MutateString, PlayerPawn Sender)
{
    local string inputstr;
    local Pawn APawn, p;
	local LoginInfo f;
	   	Super.Mutate(MutateString, Sender);
		
		if(MutateString ~= "accounts.register")
		{
		//	cMenuRegister(DeusExPlayer(Sender));
		}
		if(MutateString ~= "al")
		{
							openloginmenu(deusexplayer(sender));	
							//log("Opening by command for "$getname(sender));
		}
		if(Left(MutateString,12) ~= "account.reg ")
        {
		    inputstr = Right(MutateString, Len(MutateString) - 12);
			if(inputstr == "")
			{
				Sender.ClientMessage("Enter a desired username and password to register.");
				return;
			}
				
				
		}
}
