class BamAIAction_VisitPOIs extends BamAIAction;
	//implements(BamInterface_FinalDestinationReached);

/** If set POIClass is ignored, list of the only actors that will be considered for wander location */
var() array<BamActor_POI> SpecificPointsOfInterest;

/** Class of actors that should be considered POI */
var() class<BamActor_POI> POIClass;

/** Cached list of all valid points of interest */
var array<BamActor_POI> CachedPOIList;

/** POI that Pawn is currently heading toward */
var BamActor_POI CurrentPOI;

function OnBegin()
{
	local int q;

	if( POIClass == none && SpecificPointsOfInterest.Length == 0 )
	{
		`trace("POIClass is not set and SpecificPointsOfInterest is empty", `red);
		Finish();
		return;
	}

	// remove invalid POIs
	for(q = 0; q < SpecificPointsOfInterest.Length; ++q)
	{
		if( SpecificPointsOfInterest[q] == none )
		{
			SpecificPointsOfInterest.Remove(q--, 1);
		}
	}

	if( SpecificPointsOfInterest.Length == 0 )
	{
		CachePOIList();

		if( CachedPOIList.Length == 0 )
		{
			`trace("POIClass is not set and SpecificPointsOfInterest is empty", `red);
			Finish();
			return;
		}
	}

	HandlePOISelection();
}

function OnUnblocked()
{
	Manager.Controller.InitializeMove(CurrentPOI.Location, 0, false, FinalDestinationReached);
}

function OnEnd()
{
	Manager.Controller.UnSubscribe(class'BamSubscribableEvent_FinalDestinationReached', FinalDestinationReached);
}

function OnBlocked()
{
	Manager.Controller.UnSubscribe(class'BamSubscribableEvent_FinalDestinationReached', FinalDestinationReached);
}



/** When POI is reached slects next one and waits at the current location for a while */
function FinalDestinationReached(BamSubscriberParameters params)
{
	HandlePOISelection();
	Manager.InsertBefore(class'BamAIAction_Idle'.static.Create_Idle(CurrentPOI.GetWaitTime(), GetOccupiedLanes()), self);
}

/** Selects new POI to visit and initializes movement */
function HandlePOISelection()
{
	if( !SelectNextPOI() )
	{
		`trace("Could not find POI for" @ Manager.Controller, `yellow);
		Finish();
		return;
	}

	Manager.Controller.InitializeMove(CurrentPOI.Location, 0, false, FinalDestinationReached);
}

/** Finds all POI Actors of POIClass and adds them to CachedPOIList */
function CachePOIList()
{
	local BamActor_POI act;
	
	foreach Manager.WorldInfo.AllActors(class'BamActor_POI', act)
	{
		if( act != none && ClassIsChildOf(act.Class, POIClass) )
		{
			CachedPOIList.AddItem(act);
		}
	}

}

/** 
 * Sets the next POI that should be visited
 * @return whether POI was successfuly found
 */
function bool SelectNextPOI()
{
	local BamActor_POI prevPOI;

	prevPOI = CurrentPOI;

	// select POI from specified list of POIs
	if( SpecificPointsOfInterest.Length > 0 )
	{
		CurrentPOI = SpecificPointsOfInterest[Rand(SpecificPointsOfInterest.Length)];
		if( SpecificPointsOfInterest.Length > 1 )
		{
			while( CurrentPOI == prevPOI )
			{
				CurrentPOI = SpecificPointsOfInterest[Rand(SpecificPointsOfInterest.Length)];
			}
		}

		return true;
	}
	// select POI from cached list of POIs
	else if( CachedPOIList.Length > 0 )
	{
		CurrentPOI = CachedPOIList[Rand(CachedPOIList.Length)];
		if( CachedPOIList.Length > 1 )
		{
			while( CurrentPOI == prevPOI )
			{
				CurrentPOI = CachedPOIList[Rand(CachedPOIList.Length)];
			}
		}

		return true;
	}

	return false;
}






static function BamAIAction_VisitPOIs Create_VisitPOIs(optional class<BamActor_POI> inPOIClass, optional array<BamActor_POI> inSpecificPOIs)
{
	local BamAIAction_VisitPOIs action;
	action = new class'BamAIAction_VisitPOIs';
	action.POIClass = inPOIClass;
	action.SpecificPointsOfInterest = inSpecificPOIs;
	return action;
}

DefaultProperties
{
	bBlockAllLanes=false
	bIsBlocking=true
	Lanes=(class'BamAIActionLane_Moving')

	POIClass=class'BamActor_POI'
}