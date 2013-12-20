class BamNeed extends Object
	hidecategories(Object)
	dependson(BamAIPawn)
	abstract;

enum BamFuzzyLevels
{
	BFL_VeryLow<DisplayName=Very Low>,
	BFL_Low<DisplayName=Low>,
	BFL_Medium<DisplayName=Medium>,
	BFL_High<DisplayName=High>,
	BFL_VeryHigh<DisplayName=Very High>
};

struct BamNeedPawnStatMod
{
	var() BamPawnStat Stat;
	var() float Value;
};

struct BamNeedPawnStatModContainer
{
	var() editoronly editconst BamFuzzyLevels Level;
	var() array<BamNeedPawnStatMod> Mods;
};



var BamNeedManager Manager;

/** List of delegates that determine level of membership for each fuzzy level from BamFuzzyLevels */
var array<delegate<BamMembershipFunctionDelegate> > MembershipFunctions;


var BamFuzzyLevels CachedLevel;
var bool bRequiresUpdate;

/** Name of this need */
var() editconst const protectedwrite string NeedName;

/** Maximum level of this need */
var() private float MaxValue;
var(Random) bool bRandomLimit;
var(Random) float MinLimit;
var(Random) float MaxLimit;

/** Current level of this need */
var() private float CurrentValue;
var(Random) bool bRandomStartValue;
var(Random) float MinStartValue;
var(Random) float MaxStartValue;

/** rate at which this needs value decreases per second */
var() private float DecayRate;
var(Random) bool bRandomDecayRate;
var(Random) float MinDecayRate;
var(Random) float MaxDecayRate;

var(Mods) editfixedsize array<BamNeedPawnStatModContainer> StatMods;









delegate float BamMembershipFunctionDelegate(float val);

function Initialize()
{
	if( bRandomLimit )
		MaxValue = RandRange(MinLimit, MaxLimit);
	
	if( bRandomStartValue )
		CurrentValue = Min(RandRange(MinStartValue, MaxStartValue), MaxValue);

	if( bRandomDecayRate )
		DecayRate = RandRange(MinDecayRate, MaxDecayRate);
}

function Tick(float dt)
{
	CurrentValue = FMax(0, CurrentValue - DecayRate * dt);
	bRequiresUpdate = true;
}

function GetStatMods(out array<float> Values)
{
	local int w, currentLevel;

	while( Values.Length < BPS_MAX )
		Values.AddItem(0);

	if( bRequiresUpdate )
		GetFuzzyLevel();

	currentLevel = CachedLevel;

	for(w = 0; w < StatMods[currentLevel].Mods.Length; w++)
	{
		if( StatMods[currentLevel].Mods[w].Stat < BPS_MAX && StatMods[currentLevel].Mods[w].Stat >= 0 )
			Values[StatMods[currentLevel].Mods[w].Stat] += StatMods[currentLevel].Mods[w].Value;
	}
}

function float GetValue()
{
	return CurrentValue;
}

function float GetValuePct()
{
	return FClamp(CurrentValue / MaxValue, 0, 1);
}

function BamFuzzyLevels GetFuzzyLevel()
{
	local int q, idx;
	local array<float> MembershipLevels;
	local delegate<BamMembershipFunctionDelegate> deleg;

	if( !bRequiresUpdate )
		return CachedLevel;

	for(q = 0; q < MembershipFunctions.Length; ++q)
	{
		deleg = MembershipFunctions[q];
		if( deleg == none )
		{
			MembershipLevels.AddItem(0);
		}
		else
		{
			MembershipLevels.AddItem(deleg(GetValue()));
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

function int SelectFuzzyLevelIndex(array<float> MembershipLevels)
{
	local float highest;
	local int q, idx;

	if( MembershipLevels.Length == 0 )
		return INDEX_NONE;

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

function float MF_VeryLow(float val)
{
	if( val <= 0 )
		return 1;

	return TriangleFunction(val, 0, 0, 20);
}

function float MF_Low(float val)
{
	return TriangleFunction(val, 10, 30, 50);
}

function float MF_Medium(float val)
{
	return TrapezoidalFunction(val, 20, 40, 70, 90);
}

function float MF_High(float val)
{
	return TriangleFunction(val, 80, 90, 100);
}

function float MF_VeryHigh(float val)
{
	if( val >= 100.0 )
		return 1;

	return TriangleFunction(val, 90, 100, 100);
}

/** Returns level of membership of value parameter to trapezoidal function specified by a, b, c, d params */
function float TrapezoidalFunction(float value, float a, float b, float c, float d)
{
	if( !(a <= b && b <= c && c <= d) )
	{
		`trace("Trapezoidal function provided with bad params", `red);
		return 0;
	}

	if( value <= a || value >= d )
		return 0;

	if( value >= b && value <= c )
		return 1;

	if( value < b )
		return (value - a) / (b - a);

	if( value > c )
		return (d - value) / (d - c);
}

/** Returns level of membership of value parameter to triangular function specified by a, b, c params */
function float TriangleFunction(float value, float a, float b, float c)
{
	if( !(a <= b && b <= c) )
	{
		`trace("Triangle function provided with bad params", `red);
		return 0;
	}

	return TrapezoidalFunction(value, a, b, b, c);
}

defaultproperties
{
	MaxValue=100.0
	CurrentValue=100.0
	DecayRate=1.0

	bRequiresUpdate=true

	StatMods[BFL_VeryLow]=(Level=)
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

	MembershipFunctions[BFL_VeryLow]=MF_VeryLow
	MembershipFunctions[BFL_Low]=MF_Low
	MembershipFunctions[BFL_Medium]=MF_Medium
	MembershipFunctions[BFL_High]=MF_High
	MembershipFunctions[BFL_VeryHigh]=MF_VeryHigh
}