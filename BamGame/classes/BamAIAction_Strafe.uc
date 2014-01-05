class BamAIAction_Strafe extends BamAIAction;

enum BamStrafeDirection
{
	BSD_RandomLeftRight,
	BSD_Random,
	BSD_Left,
	BSD_Right,
	BSD_Back,
	BSD_MAX
};

/**  */
var() BamStrafeDirection StrafeDirection;

/** Distance to strafe */
var() float StrafeDistance;

/** Pawns GroundSpeedPct at the srart of this action */
var float StartingGroundSpeedPct;

function OnBegin()
{
	StartingGroundSpeedPct = Manager.Controller.BPawn.GroundSpeedPct;
	InitStrafeMove();
}

function OnEnd()
{
	Manager.Controller.BPawn.SetGroundSpeedPct(StartingGroundSpeedPct);
	Manager.Controller.UnSubscribe(BSE_FinalDestinationreached, FinalDestinationReached);
}

function OnBlocked()
{
	Finish();
}

function FinalDestinationReached(BamSubscriberParameters params)
{
	InitStrafeMove();
}

function InitStrafeMove()
{
	local Vector StrafeLocation;

	if( !GetStrafeLocation(StrafeDirection, StrafeLocation) )
	{
		`trace("Coulnd not find strafe location", `yellow);
		Finish();
		return;
	}

	Manager.Controller.BPawn.SetGroundSpeedPct(0.4);
	Manager.Controller.InitializeMove(StrafeLocation, 0, false, FinalDestinationReached);
}

function bool GetStrafeLocation(BamStrafeDirection dir, out Vector StrafeLocation)
{
	local array<Vector> viableLocations;
	local Vector tempLocation;

	if( !Manager.Controller.IsInCombat() )
	{
		Finish();
		return false;
	}

	// make sure direction is correct
	if( dir <= 0 || dir > BSD_MAX )
	{
		dir = BSD_RandomLeftRight;
	}

	switch(dir)
	{
		case BSD_Random:
			if( GetStrafeLocation(BSD_Back, tempLocation) )
			{
				viableLocations.AddItem(tempLocation);
			}
			
		case BSD_RandomLeftRight:
			if( GetStrafeLocation(BSD_Left, tempLocation) )
			{
				viableLocations.AddItem(tempLocation);
			}

			if( GetStrafeLocation(BSD_Right, tempLocation) )
			{
				viableLocations.AddItem(tempLocation);
			}
			break;
		
		case BSD_Left:
			if( TraceStrafe(StrafeDistance, MakeRotator(0, 16384, 0), tempLocation) )
			{
				viableLocations.AddItem(tempLocation);
			}

			break;
		case BSD_Right:
			if( TraceStrafe(StrafeDistance, MakeRotator(0, -16384, 0), tempLocation) )
			{
				viableLocations.AddItem(tempLocation);
			}
			
			break;
		case BSD_Back:
			if( TraceStrafe(StrafeDistance, MakeRotator(0, 32768, 0), tempLocation) )
			{
				viableLocations.AddItem(tempLocation);
			}
			break;
		default:
			return false;
	}

	if( viableLocations.Length == 0 )
	{
		return false;
	}

	StrafeLocation = viableLocations[Rand(viableLocations.Length)];
	return true;
}


function bool TraceStrafe(float distance, Rotator dir, out Vector out_Location)
{
	// local Rotator pwnRotation;
	local Vector traceDir, HitLocation, HitNormal, pwnRot;
	local Actor HitActor;

	if( !Manager.Controller.IsInCombat() )
	{
		return false;
	}

	pwnRot = Manager.Controller.GetAverageEnemyLocation() - Manager.Controller.Pawn.Location;

	// pwnRotation = Manager.Controller.Pawn.Rotation;
	// pwnRotation.Pitch = 0;
	// pwnRotation.Roll = 0;
	// traceDir = (Vector(pwnRotation) << dir);
	
	traceDir = (pwnRot << dir);

	out_Location = Manager.Controller.Pawn.Location + traceDir * distance;

	HitActor = Manager.Controller.Pawn.Trace(HitLocation, HitNormal, out_Location, Manager.Controller.Pawn.Location, true, Manager.Controller.Pawn.GetCollisionExtent());
	
	return (HitActor == none && HitLocation == vect(0, 0, 0));
}



static function BamAIAction_Strafe Create_Strafe(optional float inDuration = 0, optional BamStrafeDirection dir = default.StrafeDirection, optional float dist = default.StrafeDistance)
{
	local BamAIAction_Strafe action;
	action = new class'BamAIAction_Strafe';
	action.SetDuration(inDuration);
	action.StrafeDirection = dir;
	return action;
}

DefaultProperties
{
	bIsBlocking=true
	bBlockAllLanes=false
	Lanes=(class'BamAIActionLane_Moving')

	StartingGroundSpeedPct=1.0

	StrafeDistance=100.0
	StrafeDirection=BSD_RandomLeftRight
}