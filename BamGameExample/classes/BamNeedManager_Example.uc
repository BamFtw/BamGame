class BamNeedManager_Example extends BamNeedManager;

/** how often action selection can happen */
var float ActionSelectionInterval;

/** Time last action selection happened */
var float LastActionSelectionTime;

/** Level of thirst */
var BamFuzzyLevels Thirst;

/** Level of hunger */
var BamFuzzyLevels Hunger;

/** Level of tiredness */
var BamFuzzyLevels Tiredness;

/** Sets last action selection time */
function Initialize(BamAIController inController)
{
	super.Initialize(inController);

	LastActionSelectionTime = class'WorldInfo'.static.GetWorldInfo().TimeSeconds - RandRange(0, ActionSelectionInterval);
}

/** Updates levels and selects action */
function Tick(float DeltaTime)
{
	UpdateLevels();
	SelectAction();
}

/** Updates levels of needs */
function UpdateLevels()
{
	Tiredness = Needs[0].GetFuzzyLevel();
	Thirst = Needs[1].GetFuzzyLevel();
	Hunger = Needs[2].GetFuzzyLevel();
}

/** Every ActionSelectionInterval seconds tries to select action to replenish needs based on their levels */
function SelectAction()
{
	local int averageLevel;
	local float now;

	if( Controller.IsInCombat() )
	{
		return;
	}

	// check if need is being replenished
	if( Controller.ActionManager.Front() != none && ClassIsChildOf(Controller.ActionManager.Front().Class, class'BamAIAction_ReplenishNeeds') )
	{
		return;
	}

	now = class'WorldInfo'.static.GetWorldInfo().TimeSeconds;

	if( (now - LastActionSelectionTime) < ActionSelectionInterval )
	{
		return;
	}

	LastActionSelectionTime = now;

	averageLevel = CalcAverageNeedsLevel();
	
	// if average level is high there is no need to replenish needs
	// if level is lower RNG decides whether needs should be replenished
	if( (averageLevel >= BFL_High) || (averageLevel == BFL_Medium && RandRange(0, 1) < 0.5) || (averageLevel <= BFL_Low && RandRange(0, 1) < 0.25) )
	{
		return;
	}
	
	if( Tiredness <= BFL_Low )
	{
		PushAction(class'BamActor_Replenish_Bed');
		return;
	}

	if( Thirst <= BFL_Medium && Hunger <= BFL_Medium )
	{
		PushAction(class'BamActor_Replenish_Fridge');
		return;
	}

	if( Thirst <= BFL_Low )
	{
		PushAction(class'BamActor_Replenish_Sink');
		return;
	}

	if( Hunger <= BFL_Low )
	{
		PushAction(class'BamActor_Replenish_Fridge');
		return;
	}
}

/** Returns average level of all needs of this manager */
function int CalcAverageNeedsLevel()
{
	local int sum, q;

	if( Needs.Length == 0 )
	{
		return -1;
	}

	for(q = 0; q < Needs.Length; ++q)
	{
		sum += Needs[q].GetFuzzyLevel();
	}

	return (sum / Needs.Length);
}

/** 
 * Adds replenish needs action that will look for replenish actors of specified class
 * @param actorClass - class of the actors that Pawn should got to
 */
function PushAction(class<BamActor_Replenish> actorClass)
{
	local BamAIAction action;

	if( actorClass == none )
	{
		`trace("Action class is none", `red);
		return;
	}

	action = class'BamAIAction_ReplenishNeeds'.static.Create_ReplenishNeeds(actorClass);

	if( action != none )
	{
		Controller.ActionManager.PushFront(action);
	}
	else
	{
		`trace("Failed to spawn action", `red);
	}
}

DefaultProperties
{
	DefaultNeeds[0]=(Class=class'BamNeed_Tiredness',Archetype=BamNeed_Tiredness'bam_ar_needs.Tiredness')
	DefaultNeeds[1]=(Class=class'BamNeed_Thirst',Archetype=BamNeed_Thirst'bam_ar_needs.Thirst')
	DefaultNeeds[2]=(Class=class'BamNeed_Hunger',Archetype=BamNeed_Hunger'bam_ar_needs.Hunger')

	ActionSelectionInterval=5.0
	LastActionSelectionTime=-9999
}
