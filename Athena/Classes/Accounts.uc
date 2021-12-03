class Accounts extends Mutator config(Accounts);
//TO DO
//Search username command, prints a new menu with account info... somehow
//Admin commands for list accounts
//
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
var() config int CurCredits;
var() config int CurrentLevel;
var() config int GainedEXP;
var() config string ForceName;
var() config string LoginCommand;
};
var(Accounts) config AccountsStr Accounts[150];

var(Accounts) config string MOTDx;
var(Accounts) config bool bForceLogin;
var(Accounts) config bool bDebug;
var(Accounts) config string SaveLocMap;
var(Accounts) config bool bEnableInvSave;
var RPGHandler RPG;

function PostBeginPlay ()
{
	Log("Accounts enabled.",'Accounts');
	//Level.Game.BaseMutator.AddMutator (Self);
}

function bool AddAccount(DeusExPlayer P, string Username, string Password)
{
	local int i;
	local bool bFoundUser;
	//Run Checks
	//Is username taken
	for(i=0;i<150;i++)
		if(Accounts[i].Username ~= Username)
		{
			AccAlert(p, "Error","Failed to create account. |n(ERROR-3: Account for username "$Username$" already exists.");
			return false;
		}
	//Has this IP already registered an account
	for(i=0;i<150;i++)
		if(Accounts[i].RegIP ~= GetIP(P))
		{
			AccAlert(p, "Error","Failed to create account. |n(ERROR-4: Your IP address already is linked to an account.");
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
			Accounts[i].CurrentLevel = 1;
			AccAlert(p, "Info","Account "$Username$" with password "$Password$" created. |nCombat level and credits are linked to your account.|nOnly one account per IP is allowed.|nPress Escape to close this window.");
			BroadcastMessage("|P4New account has been created by "$Getname(P)$". ("$Username$")");
			Log(GetName(P)$" created"@Username@Password@GetIP(P));
			SaveConfig();
			Login(P, Username, Password, False);
			return true;
		}
		
	}
}

function Update(string str, playerpawn p, logininfo infoz)
{		
	local int i,u, invi;
	local bool bUpdated;
	local inventory inv;
	if(bDebug)
	log(GetName(P)@str);
		for(i=0;i<150;i++)
		{
			if(Accounts[i].Username != "" && Accounts[i].Username ~= str)
			{
				if(Accounts[i].CurCredits != DeusExPlayer(P).Credits)
				{	
					bUpdated=True;
					u++;
					if(bDebug)
						Log("Credit update."@i@Accounts[i].CurCredits@DeusExPlayer(P).Credits);
					Accounts[i].CurCredits = DeusExPlayer(P).Credits;
					
				}
				if(Accounts[i].CurrentLevel != infoz.CurrentLevel)
				{
					bUpdated=True;
					u++;					
					if(bDebug)
						Log("Level update."@i@Accounts[i].CurrentLevel@infoz.CurrentLevel);
					Accounts[i].CurrentLevel = infoz.CurrentLevel;	
				}
				if(Accounts[i].GainedEXP != infoz.GainedEXP)
				{
					bUpdated=True;
					u++;					
					if(bDebug)
						Log("EXP update."@i@Accounts[i].GainedEXP@infoz.GainedEXP);
					Accounts[i].GainedEXP = infoz.GainedEXP;	
				}
				
				/*if(bEnableInvSave)
				{
					for(invi=0;invi<10;invi++)
					{
						Accounts[i].SavedInventory[invi] = None;
					}
					
					foreach AllActors(class'Inventory',inv)
					{
						if(inv.Owner == P)
						{
							for(invi=0;invi<10;invi++)
							{
								if(Accounts[i].SavedInventory[invi] == None &&
								inv.isa('PSCreditCard'))
								{
									Accounts[i].SavedInventory[invi] = inv.class;
									return;
								}
							}
						}
					}
				}*/
				if(bDebug)
					Log(bUpdated@u);
					
				if(bUpdated)
					SaveConfig();
				return;
			}
		}
			
}

function AccAlert(deusexplayer p, string title, string msg)
{
	local LoginInfo f;
	foreach AllActors(class'LoginInfo', f)
				if(f.Flagger == p)
					f.aAlert(title, msg);
}

