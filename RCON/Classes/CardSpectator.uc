//=============================================================================
// Spectator.
//=============================================================================
class CardSpectator extends MessagingSpectator;

var AthenaMutator AM;
var int Cards[52];
var string CurrentGame;
var string rememberstring;
var string StoredCommand;
var DeusExPlayer CardPlayer;
var bool bStarting;
var int myCredits, currentBet;
var int rememberint;
var bool bHouseCantDraw, bPlayerCantDraw;
//21 vars
var int tPlayerTotal;
var int tHouseTotal;
var bool bPolling;
var string pollgame;

function Log2(string str)
{
	Log(str, 'Cards');
}

function GenerateDeck()
{
	Log2("Generated card pack.");
	//Suit 1: Hearts
	Cards[0] = 1; // A
	Cards[1] = 2;
	Cards[2] = 3;
	Cards[3] = 4;
	Cards[4] = 5;
	Cards[5] = 6;
	Cards[6] = 7;
	Cards[7] = 8;
	Cards[8] = 9;
	Cards[9] = 10;
	Cards[10] = 10; // J
	Cards[11] = 10; // Q
	Cards[12] = 10; // K
	
	//Suit 2: Clubs
	Cards[13] = 1; // A
	Cards[14] = 2;
	Cards[15] = 3;
	Cards[16] = 4;
	Cards[17] = 5;
	Cards[18] = 6;
	Cards[19] = 7;
	Cards[20] = 8;
	Cards[21] = 9;
	Cards[22] = 10;
	Cards[23] = 10; // J
	Cards[24] = 10; // Q
	Cards[25] = 10; // K
	
	//Suit 3: Spades
	Cards[26] = 1; // A
	Cards[27] = 2;
	Cards[28] = 3;
	Cards[29] = 4;
	Cards[30] = 5;
	Cards[31] = 6;
	Cards[32] = 7;
	Cards[33] = 8;
	Cards[34] = 9;
	Cards[35] = 10;
	Cards[36] = 10; // J
	Cards[37] = 10; // Q
	Cards[38] = 10; // K
	
	//Suit 4: Clubs
	Cards[39] = 1; // A
	Cards[40] = 2;
	Cards[41] = 3;
	Cards[42] = 4;
	Cards[43] = 5;
	Cards[44] = 6;
	Cards[45] = 7;
	Cards[46] = 8;
	Cards[47] = 9;
	Cards[48] = 10;
	Cards[49] = 10; // J
	Cards[50] = 10; // Q
	Cards[51] = 10; // K
}

function int DrawCard()
{
local int n, r, myDraw;
	myDraw = 0;
	while(myDraw == 0)
	{
		r = Rand(52);
		myDraw = Cards[r];
				Log2("Player drew"@myDraw@". ("$Cards[r]$")");
				//ASay("Player drew a"@myDraw$".");
				Cards[myDraw] = 0;
	}
	
	if(myDraw != 0)
		return myDraw;
}

function ASay(string str)
{
local DeusExPlayer DXP;
	if(AM.bMuted)
		return;
		
	BroadcastMessage("|c"$AM.ChatColour$"~ Trickster:"@str);
	
	foreach AllActors(class'DeusExPlayer',DXP)
	{
		DXP.PlaySound(sound'DatalinkStart', SLOT_None,,, 256);
	}
	AM.AddChatlog("|c"$AM.ChatColour$"~ Trickster:"@str);
	Log(str,'Trickster');
}

function ASayPrivate(deusexplayer dxp, string str, optional bool bBuzzah)
{
	if(bBuzzah)
	dxp.ClientMessage("|c"$AM.ChatColour$"# Trickster:"@str,'Teamsay');
	else
	dxp.ClientMessage("|c"$AM.ChatColour$"# Trickster:"@str);
	
	Log("[PRIVATE: "$DXP.PlayerReplicationInfo.PlayerName$"] "$str,'Trickster');
}

function AStatus(string str)
{
	if(str == "")
	Self.PlayerReplicationInfo.PlayerName = "|C"$AM.ChatColour$"Trickster";
	else
	Self.PlayerReplicationInfo.PlayerName = "|c"$AM.ChatColour$"Trickster ["$str$"]";
}

function string generateRandHex()
{
  local int i;
  local string UID;

  for(i=0; i<7; i++)
  {
    if(FRand() < 0.5)
      UID = UID$string(Rand(9));
    else
      UID = UID$GetHex();
  }
  return Left(UID, 6);
}

