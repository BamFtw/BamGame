class BamAIAction_CoverIdle extends BamAIAction_Cover
	dependson(BamAnimNode_Covering)
	noteditinlinenew;


function OnBegin()
{
	super.OnBegin();

	if( CoverData.Cover == none )
	{
		Finish();
		return;
	}

	SetDuration(CoverData.GetCoverIdleDuration());

	Manager.Controller.Begin_Idle();
	Manager.Controller.Pawn.SetDesiredRotation(CoverData.Cover.Rotation, true);
	Manager.Controller.SetRotation(MakeRotator(0, CoverData.Cover.Rotation.Yaw, 0));
	Manager.Controller.BPawn.SetDesiredLocation(CoverData.Cover.Location);

	Manager.Controller.BPawn.CharacterCoverState.SetState(SelectCoverState());
}

function OnEnd()
{
	Manager.Controller.Pawn.LockDesiredRotation(false);
	Manager.Controller.BPawn.CharacterCoverState.SetState(0);
	
	if( !bIsBlocked )
		Manager.PushFront(class'BamAIAction_CoverPopOut'.static.Create(CoverData));
}

function OnBlocked()
{
	Manager.Controller.Pawn.LockDesiredRotation(false);
	Manager.Controller.BPawn.CharacterCoverState.SetState(0);
	Finish();
}



function BamAnimNodeCoveringState SelectCoverState()
{
	if( BamActor_Cover_Standing(CoverData.Cover) != none )
	{
		if( CoverData.Cover.CanPopLeft() && CoverData.Cover.CanPopRight() )
			return (RandRange(0, 1) < 0.5 ? CoverState_StandingLeft : CoverState_StandingLeft);

		return (CoverData.Cover.CanPopLeft() ? CoverState_StandingLeft : CoverState_StandingLeft);
	}
	else
	{
		if( CoverData.Cover.CanPopLeft() && CoverData.Cover.CanPopRight() )
			return (RandRange(0, 1) < 0.5 ? CoverState_CrouchingLeft : CoverState_CrouchingLeft);

		return (CoverData.Cover.CanPopLeft() ? CoverState_CrouchingLeft : CoverState_CrouchingLeft);
	}

	return BamAnimNodeCoveringState(Rand(CoverState_MAX));
}


static function BamAIAction_CoverIdle Create(BamCoverActionData CovData, optional float minTime = -1, optional float maxTime = -1)
{
	local BamAIAction_CoverIdle act;
	act = new default.class;
	act.CoverData = CovData;
	return act;
}

DefaultProperties
{
	bIsBlocking=true
	bBlockAllLanes=true
}