/**
 * Object used for comunication between actions responsible for covering
 */
class BamCoverActionData extends Object
	editinlinenew
	hidecategories(Object);

/** Current cover */
var BamActor_Cover Cover;


/** List of covers previously ocupied, used for lowering desirability of most recently occupied ones */
var array<BamActor_Cover> PrevCovers;
/** How many covers can be stored in PrevCovers */
var int MaxPrevCoversCount;
/** Desirability mod applied to last taken cover and all other covers in PrevCovers list with decreasing effect */
var(Desirability) float MostRecentCoverDesirabilityMod;


/** Min time Pawn can stay in cover */
var(Idle) float MinCoverIdleTime;
/** Max time Pawn can stay in cover */
var(Idle) float MaxCoverIdleTime;



/** Number of times PopOut failed since last success */
var int FailedPopOutCount;
/** How many times can pop out fail before FailedPopOutReplacementAction is set instead of cover actions */
var(PopOut) int FailedPopOutThreashold;
/** Action that will be used when FailedPopOutCount hits FailedPopOutThreashold */
var(PopOut) BamAIActionContainer FailedPopOutReplacementAction;

/** Max distance that Pawn can traver to pop out from cover */
var(PopOut) float MaxPopOutDistance;
/** Min time of the popout */
var(PopOut) float MinPopOutDuration;
/** Max time of the popout */
var(PopOut) float MaxPopOutDuration;


/** Max distance from Pawn to Cover that allows cover to be desirable */
var(Search) float MaxCoverSearchDistance;
/** For how long cover actions should be blocked after failed cover search */
var(Search) float FailedSearchCoverBlockDuration;
/** Action that should be used when covering fails */
var(Search) BamAIActionContainer FailedCoverSearchReplacementAction;




/** Sets reference to new cover, unclaims (not on controller) current one, resets failed popout count */
function ClaimedCover(BamActor_Cover cov)
{
	if( cov == none )
		return;

	if( Cover != none && Cover != cov )
	{
		UnclaimedCover();
	}

	Cover = cov;
	FailedPopOutCount = 0;
}

/** Adds current cover to PrevCovers list */
function UnclaimedCover()
{
	if( Cover == none )
		return;

	// do not allow duplicates
	if( PrevCovers.Find(Cover) != INDEX_NONE )
		PrevCovers.RemoveItem(Cover);

	// for keeping track of recently left covers
	PrevCovers.InsertItem(0, Cover);

	// remove overflow
	while( PrevCovers.Length > MaxPrevCoversCount )
		PrevCovers.Remove(PrevCovers.Length - 1, 1);
}

/** Returns desirability modifier for cover goven as parameter based on its position in PrevCovers list */
function float GetCoverDesirabilityMod(BamActor_Cover cov)
{
	local int idx;

	idx = PrevCovers.Find(cov);

	if( idx == INDEX_NONE )
		return 1.0;

	return MostRecentCoverDesirabilityMod + idx * ((1.0 - MostRecentCoverDesirabilityMod) / MaxPrevCoversCount);
}

/** Increments number of failed pop outs */
function FailedPopOut()
{
	FailedPopOutCount++;
}

/** Resets number of failed pop out atempts */
function SucceededPopOut()
{
	FailedPopOutCount = 0;
}

/** Returns for how long Pawn should stay in cover */
function float GetCoverIdleDuration()
{
	return RandRange(MinCoverIdleTime, MaxCoverIdleTime);
}

/** Returns duration of next pop out */
function float GetCoverPopOutDuration()
{
	return RandRange(MinPopOutDuration, MaxPopOutDuration);
}

DefaultProperties
{
	Cover=none
	
	MaxPrevCoversCount=3
	MostRecentCoverDesirabilityMod=0.25

	MinCoverIdleTime=1.0
	MaxCoverIdleTime=3.5
	MaxCoverSearchDistance=1600.0
	FailedSearchCoverBlockDuration=3.5

	FailedPopOutCount=0
	FailedPopOutThreashold=2
	MaxPopOutDistance=160.0
	MinPopOutDuration=2.0
	MaxPopOutDuration=3.5

	FailedPopOutReplacementAction=(Class=class'BamAIAction_AdvanceOnEnemies')
	FailedCoverSearchReplacementAction=(Class=class'BamAIAction_AdvanceOnEnemies')
}