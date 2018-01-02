//=============================================================================
// BoxSizeWindow.
//=============================================================================
class BoxSizeWindow expands MenuUIWindow;

var MenuUIActionButtonWindow okButton;
var MenuUIActionButtonWindow defaultButton;
var MenuUIActionButtonWindow exitButton;
var MenuUIEditWindow sizeWindow;
var MenuUIHeaderWindow winText;
var localized string LoginButtonText,regbuttontext,logoutbuttontext,exitbuttontext, usernamelabel, passwordlabel;
var DeusExPlayer _windowOwner;
var Accounts Ac;

event InitWindow()
{
   local Window W;

   Super.InitWindow();
	CreateControls();
   winClient.SetBackground(Texture'DeusExUI.MaskTexture');
   winClient.SetBackgroundStyle(DSTY_Modulated);

   W = winClient.NewChild(Class'Window');
   W.SetSize(ClientWidth, ClientHeight);
   W.SetBackground(Texture'DeusExUI.MaskTexture');
   W.SetBackgroundStyle(DSTY_Modulated);
   W.Lower();

   SetTitle("Playground Accounts: Register");
}

function CreateControls()
{
   LoginButton = winButtonBar.AddButton(LoginButtonText, HALIGN_Right);
   regButton = winButtonBar.AddButton(regButtonText, HALIGN_Right);
   exitButton = winButtonBar.AddButton(exitButtonText, HALIGN_Right);
   
	CreateMenuLabel(10, 22, UserNameLabel, winClient);
	CreateMenuLabel(10, 55, PasswordLabel, winClient);

	editUserName = CreateMenuEditWindow(105, 20, 143, 20, winClient);
	editPassword = CreateMenuEditWindow(105, 54, 143, 20, winClient);
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
			// Do stuff
			//if(float(sizeWindow.GetText()) > 5)
			//	sizeWindow.setText("5.00000");
			root.PopWindow();
			_windowOwner.ConsoleCommand("Mutate accounts.login");
			bHandled = True;
			break;

		case regButton:

			GetUser = editUserName.GetText();
			GetPass = editPassword.GetText();
			Ac.AddAccount(GetUser, GetPass);
			Ac.Login(_windowOwner, GetUser, GetPass);
			root.PopWindow();
			//root.PopWindow();
			bHandled = True;
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

defaultproperties
{
     UserNameLabel="User Name"
     PasswordLabel="Password"
     CloseLabel="Close"
     loginButtonText="To Login"
     regButtonText="Confirm Register"
     closeButtonText="Close"
     ClientWidth=343
     ClientHeight=151
     clientTextures(0)=Texture'DeusExUI.UserInterface.MenuMessageBoxBackground_1'
     clientTextures(1)=Texture'DeusExUI.UserInterface.MenuMessageBoxBackground_2'
     textureRows=1
     textureCols=2
     bActionButtonBarActive=True
     bUsesHelpWindow=False
     winShadowClass=Class'DeusEx.MenuUIMessageBoxShadowWindow'
}
