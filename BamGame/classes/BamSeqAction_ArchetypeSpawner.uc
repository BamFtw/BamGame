class BamSeqAction_ArchetypeSpawner extends BamSeqAction
	hidecategories(SequenceAction);


/** Actor with Location and Rotation data for spawned Pawn */
var Object LocationActor;

/** Output spawned pawn through this link */
var Object OutputPawn;

/** Archetype to spawn */
var BamAIPawn PawnArchetype;

/** Class of the pawn that should be spawned, ignored if valid archetype is connected */
var() class<BamAIPawn> PawnClass;

/** When activated tries to spawn Pawn from archetype linked to Archetype variable link */
event Activated()
{
	local Actor spawnLocationActor;
	local BamAIPawn spawnedPawn;
	local BamAIAction aiAction;
	local BamActor_TeamManager TeamManager;

	OutputPawn = none;

	// check if pawn archetype is set
	if( PawnArchetype == none && PawnClass == none )
	{
		FailWithWarning("Pawn archetype and class are not set. One has to be.");
		return;
	}

	spawnLocationActor = Actor(LocationActor);

	// check if spawn loaction actor is set
	if( spawnLocationActor == none )
	{
		FailWithWarning("Spawn location is not set or is not an Actor");
		return;
	}

	// spawn pawn
	if( PawnArchetype != none )
	{
		spawnedPawn = class'WorldInfo'.static.GetWorldInfo().Spawn(PawnArchetype.Class,,, spawnLocationActor.Location, spawnLocationActor.Rotation, PawnArchetype);
	}
	else
	{
		spawnedPawn = class'WorldInfo'.static.GetWorldInfo().Spawn(PawnClass,,, spawnLocationActor.Location, spawnLocationActor.Rotation);
	}

	// check if pawn failed to spawn
	if( spawnedPawn == none )
	{
		FailWithWarning("Failed to spawn");
		return;
	}

	// grab connected AIAction
	if( VariableLinks.Length >= 4 && VariableLinks[3].LinkedVariables.Length > 0 && VariableLinks[3].LinkedVariables[0] != none )
	{
	 	aiAction = BamSeqVar_AIAction(VariableLinks[3].LinkedVariables[0]).GetAIAction();
	}

	// grab connected TeamManager
	if( VariableLinks.Length >= 3 && VariableLinks[2].LinkedVariables.Length > 0 && VariableLinks[2].LinkedVariables[0] != none )
	{
	 	TeamManager = BamActor_TeamManager(SeqVar_Object(VariableLinks[2].LinkedVariables[0]).GetObjectValue());
	}

	// spawn pawns controller
	if( spawnedPawn.Controller == none )
	{
		spawnedPawn.SpawnDefaultController();
	}

	// set the team
	if( BamAIController(spawnedPawn.Controller) != none && TeamManager != none )
	{
		BamAIController(spawnedPawn.Controller).SetTeamManager(TeamManager);
	}

	// push action
	if( aiAction != none )
	{
		spawnedPawn.BController.ActionManager.PushFront(aiAction);
	}


	// output spawned pawn
	OutputPawn = spawnedPawn;

	// activate succeeded output link
	OutputLinks[1].bHasImpulse = false;
	ActivateOutputLink(0);
}

/** Activates Failed output link, and displays warning message on the console */
function FailWithWarning(string warningText)
{
	`trace(warningText, `red);
	OutputLinks[0].bHasImpulse = false;
	ForceActivateOutput(1);
}

defaultproperties
{
	PawnArchetype=none

	ObjCategory="Bam.Gameplay.AI"
	ObjName="Pawn Spawner"

	ObjColor=(R=63,G=160,B=63,A=255)

	OutputLinks.Empty
	OutputLinks(0)=(LinkDesc="Succeeded")
	OutputLinks(1)=(LinkDesc="Failed")

	VariableLinks.Empty
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Spawn Point",PropertyName=LocationActor,bWriteable=false,MaxVars=1)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Archetype",PropertyName=PawnArchetype,bWriteable=false,MaxVars=1)
	VariableLinks(2)=(ExpectedType=class'SeqVar_Object',LinkDesc="Team",bWriteable=false,MaxVars=1)
	VariableLinks(3)=(ExpectedType=class'BamSeqVar_AIAction',LinkDesc="Initial Action",bWriteable=false,MaxVars=1)
	VariableLinks(4)=(ExpectedType=class'SeqVar_Object',LinkDesc="Spawned Pawn",PropertyName=OutputPawn,bWriteable=true,MaxVars=1)
}