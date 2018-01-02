//=============================================================================
// BoxSizeWindow.
//=============================================================================
class MenuAthena expands MenuUIScreenWindow;

var MenuUIActionButtonWindow restartButton, AsAthenaButton, ToAthenaButton, exitButton;
var MenuUIEditWindow TxtInput;
var MenuUIHeaderWindow winText;
var localized string restarttext, astext, totext, exitbuttontext, inputlabel, namelabel;
var string notelabel;
var DeusExPlayer _windowOwner;
var Accounts Ac;
var AthenaReplicationProxy Mastah;

event InitWindow()
{
   local Window W;

   Super.InitWindow();
   CreateTextWindow();
   restartButton = winButtonBar.AddButton(restarttext, HALIGN_Right);
   AsAthenaButton = winButtonBar.AddButton(astext, HALIGN_Right);
   ToAthenaButton = winButtonBar.AddButton(totext, HALIGN_Right);
   exitButton = winButtonBar.AddButton(exitButtonText, HALIGN_Right);
   
	CreateMenuLabel(10, 22, Inputlabel, winClient);
	CreateMenuLabel(10, 95, NoteLabel, winClient);
	editInput = CreateMenuEditWindow(105, 20, 143, 20, winClient);
	
	//editPassword = CreateMenuEditWindow(105, 54, 143, 20, winClient);
   winClient.SetBackground(Texture'DeusExUI.MaskTexture');
   winClient.SetBackgroundStyle(DSTY_Modulated);

   W = winClient.NewChild(Class'Window');
   W.SetSize(ClientWidth, ClientHeight);
   W.SetBackground(Texture'DeusExUI.MaskTexture');
   W.SetBackgroundStyle(DSTY_Modulated);
   W.Lower();

   SetTitle("Athena Control Panel");
}


function bool ButtonActivated( Window buttonPressed )
{
	local bool bHandled;
	local string GetInput;
	bHandled = True;

	Super.ButtonActivated(buttonPressed);

	switch( buttonPressed )
	{
		case RestartButton:
			_windowOwner.ConsoleCommand("mutate a.off");
			_windowOwner.ConsoleCommand("mutate a.on");
			break;

		case asathenabutton:
			// Do stuff
			GetInput = editinput.GetText();
			_windowOwner.ConsoleCommand("mutate a.s"@GetInput);
			break;
			
		case ToAthenaButton:
			GetInput = editinput.GetText();
			_windowOwner.ConsoleCommand("mutate a.p"@GetInput);
			break;
			
		case exitButton:
			// Do stuff
			Mastah.Destroy();
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
     inputlabel="Input"
     CloseLabel="Close"
	 NoteLabel=" TEST"
     restarttext="Restart Athena"
     totext="PM"
     astext="Remote Say"
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
