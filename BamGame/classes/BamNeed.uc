class BamNeed extends Object
	hidecategories(Object)
	dependson(BamAIPawn)
	abstract;

/** Default fuzzy levels */
enum BamFuzzyLevels
{
	BFL_VeryLow<DisplayName=Very Low>,
	BFL_Low<DisplayName=Low>,
	BFL_Medium<DisplayName=Medium>,
	BFL_High<DisplayName=High>,
	BFL_VeryHigh<DisplayName=Very High>,
	BFL_MAX
};


struct BamNeedPawnStatMod
{
	/** Type of affected stat */
	var() BamPawnStat Stat;
	/** value that will be added to this stat */
	var() float Value;
};


struct BamNeedPawnStatModContainer
{
	/** Level of need */
	var() editoronly editconst BamFuzzyLevels Level;
	/** List of Pawn modifications for this level of need */
	var() array<BamNeedPawnStatMod> Mods;
};


struct BamFuzzyMembershipFunctionContainer
{
	/** Level of need */
	var() editoronly editconst BamFuzzyLevels Level;
	/** Function used to calculate level of membership to this fuzzy level */
	var() editinline BamFuzzyMembershipFunction Function;
};

/** Need manager this need belongs to */
var BamNeedManager Manager;

/** Cached value of this needs level to avoid multiple recalculations per tick */
var BamFuzzyLevels CachedLevel;

/** Whether this need requires CachedLevel to be recalculated */
var bool bRequiresUpdate;

/** Name of this need */
var() editconst const protectedwrite string NeedName;

/** Maximum level of this need */
var() float MaxValue;
/** If true MaxValue will be set to value between MinLimit and MaxLimit */
var(Random) bool bRandomLimit;
var(Random) float MinLimit;
var(Random) float MaxLimit;

/** Current level of this need */
var() float CurrentValue;
/** If true CurrentValue will be set to value between MinStartValue and MaxStartValue */
var(Random) bool bRandomStartValue;
var(Random) float MinStartValue;
var(Random) float MaxStartValue;

/** rate at which this needs value decreases per second */
var() float DecayRate;
/** If true DecayRate will be set to value between MinDecayRate and MaxDecayRate */
var(Random) bool bRandomDecayRate;
var(Random) float MinDecayRate;
var(Random) float MaxDecayRate;

/** List of membership functions that determine level of membership for each fuzzy level from BamFuzzyLevels enum */
var(MembershipFunctions) editfixedsize array<BamFuzzyMembershipFunctionContainer> MembershipFunctions;

/** List of Pawn stat mods for each fuzzy level from BamFuzzyLevels enum */
var(StatMods) editfixedsize array<BamNeedPawnStatModContainer> StatMods;


/** Sets random values if needed, calls Initialize */
final function MasterInitialize()
{
	if( bRandomLimit )
	{
		MaxValue = RandRange(MinLimit, MaxLimit);
	}
	
	if( bRandomStartValue )
	{
		CurrentValue = Min(RandRange(MinStartValue, MaxStartValue), MaxValue);
	}

	if( bRandomDecayRate )
	{
		DecayRate = RandRange(MinDecayRate, MaxDecayRate);
	}

	Initialize();
}

/** Initializes */
function Initialize();

/** Updates value of the need and calls Tick */
final function MasterTick(float DeltaTime)
{
	CurrentValue = FMax(0, CurrentValue - DecayRate * DeltaTime);
	bRequiresUpdate = true;

	Tick(DeltaTime);
}

function Tick(float DeltaTime);

/** Updates Values of stat mods based on current level of this need */
function GetStatMods(out array<float> Values)
{
	local int w, currentLevel;

	while( Values.Length < BPS_MAX )
	{
		Values.AddItem(0);
	}

	if( bRequiresUpdate )
	{
		GetFuzzyLevel();
	}

	currentLevel = CachedLevel;

	for(w = 0; w < StatMods[currentLevel].Mods.Length; w++)
	{
		if( StatMods[currentLevel].Mods[w].Stat < BPS_MAX && StatMods[currentLevel].Mods[w].Stat >= 0 )
			Values[StatMods[currentLevel].Mods[w].Stat] += StatMods[currentLevel].Mods[w].Value;
	}
}

