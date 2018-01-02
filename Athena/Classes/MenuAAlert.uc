//=============================================================================
// BoxSizeWindow.
//=============================================================================
class MenuAAlert expands MenuUIScreenWindow;

var MenuUIActionButtonWindow SendButton, exitButton;
var MenuUIEditWindow editCommand, editPassword;
var MenuUIHeaderWindow winText;
var localized string exitbuttontext, passwordlabel, sendbuttontext, commandlabel;
var DeusExPlayer _windowOwner;
var localized string Username;
var string Password;
var bool bRem;
var MenuUIMessageBoxWindow AlertWin;

event InitWindow()
{
   local Window W;

   Super.InitWindow();
   CreateTextWindow();
   //SendButton = winButtonBar.AddButton(sendButtonText, HALIGN_Right);
   //exitButton = winButtonBar.AddButton(exitButtonText, HALIGN_Right);
	
   winClient.SetBackground(Texture'DeusExUI.MaskTexture');
   winClient.SetBackgroundStyle(DSTY_Modulated);

   W = winClient.NewChild(Class'Window');
   W.SetSize(ClientWidth, ClientHeight);
   W.SetBackground(Texture'DeusExDeco.BlackMaskTex');//(Texture'DeusExUI.MaskTexture');
   W.SetBackgroundStyle(DSTY_normal); //modulated
   W.Lower();
}

function Crt(string title, string str)
{
	local float i;
	i = ClientWidth;
	i += Len(Str);
	SetTitle(title);
	CreateMenuLabelX(10, 22, str, winClient);
	SetSize(ClientWidth, ClientHeight);
	AskParentForReconfigure();
}

function MenuUILabelWindow CreateMenuLabelX(int posX, int posY, String strLabel, Window winParent)
{
	local MenuUILabelWindow newLabel;

	newLabel = MenuUILabelWindow(winParent.NewChild(Class'MenuUILabelWindow'));

	newLabel.SetPos(posX, posY);
	newLabel.SetText(strLabel);
	newLabel.SetWordWrap(True);
	newLabel.SetMinWidth(250);
	return newLabel;
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

event bool VirtualKeyPressed(EInputKey key, bool bRepeat)
{
	local bool bHandled;

	switch( key )
	{
		case IK_Enter:
			bHandled = True;
			break;
	}

	return bHandled;
}

event bool RawKeyPressed(EInputKey key, EInputState iState, bool bRepeat)
{
	if (key == IK_Enter)// &&//(iState == IST_Release))
	{
		return False;
	}
	else
	{
		return false;
	}
}

defaultproperties
{
	exitbuttontext="Exit"
	passwordlabel="Password"
	sendbuttontext="Send <Enter>"
	commandlabel="Command"
     ClientWidth=600//400
     ClientHeight=156//250
     clientTextures(0)=Texture'DeusExUI.UserInterface.MenuMessageBoxBackground_1'
     clientTextures(1)=Texture'DeusExUI.UserInterface.MenuMessageBoxBackground_2'
     textureRows=3
     textureCols=2
     bActionButtonBarActive=True
     bUsesHelpWindow=False
     //winShadowClass=Class'DeusEx.MenuUIMessageBoxShadowWindow'
}
