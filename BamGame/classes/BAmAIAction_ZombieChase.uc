class BAmAIAction_ZombieChase extends BamAIAction;

var() Pawn Target;

function OnBegin()
{
	if( !Manager.Controller.IsInCombat() )
	{
		bIsFinished = true;
		return;
	}

	if( !FindGoodTarget() )
	{
		bIsFinished = true;
		return;
	}

	Manager.Controller.Subscribe(BSE_FinalDestinationReachd, FinalDestinationReached);
}

function Tick(float DeltaTime)
{
	if( !Manager.Controller.IsInCombat() || (Target == none && !FindGoodTarget()) )
	{
		bIsFinished = true;
		return;
	}

	Manager.Controller.SetFinalDestination(Target.Location, Manager.Controller.Pawn.GetCollisionRadius() * 1.25);
	Manager.Controller.Begin_Moving();
}

function OnEnd()
{
	Manager.Controller.Unubscribe(BSE_FinalDestinationReachd, FinalDestinationReached);
}

function OnBlocked()
{
	Manager.Controller.Unubscribe(BSE_FinalDestinationReachd, FinalDestinationReached);
}

function OnUnblocked()
{
	Manager.Controller.Subscribe(BSE_FinalDestinationReachd, FinalDestinationReached);
}

function FinalDestinationReached(BamSubscriberParameters params)
{
	if( bIsBlocked )
		return;

	Manager.Controller.ActionManager.PushFront(class'BAmAIAction_ZombieAttack'.static.Create(Target));
}

function bool FindGoodTarget()
{
	local int q;
	local float distance, closestDistance;
	local Pawn closestPawn;

	closestDistance = 100000000;
	closestPawn = none;

	for(q = 0; q < Manager.Controller.Team.EnemyData.Length; ++q)
	{
		distance = VSizeSq(Manager.Controller.Pawn.Location - Manager.Controller.Team.EnemyData[q].Pawn.Location);
		if( distance < closestDistance )
		{
			closestPawn = Manager.Controller.Team.EnemyData[q].Pawn;
			closestDistance = distance;
		}
	}

	Target = closestPawn;

	return Target != none;
}

DefaultProperties
{
	bIsBlocking=true
	Lanes=(Lane_Moving)
}