class BamAIAction_CoverInit extends BamAIAction_Cover;


function OnBegin()
{
	super.OnBegin();

	if( CoverData == none )
		CoverData = new class'BamCoverActionData';

	// if FailedPopOutThreashold has been reached block covering and use replacement action
	if( CoverData.FailedPopOutCount >= CoverData.FailedPopOutThreashold )
	{
		Manager.BlockActionClass(class'BamAIAction_Cover', CoverData.FailedSearchCoverBlockDuration);

		// create replacement action from archetype
		if( CoverData.FailedPopOutReplacementAction.Archetype != none )
		{
			if( Manager.IsClassBlocked(CoverData.FailedPopOutReplacementAction.Archetype.Class) )
			{
				`trace("FailedPopOutReplacementAction.Archetype class (" $  CoverData.FailedPopOutReplacementAction.Class $ ") is blocked.", `yellow);
			}

			Manager.PushFront(new CoverData.FailedPopOutReplacementAction.Archetype.Class(CoverData.FailedPopOutReplacementAction.Archetype));
		}
		// create replacement action from class
		else if( CoverData.FailedPopOutReplacementAction.Class != none )
		{
			if( Manager.IsClassBlocked(CoverData.FailedPopOutReplacementAction.Class) )
			{
				`trace("FailedPopOutReplacementAction class (" $ CoverData.FailedPopOutReplacementAction.Class $ ") is blocked", `yellow);
			}

			Manager.PushFront(new CoverData.FailedPopOutReplacementAction.Class);
		}
		else
		{
			`trace("FailedPopOutReplacementAction is not set", `yellow);
		}

		bIsFinished = true;
		return;
	}

	FindBestCover(CoverData.MaxCoverSearchDistance);

	if( CoverData.Cover == none )
	{
		// Manager.BlockActionClass(class'BamAIAction_Cover', FailedCoverBlockDuration);
		Manager.BlockActionClass(class'BamAIAction_Cover', CoverData.FailedSearchCoverBlockDuration);
		`trace("cover not found for" @ Manager.Controller, `red);
		
		if( CoverData.FailedCoverSearchReplacementAction.Archetype != none )
		{
			Manager.PushFront(new CoverData.FailedCoverSearchReplacementAction.Archetype.class(CoverData.FailedCoverSearchReplacementAction.Archetype));
		}
		else if( CoverData.FailedCoverSearchReplacementAction.Class != none )
		{
			Manager.PushFront(new CoverData.FailedCoverSearchReplacementAction.class);
		}

		bIsFinished = true;
		return;
	}
	
	Manager.Controller.ClaimCover(CoverData.Cover);

	Manager.PushFront(class'BamAIAction_CoverMoveTo'.static.Create(CoverData));
	bIsFinished = true;
}




static function BamAIAction_CoverInit Create(optional BamCoverActionData CovData)
{
	local BamAIAction_CoverInit action;
	action = new default.class;
	action.CoverData = CovData;
	return action;
}



DefaultProperties
{
	bIsBlocking=true
	bBlockAllLanes=true
}