class BamAIAction_FireAtTarget extends BamAIAction_Fire
	dependson(BamAIController);

/** Actor to shoot at */
var(Firing) Actor Target;

/** Minimum dot product (between Pawns direction and vector between Target and Pawn) that allows for shooting */
var(Firing) float MinDotToTarget;

/** Flag that tells whether Pawn is facing enemy and can fire */
var bool bCanFire;


function Tick(float DeltaTime)
{
	local BamHostilePawnData data;
	local Vector toTargetDir;
	local Pawn TargetPawn;
	local Rotator rot;

	// make sure target is correct
	if( Target == none )
	{
		if( !FindGoodTarget() )
		{
			StopFiring();
			SetTickBreak(0.1);
			return;
		}
	}

	TargetPawn = Pawn(Target);

	// if target is a pawn check if it is alive
	if( TargetPawn != none )
	{
		if( !TargetPawn.IsAliveAndWell() && !FindGoodTarget() )
		{
			StopFiring();
			SetTickBreak(0.1);
			return;
		}

		// if target is not in the TeamManagers enemies list set its location in data struct
		if( !Manager.Controller.GetEnemyData(TargetPawn, data) )
		{
			`trace("Could not get enemy (" $ TargetPawn $ ") data", `yellow);
			data.LastSeenLocation = TargetPawn.Location;
		}
	}
	else
	{
		// if target is not a Pawn set its location in data struct
		data.LastSeenLocation = Target.Location;
	}

	// calculate vector from Pawn to target
	toTargetDir = data.LastSeenLocation - Manager.Controller.Pawn.Location;

	// turn pawn toward target
	rot = Rotator(Normal(toTargetDir));
	Manager.Controller.Pawn.SetDesiredRotation(rot);
	Manager.Controller.SetDesiredViewRotation(rot);

	// check dot between pawns rotation and targets location
	bCanFire = (Vector(Manager.Controller.GetViewRotation()) dot toTargetDir >= MinDotToTarget);

	super.Tick(DeltaTime);
}


function bool CanStartFiring()
{
	return bCanFire;
}

/** Finds Pawn from enemies list of the TeamManager and sets it as Target to shoot at */
function bool FindGoodTarget()
{
	local int q;
	local array<BamHostilePawnData> pwnData;
	local Vector loc;
	local Rotator rot;

	if( !Manager.Controller.HasEnemies() )
	{
		`trace(Manager.Controller @ "has no enemies", `red);
		return false;
	}

	pwnData = Manager.Controller.Team.EnemyData;

	Manager.Controller.GetActorEyesViewPoint(loc, rot);

	for(q = 0; q < pwnData.Length; ++q)
	{
		
		// check if Pawn has clear line of sight to the target if not remove it from the list
		if( !Manager.Controller.Pawn.FastTrace(pwnData[q].LastSeenLocation, loc, , true) && 
			!Manager.Controller.Pawn.FastTrace(pwnData[q].LastSeenLocation + vect(0,0,1) * pwnData[q].Pawn.EyeHeight, loc, , true) )
		{
			pwnData.Remove(q--, 1);
		}
	}

	// randomly select one of viable targets
	if( pwnData.length > 0 )
	{
		Target = pwnData[Rand(pwnData.Length)].Pawn;
		return true;
	}

	return false;
}


function OnEnd()
{
	super.OnEnd();
	Manager.Controller.SetDesiredViewRotation(MakeRotator(0, 0, 0));
}

static function BamAIAction_FireAtTarget Create_FireAtTarget(optional Actor inTarget = none, optional float inDuration = -1, optional int inFireMode = 0)
{
	local BamAIAction_FireAtTarget action;

	action = new class'BamAIAction_FireAtTarget';
	action.Target = inTarget;
	action.WeaponFireMode = inFireMode;

	if( inDuration >= 0 )
	{
		action.SetDuration(inDuration);
	}

	return action;
}

DefaultProperties
{
	bIsBlocking=true
	Lanes=(Lane_Firing)

	MinDotToTarget=0.9
}
