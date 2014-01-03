class BamAIAction extends Object
	editinlinenew
	abstract
	hidecategories(Object);

enum BamAIActionLane
{
	Lane_Moving,
	Lane_Firing,
	Lane_Covering,
	Lane_Needs
};

/** Reference to ActionManager this action belongs to */
var BamAIActionManager Manager;

/** Whether this action blocks occupied lanes */
var private bool bIsBlocking;

/** Lanes this action occupies */
var() private array<BamAIActionLane> Lanes;

/** If true there is no need to to set Lanes array, GetOccupiedLanes will return array of all available lanes */
var() private bool bBlockAllLanes;

/** Whether this action is finished and can be removed */
var protectedwrite bool bIsFinished;

/** How long this action is active */
var protectedwrite float TimeElapsed;

/** How long this action should last */
var() private float Duration;

/** Whether action is being blocked by other action */
var bool bIsBlocked;

/** If greater than 0 Tick function will not be called from MasterTick, MasterTick decreases its value */
var float TickBreakTime;

/** Returns lanes this action is running on */
function array<BamAIactionLane> GetOccupiedLanes()
{
	local array<BamAIactionLane> result;
	local int q;

	// if action does not block all available lanes return Lanes array
	if( !bBlockAllLanes )
	{
		return Lanes;
	}

	// add all available lanes to result array
	for(q = 0; q < Lane_MAX; ++q)
		result.AddItem(BamAIActionLane(q));

	return result;
}

/** Returns whether this action is being blocked by other */
function bool IsBlocked()
{
	return bIsBlocked;
}

/** Returns whether this action is blocking its lanes */
function bool IsBlocking()
{
	return bIsBlocking;
}

/** Returns whether this action is finished, if so Manager will remove it */
function bool IsFinished()
{
	return bIsFinished;
}

/** Increments time this action is active, calls overridable Tick */
final function MasterTick(float DeltaTime)
{
	if( Manager == none || Manager.Controller == none || Manager.Controller.Pawn == none )
	{
		`trace(self @ "Manager, Controller or Pawn is none", `red);
		Finish();
		return;
	}

	TimeElapsed += DeltaTime;

	if( Duration > 0 && TimeElapsed >= Duration )
	{
		Finish();
	}

	if( TickBreakTime > 0 )
	{
		TickBreakTime -= DeltaTime;
		return;
	}

	Tick(DeltaTime);
}

/** Called each Controller Tick if this action is not blocked and TickBreakTime is not greater than 0 */
function Tick(float DeltaTime);

/** Called right after this action gets inserted into the Managers action list */
function OnBegin();

/** Called right before this action gets removed from the Managers action list */
function OnEnd();

/** Called the first time (until unblocking) this action is not Ticked becouse of being lane blocked */
function OnBlocked();

/** Called before ticking it if it was blocked during previous tick */
function OnUnblocked();

/** Sets the TimeElapsed to 0 */
function ResetTimeElepsed()
{
	TimeElapsed = 0;
}

/**
 * Sets actions duration
 * @param newDuration - how long should action last
 * @param bResetTimeElepsed - (optional, true by default) whether to reset TimeElapsed variable
 */
function SetDuration(float newDuration, optional bool bResetTimeElepsed = true)
{
	if( bResetTimeElepsed )
	{
		ResetTimeElepsed();
	}

	Duration = newDuration;
}

/** Returns maximum duration of this action */
function float GetDuration()
{
	return Duration;
}

/** Returns for how long this action will run */
function float TimeLeft()
{
	if( Duration <= 0 )
	{
		return -1;
	}

	return (Duration - TimeElapsed);
}

/** 
 * Sets the lanes this action is runing on
 * @param inLanes - lanes this action occupies
 */
function SetLanes(array<BamAIActionLane> inLanes)
{
	Lanes = inLanes;
}

/** 
 * Sets blocking flags
 * @param newBlocking - (optional, current value by default) whether action is blocking or not
 * @param blockAll - (optional, current value by default) whether action should block all available lanes
 */
function SetBlocking(optional bool newBlocking = bIsBlocking, optional bool blockAll = bBlockAllLanes)
{
	bIsBlocking = newBlocking;
	bBlockAllLanes = blockAll;
}

/** Changes bIsFinished flag so function can be removed from ActionManager */
function Finish()
{
	bIsFinished = true;
}

/** Blocks Tick function for specified amount of time */
function SetTickBreak(float newDuration)
{
	TickBreakTime = FMax(0, newDuration);
}

/** Cancels Tick function break */
function CancelTickBreak()
{
	SetTickBreak(0);
}

DefaultProperties
{
	bIsBlocked=false
	bIsBlocking=false
	bBlockAllLanes=false
	bIsFinished=false
	TimeElapsed=0
	Duration=0
	Lanes=()
}