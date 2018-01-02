class ARClient extends UBrowserHTTPClient;

//Create TCCore package
//Updater client class that checks for updates
//CodeBase class for storing common used functions
//GenericSiteQuery that takes any URL and returns the page code
var IpAddr		ServerIpAddr;
var string		ServerAddress;
var string		ServerURI;
var int			ServerPort;
var int			CurrentState;
var int			ErrorCode;
var bool		bClosed;

var globalconfig string	ProxyServerAddress;
var globalconfig int	ProxyServerPort;

var AthenaMutator AM;

function Browse(string InAddress, string InURI, optional int InPort, optional int InTimeout)
{
	CurrentState = Connecting;

	ServerAddress = InAddress;
	ServerURI = InURI;
	if(InPort == 0)
		ServerPort = 80;
	else
		ServerPort = InPort;
	
	if(InTimeout > 0 )
		SetTimer(InTimeout, False);

	ResetBuffer();

	if(ProxyServerAddress != "")
	{
		ServerIpAddr.Port = ProxyServerPort;
		if(ServerIpAddr.Addr == 0)
			Resolve( ProxyServerAddress );
		else
			DoBind();
	}
	else
	{
		ServerIpAddr.Port = ServerPort;
		if(ServerIpAddr.Addr == 0)
			Resolve( ServerAddress );
		else
			DoBind();
	}
}

function Resolved( IpAddr Addr )
{
	// Set the address
	ServerIpAddr.Addr = Addr.Addr;

	if( ServerIpAddr.Addr == 0 )
	{
		Log( "UBrowserHTTPClient: Invalid server address" );
		SetError(-1);
		return;
	}
	
	DoBind();
}

function DoBind()
{
	if( BindPort() == 0 )
	{
		Log( "UBrowserHTTPLink: Error binding local port." );
		SetError(-2);
		return;
	}

	Open( ServerIpAddr );
	bClosed = False;
}

event Timer()
{
	SetError(-3);	
}

event Opened()
{
	Enable('Tick');
	Log("Connection opened...", 'AIClient');
	if(ProxyServerAddress != "")
		SendBufferedData("GET http://"$ServerAddress$":"$string(ServerPort)$ServerURI$" HTTP/1.1"$CR$LF);
	else
		SendBufferedData("GET "$ServerURI$" HTTP/1.1"$CR$LF);
	SendBufferedData("User-Agent: Unreal"$CR$LF);
	SendBufferedData("Connection: close"$CR$LF);
	SendBufferedData("Host: "$ServerAddress$":"$ServerPort$CR$LF$CR$LF);

	CurrentState = WaitingForHeader;
}

function SetError(int Code)
{
	Disable('Tick');
	SetTimer(0, False);
	ResetBuffer();

	CurrentState = HadError;
	ErrorCode = Code;

	if(!IsConnected() || !Close())
		HTTPError(ErrorCode);
}

event Closed()
{
	bClosed = True;
}

function HTTPReceivedData(string Data)
{
	local int iconvidstart, iconvidend, imessagestart, imessageend;
	local string messagestr, convid;
	local AthenaSpectator AS;
	local AthenaMutator AMR;
	//<?xml version="1.0" encoding="UTF-8" standalone="yes"?><response conversation="8503425221487211688" emote="NONE" avatar="media/a14097360.mp4" avatarType="video/mp4" avatarTalk="media/a14097365.mp4" avatarTalkType="video/mp4" avatarBackground="media/a14097357.png"><message>As Edison said, "What good is a newborn babe?"</message></response
	Log(Data);
	//Log("Split test, message: "$Split(Data, "<message>", "</message>"));
	Log("xml data: "$_CodeBase().Split(Data, "<?", "?>"));
	//iconvidstart = InStr(Data, "<response conversation=");
	//iconvidstart += 24;
	//iconvidend = InStr(Data, " emote=");
	//iconvidend -= 1;
	//convid = Mid(Data, iconvidstart, iconvidend-iconvidstart);
	convid = _CodeBase().Split(Data, "<response conversation=", " emote=", 1,-1);
	//Log("Split test, convid: "$Split(Data, "<response conversation=", " emote", 1,-1));
	//Log("ConvID "$convid, 'AIClient');
	
	//imessagestart = InStr(Data, "<message>");
	//imessagestart += 9;
	//imessageend = InStr(Data, "</message>");	
	//messagestr = Mid(Data, imessagestart, imessageend-imessagestart);
	messagestr = _CodeBase().Split(Data, "<message>", "</message>");
	Log("Message: "$messagestr, 'AIClient');
	
	foreach AllActors(class'AthenaMutator', AMR)
	{
		if(AMR.aConvID == "")
		{
			AMR.aConvID = convid;
			Log("New conversation instance created. Recording convid: "$convid);
		}
	}
	
	foreach AllActors(class'AthenaSpectator', AS)
	{
		AS.ASay(messagestr);
	}
	Destroy();
}

function CodeBase _CodeBase()
{
	return Spawn(class'CodeBase');
}

function HTTPError(int Code)
{
	//-3 is closed normally
	//-2 is error binding port
	//400 - Error connecting
	if(Code == -3)
		Log(Code$" - Connection closed by host.", 'AIClientError');
	else if(Code == -2)
		Log(Code$" - Port binding error, connection already open?", 'AIClientError');
	else if(Code == 400)
		Log(Code$" - Connection denied by host.", 'AIClientError');
	else
		Log(Code$" - Undefined error...", 'AIClientError');
	Destroy();
}

event Tick(float DeltaTime)
{
	local string Line;
	local bool bGotData;
	local int NextState;
	local int i;
	local int Result;

	Super.Tick(DeltaTime);
	DoBufferQueueIO();

	do
	{
		NextState = CurrentState;
		switch(CurrentState)
		{
		case WaitingForHeader:
			bGotData = ReadBufferedLine(Line);
			if(bGotData)
			{
				i = InStr(Line, " ");
				Result = Int(Mid(Line, i+1));
				if(Result != 200)
				{
					SetError(Result);
					return;
				}
					
				NextState = ReceivingHeader;
			}	
			break;
		case ReceivingHeader:
			bGotData = ReadBufferedLine(Line);
			if(bGotData)
			{
				if(Line == "")
					NextState = ReceivingData;
			}	
			break;
		case ReceivingData:
			bGotData = False;
			break;
		default:
			bGotData = False;
			break;
		}
		CurrentState = NextState;
	} until(!bGotData);

	if(bClosed)
	{
		Log("Client closing.");
		Disable('Tick');
		if(CurrentState == ReceivingData)
			HTTPReceivedData(InputBuffer);

		if(CurrentState == HadError)
			HTTPError(ErrorCode);
	}
}

defaultproperties
{
}
