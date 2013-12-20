class BamActor_Replenish extends BamActor
	abstract;

struct NeedReplenishmentRate
{
	var() class<BamNeed> NeedClass;
	var() float ReplenishmentRate;
};

var array<NeedReplenishmentRate> NeedReplenishmentRates;
var array<name> ReplenishAnimationNames;


DefaultProperties
{
	Begin Object name=MyCylinderComponent
		CollisionHeight=45.0
		CollisionRadius=50.0
	End Object
}