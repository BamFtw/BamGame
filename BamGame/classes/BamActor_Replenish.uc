class BamActor_Replenish extends BamActor
	abstract;

struct NeedReplenishmentRate
{
	/** Class of the need */
	var() class<BamNeed> NeedClass;
	/** How much of need is restored per second */
	var() float ReplenishmentRate;
};

/** List of needs and rates at which they are replenished */
var() array<NeedReplenishmentRate> NeedReplenishmentRates;

/** List of animations that should be played while replenishing needs */
var() array<name> ReplenishAnimationNames;

/** Controller that is currently using this Actor */
var BamAIController IsOccupiedBy;




/** Sets occupying controller, returns whether it was succesfully occupied */
function bool Occupy(BamAIController C)
{
	if( IsOccupiedBy == none )
	{
		IsOccupiedBy = C;
		return true;
	}

	return false;
}

/** Removes reference to occupying controller and exits replenishing state */
function UnOccupy(BamAIController C)
{
	if( IsOccupiedBy == C )
	{
		IsOccupiedBy = none;
		StopReplenishing();
	}
}

/** Enters replenishing state */
function StartReplenishing()
{
	GotoState('Replenish');
}

/** Exits replenishing state */
function StopReplenishing()
{
	GotoState('Idle');
}

/** Do nothing */
auto state Idle
{

}

/** While in this state replenishes needs of the IsOcuppiedBy controller */
state Replenish
{
	event Tick(float DeltaTime)
	{
		local int q;

		global.Tick(DeltaTime);

		if( IsOccupiedBy != none )
		{
			for(q = 0; q < NeedReplenishmentRates.Length; ++q)
			{
				IsOccupiedBy.NeedManager.ReplenishNeed(NeedReplenishmentRates[q].NeedClass, NeedReplenishmentRates[q].ReplenishmentRate * DeltaTime);
			}
		}
		else
		{
			StopReplenishing();
		}
	}
}

DefaultProperties
{
	Begin Object name=MyCylinderComponent
		CollisionHeight=45.0
		CollisionRadius=50.0
	End Object
}