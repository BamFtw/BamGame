class BamAIAction_Fire extends BamAIAction
	noteditinlinenew;

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
	StartFiring();
	FiringTimeLeft = RandRange(MinFireDuration, MaxFireDuration);
}

function OnBlocked()
{
	StopFiring();
}

function OnEnd()
{
	if( !IsBlocked() )
	{
		StopFiring();
	}
}

function Tick(float DeltaTime)
{
	if( bIsFiring )
	{
		FiringTimeLeft -= DeltaTime;
		if( FiringTimeLeft <= 0 )
		{
			StopFiring();
			FiringBreakTimeLeft = RandRange(MinFireBreak, MaxFireBreak);
		}
	}
	else
	{
		FiringBreakTimeLeft -= DeltaTime;
		if( FiringBreakTimeLeft <= 0 )
		{
			StartFiring();
			FiringTimeLeft = RandRange(MinFireDuration, MaxFireDuration);
		}
	}
}

function StopFiring()
{
	Manager.Controller.Pawn.StopFire(WeaponFireMode);
	bIsFiring = false;
}

function StartFiring()
{
	Manager.Controller.Pawn.StartFire(WeaponFireMode);
	bIsFiring = false;
}


DefaultProperties
{
	bIsBlocking=true
	Lanes=(Lane_Firing,Lane_Moving)

	WeaponFireMode=0

	MinFireBreak=0.25
	MaxFireBreak=1.0
	MinFireDuration=0.5
	MaxFireDuration=1.0
}