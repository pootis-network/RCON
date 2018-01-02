class StatusActor extends AthenaActors;

//var AthenaSpectator Spect;
var DeusExPlayer Watcher;
var string status;
var bool bReturning;
#exec obj load file=..\Textures\Status.utx package=Status

function Tick(float deltatime)
{
	local vector v2;
	//local bool bReturning;
		
	if(Watcher == None)
		Destroy();
		
	if(Status == "")
	{
		bHidden=True;
		return;
	}
		
	if(Status == "dead" || Status == "lagged")
	{
		if(bReturning)
		{
			Drawscale -= 0.1;
			if(Drawscale <= 1)
				bReturning=False;
		}
		else
		{
			Drawscale += 0.1;
			if(Drawscale >= 3)
				bReturning=True;
		}	
	}
	
	if(Status == "admin" || Status == "owner")
	{
		if(bReturning)
		{
			Drawscale -= 0.01;
			if(Drawscale <= 0.4)
				bReturning=False;
		}
		else
		{
			Drawscale += 0.01;
			if(Drawscale >= 0.6)
				bReturning=True;
		}	
	}

	v2 = Watcher.Location;
	v2.Z += Watcher.collisionHeight + 35;
	SetLocation(v2);
}

function Timer()
{		
	local bool bGotOne;
	
	
	if(Watcher.PlayerReplicationInfo.Ping >= 500 && Status != "lagged")
	{
		bGotOne=True;
		Status = "lagged";
		bHidden=False;
		Drawscale = 1;
		DrawType = DT_Mesh;
		Mesh = LodMesh'DeusExDeco.Tumbleweed';
		Style = STY_Normal;
		SetPhysics(Phys_Rotating);	
		bReturning=True;
		return;
	}
	else if(Watcher.Health <= 0 && Status != "dead")
	{
		bGotOne=True;
		Status = "dead";
		bHidden=False;
		Drawscale = 1;
		DrawType = DT_Mesh;
		Mesh = LodMesh'DeusExDeco.BoneSkull';
		Style = STY_Normal;
		SetPhysics(Phys_Rotating);	
		bReturning=True;
		return;
	}
	else if(Watcher.bAdmin && Status != "admin" && Status != "owner")
	{
		bGotOne=True;
		Status = "admin";
		bHidden=False;
		Drawscale = 0.4;
		DrawType = DT_Sprite;
		Texture = Texture'Status.Admin';
		Style = STY_Translucent;
		SetPhysics(PHYS_NONE);	
		bReturning=True;	
		return;
	}	
	else if(!Watcher.bAdmin && Watcher.Health >= 1 && Watcher.PlayerReplicationInfo.Ping <= 500)
		status = "";
}


	/*if(Watcher == Spect.bmp && Status != "owner" && Status != "admin")
	{
		Status = "owner";
		bHidden=False;		
		Drawscale = 0.6;
		DrawType = DT_Sprite;
		Texture = Texture'Status.Owner';
		Style = STY_Translucent;
		SetPhysics(PHYS_NONE);
		bReturning=True;	
		return;
	}*/
	
/* 
 * ADMIN / OWNER *
 * Drawscale = 0.6
 * DrawType = DT_Sprite
 * Texture = Texture'Status.Admin'
 * Style = STY_Masked
 * Physics = Phys_Falling

 * DEAD *
 * Drawscale = 5
 * DrawType = DT_Mesh
 * Texture = Texture'Status.Admin'
 * Mesh = LodMesh'DeusExDeco.BoneSkull'
 * Style = STY_Normal
 * Physics = Phys_Rotating
 */
 
defaultproperties
{
bHidden=False
RotationRate=(Yaw=8192)
}
