//=============================================================================
// BoxSizeWindow.
//=============================================================================
class MenuLogin expands MenuUIScreenWindow;

var MenuUIActionButtonWindow LoginButton, regButton, logoutButton, exitButton;
var MenuUIEditWindow editUsername, editPassword;
var MenuUIHeaderWindow winText;
var localized string closeLabel, closebuttontext, LoginButtonText,regbuttontext,logoutbuttontext,exitbuttontext, usernamelabel, passwordlabel;
var string notelabel;
var DeusExPlayer _windowOwner;
var Accounts Ac;
var LoginInfo Mastah;
var string tempMOTD;
var bool bLoadLoc;
var PersonaNormalTextWindow myMOTD;
var MenuUILabelWindow motdl;

event InitWindow()
{
   local Window W;

   Super.InitWindow();
   CreateTextWindow();
   LoginButton = winButtonBar.AddButton(LoginButtonText, HALIGN_Right);
   regButton = winButtonBar.AddButton(regButtonText, HALIGN_Right);
   logoutButton = winButtonBar.AddButton(logoutButtonText, HALIGN_Right);
   exitButton = winButtonBar.AddButton(exitButtonText, HALIGN_Right);
  
	CreateMenuLabel(10, 22, UserNameLabel, winClient);
	CreateMenuLabel(10, 55, PasswordLabel, winClient);
	CreateMenuLabel(10, 85, NoteLabel, winClient);
	editUserName = CreateMenuEditWindow(105, 20, 143, 20, winClient);
	editPassword = CreateMenuEditWindow(105, 54, 143, 20, winClient);
	

	
	
	/*myMOTD = PersonaNormalTextWindow(winclient.NewChild(class'PersonaNormalTextWindow'));
	myMOTD.SetText(tempmotd);
	myMOTD.SetWindowAlignments(HALIGN_Left, VALIGN_Top, 10, 75);
	myMOTD.SetMaxLines(20);
	myMOTD.SetWordWrap(True);*/
	
   winClient.SetBackground(Texture'DeusExUI.MaskTexture');
   winClient.SetBackgroundStyle(DSTY_Modulated);

   W = winClient.NewChild(Class'Window');
   W.SetSize(ClientWidth, ClientHeight);
   W.SetBackground(Texture'DeusExUI.MaskTexture');
   W.SetBackgroundStyle(DSTY_Modulated);
   W.Lower();
	
   SetTitle("RCON Accounts");
}

function SetMOTD(string str)
{
	CreateMenuLabel(10, 85, str, winClient);
}

event bool ToggleChanged(Window button, bool bNewToggle)
{
	/*if (button.IsA('PersonaNotesEditWindow'))
	{
		EnableButtons();
	}
	else */if (button == chkLoc)
	{
		bLoadLoc = bNewToggle;
	}

	return True;
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
			//if(GetPass == "" || GetUser == "")
			//{
			//	_windowOwner.ClientMessage("|P2ERROR: Values must not be left blank.");
			//}
			//else
			//{
				if(Mastah.Login(_windowOwner, GetUser, GetPass, bLoadLoc))
				{
					//_windowOwner.ClientMessage("Sending login"@_windowowner.playerreplicationinfo.playername@getuser@getpass);
					root.PopWindow();
					bHandled = True;
				}
		//	}
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
				Mastah.Login(_windowOwner, GetUser, GetPass, bLoadLoc);
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
			Mastah.bCheckLogin(_windowOwner);
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
	ac.Login(p,Username,Password, bLoadLoc);
}

function bool Logout(DeusExPlayer P)
{
	ac.Logout(p);
}

event bool VirtualKeyPressed(EInputKey key, bool bRepeat)
{
	local bool bHandled;

	switch( key )
	{
		case IK_Enter:
				if(Mastah.Login(_windowOwner, editUserName.GetText(), editPassword.GetText(), bLoadLoc))
				{
					root.PopWindow();
				}
				bHandled = True;
			break;
	}

	return bHandled;
}

event bool RawKeyPressed(EInputKey key, EInputState iState, bool bRepeat)
{
	if ((key == IK_Enter) && (iState == IST_Release))
	{
		if(Mastah.Login(_windowOwner, editUserName.GetText(), editPassword.GetText(), bLoadLoc))
		{
			root.PopWindow();
		}
		return True;
	}
	else
	{
		return false;
	}
}

defaultproperties
{
     UserNameLabel="Username"
     PasswordLabel="Password"
     CloseLabel="Close"
     bLoadLoc=True
     NoteLabel=" |P2Accounts allows you to protect your username|n server features, like cheats and recording your credits.|nYou must login to play on this server!|P1|n Enter a username and password then click |n Register to create an account using the input.|n Then click Login or press Enter key to begin!|n If you you have an account, enter in the details|n then click Login.|n|n|P7(>Say m.setskin |P2<skin name>|P7 to set your permanent skin|n(>Say m.setusername |P2<new username>|P7 to change username|n(>Say m.setpass |P2<new pass>|P7 to change password|n(>Say m.acc to bring this menu back."
     loginButtonText="Login <Enter>"
     logoutButtontext="Logout"
     regButtonText="Register"
     closeButtonText="Close"
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
