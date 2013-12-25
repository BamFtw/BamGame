class BamActor_Cover extends BamActor
	abstract
	placeable;


/** Controller currently occupying this cover */
var BamAIController ClaimedBy;

/** Whether leaning up is possible in this cover */
var() private bool bLeanUp;

/** Whether leaning to the left is possible in this cover */
var() private bool bLeanLeft;

/** Whether leaning to the right is possible in this cover */
var() private bool bLeanRight;

/** Calculated desirability of this cover will be multiplied by this value */
var() private float DesirabilityModifier;


/** If not calimed sets reference to claiming controller to the one passed as parameter */
function bool Claim(BamAIController ctrl)
{
	if( ctrl == none || IsClaimed() )
	{
		return false;
	}

	ClaimedBy = ctrl;

	return true;
}

/** Removes reference to contoroller claiming this cover */
function UnClaim()
{
	ClaimedBy = none;
}

/** Return whether this cover is currently claimed by someone */
function bool IsClaimed()
{
	return ClaimedBy != none && ClaimedBy.Cover == self && ClaimedBy.BPawn != none && ClaimedBy.BPawn.IsAliveAndWell();
}



/** Returns whether this cover allows to lean to the left */
function bool CanPopLeft()
{
	return bLeanLeft;
}

/** Returns whether this cover allows to lean to the right */
function bool CanPopRight()
{
	return bLeanRight;
}

/** Returns whether this cover allows to lean up */
function bool CanPopUp()
{
	return bLeanUp;
}

/** Returns dot product between two vectors with Z axis set to 0 */
function float Dot2D(Vector v1, Vector v2)
{
	v1.Z = 0;
	v2.Z = 0;

	return Normal(v1) dot Normal(v2);
}

/** Returns desirability of this cover based on the list of enemy locations passed as prameter */
function float GetDesirability(array<Vector> EnemyLocations)
{
	local int q;
	local float dotSum, currentDot;
	local Vector dir;
	local float tempDesirabilityMod;

	if( EnemyLocations.Length == 0 )
	{
		`trace("Getting desirability without enemeis.", `red);
		return 0;
	}

	dir = Vector(Rotation);

	tempDesirabilityMod = 1.0;

	for(q = 0; q < EnemyLocations.Length; ++q)
	{
		currentDot = Dot2D(dir, EnemyLocations[q] - Location);
		
		// for every dot product below zero reduce desirability
		if( currentDot <= 0 )
		{
			tempDesirabilityMod *= 0.8;
		}
		
		dotSum += currentDot;
	}

	return FClamp((dotSum / EnemyLocations.Length) * DesirabilityModifier * tempDesirabilityMod, 0, 1);
}


defaultproperties
{
	bStatic=true
	bNoDelete=true
	
	bLeanUp=true
	bLeanLeft=true
	bLeanRight=true
	DesirabilityModifier=1.0
}