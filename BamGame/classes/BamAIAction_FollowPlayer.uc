class BamAIAction_FollowPlayer extends BamAIAction
	hidecategories(BamAIAction);

var BamPawn PlayerPawn;

var() float StartRunDistance;

var() float DesiredDistanceToPlayer;

var() bool bFinishActionOnPlayerReached;

var() bool bDelayOnMoveOut;

var() float MinDelayedMoveOutDelay;

var() float MaxDelayedMoveOutDelay;



function OnBegin()
{
	PlayerPawn = BamPawn(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().Pawn);

	if( PlayerPawn == none || !PlayerPawn.IsAliveAndWell() )
	{
		Finish();
		return;
	}
}

function OnEnd()
{
	Manager.Controller.Begin_Idle();
}



function Tick(float DeltaTime)
{
	if( Manager.Controller == none || Manager.Controller.Pawn == none )
		return;

	if( PlayerPawn == none || !PlayerPawn.IsAliveAndWell() )
	{
		Finish();
		return;
	}

	if( VSize(PlayerPawn.Location - Manager.Controller.Pawn.Location) < DesiredDistanceToPlayer )
	{
		if( bFinishActionOnPlayerReached )
			Finish();

		bDelayOnMoveOut = true;
		Manager.Controller.Begin_Idle();
		return;
	}

	if( bDelayOnMoveOut )
	{
		bDelayOnMoveOut = false;
		Manager.InsertBefore(class'BamAIAction_Delay'.static.Create(RandRange(MinDelayedMoveOutDelay, MaxDelayedMoveOutDelay), GetOccupiedLanes()), self);
		return;
	}

	Manager.Controller.SetFinalDestination(PlayerPawn.Location);
	Manager.Controller.Pawn.SetWalking( VSize(PlayerPawn.Location - Manager.Controller.Pawn.Location) > StartRunDistance );
	Manager.Controller.Begin_Moving();
}


static function BamAIAction_FollowPlayer Create()
{
	local BamAIAction_FollowPlayer action;
	action = new default.class;
	return action;
}

DefaultProperties
{
	bIsBlocking=true
	bIsFinished=false
	Lanes=(Lane_Moving)


	StartRunDistance=256.0
	DesiredDistanceToPlayer=128.0
	bFinishActionOnPlayerReached=false

	MinDelayedMoveOutDelay=0.8
	MaxDelayedMoveOutDelay=1.6

	bDelayOnMoveOut=false
}