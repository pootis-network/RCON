//=============================================================================
// Spectator.
//=============================================================================
class Spec extends MessagingSpectator;

var IRCLink _IRC;

function string RCR(string in)
{
local string TempMessage, TempLeft, TempRight, OutMessage, _TmpString;
	OutMessage=in;
    while (instr(caps(outmessage), "|P") != -1)
    {
        tempRight=(right(OutMessage, (len(OutMessage)-instr(caps(OutMessage), "|P"))-3));
        tempLeft=(left(OutMessage, instr(caps(OutMessage), "|P")) );
        OutMessage=TempLeft$TempRight;
    }
		return OutMessage;
}

function string RCR2(string in)
{
local string TempMessage, TempLeft, TempRight, OutMessage, _TmpString;
	OutMessage=in;
    while (instr(caps(outmessage), "|C") != -1)
    {
        tempRight=(right(OutMessage, (len(OutMessage)-instr(caps(OutMessage), "|C"))-8));
        tempLeft=(left(OutMessage, instr(caps(OutMessage), "|C")) );
        OutMessage=TempLeft$TempRight;
    }
			return OutMessage;
}

function ClientMessage(coerce string S, optional name Type, optional bool bBeep)
{
local int i;
local string output;
local string line, newnick,ss;

		/*
		if(inStr(caps(s), caps("|p")) != -1)
		{
			i = InStr(caps(s), caps("|p"));
			while (i != -1) {	
				Output = Output $ Left(s, i) $ "";
				s = Mid(s, i + 3);	
				i = InStr(caps(s), caps("|p"));
			}
			s = Output $ s;
		}
			
		if(inStr(caps(s), caps("|C")) != -1)
		{
			i = InStr(caps(s), caps("|C"));
			while (i != -1) {	
				Output = Output $ Left(s, i) $ "";
				s = Mid(s, i + 8);	
				i = inStr(caps(s), caps("|C"));
			}
			s = Output $ s;
		}*/
	ss = RCR(s);
	ss = RCR2(ss);
	
	if(_IRC.bClientMode)
	{
	if(Type == 'Say')
	{
    Line = Right(ss, Len(s)-instr(ss,"): ")-Len("): "));
	 newnick = Left(ss, InStr(ss,"("));
	 _IRC.SendCommand("NICK "$newnick);
	  _IRC.SendMessage(Line);
	  return;
	  }
	}
	
	if(_IRC.iMode == 2)
	{
		if(Type == 'Say' || Type == 'TeamSay')
		{
			_IRC.SendMessage(sS);
		}
	}
	else
	{
		_IRC.SendMessage(sS);
	}
}

defaultproperties
{
}