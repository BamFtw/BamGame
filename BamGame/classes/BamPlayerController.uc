class BamPlayerController extends GamePlayerController;



exec function Crouch()
{

}


simulated exec function Duck()
{
	if( Pawn == none )
		return;

	Pawn.ShouldCrouch(!Pawn.bIsCrouched);
}

simulated exec function UnDuck()
{
	//Pawn.ShouldCrouch(false);
}

exec function DebugNextPawn()
{
	if( BamHUD(myHUD) != none )
	{
		BamHUD(myHUD).DebugNextPawn();
	}
}


defaultproperties
{
	CameraClass=class'BamCamera'
}