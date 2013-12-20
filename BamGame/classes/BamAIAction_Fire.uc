class BamAIAction_Fire extends BamAIAction;

function OnBegin()
{
	SetDuration(RandRange(0.6, 2.0));
	Manager.Controller.Pawn.StartFire(0);
	Manager.Controller.Begin_Idle();
}

function OnBlocked()
{
	Manager.Controller.Pawn.StopFire(0);
}

function OnEnd()
{
	Manager.Controller.Pawn.StopFire(0);
}

function Tick(float DeltaTime)
{
	if( class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().Pawn != none )
		Manager.Controller.Pawn.SetDesiredRotation(Rotator(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().Pawn.Location - Manager.Controller.Pawn.Location));
}

DefaultProperties
{
	Duration=2.0
	bIsBlocking=true
	Lanes=(Lane_Firing,Lane_Moving)
}