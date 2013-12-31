class BamAIActionManager extends Object;


struct BamBlockedActionClassData
{
	/** Class of actions that should not be allowed */
	var class<BamAIAction> ActionClass;
	/** Time until class is unblocked */
	var float TimeLeft;
	/** Whether to check if tested classes inherit from this one */
	var bool bUseInheritance;

	StructDefaultProperties
	{
		bUseInheritance=true
	}
};


/** reference to WorilInfo */
var WorldInfo WorldInfo;

/** Controller that is using this manager */
var BamAIController Controller;

/** List of the actions */
var array<BamAIAction> Actions;

/** List of classes that are not allowed to be pushed on the Actions list */
var array<BamBlockedActionClassData> LockedActionClasses;

/** Sets reference to Controller and WorldInfo, calls Initialize */
final function MasterInitialize(BamAIController C)
{
	if( C == none )
	{
		`trace("Initialized with invalid controller", `red);
		return;
	}

	Controller = C;
	WorldInfo = C.WorldInfo;

	Initialize();
}

/** Used for initializing custom ActionManagers */
function Initialize();


/** Manages Actions and LockedActionClasses lists */
function Tick(float DeltaTime)
{
	local int q, w;
	local array<BamAIActionLane> blockedLanes, currentActionLanes;
	local array<BamAIAction> tempActions;

	if( Controller == none || Controller.Pawn == none || !Controller.Pawn.IsAliveAndWell() )
	{
		return;
	}

	// so compiler wouldn't warn about uninitialized use of variable
	blockedLanes.Length = 0;

	// tick down blocked action classes times
	if( LockedActionClasses.Length > 0 )
	{
		for(q = 0; q < LockedActionClasses.Length; ++q)
		{
			LockedActionClasses[q].TimeLeft -= DeltaTime;
			if( LockedActionClasses[q].TimeLeft <= 0 )
				LockedActionClasses.Remove(q--, 1);
		}
	}

	// create copy of action list so adding and removing them during 
	// iteration wouldn't cause problems
	tempActions = Actions;

	// tick all unblocked actions
	if( tempActions.Length > 0 )
	{
		for(q = 0; q < tempActions.Length; ++q)
		{
			if( tempActions[q] == none )
			{
				`trace("Action is none", `red);
				continue;
			}

			// cache lanes current action is on
			currentActionLanes = tempActions[q].GetOccupiedLanes();

			if( !LaneOverlap(blockedLanes, currentActionLanes) )
			{
				// if action is blocking add its lanes to blockedLanes
				if( tempActions[q].IsBlocking() )
				{
					for(w = 0; w < currentActionLanes.Length; w++)
					{
						if( blockedLanes.Find(currentActionLanes[w]) == INDEX_NONE )
						{
							blockedLanes.AddItem(currentActionLanes[w]);
						}
					}
				}

				// check if action was blocked last tick and unblock it if needed
				if( tempActions[q].IsBlocked() )
				{
					tempActions[q].bIsBlocked = false;
					tempActions[q].OnUnblocked();
					AILog("Unblocked action:" @ tempActions[q]);
				}

				// tick current action if it is not finished
				if( !tempActions[q].IsFinished() )
				{
					tempActions[q].MasterTick(DeltaTime);
				}
			}
			else
			{
				// block action if needed
				if( !tempActions[q].IsBlocked() )
				{
					tempActions[q].bIsBlocked = true;
					tempActions[q].OnBlocked();
					AILog("Blocked action:" @ tempActions[q]);
				}
			}

			// remove action from the list if it is finished
			if( tempActions[q].IsFinished() )
			{
				AILog("Action finished:" @ tempActions[q]);
				Remove(tempActions[q]);
			}
		}
	}
}

/** Removes references to Controller and actions */
function Destroyed()
{
	Controller = none;
	Actions.Length = 0;
	LockedActionClasses.Length = 0;
}

/** Returns whether action list is empty */
function bool IsEmpty()
{
	return Actions.Length == 0;
}

/** Returns first action on the Action list */
function BamAIAction Front()
{
	return Actions.Length == 0 ? none : Actions[0];
}

/** Returns the last action on the Action list */
function BamAIAction Back()
{
	return Actions.Length == 0 ? none : Actions[Actions.Length - 1];
}

/** Retruns whether any of the elements in a1 exists in a2 */
function bool LaneOverlap(array<BamAIActionLane> a1, array<BamAIActionLane> a2)
{
	local int q, w;

	if( a1.Length == 0 || a2.Length == 0 )
		return false;

	for(q = 0; q < a1.Length; ++q)
	{
		for(w = 0; w < a2.Length; w++)
		{
			if( a1[q] == a2[w] )
			{
				return true;
			}
		}
	}

	return false;
}

/** 
 * Removes all actions from the list
 * @param bEndAction - (optional, false by default) whether removed action should have their OnEnd functions called before they are removed
 */
