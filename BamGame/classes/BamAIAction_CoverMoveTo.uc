class BamAIAction_CoverMoveTo extends BamAIAction_Cover
	noteditinlinenew;

function Tick(float DeltaTime)
{
	if( !Manager.Controller.Is_Moving() )
	{
		Manager.Controller.Begin_Moving();
	}
}

function OnBegin()
{
	super.OnBegin();
	
	if( CoverData.Cover == none )
	{
		Finish();
		return;
	}

	Manager.Controller.Pawn.SetWalking(true);

	Manager.Controller.SetFinalDestination(CoverData.Cover.Location);
	Manager.Controller.Begin_Moving();
	Manager.Controller.Subscribe(BSE_FinalDestinationReached, FinalDestinationReached);
}

function OnEnd()
{
	Manager.Controller.UnSubscribe(BSE_FinalDestinationReached, FinalDestinationReached);
}

function OnUnBlocked()
{
	Manager.Controller.Subscribe(BSE_FinalDestinationReached, FinalDestinationReached);
}

function OnBlocked()
{
	Manager.Controller.UnSubscribe(BSE_FinalDestinationReached, FinalDestinationReached);
}

function FinalDestinationReached(BamSubscriberParameters params)
{
	if( bIsBlocked )
		return;

	Manager.PushFront(class'BamAIAction_CoverIdle'.static.Create(CoverData));
	Finish();
}




static function BamAIAction_CoverMoveTo Create(BamCoverActionData CovData)
{
	local BamAIAction_CoverMoveTo act;
	act = new default.class;

	// act.Cover = cov;
	act.CoverData = CovData;

	return act;
}



DefaultProperties
{
	bIsBlocking=true
	Lanes=(Lane_Covering,Lane_Moving)
}