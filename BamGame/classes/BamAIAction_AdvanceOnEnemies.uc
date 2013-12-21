class BamAIAction_AdvanceOnEnemies extends BamAIAction
	editinlinenew;

var BamAIAction_FireAtTarget FiringAction;

var() bool bRun;

var() bool bFireDuringWalk;

var() float MinDuration;
var() float MaxDuration;

function OnBegin()
{
	local array<Vector> EnemyLocations;

	if( !Manager.Controller.IsInCombat() )
	{
		`trace("Controller is not in combat", `yellow);
		Finish();
		return;
	}

	EnemyLocations = Manager.Controller.GetEnemyLocations();

	if( EnemyLocations.Length == 0 )
	{
		`trace("Controller has no enemies", `yellow);
		Finish();
		return;
	}

	if( !bRun && bFireDuringWalk )
	{
		FiringAction = class'BamAIAction_FireAtTarget'.static.Create();

		if( FiringAction != none )
		{
			Manager.InsertBefore(FiringAction, self);
		}
	}

	SetDuration(RandRange(MinDuration, MaxDuration));

	Manager.Controller.SetFinalDestination(EnemyLocations[Rand(EnemyLocations.Length)], Manager.Controller.Pawn.GetCollisionRadius() * 4.0);
	Manager.Controller.Pawn.SetWalking(bRun);
	Manager.Controller.Begin_Moving();
	Manager.Controller.Subscribe(BSE_FinalDestinationReached, FinalDestinationReached);
}

function OnBlocked()
{
	Finish();
	Manager.Controller.UnSubscribe(BSE_FinalDestinationReached, FinalDestinationReached);
}

function OnEnd()
{
	if( FiringAction != none )
	{
		FiringAction.Finish();
	}

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
	SetDuration(RandRange(1.0, 2.0));
}


DefaultProperties
{
	bIsBlocking=true
	Lanes=(Lane_Moving)

	Duration=4.0

	bRun=false
	bFireDuringWalk=true

	MinDuration=4.0
	MaxDuration=6.0
}