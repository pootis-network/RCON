//=============================================================================
// tcDTD - The Clown's Dynamic Text Display menu
// TEST
//=============================================================================
class tcDTD expands MenuUIScreenWindow;

var MenuUIActionButtonWindow FriendButton, SearchButton, exitButton;
var MenuUIEditWindow editUsername, editPassword;
var MenuUIHeaderWindow winText;
var localized string ExitButonText, friendButtonText, usernamelabel, passwordlabel;
var string notelabel;
var DeusExPlayer _windowOwner;
var Accounts Ac;
var AccountQuery Mastah;
var string tempMOTD;

event InitWindow()
{
   local Window W;

   Super.InitWindow();
   CreateTextWindow();
   FriendButton = winButtonBar.AddButton(FriendButtonText, HALIGN_Right);
  //// regButton = winButtonBar.AddButton(regButtonText, HALIGN_Right);
  // logoutButton = winButtonBar.AddButton(logoutButtonText, HALIGN_Right);
   exitButton = winButtonBar.AddButton(exitButtonText, HALIGN_Right);
   /*
    * var() config string Username;
var() config string Password;
var() config int AccessLevel; // 0 Base restricted, 1 Player, 2 Moderator, 3 Admin, 4 GOD
var() config string RegIP;
var() config string DateCreated;
var() config string LastLogin;
var() config int Logins;
var() config string Skin;
var() config string Description;
var() config int CurCredits;*/
	CreateMenuLabel(10, 20, "Username", winClient);
	CreateMenuLabel(10, 40, "Password", winClient);
	CreateMenuLabel(10, 60, "IP", winClient);
	CreateMenuLabel(10, 80, "Date Created", winClient);
	CreateMenuLabel(10, 100, "Last Login", winClient);
	CreateMenuLabel(10, 120, "Logins", winClient);
	CreateMenuLabel(10, 140, "Skin", winClient);
	CreateMenuLabel(10, 160, "Description", winClient);
	CreateMenuLabel(10, 180, "Credits", winClient);
	editUserName = CreateMenuEditWindow(105, 20, 143, 20, winClient);
	editPassword = CreateMenuEditWindow(105, 54, 143, 20, winClient);
   winClient.SetBackground(Texture'DeusExUI.MaskTexture');
   winClient.SetBackgroundStyle(DSTY_Modulated);

   W = winClient.NewChild(Class'Window');
   W.SetSize(ClientWidth, ClientHeight);
   W.SetBackground(Texture'DeusExUI.MaskTexture');
   W.SetBackgroundStyle(DSTY_Modulated);
   W.Lower();

   SetTitle("Playground Accounts");
}


function bool ButtonActivated( Window buttonPressed )
{
	local bool bHandled;
	local string GetUser, GetPass;
	bHandled = True;

	Super.ButtonActivated(buttonPressed);

	switch( buttonPressed )
	{
		case LoginButton:
			GetUser = editUserName.GetText();
			GetPass = editPassword.GetText();
			//Mastah.Login(_windowOwner, GetUser, GetPass);
			//_windowOwner.ClientMessage("Sent login"@_windowowner.playerreplicationinfo.playername@getuser@getpass);
			if(Mastah.Login(_windowOwner, GetUser, GetPass))
			{
				//_windowOwner.ClientMessage("Sending login"@_windowowner.playerreplicationinfo.playername@getuser@getpass);
				root.PopWindow();
				bHandled = True;
			}
			break;

		case regButton:
			// Do stuff
			GetUser = editUserName.GetText();
			GetPass = editPassword.GetText();
			//_windowOwner.ClientMessage("Sending reg"@_windowowner.playerreplicationinfo.playername@getuser@getpass);
			//Mastah.AddAccount(_windowOwner, GetUser, GetPass);
			if(Mastah.AddAccount(_windowOwner, GetUser, GetPass))
			{
			//_windowOwner.ClientMessage("Sent reg"@_windowowner.playerreplicationinfo.playername@getuser@getpass);
				root.PopWindow();
				bHandled = True;
			}
			break;
			
		case LogoutButton:
			// Do stuff
			//_windowOwner.ClientMessage("Sending logout"@_windowowner.playerreplicationinfo.playername);
			//Mastah.Logout(_windowOwner);
			if(Mastah.Logout(_windowOwner))
			{
			//_windowOwner.ClientMessage("sent logout"@_windowowner.playerreplicationinfo.playername);
				root.PopWindow();
				bHandled = True;
			}
			break;
			
		case exitButton:
			// Do stuff
			root.PopWindow();
			bHandled = True;
			break;

		default:
			bHandled = False;
			break;
	}

	return bHandled;
}

function CreateTextWindow()
{
	winText = CreateMenuHeader(21, 13, "", winClient);
	winText.SetTextAlignments(HALIGN_Center, VALIGN_Center);
	winText.SetFont(Font'FontMenuHeaders_DS');
	winText.SetWindowAlignments(HALIGN_Full, VALIGN_Full, 20, 14);
}

function SetMessageText( String msgText )
{
	winText.SetText(msgText);

	AskParentForReconfigure();
}

function bool AddAccount(DeusExPlayer P, string Username, string Password)
{
	ac.AddAccount(p,username,password);
}

function bool Login(DeusExPlayer P, string Username, string Password)
{
	ac.Login(p,Username,Password);
}

function bool Logout(DeusExPlayer P)
{
	ac.Logout(p);
}

defaultproperties
{
     UserNameLabel="Username"
     PasswordLabel="Password"
     friendButtonText="Friend"
	 exitButtonText="Close"
     ClientWidth=400
     ClientHeight=250
   //  clientTextures(0)=Texture'DeusExUI.UserInterface.MenuMessageBoxBackground_1'
    // clientTextures(1)=Texture'DeusExUI.UserInterface.MenuMessageBoxBackground_2'
     textureRows=3
     textureCols=2
     bActionButtonBarActive=True
     bUsesHelpWindow=False
    // winShadowClass=Class'DeusEx.MenuUIMessageBoxShadowWindow'
}
