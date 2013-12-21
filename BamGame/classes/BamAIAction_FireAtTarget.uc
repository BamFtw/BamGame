class BamAIAction_FireAtTarget extends BamAIAction_Fire
	noteditinlinenew
	dependson(BamAIController);


var(Firing) Actor Target;

var(Firing) float MinDotToTarget;

var bool bCanFire;

function Tick(float DeltaTime)
{
	local BamHostilePawnData data;
	local Vector toTargetDir;
	local Pawn TargetPawn;

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

		if( !Manager.Controller.GetEnemyData(TargetPawn, data) )
		{
			`trace("Could not get enemy (" $ TargetPawn $ ") data", `yellow);
			data.Pawn = TargetPawn;
			data.LastSeenLocation = TargetPawn.Location;
		}
	}
	else
	{
		data.LastSeenLocation = Target.Location;
	}

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

		// check if Pawn has clear line of sight to the target
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
	MinDotToTarget=0.9
}
