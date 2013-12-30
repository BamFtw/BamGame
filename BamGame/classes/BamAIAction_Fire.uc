class BamAIAction_Fire extends BamAIAction;

/** Time of firing break left */
var float FiringBreakTimeLeft;
/** Time of burst left */
var float FiringTimeLeft;
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
		FiringTimeLeft -= DeltaTime;
		if( FiringTimeLeft <= 0 )
		{
			StopFiring(true);
		}
	}
	else
	{
		FiringBreakTimeLeft -= DeltaTime;
		if( FiringBreakTimeLeft <= 0 )
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
		FiringTimeLeft = RandRange(MinFireDuration, MaxFireDuration);
	}

	return true;
}

function bool StopFiring(optional bool bSetTimer = false)
{
	Manager.Controller.Pawn.StopFire(WeaponFireMode);
	bIsFiring = false;

	if( bSetTimer )
	{
		FiringBreakTimeLeft = RandRange(MinFireBreak, MaxFireBreak);
	}

	return true;
}

function bool CanStartFiring()
{
	return true;
}


static function BamAIAction_Fire Create_Fire(optional float inDuration = -1, optional int inFireMode = 0)
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
	Lanes=(Lane_Firing)

	FiringBreakTimeLeft=0
	FiringTimeLeft=0

	WeaponFireMode=0

	MinFireBreak=0.25
	MaxFireBreak=1.0
	MinFireDuration=0.5
	MaxFireDuration=1.0
}