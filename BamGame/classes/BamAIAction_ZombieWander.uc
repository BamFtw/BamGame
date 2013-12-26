class BamAIAction_ZombieWander extends BamAIAction;

var() float MaxRadius;
var() float MinRadius;

var() float MinWaitTime;
var() float MaxWaitTime;

var Vector WanderLocation;

var float WaitTime;

function OnBegin()
{
	super.OnBegin();
	FindWanderLocation();
}

function Tick(float DeltaTime)
{
	if( WaitTime > 0 )
	{
		WaitTime = FMax(0, WaitTime - DeltaTime);
		
		if( WaitTime == 0 )
		{
			FindWanderLocation();
		}
	}
}


function bool FindWanderLocation()
{
	local array<Vector> GoodPositions;
	local int q;
	local bool bGoodSpotFound;
	local float MinRadiusSq;

	Manager.Controller.NavigationHandle.GetValidPositionsForBox(Manager.Controller.Pawn.Location, MaxRadius, Manager.Controller.Pawn.GetCollisionExtent(), true, GoodPositions, MinRadius);

	if( GoodPositions.Length == 0 )
	{
		`trace("No good positions for zombie wander", `red);
		Finish();
		return false;
	}

	MinRadiusSq = MinRadius * MinRadius;

	while( !bGoodSpotFound && GoodPositions.Length > 0 )
	{
		q = Rand(GoodPositions.Length);
		if( VSizeSq(GoodPositions[q] - Manager.Controller.Pawn.Location) >= MinRadiusSq)
		{
			WanderLocation = GoodPositions[q];
			bGoodSpotFound = true;
		}
		else
		{
			GoodPositions.Remove(q, 1);
		}
	}

	if( GoodPositions.Length == 0 )
		return false;

	Manager.Controller.InitializeMove(WanderLocation, 0, false, FinalDestinationReached);

	return true;
}


function FinalDestinationReached(BamSubscriberParameters params)
{
	if( bIsBlocked )
		return;

	WaitTime = RandRange(MinWaitTime, MaxWaitTime);

	if( WaitTime <= 0 )
	{
		FindWanderLocation();
	}
	else
	{
		Manager.Controller.Begin_Idle();
	}
}








static function BamAIAction_ZombieWander Create_ZombieWander(optional float inMaxRadius = -1, optional float inMinRadius = -1, optional float inMinWaitTime = -1, optional float inMaxWaitTime = -1)
{
	local BamAIAction_ZombieWander action;
	action = new class'BamAIAction_ZombieWander';
	
	if( inMinRadius >= 0 )
	{
		action.MinRadius = inMinRadius;
	}
	
	if( inMaxRadius >= 0 )
	{
		action.MaxRadius = inMaxRadius;
	}

	if( inMinWaitTime >= 0 )
	{
		action.MinWaitTime = inMinWaitTime;
	}
	
	if( inMaxWaitTime >= 0 )
	{
		action.MaxWaitTime = inMaxWaitTime;
	}
	
	return action;
}

DefaultProperties
{
	bIsBlocking=true;
	Lanes=(Lane_Moving)

	MaxRadius=0
	MinRadius=0
	MinWaitTime=0.5
	MaxWaitTime=1.0
}