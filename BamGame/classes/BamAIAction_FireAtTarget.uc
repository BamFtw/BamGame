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
			`trace("StopFire 1", `green);
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
			`trace("StopFire 2", `green);
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

	// if( !HasClearLOS(data.LastSeenLocation, data.Pawn) )
	// {
	// 	`trace("StopFire 3", `green);
	// 	StopFiring();
	// 	return;
	// }

	// turn pawn toward target
	rot = Rotator(Normal(toTargetDir));
	Manager.Controller.Pawn.SetDesiredRotation(rot);
	Manager.Controller.SetDesiredViewRotation(rot);

	// check dot between pawns rotation and targets location
	bCanFire = (Vector(Manager.Controller.GetViewRotation()) dot toTargetDir >= MinDotToTarget);

	super.Tick(DeltaTime);
}


function OnEnd()
{
	super.OnEnd();
	Manager.Controller.SetDesiredViewRotation(MakeRotator(0, 0, 0));
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
		// if( !Manager.Controller.Pawn.FastTrace(pwnData[q].LastSeenLocation, loc, , true) && 
		// 	!Manager.Controller.Pawn.FastTrace(pwnData[q].LastSeenLocation + vect(0,0,1) * pwnData[q].Pawn.EyeHeight, loc, , true) )
		// 	
		
		// Manager.Controller.DrawDebugLine(pwnData[q].LastSeenLocation + vect(0,0,1) * pwnData[q].Pawn.EyeHeight, loc, 0, 255, 0, true);

		if( !HasClearLOS(pwnData[q].LastSeenLocation, pwnData[q].Pawn) )
		{
			pwnData.Remove(q--, 1);
		}

		// Manager.AILog("Firing check actors:");
		// Manager.AILog("     -" @ a1);
		// Manager.AILog("     -" @ a2);
	}

	`trace(Manager.Controller.Pawn @ pwnData.length, `purple);

	// randomly select one of viable targets
	if( pwnData.length > 0 )
	{
		Target = pwnData[Rand(pwnData.Length)].Pawn;
		return true;
	}

	return false;
}

function bool HasClearLOS(Vector enemyLoc, Pawn enemy)
{
	local Vector HitLocation, HitNormal, eyeLoc;
	local Rotator rot;
	local Actor a1, a2;

	Manager.Controller.GetActorEyesViewPoint(eyeLoc, rot);

	a1 = Manager.Controller.Pawn.Trace(HitLocation, HitNormal, enemyLoc, eyeLoc, true, , , class'Actor'.const.TRACEFLAG_Bullet);
	// if( a1 != none && a1 != target )
	// {
	// 	Manager.Controller.DrawDebugLine(HitLocation, eyeLoc, 255, 0, 0, true);
	// }

	a2 = Manager.Controller.Pawn.Trace(HitLocation, HitNormal, enemyLoc + vect(0,0,1) * enemy.EyeHeight, enemyLoc, true, , , class'Actor'.const.TRACEFLAG_Bullet);
	// if( a2 != none && a2 != target )
	// {
	// 	Manager.Controller.DrawDebugLine(HitLocation, eyeLoc, 0, 255, 0, true);
	// }

	return (a1 == none || a1 == target) && (a2 == none || a2 == target);
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