/** Returns current value of this need */
function float GetValue()
{
	return CurrentValue;
}

/** Returns percent of this needs fulfillment */
function float GetValuePct()
{
	return FClamp(CurrentValue / MaxValue, 0, 1);
}

/** Returns current fuzzy level of this need, recalculates it if bRequiresUpdate flag is true */
function BamFuzzyLevels GetFuzzyLevel()
{
	local int q, idx;
	local array<float> MembershipLevels;

	if( !bRequiresUpdate )
	{
		return CachedLevel;
	}

	for(q = 0; q < MembershipFunctions.Length; ++q)
	{
		if( MembershipFunctions[q].Function == none )
		{
			MembershipLevels.AddItem(0);
		}
		else
		{
			MembershipLevels.AddItem(MembershipFunctions[q].Function.GetMembershipLevel(GetValue()));	
		}
	}

	idx = SelectFuzzyLevelIndex(MembershipLevels);

	if( idx == INDEX_NONE || idx < 0 )
	{
		`trace("Fuzzy level out of bounds", `red);
		return BFL_MAX;
	}

	CachedLevel = BamFuzzyLevels(idx);
	bRequiresUpdate = false;

	return CachedLevel;
}

/** Returns fuzzy levels based on membership levels of each fuzzy level from MembershipLevels array */
function int SelectFuzzyLevelIndex(array<float> MembershipLevels)
{
	local float highest;
	local int q, idx;

	if( MembershipLevels.Length == 0 )
	{
		return INDEX_NONE;
	}

	idx = INDEX_NONE;
	highest = 0;

	for(q = 0; q < MembershipLevels.Length; ++q)
	{
		if( MembershipLevels[q] > highest )
		{
			highest = MembershipLevels[q];
			idx = q;
		}
	}

	return idx;
}

/** Increases CurrentValue by Amount passed as parameter */
function Replenish(float Amount)
{
	CurrentValue = Max(MaxValue, CurrentValue + Amount);
	bRequiresUpdate = true;
}


defaultproperties
{
	MaxValue=100.0
	CurrentValue=100.0
	DecayRate=1.0

	bRequiresUpdate=true

	StatMods[BFL_VeryLow]=(Level=BFL_VeryLow)
	StatMods[BFL_Low]=(Level=BFL_Low)
	StatMods[BFL_Medium]=(Level=BFL_Medium)
	StatMods[BFL_High]=(Level=BFL_High)
	StatMods[BFL_VeryHigh]=(Level=BFL_VeryHigh)

	bRandomLimit=false
	MinLimit=90
	MaxLimit=110
	bRandomStartValue=false
	MinStartValue=40
	MaxStartValue=110
	bRandomDecayRate=false
	MinDecayRate=0.75
	MaxDecayRate=1.25

	
	Begin Object class=BamFuzzyMembershipFunction_Trapezoidal name=MemFunc_VeryLow
		A=-100
		B=-100
		C=0
		D=20
	End Object
	
	Begin Object class=BamFuzzyMembershipFunction_Triangular name=MemFunc_Low
		A=10
		B=30
		C=50
	End Object

	Begin Object class=BamFuzzyMembershipFunction_Trapezoidal name=MemFunc_Medium
		A=20
		B=40
		C=70
		D=90
	End Object

	Begin Object class=BamFuzzyMembershipFunction_Triangular name=MemFunc_High
		A=80
		B=90
		C=100
	End Object

	Begin Object class=BamFuzzyMembershipFunction_Trapezoidal name=MemFunc_VeryHigh
		A=90
		B=100
		C=1000
		D=1000
	End Object


	MembershipFunctions[BFL_VeryLow]=(Level=BFL_VeryLow,Function=MemFunc_VeryLow)
	MembershipFunctions[BFL_Low]=(Level=BFL_Low,Function=MemFunc_Low)
	MembershipFunctions[BFL_Medium]=(Level=BFL_Medium,Function=MemFunc_Medium)
	MembershipFunctions[BFL_High]=(Level=BFL_High,Function=MemFunc_High)
	MembershipFunctions[BFL_VeryHigh]=(Level=BFL_VeryHigh,Function=MemFunc_VeryHigh)
}