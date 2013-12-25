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

	// make sure target is correct
	if( Target == none )
	{
		if( !FindGoodTarget() )
		{
			`trace("Target is none, couldn't find new one", `red);
			StopFiring();
			Finish();
			return;
		}
	}

	TargetPawn = Pawn(Target);

	// if target is a pawn check if it is alive
	if( TargetPawn != none )
	{
		if( !TargetPawn.IsAliveAndWell() && !FindGoodTarget() )
		{
			`trace("Target Pawn is bad, couldn't find new one", `red);
			StopFiring();
			Finish();
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
	toTargetDir.Z = 0;

	// turn pawn toward target
	Manager.Controller.Pawn.SetDesiredRotation(Rotator(Normal(toTargetDir)));

	// check dot between pawns rotation and targets location
	bCanFire = (Vector(Manager.Controller.Pawn.Rotation) dot toTargetDir) >= MinDotToTarget;

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
	local Pawn lastSeenPwn;
	local float lastSeenPwnTime;
	local array<BamHostilePawnData> pwnData;

	if( !Manager.Controller.HasEnemies() )
	{
		`trace(Manager.Controller @ "has no enemies", `red);
		return false;
	}

	lastSeenPwnTime = -999999.0;

	pwnData = Manager.Controller.Team.EnemyData;

	for(q = 0; q < pwnData.Length; ++q)
	{
		// find the last seen pawn
		if( pwnData[q].LastSeenTime > lastSeenPwnTime )
		{
			lastSeenPwnTime = pwnData[q].LastSeenTime;	
			lastSeenPwn = pwnData[q].Pawn;
		}

		// check if Pawn has clear line of sight to the target if not remove it from the list
		if( !Manager.Controller.Pawn.FastTrace(pwnData[q].LastSeenLocation) )
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

	// if there are no viable targets select last seen one
	if( lastSeenPwn != none )
	{
		`trace("Choosing last seen target", `yellow);
		Target = lastSeenPwn;
		return true;
	}

	`trace(Manager.Controller @ "fail", `red);
	return false;
}


static function BamAIAction_FireAtTarget Create(optional Actor inTarget, optional float inDuration = -1)
{
	local BamAIAction_FireAtTarget action;

	action = new default.class;
	action.Target = inTarget;

	if( inDuration >= 0 )
		action.SetDuration(inDuration);

	return action;
}

DefaultProperties
{
	bIsBlocking=true
	Lanes=(Lane_Firing)

	MinDotToTarget=0.9
}