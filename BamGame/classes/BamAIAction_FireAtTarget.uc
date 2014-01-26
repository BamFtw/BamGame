class BamAIAction_FireAtTarget extends BamAIAction_Fire
	dependson(BamAIController)
	noteditinlinenew;

/** Actor to shoot at */
var(Firing) Actor Target;

/** Minimum dot product (between Pawns direction and vector between Target and Pawn) that allows for shooting */
var(Firing) float MinDotToTarget;

/** Flag that tells whether Pawn is facing enemy and can fire */
var bool bCanFire;

/** Whether target is player pawn */
var bool bFiringAtPlayer;

var bool BlockedFiringSlot;

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
			if( BlockedFiringSlot )
			{
				Manager.Game.GameIntensity.TempUnblockFiringSlot();
				BlockedFiringSlot = false;
			}
		
			StopFiring();
			SetTickBreak(0.1);
			return;
		}

		// if target is not in the TeamManagers enemies list set its location in data struct
		if( !Manager.Controller.GetEnemyData(TargetPawn, data) )
		{
			data.LastSeenLocation = TargetPawn.Location;
		}
	}
	else
	{
		// if target is not a Pawn set its location in data struct
		data.LastSeenLocation = Target.Location;
	}

	// if target is not in LOS stop firing
	if( !HasClearLOS(data.LastSeenLocation, data.Pawn) )
	{
		StopFiring();
		return;
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

/** Starts firing */
function bool StartFiring(optional bool bSetTimer = false)
{
	if( !super.StartFiring(bSetTimer) )
	{
		return false;
	}

	if( Target == Manager.WorldInfo.GetALocalPlayerController().Pawn )
	{
		Manager.Game.GameIntensity.StartedFiringAtPlayer(Manager.Controller.Pawn);
		bFiringAtPlayer = true;
	}

	return true;
}

/** Stops firing */
function bool StopFiring(optional bool bSetTimer = false)
{
	super.StopFiring(bSetTimer);

	if( BlockedFiringSlot )
	{
		Manager.Game.GameIntensity.TempUnblockFiringSlot();
		BlockedFiringSlot = false;
	}

	if( bFiringAtPlayer )
	{
		Manager.Game.GameIntensity.BlockFiringSlot(RandRange(0.3,0.9));
		Manager.Game.GameIntensity.StoppedFiringAtPlayer(Manager.Controller.Pawn);
		bFiringAtPlayer = false;
	}

	return true;
}

/** Stops firing and resets controllers view pitch */
function OnEnd()
{
	if( BlockedFiringSlot )
	{
		Manager.Game.GameIntensity.TempUnblockFiringSlot();
		BlockedFiringSlot = false;
	}

	Manager.Game.GameIntensity.BlockFiringSlot(RandRange(0.3,0.9));

	StopFiring();
	Manager.Controller.SetDesiredViewRotation(MakeRotator(0, 0, 0));
}

/** Returns whether firing can begin */
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
		if( !IsPawnViableTarget(pwnData[q].Pawn) || !HasClearLOS(pwnData[q].LastSeenLocation, pwnData[q].Pawn) )
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

/** Returns whether pawn given as parameter is viable target to shoot at */
function bool IsPawnViableTarget(Pawn pwn)
{
	// check if pawn belongs to player and GI allows shooting at him
	if( pwn == Manager.WorldInfo.GetALocalPlayerController().Pawn )
	{
		if( Manager.Game.GameIntensity.CanFireAtPlayer() )
		{
			Manager.Game.GameIntensity.TempBlockFiringSlot();
			BlockedFiringSlot = true;
			return true;
		}
		else
		{
			return false;
		}
		
	}

	return pwn != none;
}

/** 
 * Returns whether Pawn has clear line of sight to enemy at the specified location
 * @param enemyLoc - actual Enemy Pawn location is not taken into account instead this one is used
 * @param enemy - enemy pawn used for calculating eye height
 * @return whether Pawn has clear line of sight to enemy at the specified location
 */
function bool HasClearLOS(Vector enemyLoc, Pawn enemy)
{
	local Vector HitLocation, HitNormal, eyeLoc;
	local Rotator rot;
	local Actor a1, a2;

	Manager.Controller.GetActorEyesViewPoint(eyeLoc, rot);

	a1 = Manager.Controller.Pawn.Trace(HitLocation, HitNormal, enemyLoc, eyeLoc, true, , , class'Actor'.const.TRACEFLAG_Bullet);

	if( enemy != none )
	{
		a2 = Manager.Controller.Pawn.Trace(HitLocation, HitNormal, enemyLoc + vect(0,0,1) * enemy.EyeHeight, enemyLoc, true, , , class'Actor'.const.TRACEFLAG_Bullet);
	}

	return (a1 == none || a1 == enemy) && (a2 == none || a2 == enemy);
}






static function BamAIAction_FireAtTarget Create_FireAtTarget(optional Actor inTarget = none, optional float inDuration = 0, optional int inFireMode = default.WeaponFireMode)
{
	local BamAIAction_FireAtTarget action;
	action = new class'BamAIAction_FireAtTarget';
	action.Target = inTarget;
	action.WeaponFireMode = inFireMode;
	action.SetDuration(inDuration);
	return action;
}

DefaultProperties
{
	bIsBlocking=true
	Lanes=(class'BamAIActionLane_Firing')

	MinDotToTarget=0.9
	bFiringAtPlayer=false
	WeaponFireMode=0
}