function string GetHex()
{
local int i;
	if(FRand() < 0.2)
		return "a";
	else if(FRand() >= 0.2 && FRand() < 0.4)
		return "b";
	else if(FRand() >= 0.4 && FRand() < 0.6)
		return "c";
	else if(FRand() >= 0.6 && FRand() < 0.8)
		return "d";
	else if(FRand() >= 0.8)
		return "f";
}

function string generateRandStr(int max)
{
  local int i;
  local string UID;
	local string Charz[26];
	charz[0]="A";
	charz[1]="B";
	charz[2]="C";
	charz[3]="D";
	charz[4]="E";
	charz[5]="F";
	charz[6]="G";
	charz[7]="H";
	charz[8]="I";
	charz[9]="J";
	charz[10]="K";
	charz[11]="L";
	charz[12]="M";
	charz[13]="N";
	charz[14]="O";
	charz[15]="P";
	charz[16]="Q";
	charz[17]="R";
	charz[18]="S";
	charz[19]="T";
	charz[20]="U";
	charz[21]="V";
	charz[22]="W";
	charz[23]="X";
	charz[24]="Y";
	charz[25]="Z";

  for(i=0; i<max; i++)
  {
      UID = UID$charz[rand(26)];
  }
  return UID;
}

function string generateRandChar(int max)
{
  local int i;
  local string UID;

  for(i=0; i<max; i++)
  {
      UID = UID$Chr(Rand(65));
  }
  return UID;
}

function Killme()
{
	local AthenaMutator AM;
	foreach Allactors(class'AthenaMutator', AM)
	{
		AM.Killphrase = generateRandStr(4);
		AM.card = None;
		Destroy();
		BroadcastMessage("Athena killed by killphrase.");
	}
}

function StartGameVote(string ginput)
{

}

function ClientMessage(coerce string S, optional name Type, optional bool bBeep)
{
local int j, i, n;
local string output, ip;
local string line, savename;
local DeusExPlayer DXP;
local string ignorename, sender;
local deusexplayer senderplayer;
local string astr;
		
	if(instr(caps(S), caps("["$AM.Killphrase$"]")) != -1)
		Killme();
	if(bStarting && storedcommand == "")
		return;
		
	if(Type == 'Say')
	{
		if(instr(caps(S), caps("): ")) != -1)
		{
			Line = Right(s, Len(s)-instr(s,"): ")-Len("): "));
			Line = AM.RCR(Line);
			Line = AM.RCR2(Line);
			Sender = Left(s, InStr(s,"("));
		}
		//Start ignore check
			sender = Left(s, InStr(s,"("));
					foreach AllActors(class'DeusExPlayer',DXP)
						if(DXP.PlayerReplicationInfo.PlayerName == sender)
							senderplayer = DXP;
							
			IP = senderplayer.GetPlayerNetworkAddress();
			IP = Left(IP, InStr(IP, ":"));

				for (n=0;n<20;n++)
						if(IP == AM.IgnoreIP[n])
							return;
	
		if(Left(Line,4) ~= "bet " && CurrentGame == "")
		{
			rememberint = int(Right(Line, Len(Line)-4));
			if(Senderplayer.Credits >= rememberint)
			{
			ASay("Bet taken.");
			senderplayer.Credits -= rememberint;
			CurrentBet += rememberint;
			}
			else
			{
			ASay("Player can't afford to bet that much.");
			}
		}
		
		if(Line ~= "hit me" && CurrentGame == "21" && SenderPlayer == CardPlayer)
		{
			if(bPlayerCantDraw)
			{
				ASay("Player can't draw now. (Cards over or is 21)");
			}
			else
			{
				if(FRand() < 0.5 && tHouseTotal >= 12)
				{
					ASay("House stands. Final total is"@tHouseTotal$".");
					bHouseCantDraw=True;
				}

				n = DrawCard();
				tPlayerTotal += n;
				ASay("Player One draws"@n@"(Current total"@tPlayerTotal$")");		
					
					if(!bHouseCantDraw)
					{
						j = DrawCard();
						tHouseTotal += j;
						ASay("House draws "$j);
					}


					if(tPlayerTotal >= 21)
						bPlayerCantDraw=True;
					
					if(tHouseTotal >= 21)
						bPlayerCantDraw=True;
					
				AStatus("Checking totals...");
				storedcommand="check";
				SetTimer(1,False);
			}
			return;
		}

		if(Line ~= "stand" && CurrentGame == "21" && SenderPlayer == CardPlayer)
		{
			if(FRand() < 0.5 && tHouseTotal >= 12)
			{
				ASay("House stands. Final total is"@tHouseTotal$".");
				bHouseCantDraw=True;
			}
						
			bPlayerCantDraw=True;
			j = DrawCard();

				if(!bHouseCantDraw)
				{
					tHouseTotal += j;
					ASay("House draws "$j);
				}

				if(tHouseTotal >= 21)
					bHouseCantDraw=True;
				
			AStatus("Checking totals...");
			storedcommand="check";
			SetTimer(1,False);
			return;
		}
		
		if(Left(Line,17) ~= "trickster, start " && CurrentGame == "")
		{
			rememberstring = Right(Line, Len(Line)-17);
				SetTimer(1,False);
				bStarting=True;
				AStatus("Thinking...");
				CardPlayer=senderplayer;
				StoredCommand = "startgame";
		}
		
		if(Line ~= "trickster, shut down")
		{
			KillMe();
			return;
		}

	}//End if(type)
}
	
