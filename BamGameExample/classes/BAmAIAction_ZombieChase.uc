class BAmAIAction_ZombieChase extends BamAIAction;

var() Pawn Target;

function OnBegin()
{
	if( !Manager.Controller.IsInCombat() )
	{
		Finish();
		return;
	}

	if( Target == none && !FindGoodTarget() )
	{
		Finish();
		return;
	}



	Manager.Controller.bUseDynamicActorAvoidance = false;
	Manager.Controller.Subscribe(class'BamSubscribableEvent_FinalDestinationReached', FinalDestinationReached);
}

function Tick(float DeltaTime)
{
	if( !Manager.Controller.IsInCombat() || ((Target == none || !Target.IsAliveAndWell()) && !FindGoodTarget())  )
	{
		Finish();
		return;
	}

	if( VSize(Target.Location - Manager.Controller.Pawn.Location) <= Manager.Controller.BPawn.MeleeProperties.Range * 0.75 )
	{
		Manager.Controller.ActionManager.PushFront(class'BAmAIAction_ZombieAttack'.static.Create_ZombieAttack(Target));
		return;
	}

	Manager.Controller.SetFinalDestination(Target.Location, Manager.Controller.Pawn.GetCollisionRadius() * 2.0);
	Manager.Controller.Begin_Moving();
}

function OnEnd()
{
	Manager.Controller.Unsubscribe(class'BamSubscribableEvent_FinalDestinationReached', FinalDestinationReached);
	Manager.Controller.bUseDynamicActorAvoidance = Manager.Controller.default.bUseDynamicActorAvoidance;
}

function OnBlocked()
{
	Manager.Controller.Unsubscribe(class'BamSubscribableEvent_FinalDestinationReached', FinalDestinationReached);
}

function OnUnblocked()
{
	Manager.Controller.Subscribe(class'BamSubscribableEvent_FinalDestinationReached', FinalDestinationReached);
}

function FinalDestinationReached(BamSubscriberParameters params)
{
	if( bIsBlocked )
		return;

	Manager.Controller.ActionManager.PushFront(class'BAmAIAction_ZombieAttack'.static.Create_ZombieAttack(Target));
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





static function BAmAIAction_ZombieChase Create_ZombieChase(optional Pawn inTarget = none)
{
	local BAmAIAction_ZombieChase action;
	action = new class'BAmAIAction_ZombieChase';
	action.Target = inTarget;
	return action;
}

DefaultProperties
{
	bIsBlocking=true
	Lanes=(class'BamAIActionLane_Moving')
}