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




/** Returns lanes this action is running on */
function array<BamAIactionLane> GetOccupiedLanes()
{
	local array<BamAIactionLane> result;
	local int q;

	// if action does not block all available lanes return Lanes array
	if( !bBlockAllLanes )
		return Lanes;

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

	Tick(DeltaTime);
}

/** Called each Controller Tick if this action is not blocked */
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

/** Sets duration of this action */
function SetDuration(float inDuration)
{
	Duration = inDuration;
}

/** Returns maximum duration of this action */
function float GetDuration()
{
	return Duration;
}

/** Returns how much time this action will run for */
function float TimeLeft()
{
	if( Duration <= 0 )
		return -1;

	return (Duration - TimeElapsed);
}

/** Sets the lanes this action is runing on */
function SetLanes(array<BamAIActionLane> inLanes)
{
	Lanes = inLanes;
}

function SetBlocking(optional bool newBlocking = bIsBlocking, optional bool blockAll = bBlockAllLanes)
{
	bIsBlocking = newBlocking;
	bBlockAllLanes = blockAll;
}

function Finish()
{
	bIsFinished = true;
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