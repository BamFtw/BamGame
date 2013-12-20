class BamAIAction_Shelter extends BamAIAction;

var BamActor_Shelter Shelter;

var() name CoverAnimationName;

function OnBegin()
{
	if( !Manager.Controller.IsInCombat() )
	{
		bIsFinished = true;
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

event Tick(float DeltaTime)
{
	if( !Manager.Controller.IsInCombat() )
	{
		bIsFinished = true;
		return;
	}

	if( Shelter == none && !FindShelter() )
		return;


}

function bool FindShelter()
{
	local WorldInfo wi;
	local BamActor_Shelter act;

	wi = class'WorldInfo'.static.GetWorldInfo();

	foreach wi.DynamicActors(class'BamActor_Shelter', act)
	{
		if( act.OccupiedBy == none || !act.OccupiedBy.IsAliveAndWell() )
		{
			Shelter = act;
			Shelter.OccupiedBy = Manager.Controller.Pawn;
			
			Manager.Controller.Subscribe(BSE_FinalDestinationReached, FinalDestinationReached);
			Manager.Controller.SetFinalDestination(Shelter.Location);
			Manager.Controller.Pawn.SetWalking(true);
			Manager.Controller.Begin_Moving();

			return true;
		}
	}

	return false;
}





function FinalDestinationReached(BamSubscriberParameters params)
{
	if( bIsBlocked )
	
		return;

	if( Manager.Controller.BPawn.CharacterTopBodySlot != none )
	{
		Manager.Controller.BPawn.CharacterTopBodySlot.StopCustomAnim(0.4);
	}

	if( Manager.Controller.BPawn.CharacterFullBodySlot != none )
	{
		`trace("Playing CoverAnimationName on FBS", `green);
		Manager.Controller.BPawn.CharacterFullBodySlot.PlayCustomAnim(CoverAnimationName, 1.0, 0.4, 0.4, true, true);
	}

	Manager.Controller.BPawn.SetDesiredLocation(Shelter.Location);
}

DefaultProperties
{
	bIsBlocking=true
	bBlockAllLanes=true

	CoverAnimationName=cover_shelter
}