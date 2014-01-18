class BamAIAction_Investigate extends BamAIAction
	noteditinlinenew;

/** Location to investigate */
var() Vector SuspiciousLocation;

/** Point near SuspiciousLocation to move to */
var Vector MoveLocation;

/** Max distance from SuspiciouseLocation */
var() float Radius;



function OnBegin()
{
	local array<Vector> out_ValidPositions;

	if( SuspiciousLocation == vect(0, 0, 0) )
	{
		`trace("Invalid SuspiciousLocation", `red);
		return;
	}

	Manager.Controller.NavigationHandle.GetValidPositionsForBox(SuspiciousLocation, Radius, Manager.Controller.Pawn.GetCollisionExtent(), true, out_ValidPositions);

	if( out_ValidPositions.Length == 0 )
	{
		MoveLocation = SuspiciousLocation;
	}
	else
	{
		MoveLocation = out_ValidPositions[Rand(out_ValidPositions.Length)];
	}

	Manager.BlockActionClass(class'BamAIAction_ReplenishNeeds', 9999999, true);

	Manager.Controller.InitializeMove(MoveLocation, , true, FinalDestinationReached);
}

function OnBlocked()
{
	Finish();
}

function OnEnd()
{
	Manager.UnBlockActionClass(class'BamAIAction_ReplenishNeeds');
}

function FinalDestinationReached(BamSubscriberParameters params)
{
	Manager.Controller.Pawn.SetDesiredRotation(Rotator(SuspiciousLocation - Manager.Controller.Pawn.Location));

	SetDuration(1.0);
}




static function BamAIAction_Investigate Create_Investigate(Vector inSuspiciousLocation)
{
	local BamAIAction_Investigate action;
	action = new class'BamAIAction_Investigate';
	action.SuspiciousLocation = inSuspiciousLocation;
	return action;
}


DefaultProperties
{
	bIsBlocking=true
	Lanes=(class'BamAIActionLane_Moving')
}