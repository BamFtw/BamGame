class BamNeedManager extends Object;

struct BamNeedContainer
{
	var() class<BamNeed> Class;
	var() BamNeed Archetype;
};

/** Controller that uses this manager */
var BamAIController Controller;

/** List of needs that should be spawned during initialization */
var array<BamNeedContainer> DefaultNeeds;
/** List of needs */
var() array<BamNeed> Needs;



function Initialize(BamAIController inController)
{
	local int q, w;
	local BamNeed need;

	Controller = inController;

	// remove duplicates and bad entries
	for(q = 0; q < DefaultNeeds.Length; ++q)
	{
		if( DefaultNeeds[q].Archetype == none && DefaultNeeds[q].class == none )
			DefaultNeeds.Remove(q--, 1);

		for(w = q + 1; w < DefaultNeeds.Length; w++)
		{
			if( DefaultNeeds[q].Archetype == none && DefaultNeeds[w].Archetype == none )
			{
				if( DefaultNeeds[q].Class == DefaultNeeds[w].Class )
					DefaultNeeds.Remove(w--, 1);
			}
			else 
			{
				if( DefaultNeeds[q].Archetype == DefaultNeeds[w].Archetype )
					DefaultNeeds.Remove(w--, 1);
			}
		}
	}

	// create needs
	for(q = 0; q < DefaultNeeds.Length; ++q)
	{
		if( DefaultNeeds[q].Archetype != none )
		{
			need = new DefaultNeeds[q].Archetype.Class(DefaultNeeds[q].Archetype);
		}
		else if( DefaultNeeds[q].Class != none )
		{
			need = new DefaultNeeds[q].Class;
		}

		if( need != none )
		{
			need.Manager = self;
			Needs.AddItem(need);
		}
	}
}

function Tick(float DeltaTime)
{
	local int q;

	if( Controller == none || Controller.Pawn == none || !Controller.Pawn.IsAliveAndWell() )
		return;

	for(q = 0; q < Needs.Length; ++q)
	{
		Needs[q].Tick(DeltaTime);
	}

	UpdatePawn(BamAIPawn(Controller.Pawn));
}

function UpdatePawn(BamAIPawn pwn)
{
	local array<float> Values;
	local int q;

	if( pwn == none )
		return;
		
	Values.Length = BPS_MAX;

	for(q = 0; q < Needs.Length; ++q)
	{
		Needs[q].GetStatMods(Values);
	}

	pwn.UpdateStats(Values);
}
