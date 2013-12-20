class BamAIAction_Delay extends BamAIAction;

var() bool bStopMovement;

var() bool bWasMoving;

function OnBegin()
{
	if( bStopMovement && Manager.Controller.Is_Moving() )
	{
		bWasMoving = true;
		Manager.Controller.Begin_Idle();
	}
}

function OnEnd()
{
	if( Manager.Front() == self && bWasMoving )
	{
		Manager.Controller.Begin_Moving();
	}
}

static function BamAIAction_Delay Create(float inDuration, optional array<BamAIActionLane> inLanes, optional bool stopMovement = false, optional bool wasMoving = false)
{
	local BamAIAction_Delay act;

	act = new default.class;

	act.bStopMovement = stopMovement;
	act.bWasMoving = wasMoving;
	act.SetDuration(inDuration);
	act.SetLanes(inLanes);

	return act;
}

DefaultProperties
{
	bIsBlocking=true
	bStopMovement=false
	bWasMoving=false
}