class BamAIAction_AdvanceOnEnemies extends BamAIAction
	editinlinenew;

/** Action responsible for firing */
var BamAIAction_FireAtTarget FiringAction;

/** Whether Pawn should run */
var() bool bRun;

/** Whether pawn should fire while moving */
var() bool bFireDuringWalk;

/** Miniumum duration of this action */
var() float MinDuration;

/** Maximum duration of this action */
var() float MaxDuration;

/** Selects target to move to and creates firing action if needed */
function OnBegin()
{
	local array<Vector> EnemyLocations;

	if( !Manager.Controller.IsInCombat() )
	{
		`trace("Controller is not in combat", `yellow);
		Finish();
		return;
	}

	// get enemy location
	EnemyLocations = Manager.Controller.GetEnemyLocations();

	if( EnemyLocations.Length == 0 )
	{
		`trace("Controller has no enemies", `yellow);
		Finish();
		return;
	}

	// if pawn shouldnt run and should fire create firing action
	if( !bRun && bFireDuringWalk )
	{
		FiringAction = class'BamAIAction_FireAtTarget'.static.Create();

		if( FiringAction != none )
		{
			Manager.InsertBefore(FiringAction, self);
		}
	}

	SetDuration(RandRange(MinDuration, MaxDuration));
	 
	// move to randomly selected enemy
	Manager.Controller.InitializeMove(EnemyLocations[Rand(EnemyLocations.Length)], Manager.Controller.Pawn.GetCollisionRadius() * 4.0, bRun, FinalDestinationReached);
}

function OnBlocked()
{
	Finish();
	Manager.Controller.UnSubscribe(BSE_FinalDestinationReached, FinalDestinationReached);
}

function OnEnd()
{
	// finish firing action
	if( FiringAction != none )
	{
		FiringAction.Finish();
	}

	// stop moving
	if( !IsBlocked() )
	{
		Manager.Controller.Begin_Idle();
	}
}




function FinalDestinationReached(BamSubscriberParameters params)
{
	if( bIsBlocked )
		return;

	Manager.Controller.Begin_Idle();
	// delay end
	SetDuration(RandRange(1.0, 2.0));
}


DefaultProperties
{
	bIsBlocking=true
	Lanes=(Lane_Moving)

	bRun=false
	bFireDuringWalk=true

	MinDuration=4.0
	MaxDuration=6.0
}