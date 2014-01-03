class BamAIAction_Cover extends BamAIAction
	abstract
	dependson(BamCoverActionData);

/** Object storing preferences of the cover action */
var() editinline BamCoverActionData CoverData;

/** 
 * Finds best available cover on the map, returns whether cover was successfuly found
 * @param maxDistance - max distance between cover and pawn above which covers desirability is always 0
 * @param desirabilityBase - desirability level that Cover has to exceed to be considered viable
 */
function bool FindBestCover(optional float maxDistance = CoverData.MaxCoverSearchDistance, optional float  desirabilityBase = 0)
{
	local BamActor_Cover currentCover, bestCover;
	local float bestCoverDesirability, currentCoverDesirability, distanceToCover, distanceRatio, pawnCollisionHeight, maxDistanceFromCenter, distanceToEnemyCenter;
	local array<Vector> EnemyLocations;
	local Vector enemyCenter;
	local int q;

	// make sure controller and pawn are ok
	if( Manager.Controller == none || Manager.Controller.Pawn == none )
	{
		return false;
	}

	// make sure controller has enemies
	if( !Manager.Controller.HasRangedEnemies() )
	{
		// `trace(Manager.Controller @ "has no enemies", `red);
		return false;
	}

	bestCover = none;
	bestCoverDesirability = desirabilityBase;
	EnemyLocations = Manager.Controller.GetRangedEnemyLocations();
	currentCoverDesirability = 0;

	for(q = 0; q < EnemyLocations.Length; ++q)
	{
		enemyCenter += EnemyLocations[q];
	}

	enemyCenter /= EnemyLocations.Length;

	maxDistanceFromCenter = CoverData.MaxDistanceFromEnemyCenter * CoverData.MaxDistanceFromEnemyCenter;

	// so sqared vsize can be used
	maxDistance *= maxDistance;

	

	// max allowed difference between pawns and covers location Z component
	pawnCollisionHeight = Manager.Controller.Pawn.GetCollisionHeight() * 1.5;

	// go through all of the covers and find the one with the highest desirability within specified range
	foreach Manager.WorldInfo.AllActors(class'BamActor_Cover', currentCover)
	{
		distanceToEnemyCenter = VSizeSq2D(currentCover.Location - enemyCenter);
		distanceToCover = VSizeSq2D(currentCover.Location - Manager.Controller.Pawn.Location);

		// make sure cover is free and in range
		if( currentCover.IsClaimed() || distanceToEnemyCenter > maxDistanceFromCenter || distanceToCover > maxDistance || Abs(currentCover.Location.Z - Manager.Controller.Pawn.Location.Z) > pawnCollisionHeight )
		{
			continue;
		}

		distanceRatio = 1 - FClamp((distanceToCover / maxDistance) ** 0.125, 0, 1);

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
