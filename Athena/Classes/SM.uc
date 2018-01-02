class SM extends Mutator;

replication
{
   reliable if (Role == ROLE_Authority)
      ShowMessage;
}

simulated function PostBeginPlay ()
{
	//Level.Game.BaseMutator.AddMutator (Self);
	Log("SM test added.");
}

simulated function ShowMessage(DeusExPlayer Player, string Message)
{
  local HUDMissionStartTextDisplay    HUD;
  if ((Player.RootWindow != None) && (DeusExRootWindow(Player.RootWindow).HUD != None))
  {
    HUD = DeusExRootWindow(Player.RootWindow).HUD.startDisplay;
  }
  if(HUD != None)
  {
    HUD.shadowDist = 0;
	HUD.setFont(Font'FontMenuSmall_DS');
    HUD.Message = "";
    HUD.charIndex = 0;
    HUD.winText.SetText("");
    HUD.winTextShadow.SetText("");
    HUD.displayTime = 9.50;
    HUD.perCharDelay = 0.05;
    HUD.AddMessage(Message);
    HUD.StartMessage();
  }
}

function Mutate(string MutateString, PlayerPawn Sender)
{
    local string inputstr;
    local DeusExPlayer APawn, p;
		
	   	Super.Mutate(MutateString, Sender);
		
		if(Left(MutateString,2) ~= "s ")
        {
		    inputstr = Right(MutateString, Len(MutateString) - 2);
		    foreach AllActors(class'DeusExPlayer', P);
				ShowMessage(p,inputstr);
		}
}
