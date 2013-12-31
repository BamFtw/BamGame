class BamAIAction_ReplenishNeeds extends BamAIAction;


var class<BamActor_Replenish> ReplenishActorClass; 

var BamActor_Replenish ReplenishActor;


function OnBegin()
{
	if( ReplenishActorClass == none )
	{
		`trace("Replenish actor class is none", `red);
		Finish();
		return;
	}

	FindReplenishActor();

	if( ReplenishActor == none )
	{
		`trace("Could not find any unoccupied actor of clsss" @ ReplenishActorClass, `red);
		Finish();
		return;
	}

	ReplenishActor.Occupy(Manager.Controller);
	Manager.Controller.InitializeMove(ReplenishActor.Location, Manager.Controller.Pawn.GetCollisionRadius(), , FinalDestinationReached);
}

function OnBlocked()
{
	Finish();
}

function OnEnd()
{
	if( ReplenishActor != none )
	{
		ReplenishActor.UnOccupy(Manager.Controller);
		ReplenishActor = none;
	}

	Manager.Controller.BPawn.CharacterFullBodySlot.StopCustomAnim(0.2);
	Manager.Controller.BPawn.CancelDesiredLocation();
	Manager.Controller.BPawn.LockDesiredRotation(false, false);
}



function FindReplenishActor()
{
	local Actor act;
	local BamActor_Replenish actRepl;
	local float distance, closestDistance;
	local BamActor_Replenish closestActor;

	closestDistance = 999999999;
	closestActor = none;

	foreach Manager.WorldInfo.DynamicActors(ReplenishActorClass, act)
	{
		actRepl = BamActor_Replenish(act);
		if( actRepl != none && actRepl.IsOccupiedBy == none )
		{
			distance = VSizeSq(Manager.Controller.Pawn.Location - actRepl.Location);
			if( distance < closestDistance )
			{
				closestDistance = distance;
				closestActor = actRepl;
			}
		}
	}

	ReplenishActor = closestActor;
}


function FinalDestinationReached(BamSubscriberParameters params)
{
	local int q, w;
	local float maxTime, currentTime, dur;

	Manager.Controller.Begin_Idle();

	if( ReplenishActor != none )
	{
		ReplenishActor.StartReplenishing();

		Manager.Controller.BPawn.CharacterFullBodySlot.PlayCustomAnim(ReplenishActor.ReplenishAnimationNames[Rand(ReplenishActor.ReplenishAnimationNames.Length)], 1.0, 0.2, 0.2, true, true);

		Manager.Controller.BPawn.SetDesiredRotation(ReplenishActor.Rotation, true);
		Manager.Controller.BPawn.SetDesiredLocation(ReplenishActor.Location);

		// calculate duration
		for(q = 0; q < ReplenishActor.NeedReplenishmentRates.Length; ++q)
		{
			for(w = 0; w < Manager.Controller.NeedManager.Needs.Length; ++w)
			{
				if( Manager.Controller.NeedManager.Needs[w].Class == ReplenishActor.NeedReplenishmentRates[q].NeedClass )
				{
					currentTime = (Manager.Controller.NeedManager.Needs[w].MaxValue - Manager.Controller.NeedManager.Needs[w].CurrentValue) / ReplenishActor.NeedReplenishmentRates[q].ReplenishmentRate;
					
					if( currentTime > maxTime )
					{
						maxTime = currentTime;
					}
				}
			}
		}
	}

	dur = FClamp(maxTime, 4, 10);
	
	SetDuration(dur);
}



static function BamAIAction_ReplenishNeeds Create_ReplenishNeeds(class<BamActor_Replenish> repActorClass)
{
	local BamAIAction_ReplenishNeeds action;
	action = new class'BamAIAction_ReplenishNeeds';
	action.ReplenishActorClass = repActorClass;
	return action;
}

DefaultProperties
{
	bIsBlocking=true
	bBlockAllLanes=true
}