function Clear(optional bool bEndActions = false)
{
	if( bEndActions )
	{
		AILog("Clearing action list WITH ending action");
		while( !IsEmpty() )
		{
			Actions[0].bIsBlocked = false;
			Actions[0].OnEnd();
			Actions.Remove(0, 1);
		}
	}
	else
	{
		AILog("Clearing action list WITHOUT ending action");
	}

	Actions.Length = 0;
}

/** 
 * Removes action from the list
 * @param action - action to remove
 * @return action removed from the list or none if action was not on the list
 */
function BamAIAction Remove(BamAIAction action)
{
	if( action != none && Actions.Find(action) != INDEX_NONE )
	{
		action.OnEnd();
		Actions.RemoveItem(action);
		AILog("Removed action:" @ action);
		return action;
	}

	return none;
}

/** 
 * Adds action to the front of the list
 * @param action - action to insert
 */
function PushFront(BamAIAction action)
{
	if( action == none || IsClassBlocked(action.Class) )
	{
		return;
	}

	if( Actions.Length == 0 )
	{
		Actions.AddItem(action);
	}
	else
	{
		Actions.InsertItem(0, action);
	}

	AILog("Action inserted at the start:" @ action);

	InitAction(action);
}

/** 
 * Adds action to the back of the list
 * @param action - action to insert
 */
function PushBack(BamAIAction action)
{
	if( action == none || IsClassBlocked(action.Class) )
	{
		return;
	}
	
	AILog("Action inserted at the end:" @ action);
	Actions.AddItem(action);
	InitAction(action);
}

/** 
 * Inserts action after another action
 * @param action - action to insert
 * @param marker - action will be inserted after this one
 */
function bool InsertAfter(BamAIAction action, BamAIAction marker)
{
	if( InsertNearMarker(action, marker, 1) )
	{
		InitAction(action);
		return true;
	}

	return false;
}

/** 
 * Inserts action before another action
 * @param action - action to insert
 * @param marker - action will be inserted before this one
 */
function bool InsertBefore(BamAIAction action, BamAIAction marker)
{
	if( InsertNearMarker(action, marker) )
	{
		InitAction(action);
		return true;
	}

	return false;
}

/** 
 * Sets Actions action manager reference and initializes it 
 * @param action - action to initialize
 */
private function InitAction(BamAIAction action)
{
	AILog("Initializing action:" @ action);
	action.Manager = self;
	action.OnBegin();
}

/** 
 * 	Inserts action near merker action with specified ofset
 *  @param action - action to insert
 *  @param marker - action will be inserted near this one
 *  @param offset - offset from the markers position
 */
private function bool InsertNearMarker(BamAIAction action, BamAIAction marker, optional int offset = 0)
{
	local int index;

	if( action == none || marker == none || IsClassBlocked(action.Class) )
	{
		return false;
	}

	index = Actions.Find(marker);

	if( index != INDEX_NONE )
	{
		Actions.InsertItem(index + offset, action);
		AILog("Action (" $ action $ "inserted near" @ marker);
		return true;
	}

	return false;
}

/**
 * Blocks possibility of pushing action of given type for blockDuration time
 * @param class<BamAIAction> actClass - class of the actions that shuld be blocked
 * @param float              blockDuration - for how long specified actions should be blocked
 * @param optional bool      bInheritance - whether child classes of actClass should also be blocked
 */
function BlockActionClass(class<BamAIAction> actClass, float blockDuration, optional bool bInheritance = true)
{
	local int q;
	local BamBlockedActionClassData data;

	if( actClass == none || blockDuration <= 0 )
	{
		return;
	}

	for(q = 0; q < LockedActionClasses.Length; ++q)
	{
		if( LockedActionClasses[q].ActionClass == actClass )
		{
			return;
		}
	}

	AILog("Blocked action class" @ actClass);

	data.bUseInheritance = bInheritance;
	data.ActionClass = actClass;
	data.TimeLeft = blockDuration;

	LockedActionClasses.AddItem(data);
}

/** 
 * Removes action class given as parameter from list of blocked classes
 * @param class<BamAIAction> actClass - class that should be allowed to be pushed
 */
function UnblockActionClass(class<BamAIAction> actClass)
{
	local int q;

	if( actClass == none )
	{
		return;
	}

	for(q = 0; q < LockedActionClasses.Length; ++q)
	{
		if( LockedActionClasses[q].ActionClass == actClass )
		{
			LockedActionClasses.Remove(q--, 1);
			return;
		}
	}
}



/** Returns whether class given as parameter is not currently allowed to be added to Action list */
function bool IsClassBlocked(class<BamAIAction> actClass)
{
	local int q;

	if( actClass == none )
	{
		return false;
	}

	for(q = 0; q < LockedActionClasses.Length; ++q)
	{
		if( (LockedActionClasses[q].ActionClass == actClass) || (LockedActionClasses[q].bUseInheritance && ClassIsChildOf(actClass, LockedActionClasses[q].ActionClass)) )
		{
			return true;
		}
	}
	
	return false;
}

function AILog(string msg)
{
	if( Controller != none )
	{
		Controller.AILog_Internal(msg);
	}
}