function Timer()
{
local int h, hh, p, ph, n, j;
local bool bPB, bHB;

	if(storedcommand == "bj1endgame")
	{
		if(tPlayerTotal == 21)
			ASay("Player One total is 21!");
		else if(tPlayerTotal > 21)
		{
			bPB=True;
			ASay("Player One is bust!");
		}
			
		if(tHouseTotal == 21)
			ASay("House total is 21!");
		else if(tHouseTotal > 21)
		{
			bHB=True;
			ASay("House is bust!");
		}
		
		if(tHouseTotal == 21 || tPlayerTotal == 21)
		{
			ASay("Draw! Credits returned.");
			CardPlayer.Credits += currentBet;
			CurrentBet = 0;
		}
		else if(tHouseTotal <= 21 && bPB)
		{
			ASay("House wins.");
			myCredits += currentBet*2;
			currentBet = 0;
		}
		else if(tPlayerTotal <= 21 && bHB)
		{
			ASay("Player wins.");
			CardPlayer.Credits += currentBet*2;
			currentBet = 0;
		}
		else if(tPlayerTotal <= tHouseTotal && !bHB && !bPB)
		{
			ASay("House wins.");
			myCredits += currentBet*2;
			currentBet = 0;			
		}
		else if(tPlayerTotal >= tHouseTotal && !bHB && !bPB)	
		{
			ASay("Player wins.");
			CardPlayer.Credits += currentBet*2;
			currentBet = 0;		
		}
		else if(tPlayerTotal == tHouseTotal)	
		{
			ASay("Draw! Credits returned.");
			CardPlayer.Credits += currentBet;
			CurrentBet = 0;
		}
		
		Storedcommand="";
		Cardplayer=None;
		CurrentGame="";
		AStatus("");
	}
	if(Currentgame == "21" && Storedcommand == "bj1drawinitcards")
	{
		StoredCommand = "";
		p = drawcard();
		ph = drawcard();
		h = drawcard();
		hh = drawcard();
		tPlayerTotal += p;
		tPlayerTotal += ph;
		tHouseTotal += h;
		tHouseTotal += hh;
		Log("Player draws: "$p$" and "$ph);
		Log("House draws: "$h$" and "$hh);
		ASay("House draws "$h$" and a hidden hole card.");
		ASay("Player One draws"@p@"and"@ph$" (Current total"@tPlayerTotal$")");
		AStatus("");
	}
	
	if(Currentgame == "21" && storedcommand == "check")
	{
		if(bPlayerCantDraw && bHouseCantDraw)
		{
			storedcommand="bj1endgame";
			ASay("Game over, noone can draw.");
			AStatus("Checking totals...");
			SetTimer(1,False);
		}
		else
		{
			ASay("Hit or stand?");
			AStatus("Waiting for response...");
			storedcommand = "";
		}
	}	

	if(storedcommand == "startgame")
	{
			if(currentBet == 0)
			{
				AStatus("");
				ASay("A bet is needed.");
				storedcommand="";
				rememberstring="";
				bStarting=False;
				return;
			}
			
		if(rememberstring == "21" || rememberstring == "twenty-one" || rememberstring == "twenty one"  || rememberstring == "blackjack")
		{
			ASay("Beginning Blackjack (21)");
			Rememberstring="";
			StoredCommand="bj1drawinitcards";
			GenerateDeck();
			bHouseCantDraw=False;
			bPlayerCantDraw=False;
			tPlayerTotal=0;
			tHouseTotal=0;
			bStarting=False;
			CurrentGame = "21";
			AStatus("Launching Blackjack...");
			SetTimer(1,false);
		}
		else if(rememberstring == "poker" || rememberstring == "highlow")
		{
			ASay("This game is not yet implemented.");
			AStatus("");
			bStarting=False;
			CardPlayer = None;
		}
	}
}

defaultproperties
{
}
