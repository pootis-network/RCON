class ShowMessageActor extends RCONActors;

replication
{
   reliable if (Role == ROLE_Authority)
      _ShowMessage;
}

simulated function _ShowMessage(DeusExPlayer _Player, string _Message)
{
  local HUDMissionStartTextDisplay    _HUD;
  if ((_Player.RootWindow != None) && (DeusExRootWindow(_Player.RootWindow).HUD != None))
  {
    _HUD = DeusExRootWindow(_Player.RootWindow).HUD.startDisplay;
  }
  if(_HUD != None)
  {
    _HUD.shadowDist = 0;
	_HUD.setFont(Font'FontMenuSmall_DS');
    _HUD.Message = "";
    _HUD.charIndex = 0;
    _HUD.winText.SetText("");
    _HUD.winTextShadow.SetText("");
    _HUD.displayTime = 7.50;
    _HUD.perCharDelay = 0.2;
    _HUD.AddMessage(_Message);
    _HUD.StartMessage();
  }
}

defaultproperties
{
}
