class BamAIAction_Patrol extends BamAIAction
	hidecategories(BamAIAction)
	editinlinenew;

enum BamPatrolType
{
	BPT_Loop<DisplayName=Loop>,
	BPT_BackAndForth<DisplayName=Back and forth>,
	BPT_ReachEndAndStop<DisplayName=Reach end and stop>
};

/** Array storing all the points that make up the patrol route */
var() array<BamActor_PatrolPoint> Route;

/** Type of patrolling */
var() BamPatrolType Type;

/** Index in the Route array that should be reached first */
var() int StartIndex;

/** Whether Pawn should run or walk while patroling */
var() bool bRunWhilePatrolling;

/** Index of the PatrolPoint that Pawn is heading toward */
var int CurrentIndex;

/** Flag used while Type is BPT_BackAndForth to determine direction of the patrol route */
var bool bBackAndForthDir;



function OnBegin()
{
	CleanUpRoute();

	if( Route.Length == 0 )
	{
		`trace("Route is empty", `red);
		Finish();
		return;
	}

	CurrentIndex = StartIndex;
	FixCurrentIndex();

	StartPatrol();
}

function OnEnd()
{
	Manager.Controller.Pawn.LockDesiredRotation(false);
	Manager.Controller.UnSubscribe(BSE_FinalDestinationReached, FinalDestinationReached);
}

function OnBlocked()
{
	Manager.Controller.Pawn.LockDesiredRotation(false);
	Manager.Controller.UnSubscribe(BSE_FinalDestinationReached, FinalDestinationReached);
}

function OnUnblocked()
{
	Manager.Controller.Subscribe(BSE_FinalDestinationReached, FinalDestinationReached);
	Manager.Controller.Begin_Moving();
}


function FinalDestinationReached(BamSubscriberParameters params)
{
	local float waitTime;
	waitTime = FMax(0.01, Route[CurrentIndex].GetWaitTime());

	Manager.Controller.Pawn.SetDesiredRotation(Route[CurrentIndex].Rotation, true);

	SetNextIndex();
	
	if( bIsFinished )
		return;

	StartPatrol();

	Manager.PushFront(class'BamAIAction_Idle'.static.Create(waitTime, GetOccupiedLanes(), true, true));
}


function CleanUpRoute()
{
	local int q;
	for(q = 0; q < Route.Length; ++q)
	{
		if( Route[q] == none )
			Route.Remove(q--, 1);
	}
}

function SetNextIndex()
{
	switch (Type)
	{
	case BPT_ReachEndAndStop:
		if( CurrentIndex == Route.Length - 1 )
		{
			Finish();
		}
		CurrentIndex++;
	    break;
	  
	case BPT_BackAndForth:
		if( !bBackAndForthDir && CurrentIndex == Route.Length - 1 )
		{
			bBackAndForthDir = true;
		}
		else if( bBackAndForthDir && CurrentIndex == 0 )
		{
			bBackAndForthDir = false;
		}

		CurrentIndex += (bBackAndForthDir ? -1 : 1);
			break;
	default:
		CurrentIndex++;
	}
		
	FixCurrentIndex();
}

function StartPatrol()
{
	Manager.Controller.InitializeMove(Route[CurrentIndex].Location, Manager.Controller.Pawn.GetCollisionRadius() * 2.0, bRunWhilePatrolling, FinalDestinationReached);
}

function FixCurrentIndex()
{
	if( CurrentIndex >= Route.Length || CurrentIndex < 0 )
		CurrentIndex = 0;
}

static function BamAIAction_Patrol Create(array<BamActor_PatrolPoint> inRoute, optional BamPatrolType inType, optional int inStartIndex = 0, optional bool _bRunWhilePatrolling = false)
{
	local BamAIAction_Patrol act;
	act = new default.class;

	act.Route = inRoute;
	act.StartIndex = inStartIndex;
	act.Type = inType;
	act.bRunWhilePatrolling = _bRunWhilePatrolling;

	return act;
}



DefaultProperties
{
	bIsBlocking=true
	Lanes=(Lane_Moving)

	bRunWhilePatrolling=false
	StartIndex=0
}