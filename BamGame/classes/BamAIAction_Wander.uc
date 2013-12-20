class BamAIAction_Wander extends BamAIAction;
	//implements(BamInterface_FinalDestinationReached);

/** If set POIClass is ignored, list of the only actors that will be considered for wander location */
var() array<BamActor_POI> SpecificPointsOfInterest;

/** Class of actors that should be considered POI */
var() class<BamActor_POI> POIClass;

var array<BamActor_POI> CachedPOIList;

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
		if( SpecificPointsOfInterest[q] == none )
			SpecificPointsOfInterest.Remove(q--, 1);

	if( SpecificPointsOfInterest.Length == 0 )
		CachePOIList();

	HandlePOISelection();
}

function OnEnd()
{
	//Manager.Controller.Unsubscribe_FinalDestinationReached(self);
	Manager.Controller.UnSubscribe(BSE_FinalDestinationReached, FinalDestinationReached);
}

function Tick(float DeltaTime)
{
	if( !Manager.Controller.Is_Moving() )
	{
		Manager.Controller.Begin_Moving();
	}
}

function FinalDestinationReached(BamSubscriberParameters params)
{
	`trace("Final dest reached", `purple);
	HandlePOISelection();

	Manager.InsertBefore(class'BamAIAction_Delay'.static.Create(RandRange(CurrentPOI.MinWaitTime, CurrentPOI.MaxWaitTime), GetOccupiedLanes()), self);
}

function HandlePOISelection()
{
	if( !SelectNextPOI() )
	{
		`trace("Could not find POI for" @ Manager.Controller, `yellow);
		Finish();
		return;
	}

	`trace("Selected new POI" @ CurrentPOI,`cyan);

	//Manager.Controller.Subscribe_FinalDestinationReached(self);
	Manager.Controller.Subscribe(BSE_FinalDestinationReached, FinalDestinationReached);
	Manager.Controller.Pawn.SetWalking(false);
	Manager.Controller.SetFinalDestination(CurrentPOI.Location);
	Manager.Controller.Begin_Moving();
}

function CachePOIList()
{
	local WorldInfo wi;
	local BamActor_POI act;

	wi = class'WorldInfo'.static.GetWorldInfo();
	
	foreach wi.AllActors(class'BamActor_POI', act)
	{
		if( act != none )
			CachedPOIList.AddItem(act);
	}

}

function bool SelectNextPOI()
{
	local BamActor_POI prevPOI;

	prevPOI = CurrentPOI;

	if( SpecificPointsOfInterest.Length > 0 )
	{
		CurrentPOI = SpecificPointsOfInterest[Rand(SpecificPointsOfInterest.Length)];

		while( SpecificPointsOfInterest.Length > 1 && CurrentPOI == prevPOI )
			CurrentPOI = SpecificPointsOfInterest[Rand(SpecificPointsOfInterest.Length)];

		return true;
	}
	else if( CachedPOIList.Length > 0 )
	{
		CurrentPOI = CachedPOIList[Rand(CachedPOIList.Length)];
		
		while( CachedPOIList.Length > 1 && CurrentPOI == prevPOI )
			CurrentPOI = CachedPOIList[Rand(CachedPOIList.Length)];

		return true;
	}

	return false;
}

DefaultProperties
{
	bBlockAllLanes=true
	bIsBlocking=true
	POIClass=class'BamActor_POI'
}