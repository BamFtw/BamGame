class BamAIAction_Idle extends BamAIAction;


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

static function BamAIAction_Idle Create_Idle(float inDuration, optional array<BamAIActionLane> inLanes, optional bool bSetLanes = false, optional bool stopMovement = false, optional bool wasMoving = false)
{
	local BamAIAction_Idle act;

	act = new class'BamAIAction_Idle';

	act.bStopMovement = stopMovement;
	act.bWasMoving = wasMoving;
	act.SetDuration(inDuration);
	
	if( bSetLanes )
	{
		act.SetLanes(inLanes);
	}

	return act;
}

DefaultProperties
{
	bIsBlocking=true
	bBlockAllLanes=false
	bStopMovement=false
	bWasMoving=false
	Lanes=(Lane_Moving)
	Duration=0
}
