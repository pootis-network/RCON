class RCONReplacer extends Actor
config(RCON);
//A configurable replacer.
struct ReplacementsStruct
{
var() config name OrigActorTag;
var() config string newActorClass;
};
var() config ReplacementsStruct Replacements[50];

function BeginPlay()
{
local Inventory w;
local int r;
local class<Inventory> GiveClass;

		for(r=0;r<Arraycount(Replacements);r++)
		{
			Foreach AllActors(class'Inventory',w)
			{	
				if(w.tag == Replacements[r].OrigActorTag)
				{
						if( Replacements[r].newActorClass!="" )
						{
						GiveClass = class<inventory>( DynamicLoadObject( Replacements[r].newActorClass, class'Class' ) );
						Spawn(GiveClass,w,,w.Location,w.Rotation);
						W.Destroy();
						}

				}
				w.SetPhysics(Phys_None);
			}
		}
		Log("Replacer actor finished set functions. Deleting replacer object.",'RCON');
		Destroy();
}

defaultproperties
{
bHidden=True
}