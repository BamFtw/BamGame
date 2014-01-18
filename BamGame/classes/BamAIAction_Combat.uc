class BamAIAction_Combat extends BamAIAction
	hidecategories(BamAIAction)
	noteditinlinenew;

var BamAIAction_CombatBlocker BlockerAction;

var float LastCoverTryTime;



function Tick(float DeltaTime)
{
	if( Manager.Controller == none )
	{
		return;
	}

	if( !Manager.Controller.HasEnemies() )
	{
		Finish();
		return;
	}

	if( Manager.Front() == self )
	{
		if( (Manager.WorldInfo.TimeSeconds - LastCoverTryTime) >= 5.0 )
		{
			LastCoverTryTime = Manager.WorldInfo.TimeSeconds;
			Manager.PushFront(class'BamAIAction_CoverInit'.static.Create_CoverInit());
		}
	}
}

function OnBegin()
{
	BlockerAction = class'BamAIAction_CombatBlocker'.static.Create_CombatBlocker();
	Manager.InsertAfter(BlockerAction, self);
}

function OnEnd()
{
	while( Manager.Front() != self && Manager.Front() != none )
	{
		Manager.Front().bIsBlocked = false;
		Manager.Remove(Manager.Front());
	}

	Manager.Remove(blockerAction);
}






static function BamAIAction_Combat Create_Combat()
{
	local BamAIAction_Combat action;
	action = new class'BamAIAction_Combat';
	return action;
}

DefaultProperties
{
	bIsBlocking=false
	bBlockAllLanes=false
	Duration=0

	LastCoverTryTime=-999.0
}