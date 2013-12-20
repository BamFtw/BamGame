class BamActor_Cover extends BamActor
	abstract
	placeable;



var BamAIController ClaimedBy;

var() private bool bLeanUp;

var() private bool bLeanLeft;

var() private bool bLeanRight;

var() private float DesirabilityModifier;


function bool Claim(BamAIController ctrl)
{
	if( ctrl == none || IsClaimed() )
		return false;

	ClaimedBy = ctrl;

	return true;
}

function UnClaim()
{
	ClaimedBy = none;
}

function bool IsClaimed()
{
	return ClaimedBy != none && ClaimedBy.Cover == self && ClaimedBy.BPawn != none && ClaimedBy.BPawn.IsAliveAndWell();
}



function bool CanPopLeft()
{
	return bLeanLeft;
}

function bool CanPopRight()
{
	return bLeanRight;
}

function bool CanPopUp()
{
	return bLeanUp;
}

function float Dot2D(Vector v1, Vector v2)
{
	v1.Z = 0;
	v2.Z = 0;

	return Normal(v1) dot Normal(v2);
}

function float GetDesirability(array<Vector> EnemyLocations)
{
	local int q;
	local float dotSum;
	local Vector dir;

	if( EnemyLocations.Length == 0 )
	{
		`trace("Getting desirability without enemeis.", `red);
		return 0;
	}

	dir = Vector(Rotation);

	for(q = 0; q < EnemyLocations.Length; ++q)
	{
		dotSum += Dot2D(dir, EnemyLocations[q] - Location);
	}

	return FClamp((dotSum / EnemyLocations.Length) * DesirabilityModifier, 0, 1);
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