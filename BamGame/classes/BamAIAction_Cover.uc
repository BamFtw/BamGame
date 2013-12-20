class BamAIAction_Cover extends BamAIAction
	abstract
	dependson(BamCoverActionData);

/** Object storing preferences of the cover action */
var() editinline BamCoverActionData CoverData;

/**  */
var WorldInfo WorldInfo;

/** Caches reference to WorldInfo */
function OnBegin()
{
	super.OnBegin();
	WorldInfo = class'WorldInfo'.static.GetWorldInfo();
}

/** 
 * Finds best available cover on the map, returns whether cover was successfuly found
 * @param maxDistance - max distance between cover and pawn above which covers desirability is always 0
 * @param desirabilityBase - desirability level that Cover has to exceed to be considered viable
 */
function bool FindBestCover(optional float maxDistance = CoverData.MaxCoverSearchDistance, optional float  desirabilityBase = 0)
{
	local BamActor_Cover currentCover, bestCover;
	local float bestCoverDesirability, currentCoverDesirability, distanceRatio;
	local array<Vector> EnemyLocations;

	// make sure controller and pawn are ok
	if( Manager.Controller == none || Manager.Controller.Pawn == none )
	{
		return false;
	}

	// make sure controller has enemies
	if( !Manager.Controller.HasEnemies() )
	{
		`trace(Manager.Controller @ "has no enemies", `red);
		return false;
	}

	bestCover = none;
	bestCoverDesirability = desirabilityBase;
	EnemyLocations = Manager.Controller.GetEnemyLocations();
	currentCoverDesirability = 0;

	// go through all of the covers and find the one with the highest desirability within specified range
	foreach WorldInfo.AllActors(class'BamActor_Cover', currentCover)
	{
		// make sure cover is free and in range
		if( currentCover.IsClaimed() || VSize2D(Manager.Controller.Pawn.Location - currentCover.Location) > maxDistance )
			continue;

		distanceRatio = 1 - FClamp(VSize2D((currentCover.Location - Manager.Controller.Pawn.Location) / maxDistance) ** 0.125, 0, 1);

		currentCoverDesirability = currentCover.GetDesirability(EnemyLocations) * distanceRatio * CoverData.GetCoverDesirabilityMod(currentCover);

		if( currentCoverDesirability > bestCoverDesirability )
		{
			bestCover = currentCover;
			bestCoverDesirability = currentCoverDesirability;
		}
	}

	if( bestCover != none )
	{
		CoverData.ClaimedCover(bestCover);
		return true;
	}

	return false;
}
