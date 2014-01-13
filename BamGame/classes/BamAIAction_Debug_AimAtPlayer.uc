class BamAIAction_Debug_AimAtPlayer extends BamAIAction
	editinlinenew;

/** Updates rotation of the AIPawn so it would aim at players Pawn */
event Tick(float DeltaTime)
{
	local Rotator rot;

	if( Manager.WorldInfo.GetALocalPlayerController().Pawn == none )
	{
		return;
	}

 	rot = Rotator(Manager.WorldInfo.GetALocalPlayerController().Pawn.Location - Manager.Controller.Pawn.Location);

	Manager.Controller.Pawn.SetDesiredRotation(rot);
	Manager.Controller.SetDesiredViewRotation(rot);
}

DefaultProperties
{
	bIsBlocking=true
	bBlockAllLanes=true
}