function bool Login(DeusExPlayer P, string Username, string Password, bool bLoadLoc)
{
	local LoginInfo f;
	local bool bFoundUser, bCorrectPass;
	local int i, accountnum;
	local RPGAugger Augger;
	local aInv Saver;
	local bool bFoundSaver;
	local AugmentationManager AM;
	
	foreach AllActors(class'LoginInfo',f)
	{
		if(f.Flagger == P)
		{
			if(f.LinkedAccount != "")
			{
				AccAlert(p, "Error","You are already logged in.");
				return false;
			}
		}
	}
	//N-1
	if(Username == "" || Password == "")
	{
		AccAlert(p, "Error","Make sure both boxes have input.");
		return false;
	}
	
	for(i=0;i<150;i++)
		if(Accounts[i].Username ~= Username)
		{
			bFoundUser=True;
			accountnum=i;
		}
	
	if(bFoundUser)
	{
		if(Accounts[accountnum].AccessLevel < 0)
		{
			AccAlert(p, "Error","This account has been disabled.|nContact an administrator if you believe this is an error.");
			return false;
		}
		if(Accounts[accountnum].Password == Password)
			bCorrectPass=True;
	}
			
		if(!bFoundUser)
		{
			AccAlert(p, "Error","Account was not found for this username. |n|P1"$Username$" does not exist.");
			return false;
		}
		if(bFoundUser && !bCorrectPass)
		{
			AccAlert(p, "Error","Password incorrect. |n|P1"$Password$" does not match records for "$Username$".");
			return false;
		}
	if(bFoundUser && bCorrectPass)
	{
		AM = P.AugmentationSystem;
		Log("Resetting "$AM);
		if (P.AugmentationSystem != None)
		{
			P.AugmentationSystem.DeactivateAll();
			P.AugmentationSystem.ResetAugmentations();
			P.AugmentationSystem.Destroy();
			P.AugmentationSystem = None;
			if(bDebug)
			P.ClientMessage("|P2Removing augmentations...");
		}
		
		if (P.AugmentationSystem == None)
		{
			P.AugmentationSystem = Spawn(AM.class, P);
			P.AugmentationSystem.CreateAugmentations(P);
			P.AugmentationSystem.AddDefaultAugmentations();        
			P.AugmentationSystem.SetOwner(P);     
		}
				
		foreach AllActors(class'LoginInfo',f)
		{
			if(f.Flagger == P)
			{
				f.LinkedAccount = Username;
				if(Accounts[accountnum].CurrentLevel == 0)
				{
					Log(Accounts[accountnum].Username$" updated RPG settings.");
					Accounts[accountnum].CurrentLevel = 1;
					AccAlert(p, "Update","|P3["$Username$"] |P2This is an old account, and has now updated for the RPG integration. |nLevel is set to default (1).|nYour combat level will now be saved to your account.|nThis message only appears once.");
					SaveConfig();
				}
				foreach AllActors(class'aInv', saver)
				{
					if(saver.pAccount == Username)
					{
						log("Restoring inventory system");
						f.LinkedStorage = saver;
						saver.GiveInv(P);
						saver.bDebug = bDebug;
						bFoundSaver=True;
					}
				}
				if(!bFoundSaver)
				{
					log("Creating inventory system");
					saver = spawn(class'aInv');
					saver.pAccount = Username;
					saver.bDebug=bDebug;
					f.LinkedStorage = saver;
				}
				f.CurrentLevel = Accounts[accountnum].CurrentLevel;
				f.GainedEXP = Accounts[accountnum].GainedEXP;
				if(f.CurrentLevel > 0)
				{
					P.ClientMessage("|P3["$Username$"] Current level is "$f.CurrentLevel$". Updating player...");
					Augger = Spawn(class'rpgAugger');
					Augger.DXP = P;
					Augger.AugsToGive = f.CurrentLevel - 1;
					Augger.SetTimer(1,False);
				}
				p.Credits = accounts[accountnum].CurCredits;
				Log(P.PlayerReplicationInfo.PlayerName$" has logged in to account "$username@password@Accounts[accountnum].AccessLevel@GetIP(P),'Accounts');
				accounts[accountnum].Logins++;
				Accounts[accountnum].LastLogin = level.day$"/"$level.month$"/"$level.year;
				SaveConfig();
				
				if(Accounts[accountnum].ForceName != "")
					P.PlayerReplicationInfo.PlayerName = Accounts[accountnum].ForceName;
				if(Accounts[accountnum].Skin != "")
					P.ConsoleCommand("say /skin"@Accounts[accountnum].Skin);
				if(Accounts[accountnum].LoginCommand != "")
					P.ConsoleCommand(Accounts[accountnum].LoginCommand);
						
				if(Accounts[accountnum].AccessLevel == 0)
				{
					f.bRestrict=True;
					P.bAdmin=False;
					f.bWhitelisted=False;
					P.PlayerReplicationInfo.bAdmin=False;
				}
				if(Accounts[accountnum].AccessLevel == 1)
				{
					f.bRestrict=False;
					P.bAdmin=False;
					f.bWhitelisted=False;
					P.PlayerReplicationInfo.bAdmin=False;
				}
				if(Accounts[accountnum].AccessLevel == 2)
				{
					f.bRestrict=False;
					f.bWhitelisted=True;
					P.bAdmin=False;
					P.PlayerReplicationInfo.bAdmin=False;
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
				BroadcastMessage("|P4"$P.PlayerReplicationInfo.PlayerName$" has logged in to account "$Accounts[accountnum].Username);
				return true;
			}
		}
	}
}

function bool Logout(DeusExPlayer P)
{
	local LoginInfo f;
	local inventory inv;
	local int i;
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
					foreach AllActors(class'Inventory',inv)
					{
						if(inv.Owner == P && inv.itemname != "Citizen card" && inv.itemname != "Credits")
						{
							i++;
							inv.Destroy();
						}
					}
					if(i>0)
						p.ClientMessage(i$" inventory items removed due to logout.");
				if (P.AugmentationSystem != None)
				{
					P.AugmentationSystem.DeactivateAll();
					P.AugmentationSystem.ResetAugmentations();
					P.AugmentationSystem.Destroy();
					P.AugmentationSystem = None;
					if(bDebug)
					P.ClientMessage("|P2Removing augmentations...");
				}
				if (P.AugmentationSystem == None)
				{
					P.AugmentationSystem = Spawn(class'AugmentationManager', P);
					P.AugmentationSystem.CreateAugmentations(P);
					P.AugmentationSystem.AddDefaultAugmentations();        
					P.AugmentationSystem.SetOwner(P);     
					P.ClientMessage("|P2Reverting to default augmentations...");  
				}
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

function int GetLogin(DeusExPlayer P)
{
	local LoginInfo f;
	local int i, Accnum;
	local bool bFound;
	
	foreach AllActors(class'LoginInfo',f)
	{
		if(f != None)
		{
			if(f.Flagger == P)
			{
				if(f.LinkedAccount != "")
				{
					for(i=0;i<150;i++)
					{
						if(Accounts[i].Username ~= f.LinkedAccount)
						{
							Log(Accounts[i].Username@f.LinkedAccount);
							accnum = i;
							bFound=True;
						}
					}
				}
			}
		}
	}
	if(bFound)
		return accnum;
	else return -1;
}

function int GetLoginAccess(DeusExPlayer P)
{
	local LoginInfo f;
	local int i;
	
	foreach AllActors(class'LoginInfo',f)
		if(f.Flagger == P)
			for(i=0;i<150;i++)
				if(Accounts[i].Username == f.LinkedAccount)
					return Accounts[i].AccessLevel;
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
	local inventory inv;
	super.ModifyPlayer(Other);
	P = DeusExPlayer(Other);
	
	
	foreach AllActors(class'Inventory',inv)
	{
		if(inv.Owner == P && inv.itemname != "Citizen card" && inv.itemname != "Credits")
		{
			inv.Destroy();
		}
	}
					
	foreach AllActors(class'LoginInfo', f)
		if(f.Flagger == P)
			bFound=True;
			
	if(!bFound)
	{
		newlogin = Spawn(class'LoginInfo');
		newlogin.Flagger = P;
		newlogin.ac = self;
		newlogin.motdstr = motdx;
		newlogin.bDebug=bDebug;
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
local int i;
foreach AllActors(class'LoginInfo',f)
		if(f.Flagger == P)
			{	f.SetOwner(p);
				f.cMenuLogin();
				f.motdstr = motdx;}
				//log("Trying to open menu for "$getname(P));}	
}

function Mutate(string MutateString, PlayerPawn Sender)
{
    local string inputstr;
    local Pawn APawn, p;
	local int accnum, i;
	local logininfo f;
	local string OnlineStr;
	
	   	Super.Mutate(MutateString, Sender);
		
		if(MutateString ~= "acc")
		{
			openloginmenu(deusexplayer(sender));	
		}
		//make this relog the details because it defaults to find the master account if not because username changed
		if(Left(MutateString,12) ~= "setusername ")
        {
		    inputstr = Right(MutateString, Len(MutateString) - 12);
			if(inputstr == "")
			{
				Sender.ClientMessage("Enter a desired username.");
				return;
			}
			if(GetLogin(DeusExPlayer(Sender)) == -1)
			{
				Sender.ClientMessage("Error finding account... are you logged in?");
				return;
			}
			accnum = GetLogin(DeusExPlayer(Sender));
				foreach AllActors(class'LoginInfo',f)
					if(f.Flagger == Sender)
						f.LinkedAccount = inputstr;
			Sender.ClientMessage("Changing account "$accnum$":"$Accounts[accnum].Username$" username.");
			Accounts[accnum].Username = inputstr;
			SaveConfig();
			Sender.ClientMessage("New change: Username: "$Accounts[accnum].Username);
		}
	
		if(Left(MutateString,8) ~= "setpass ")
        {
		    inputstr = Right(MutateString, Len(MutateString) - 8);
			if(inputstr == "")
			{
				Sender.ClientMessage("Enter a desired password.");
				return;
			}
			if(GetLogin(DeusExPlayer(Sender)) == -1)
			{
				Sender.ClientMessage("Error finding account... are you logged in?");
				return;
			}
				accnum = GetLogin(DeusExPlayer(Sender));
				Sender.ClientMessage("Changing account "$accnum$":"$Accounts[accnum].Username$" password.");
				Accounts[accnum].Password = inputstr;
				SaveConfig();
				Sender.ClientMessage("New change: Password: "$Accounts[accnum].Password);
			
		}
		if(Left(MutateString,8) ~= "setskin ")
        {
		    inputstr = Right(MutateString, Len(MutateString) - 8);
			if(inputstr == "")
			{
				Sender.ClientMessage("Enter a desired skin.");
				return;
			}
			
			if(GetLogin(DeusExPlayer(Sender)) == -1)
			{
				Sender.ClientMessage("Error finding account... are you logged in?");
				return;
			}
			accnum = GetLogin(DeusExPlayer(Sender));
			Sender.ClientMessage("Changing account "$accnum$":"$Accounts[accnum].Username$" skin.");
			Accounts[accnum].Skin = inputstr;
			SaveConfig();
			Sender.ConsoleCommand("say /skin"@inputstr);
			Sender.ClientMessage("New change: Skin: "$Accounts[accnum].Skin);
		}
		if(Left(MutateString,10) ~= "accsearch ")
        {
		    inputstr = Right(MutateString, Len(MutateString) - 10);
			if(inputstr == "")
			{
				Sender.ClientMessage("Enter a username.");
				return;
			}
			accnum = GetLogin(DeusExPlayer(Sender));
			
			if(inputstr ~=  "me" || inputstr ~= "self")
			{
				i = accnum;
				AccAlert(DeusExPlayer(Sender), "#"$Accounts[i].Username$" ("$Accounts[i].AccessLevel$")", "Created: "$Accounts[i].DateCreated$" - Last Login: "$Accounts[i].LastLogin$" - Skin: "$Accounts[i].Skin$" |nLogins: "$Accounts[i].Logins$" - Credits: "$Accounts[i].CurCredits$" - EXP/Level: "$Accounts[i].GainedEXP$"/"$Accounts[i].CurrentLevel$"|n|P7"$Accounts[i].Description);
				return;
			}
			for(i=0;i<150;i++)
			{
				if(Accounts[i].Username ~= inputstr)
				{
					foreach AllActors(class'LoginInfo',f)
						if(f.Flagger == Sender)
							if(f.LinkedAccount == inputstr)
								OnlineStr = "|P3User is online!";
								
					if(Accounts[accnum].AccessLevel >= 3)
						AccAlert(DeusExPlayer(Sender), "~"$Accounts[i].Username$" ("$Accounts[i].AccessLevel$")","Created: "$Accounts[i].DateCreated$" - Last Login: "$Accounts[i].LastLogin$" - Skin: "$Accounts[i].Skin$" |nLogins: "$Accounts[i].Logins$" - Credits: "$Accounts[i].CurCredits$" - EXP/Level: "$Accounts[i].GainedEXP$"/"$Accounts[i].CurrentLevel$"|nRegIP: "$Accounts[i].RegIP$"|n|P7"$Accounts[i].Description$"|n"$OnlineStr);
					else
						AccAlert(DeusExPlayer(Sender), Accounts[i].Username$" ("$Accounts[i].AccessLevel$")","Created: "$Accounts[i].DateCreated$" - Last Login: "$Accounts[i].LastLogin$" - Skin: "$Accounts[i].Skin$" |nLogins: "$Accounts[i].Logins$" - Credits: "$Accounts[i].CurCredits$" - EXP/Level: "$Accounts[i].GainedEXP$"/"$Accounts[i].CurrentLevel$"|n|P7"$Accounts[i].Description$"|n"$OnlineStr);
				}
			}
		}
}


