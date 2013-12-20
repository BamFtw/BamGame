class BamAIAction_FireAtTarget extends BamAIAction
	noteditinlinenew
	dependson(BamAIController);

var() Pawn Target;

var bool bFiring;

var() bool bBurstFire;

var float BurstTimeLeft;

var() float MinBurstDuration;
var() float MaxBurstDuration;

function Tick(float DeltaTime)
{
	local BamHostilePawnData data;
	local Vector toTargetDir;

	if( (Target == none || !Target.IsAliveAndWell()) && !FindGoodTarget() )
	{
		Finish();
		return;
	}

	if( !Manager.Controller.GetEnemyData(Target, data) || !data.Pawn.IsAliveAndWell() )
	{
		Finish();
		return;
	}

	toTargetDir = data.LastSeenLocation - Manager.Controller.Pawn.Location;
	toTargetDir.Z = 0;
	toTargetDir = Normal(toTargetDir);

	Manager.Controller.Pawn.SetDesiredRotation(Rotator(toTargetDir));

	if( !bFiring && Vector(Manager.Controller.Pawn.Rotation) dot toTargetDir > 0.9 )
	{
		bFiring = true;
		Manager.Controller.Pawn.StartFire(0);
	}
	else if( bFiring )
	{
		bFiring = false;
		Manager.Controller.Pawn.StopFire(0);
	}
}

function OnBlocked()
{
	Finish();
}

function OnEnd()
{
	Finish();
	
	if( Manager.Controller != none && Manager.Controller.Pawn != none && !IsBlocked() )
	{
		bFiring = false;
		Manager.Controller.Pawn.StopFire(0);
	}
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






static function BamAIAction_FireAtTarget Create(optional Pawn inTarget, optional float inDuration = -1)
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
	bFiring=false
	Duration=1.5
}