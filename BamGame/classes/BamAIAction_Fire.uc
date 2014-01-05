class BamAIAction_Fire extends BamAIAction;

/** Time at which firing break should end */
var float FiringBreakEndTime;
/** Time at which firing should end */
var float FiringEndTime;

/** Whether Pawn is currently firing */
var bool bIsFiring;

/** Which weapons mode should be used while firing */
var(Firing) int WeaponFireMode;

/** Min time between bursts */
var(Firing) float MinFireBreak;
/** Max time between bursts */
var(Firing) float MaxFireBreak;

/** Min burst duration */
var(Firing) float MinFireDuration;
/** Max burst duration */
var(Firing) float MaxFireDuration;


function OnBegin()
{
	StopFiring(false);
}

function OnBlocked()
{
	// blocking action should stop firing in its OnBegin if needed
	// StopFiring(false);
}

function OnEnd()
{
	StopFiring(false);
}

function Tick(float DeltaTime)
{
	if( bIsFiring )
	{
		if( FiringEndTime <= Manager.WorldInfo.TimeSeconds )
		{
			StopFiring(true);
		}
	}
	else
	{
		if( FiringBreakEndTime <= Manager.WorldInfo.TimeSeconds )
		{
			StartFiring(true);
		}
	}
}

function bool StartFiring(optional bool bSetTimer = false)
{
	if( !CanStartFiring() )
	{
		return false;
	}

	Manager.Controller.Pawn.StartFire(WeaponFireMode);
	bIsFiring = true;

	if( bSetTimer )
	{
		FiringEndTime = Manager.WorldInfo.TimeSeconds + RandRange(MinFireDuration, MaxFireDuration);
	}

	return true;
}

function bool StopFiring(optional bool bSetTimer = false)
{
	Manager.Controller.Pawn.StopFire(WeaponFireMode);
	bIsFiring = false;

	if( bSetTimer )
	{
		FiringBreakEndTime = Manager.WorldInfo.TimeSeconds + RandRange(MinFireBreak, MaxFireBreak);
	}

	return true;
}

function bool CanStartFiring()
{
	return true;
}


static function BamAIAction_Fire Create_Fire(optional float inDuration = -1, optional int inFireMode = default.WeaponFireMode)
{
	local BamAIAction_Fire action;

	action = new class'BamAIAction_Fire';
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
	Lanes=(class'BamAIActionLane_Firing')

	WeaponFireMode=0

	MinFireBreak=0.25
	MaxFireBreak=1.0
	MinFireDuration=0.5
	MaxFireDuration=1.0
}