class BamAIAction_Fire extends BamAIAction;


var float FiringBreakTimeLeft;

var float FiringTimeLeft;

var bool bIsFiring;


var(Firing) int WeaponFireMode;

var(Firing) float MinFireBreak;
var(Firing) float MaxFireBreak;

var(Firing) float MinFireDuration;
var(Firing) float MaxFireDuration;


function OnBegin()
{
	StopFiring(false);
}

function OnBlocked()
{
	// blocking action should stop firing if needed
	// StopFiring(false);
}

function OnEnd()
{
	/**local int q;
	if( IsBlocked() )
	{
		`trace("Cant stop firing, blocked", `red);
		for(q = 0; q < Manager.Actions.Length; ++q)
		{
			`log(Manager.Actions[q]);
		}
	}*/

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