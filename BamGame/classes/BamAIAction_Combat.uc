class BamAIAction_Combat extends BamAIAction
	hidecategories(BamAIAction)
	editinlinenew;

var BamAIAction_CombatBlocker BlockerAction;

var float LastCoverTryTime, LastFollowPlayerTime;



function Tick(float DeltaTime)
{
	if( Manager.Controller == none )
	{
		return;
	}

	if( !Manager.Controller.HasEnemies() )
	{
		`trace("Should end", `purple);
		bIsFinished = true;
		return;
	}

	if( Manager.Front() == self )
	{
		if( (class'WorldInfo'.static.GetWorldInfo().TimeSeconds - LastCoverTryTime) >= 5.0 )
		{
			LastCoverTryTime = class'WorldInfo'.static.GetWorldInfo().TimeSeconds;
			Manager.PushFront(class'BamAIAction_CoverInit'.static.Create());
		}
	}

	/**if( Manager.Front() == self )
	{
		if( (class'WorldInfo'.static.GetWorldInfo().TimeSeconds - LastFollowPlayerTime) >= 5.0 )
		{
			LastFollowPlayerTime = class'WorldInfo'.static.GetWorldInfo().TimeSeconds;
			Manager.PushFront(class'BamAIAction_FollowPlayer'.static.Create());
		}
	}*/
}

function OnBegin()
{
	BlockerAction = class'BamAIAction_CombatBlocker'.static.Create();
	Manager.InsertAfter(BlockerAction, self);
}

function OnEnd()
{
	local int q;
	`trace("Running on END FOR COMBAT ------------!!!!!!!!!!!!!!!!", `purple);
	
	for(q= 0; q< Manager.Actions.Length; ++q)
	{
		`log("   -" @ q @ Manager.Actions[q]);
	}

	`log("\n\n");

	while( Manager.Front() != self )
	{
		`log("Removing action" @ Manager.Front());
		Manager.Remove(Manager.Front());
	}

	Manager.Remove(blockerAction);
}

static function BamAIAction_Combat Create()
{
	local BamAIAction_Combat action;
	action = new default.class;
	return action;
}

DefaultProperties
{
	bIsBlocking=false
	bBlockAllLanes=false
	Duration=0

	LastCoverTryTime=-999.0
	LastFollowPlayerTime=-999.0
}