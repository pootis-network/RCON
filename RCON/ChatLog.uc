class Chatlog expands ToolWindow;

var ToolListWindow   lstFlags;
var ToolButtonWindow btnEdit;   
var ToolButtonWindow btnDelete; 
var ToolButtonWindow btnAdd;    
var ToolButtonWindow btnClose;  
var RadioBoxWindow   radSort;
var Window           winSort;
var ToolRadioButtonWindow	btnSortName;
var ToolRadioButtonWindow	btnSortType;

var String			 saveFlagName;
var EFlagType		 saveFlagType;
var int				 saveRowID;
var CLC Logger;
	
event InitWindow()
{
	Super.InitWindow();

	// Center this window	
	SetSize(565, 420);
	SetTitle("Chat Log");

	// Create the controls
	CreateControls();
	PopulateFlagsList();
}

function CreateControls()
{
	CreateSortRadioWindow();

	CreateFlagsList();
	
	btnClose  = CreateToolButton(465, 368, "|&Close");
}

function CreateSortRadioWindow()
{
	CreateToolLabel(16, 33, "Sort By:");
	
	radSort = RadioBoxWindow(NewChild(Class'RadioBoxWindow'));
	radSort.SetPos(65, 30);
	radSort.SetSize(180, 20);
	winSort = radSort.NewChild(Class'Window');

	btnSortName = ToolRadioButtonWindow(winSort.NewChild(Class'ToolRadioButtonWindow'));
	btnSortName.SetText("Name");
	btnSortName.SetPos(0, 5);

	btnSortType = ToolRadioButtonWindow(winSort.NewChild(Class'ToolRadioButtonWindow'));
	btnSortType.SetText("Type");
	btnSortType.SetPos(65, 5);

	btnSortName.SetToggle(True);
}

function CreateFlagsList()
{
	lstFlags = CreateToolList(15, 60, 425, 332);

	lstFlags.EnableMultiSelect(False);
	lstFlags.SetColumns(2);

	lstFlags.SetColumnTitle(0, "Name");
	lstFlags.SetColumnTitle(1, "Message");

	lstFlags.EnableAutoExpandColumns(True);
	lstFlags.SetColumnWidth(0, 210);
	lstFlags.SetColumnWidth(1, 75);
	lstFlags.SetColumnWidth(2, 100);

	lstFlags.SetSortColumn(0);
	lstFlags.AddSortColumn(1);

	lstFlags.HideColumn(2);
}

function PopulateFlagsList()
{
	local int rowIndex;
	local int flagIterator;
	local Name flagName;
	local int i;

	
	lstFlags.DeleteAllRows();
	
		Logger = Spawn(class'CLC');
		Logger.GetLogs();
		 for(i=0; i<79; i++)
		 {
			if(Logger.Chatlogs[i] != "")
			{
				rowIndex = lstFlags.AddRow( Logger.Chatlogs[i] );
			}
		}
	Logger.Destroy();
	EnableButtons();
}

function bool ButtonActivated( Window buttonPressed )
{
	local bool bHandled;

	bHandled = True;

	switch( buttonPressed )
	{
		case btnClose:
			root.PopWindow();
			break;

		default:
			bHandled = False;
			break;
	}

	if ( !bHandled ) 
		bHandled = Super.ButtonActivated( buttonPressed );

	return bHandled;
}

defaultproperties
{
}
