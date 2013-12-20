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
		bIsFinished = true;
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

	Manager.Controller.SetFinalDestination(WanderLocation);
	Manager.Controller.Subscribe(BSE_FinalDestinationReached, FinalDestinationReached);
	Manager.Controller.Pawn.SetWalking(false);
	Manager.Controller.Begin_Moving();

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

DefaultProperties
{
	bIsBlocking=true;
	Lanes=(Lane_Moving)
}