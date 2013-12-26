class BamAIAction_Shelter extends BamAIAction
	noteditinlinenew;

var BamActor_Shelter Shelter;

var() name CoverAnimationName;

function OnBegin()
{
	if( !Manager.Controller.IsInCombat() )
	{
		Finish();
		return;
	}

	Manager.BlockActionClass(class'BamAIAction', 9999999);
	if( Manager.Controller.BPawn.CharacterTopBodySlot != none )
	{
		`trace("Playing CoverAnimationName on top slot", `green);
		Manager.Controller.BPawn.CharacterTopBodySlot.PlayCustomAnim(CoverAnimationName, 1.0, 0.4, 0.4, true, true);
	}
	else
	{
		`trace("Manager.Controller.BPawn.CharacterTopBodySlot == none", `red);
	}
}

function OnEnd()
{
	Manager.UnblockActionClass(class'BamAIAction');
	Shelter.OccupiedBy = none;

	if( Manager.Controller.BPawn.CharacterTopBodySlot != none )
	{
		Manager.Controller.BPawn.CharacterTopBodySlot.StopCustomAnim(0.4);
	}

	if( Manager.Controller.BPawn.CharacterFullBodySlot != none )
	{
		Manager.Controller.BPawn.CharacterFullBodySlot.StopCustomAnim(0.4);
	}
}

function OnBlocked()
{
	Finish();
}

event Tick(float DeltaTime)
{
	if( !Manager.Controller.IsInCombat() )
	{
		Finish();
		return;
	}

	if( Shelter == none && !FindShelter() )
	{
		return;
	}
}

function bool FindShelter()
{
	local BamActor_Shelter act, closestShelter;
	local float closestShelterDistance, currentDistance;

	closestShelterDistance = 99999999999;
	closestShelter = none;

	foreach Manager.WorldInfo.DynamicActors(class'BamActor_Shelter', act)
	{
		if( act.OccupiedBy == none || !act.OccupiedBy.IsAliveAndWell() )
		{
			currentDistance = VSizeSq(Manager.Controller.Pawn.Location - act.Location);

			if( currentDistance < closestShelterDistance )
			{
				closestShelterDistance = currentDistance;
				closestShelter = act;
			}			
		}
	}

	if( closestShelter == none )
	{
		return false;
	}

	Shelter = closestShelter;

	Shelter.OccupiedBy = Manager.Controller.Pawn;

	Manager.Controller.Subscribe(BSE_FinalDestinationReached, FinalDestinationReached);
	Manager.Controller.SetFinalDestination(Shelter.Location);
	Manager.Controller.Pawn.SetWalking(true);
	Manager.Controller.Begin_Moving();

	return true;
}





function FinalDestinationReached(BamSubscriberParameters params)
{
	if( bIsBlocked )
	{
		return;
	}

	if( Manager.Controller.BPawn.CharacterTopBodySlot != none )
	{
		Manager.Controller.BPawn.CharacterTopBodySlot.StopCustomAnim(0.4);
	}

	if( Manager.Controller.BPawn.CharacterFullBodySlot != none )
	{
		Manager.Controller.BPawn.CharacterFullBodySlot.PlayCustomAnim(CoverAnimationName, 1.0, 0.4, 0.4, true, true);
	}

	Manager.Controller.BPawn.SetDesiredLocation(Shelter.Location);
}






function BamAIAction_Shelter Create_Shelter()
{
	local BamAIAction_Shelter action;
	action = new class'BamAIAction_Shelter';
	return action;
}





DefaultProperties
{
	bIsBlocking=true
	bBlockAllLanes=true

	CoverAnimationName=cover_shelter
}