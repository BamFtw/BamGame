class BamNeedManager_Example extends BamNeedManager;

var float ActionSelectionInterval;
var float LastActionSelectionTime;

var BamFuzzyLevels Thirst;
var BamFuzzyLevels Hunger;
var BamFuzzyLevels Tiredness;

function Initialize(BamAIController inController)
{
	super.Initialize(inController);
	LastActionSelectionTime = class'WorldInfo'.static.GetWorldInfo().TimeSeconds - RandRange(0, ActionSelectionInterval);
}

function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);
	UpdateLevels();
	SelectAction();
}

function UpdateLevels()
{
	Tiredness = Needs[0].GetFuzzyLevel();
	Thirst = Needs[1].GetFuzzyLevel();
	Hunger = Needs[2].GetFuzzyLevel();
}

function SelectAction()
{
	local int averageLevel;
	local float now;

	now = class'WorldInfo'.static.GetWorldInfo().TimeSeconds;

	if( (now - LastActionSelectionTime) < ActionSelectionInterval )
		return;

	LastActionSelectionTime = now;

	averageLevel = (Tiredness + Thirst + Hunger) / 3;
	
	if( (averageLevel > BFL_Medium) || 
		(averageLevel == BFL_Medium && RandRange(0, 1) < 0.25) ||
		(averageLevel >= BFL_Low && RandRange(0, 1) < 0.5) )
		return;
	
	`trace("\"Selecting\" need action", `purple);
}


DefaultProperties
{
	DefaultNeeds[0]=(Class=class'BamNeed_Tiredness',Archetype=BamNeed_Tiredness'bam_ar_needs.Tiredness')
	DefaultNeeds[1]=(Class=class'BamNeed_Thirst',Archetype=BamNeed_Thirst'bam_ar_needs.Thirst')
	DefaultNeeds[2]=(Class=class'BamNeed_Hunger',Archetype=BamNeed_Hunger'bam_ar_needs.Hunger')

	ActionSelectionInterval=6.0
	LastActionSelectionTime=-9999
}
