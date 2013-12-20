class BamAIAction_AdvanceOnEnemies extends BamAIAction
	editinlinenew;

var float FireTimer;
var() bool bRun;

var(Firing) bool bFireDuringWalk;
var(Firing) float MinFireInterval;
var(Firing) float MaxFireInterval;
var(Firing) float MinFireDuration;
var(Firing) float MaxFireDuration;

event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	FireTimer -= DeltaTime;

	if( bFireDuringWalk && !bRun && FireTimer <= 0 )
	{
		ResetFireTimer();
		Manager.InsertBefore(class'BamAIAction_FireAtTarget'.static.Create(, RandRange(MinFireDuration, MaxFireDuration)), self);
	}
}

function OnBegin()
{
	local array<Vector> EnemyLocations;

	if( !Manager.Controller.IsInCombat() )
	{
		`trace("Controller is not in combat", `yellow);
		bIsFinished = true;
		return;
	}

	EnemyLocations = Manager.Controller.GetEnemyLocations();

	if( EnemyLocations.Length == 0 )
	{
		`trace("Controller has no enemies", `yellow);
		bIsFinished = true;
		return;
	}

	Manager.Controller.SetFinalDestination(EnemyLocations[Rand(EnemyLocations.Length)], Manager.Controller.Pawn.GetCollisionRadius() * 5.0);
	Manager.Controller.Pawn.SetWalking(bRun);
	Manager.Controller.Begin_Moving();
	Manager.Controller.Subscribe(BSE_FinalDestinationReached, FinalDestinationReached);

	ResetFireTimer();
}

function OnBlocked()
{
	bIsFinished = true;
	Manager.Controller.UnSubscribe(BSE_FinalDestinationReached, FinalDestinationReached);
}

function OnEnd()
{
	if( !IsBlocked() )
		Manager.Controller.Begin_Idle();
}




function ResetFireTimer()
{
	FireTimer = RandRange(MinFireInterval, MaxFireInterval);
}


function FinalDestinationReached(BamSubscriberParameters params)
{
	if( bIsBlocked )
		return;

	Manager.Controller.Begin_Idle();
	bIsFinished=true;
}


DefaultProperties
{
	bIsBlocking=true
	bBlockAllLanes=false
	Lanes=(Lane_Moving)

	Duration=4.0

	bRun=false

	bFireDuringWalk=true
	MinFireInterval=0.8
	MaxFireInterval=2.0
	MinFireDuration=0.6
	MaxFireDuration=1.0

}