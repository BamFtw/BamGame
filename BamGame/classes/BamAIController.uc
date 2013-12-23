class BamAIController extends AIController;


enum BamSubscribableEvents
{
	BSE_None,
	BSE_FinalDestinationReached,
	BSE_TakeDamage,
	BSE_DetectEnemy,
	BSE_HearNoise
};

struct BamHostilePawnDetectionData
{
	var Pawn Pawn;
	var float DetectionChance;
	var float LastRaiseTime;
};

struct BamHostilePawnData
{
	var Pawn Pawn;
	var Vector LastSeenLocation;
	var float LastSeenTime;
};

struct BamAIActionContainer
{
	var() class<BamAIAction> Class;
	var() editinline BamAIAction Archetype;
};



/** unrealscript can't store arrays of arrays so this one needs to be in the struct */
struct BamSubscribersList
{
	var array<delegate<BamSubscriber> > List;
};

/** List of all event subscribers, indexes of this array are the same as enums in BamSubscribableEvents */
var array<BamSubscribersList> SubscribersLists;


/**  */
var array<BamHostilePawnDetectionData> EnemyDetectionData;



/** Reference to controlled pawn */
var BamAIPawn BPawn;
/** reference to TeamManager this controller belongs to */
var BamActor_TeamManager Team;





/** While in 'Moving' state, how often should pathfinding algorithm be ran */
var() float PathfindingInterval;
/** Modifier of Pawns collision extent used while testing whether anyting is blocking its way */
var() float PathfindingFrontCollisionExtentMod;
/** Modifier of Pawns collision radius used while testing whether anyting is blocking its way */
var() float PathfindingFrontCollisionRadiusMultiplier;

/** Location on the Pawns path that Pawn is currently heading toward */
var Vector MoveLocation;
/** Location to which Pawn should head while in 'Moving' state */
var protectedwrite Vector FinalDestination;
/** Radius from FinalDestination location that allows for reaching it */
var protectedwrite float FinalDestinationDistanceOffset;
/** Last reached destination stored so FinalDestinationReached wouldn't be called multiple times for one location */
// var Vector LastReachedFinalDestination;
/**  */
var() float FinalDestCollisionRadiusMod;

/** Class of the default action that will be set on ActionManager creation (not needed if archetype is set) */
var() class<BamAIAction> DefaultActionClass;
/** Archetype of the default action that will be set on ActionManager creation (if set, DefaultActionClass is not needed) */
var() BamAIAction DefaultActionArchetype;

/** Flag that is used for switching between default and combat actions */
var bool bIsInCombat;

/** Action that is used while unit is out of combat */
var() BamAIActionContainer DefaultAction;
/** Action that is used while unit is in combat */
var() BamAIActionContainer CombatAction;


/** Class of the action manager that this controller will use */
var() class<BamAIActionManager> ActionManagerClass;
/** Reference to action manager that this controller uses */
var BamAIActionManager ActionManager;

/** Class of the need manager that this controller will use */
var() class<BamNeedManager> NeedManagerClass;
/** Reference to need manager that this controller uses */
var BamNeedManager NeedManager;


/** Actor used as focus point of the Pawn during movement */
var BamActor_MoveFocus MoveFocusActor;
var bool bUseMoveFocusActor;

/** Currently claimed cover */
var BamActor_Cover Cover;

// debug
var name currentState;

/** Delegate used for subscribing to certain events specified in BamSubscribableEvents enum */
delegate BamSubscriber(BamSubscriberParameters params);

/** Cleanup */
event Destroyed()
{
	`trace("Controller Destroyed", `green);
	BPawn = none;
	Pawn = none;
	Team = none;
	Cover = none;

	DefaultAction.Archetype = none;
	CombatAction.Archetype = none;

	ActionManager.Destroyed();
	ActionManager = none;

	MoveFocusActor.Destroy();

	super.Destroyed();
}

event PreBeginPlay()
{
	super.PreBeginPlay();

	SubscribersLists.Length = BSE_MAX;

	MoveFocusActor = Spawn(class'BamActor_MoveFocus', self, , , , , true);
}



event PostBeginPlay()
{
	super.PostBeginPlay();
}

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);

	BPawn = BamAIPawn(inPawn);

	if( SpawnActionManager() )
	{
		ActionManager.PushFront(SpawnDefaultAIAction());
	}

	SpawnNeedManager();
}

/** Creates action manager and sets its contoller reference */
function bool SpawnNeedManager()
{
	if( NeedManagerClass != none )
	{
		NeedManager = new NeedManagerClass;
	}

	if( NeedManager == none )
	{
		NeedManager = new class'BamNeedManager';
	}

	if( NeedManager == none )
	{
		`trace("Failed to create NeedManager", `red);
		return false;
	}

	NeedManager.Initialize(self);
	return true;
}

/** Creates action manager and sets its contoller reference */
function bool SpawnActionManager()
{
	if( ActionManagerClass != none )
	{
		ActionManager = new ActionManagerClass;
	}

	if( ActionManager == none )
	{
		ActionManager = new class'BamAIActionManager';
	}

	if( ActionManager == none )
	{
		`trace("Failed to create ActionManager", `red);
		return false;
	}

	ActionManager.Controller = self;
	return true;
}

function BamAIAction SpawnDefaultAIAction()
{
	if( DefaultAction.Archetype != none )
	{
		return new DefaultAction.Archetype.Class(DefaultAction.Archetype);
	}
	else if( DefaultAction.Class != none )
	{
		return new DefaultAction.Class;
	}

	return none;
}

event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	if( !bIsInCombat && IsInCombat() )
	{
		bIsInCombat = true;
		if( CombatAction.Archetype != none )
		{
			ActionManager.PushFront(new CombatAction.Archetype.Class(CombatAction.Archetype));//class'BamAIAction_Combat'.static.Create());
		}
		else if( CombatAction.Class != none )
		{
			ActionManager.PushFront(new CombatAction.Class);//class'BamAIAction_Combat'.static.Create());
		}
		else
		{
			`trace("combat action not set", `red);
		}
	}
	else if( bIsInCombat && !IsInCombat() )
	{
		bIsInCombat = false;
	}

	NeedManager.Tick(DeltaTime);

	// tick action manager
	if( ActionManager != none )
	{
		ActionManager.Tick(DeltaTime);
	}
}


event HearNoise(float Loudness, Actor NoiseMaker, optional Name NoiseType)
{
	super.HearNoise(Loudness, NoiseMaker, NoiseType);
	CallSubscribers(BSE_HearNoise, class'BamSubscriberParameters_HearNoise'.static.Create(self, BPawn, Loudness, NoiseMaker, NoiseType));
}

event SeeMonster(Pawn Seen)
{
	super.SeePlayer(Seen);
	SeePawn(Seen);
}

event SeePlayer(Pawn Seen)
{
	super.SeePlayer(Seen);
	SeePawn(Seen);
}

/** Called by SeeMonster and SeePlayer, checks if Seen is hostile and adds it to enemies list if needed */
function SeePawn(Pawn Seen)
{
	if( IsPawnHostile(Seen) )
	{
		EnemySpotted(Seen);
	}
}

/** Pawns TakeDamage event calls this one, used for notifying subscribers */
event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	CallSubscribers(BSE_TakeDamage, class'BamSubscriberParameters_TakeDamage'.static.Create(self, BPawn, Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser));
}

/** Returns whether pawn given as parameter is hostile */
function bool IsPawnHostile(Pawn pwn)
{
	if( pwn == none || Team == none )
	{
		return false;
	}

	return (Team.RelationToPawn(pwn) < 0);
}

/** Adds enemy information to EnemyData list or updates it, calls DetectEnemy subscribers */
function EnemySpotted(Pawn pwn)
{
	if( Team.EnemySpotted(pwn) )
	{
		CallSubscribers(BSE_DetectEnemy, class'BamSubscriberParameters_DetectEnemy'.static.Create(self, BPawn, pwn));
	}
}

/**
 * Returns whether distance between vectors given as parameter (v1 and v2) is smaller or equal to maxDistance
 */
function bool CompareVectors2D(Vector v1, Vector v2, optional float maxDistance = 0)
{
	return (Vsize2D(v1 - v2) <= maxDistance);
}

/**
 *  Returns Location of the next Point in the path to the goal that Controlled Pawn should head toward
 *  Checks if anything is blocking path and if so tries to avoid it
 *
 *  @param goal - final destination that should be reached
 */
function Vector FindNavMeshPath(Vector goal)
{
	local int q;
	local float TestMoveDistance, tempDistance;
	local array<Vector> availableMoveLocations;
	local Vector tempDestination, moveLoc, HitLocation, HitNormal, TraceEnd, Extent, TraceEndFinal;
	local Actor HitActor;

	moveLoc = goal;

	if( Pawn == none || !Pawn.IsAliveAndWell() )
	{
		return vect(0,0,0);
	}

	// default nav mesh pathfinding
	if( !NavigationHandle.PointReachable(goal) )
	{
		NavigationHandle.PathConstraintList = none;
		NavigationHandle.PathGoalList = none;
		NavigationHandle.ClearConstraints();

		class'NavMeshPath_Toward'.static.TowardPoint(NavigationHandle, goal);
		class'NavMeshGoal_At'.static.AtLocation(NavigationHandle, goal, Pawn.GetCollisionRadius(), true);

		if( NavigationHandle.FindPath() )
		{
			NavigationHandle.SetFinalDestination(goal);
			if( NavigationHandle.GetNextMoveLocation(tempDestination, Pawn.GetCollisionRadius()) && !CompareVectors2D(Pawn.Location, tempDestination, 16.0) )
			{
				moveLoc = tempDestination;
			}
		}
	}

	// check if there is anything in front of the pawn
	TestMoveDistance = Pawn.GetCollisionRadius() * PathfindingFrontCollisionRadiusMultiplier;
	if( TestMoveDistance > VSize2D(Pawn.Location - moveLoc) )
	{
		TestMoveDistance = VSize2D(Pawn.Location - moveLoc);
	}

	TraceEnd = moveLoc - Pawn.Location;
	TraceEnd.Z = Pawn.Location.Z;
	TraceEnd = Normal(TraceEnd) * TestMoveDistance;

	Extent = Pawn.GetCollisionExtent() * PathfindingFrontCollisionExtentMod;

	HitActor = Trace(HitLocation, HitNormal, Pawn.Location + TraceEnd, Pawn.Location,  true, Extent);

	// if there is, test if pawn can step to the side
	if( HitActor != none )
	{
		for(q = -2; q < 3; ++q)
		{
			if( q == 0 )
				continue;

			TraceEndFinal = Pawn.Location + (TraceEnd << MakeRotator(0, q * 16384, 0));
			TraceEndFinal.Z = Pawn.Location.Z;
			HitActor = Trace(HitLocation, HitNormal, TraceEndFinal, Pawn.Location,  true, Extent);
			
			if( HitActor == none && NavigationHandle.PointReachable(TraceEndFinal) )
				availableMoveLocations.AddItem(TraceEndFinal);
		}
		
		// if step to the side location was found get the closest one to the goal
		if( availableMoveLocations.Length > 0 )
		{
			tempDistance = 999999999;

			for(q = 0; q < availableMoveLocations.Length; ++q)
			{
				if( Vsize2D(moveLoc - availableMoveLocations[q]) < tempDistance )
				{
					tempDistance = Vsize2D(moveLoc - availableMoveLocations[q]);
					goal = availableMoveLocations[q];
				}
			}

			return goal;
		}
	}

	return moveLoc;
}


function bool SetTeamManager(BamActor_TeamManager teamMgr)
{
	if( teamMgr == none )
	{
		return false;
	}

	if( Team != none )
	{
		Team.Quit(self);
	}

	Team = teamMgr;

	Team.Join(self);
	return true;
}

function bool HasEnemies()
{
	return Team.HasEnemies();
}

event bool IsInCombat(optional bool bForceCheck)
{
	return Team.IsInCombat();
}

function array<Vector> GetEnemyLocations()
{
	return Team.GetEnemyLocations();
}

function bool GetEnemyData(Pawn enemyPwn, out BamHostilePawnData data)
{
	return Team.GetEnemyData(enemyPwn, data);
}

function ClaimCover(BamActor_Cover cov)
{
	if( cov == none )
	{
		return;
	}

	UnClaimCover();

	if( cov.Claim(self) )
	{
		Cover = cov;
	}
}


function UnClaimCover()
{
	if( Cover == none )
	{
		return;
	}
	
	Cover.UnClaim();
	Cover = none;
}


/**
 * Changes state to the on given as parameter
 *
 * @return name of the state that was just entered
 */
function name ChangeStateRequest(name stateName)
{
	if( GetStateName() != stateName )
	{
		GotoState(stateName);
	}

	return stateName;
}

/** state transition to 'Idle' */
function name Begin_Idle()
{
	return ChangeStateRequest('Idle');
}

/** state transition to 'Moving' */
function name Begin_Moving()
{
	return ChangeStateRequest('Moving');
}

/** Returns whether controller is in idle state */
function bool Is_Idle()
{
	return IsInState('Idle');
}

/** Returns whether controller is in moving state */
function bool Is_Moving()
{
	return IsInState('Moving');
}

/**
 * Initializes move parameters and begins movment
 * @param newFinalDest - location to which pawn should travel
 * @param MaxDistanceOffset - (optional, 0 by default) distance from the FinalDestination that will allow reaching it
 * @param bRun - (optional, false by default) whether Pawn should run or walk
 * @param FDRSub - (optional) delegate (BamSubscriber) that will be called when FinalDestination will be reached
 */
function InitializeMove(Vector newFinalDest, optional float MaxDistanceOffset = 0.0, optional bool bRun = false, optional delegate<BamSubscriber> FDRSub = none)
{
	if( FDRSub != none )
	{
		Subscribe(BSE_FinalDestinationReached, FDRSub);
	}

	BPawn.SetWalking(bRun);
	SetFinalDestination(newFinalDest, MaxDistanceOffset);
	Begin_Moving();
}

/**
 * Sets the location of the FinalDestination
 * @param destination - point that Pawn should try reach
 * @param MaxDistanceOffset - distance from the FinalDestination that will allow reaching it
 */
function SetFinalDestination(Vector destination, optional float MaxDistanceOffset = 0.0)
{
	FinalDestination = destination;
	FinalDestinationDistanceOffset = FMax(0, MaxDistanceOffset);
}

/** Called by 'Moving' state when Pawn gets within CollisionRadius range with FinalDestination, informs active Action about it */
function FinalDestinationReached()
{
	CallSubscribers(BSE_FinalDestinationReached, class'BamSubscriberParameters_FinalDestinationReached'.static.Create(self, BPawn, FinalDestination));
}

/** Stops latent functions and zeroes Pawn movment variables */
function StopMovement()
{
	StopLatentExecution();
	
	if( Pawn != none )
	{
		Pawn.ZeroMovementVariables();
	}
}


/** Subscribes delegate given as parameter to event from BamSubscribableEvents enum */
function Subscribe(BamSubscribableEvents evnt, delegate<BamSubscriber> sub)
{
	// check if event is correct and delegate is not none
	if( evnt <= BSE_None || evnt >= BSE_MAX || sub == none )
	{
		return;
	}

	// do not allow duplicates
	if( SubscribersLists[evnt].List.Find(sub) != INDEX_NONE )
	{
		return;
	}

	SubscribersLists[evnt].List.AddItem(sub);
}

/** Removes subscribed delegate from the list for specified event */
function UnSubscribe(BamSubscribableEvents evnt, delegate<BamSubscriber> sub)
{
	// check if event is correct and delegate is not none
	if( evnt <= BSE_None || evnt >= BSE_MAX || sub == none )
	{
		return;
	}

	SubscribersLists[evnt].List.RemoveItem(sub);
}

/** 
 * Calls all subscribers of the event given as parameter and passes params object to them.
 * Clears subscribers list for event given as parameter.
 */
function CallSubscribers(BamSubscribableEvents evnt, optional BamSubscriberParameters params)
{
	local int q;
	local array<delegate<BamSubscriber> > subsList;
	local delegate<BamSubscriber> deleg;

	// check if event is correct
	if( evnt <= BSE_None || evnt > BSE_MAX )
	{
		`trace("Wrong event given as parameter (" $ evnt $ ")" , `red);
		return;
	}

	// check if size of SubscribersLists is correct
	if( SubscribersLists.Length <= evnt )
	{
		`trace("Subscribers lists array is too short (" $ SubscribersLists.Length $ ")", `red);
		return;
	}

	subsList = SubscribersLists[evnt].List;

	for(q = 0; q < subsList.Length; ++q)
	{
		deleg = subsList[q];
		SubscribersLists[evnt].List.RemoveItem(deleg);
		deleg(params);
	}
}







/**_______________________________________________________Idle */
auto state Idle
{
	event BeginState(name PreviousStateName)
	{
		StopMovement();
	}
}

/**_______________________________________________________Moving */
state Moving
{
	event EndState(name NextStateName)
	{
		StopMovement();
	}

	event Tick(float DeltaTime)
	{
		local float distToFD, FDRange;
		global.Tick(DeltaTime);

		if( Pawn == none )
		{
			return;
		}

		distToFD = VSize2D(FinalDestination - Pawn.Location);
		FDRange = (Pawn.GetCollisionRadius() * FinalDestCollisionRadiusMod) + FinalDestinationDistanceOffset;

		if( distToFD <= FDRange )
		{
			FinalDestinationDistanceOffset = 0;
			FinalDestinationReached();
			Begin_Idle();
		}
	}

begin:
	if( Pawn != none )
	{
		SetTimer(PathfindingInterval, false, nameof(StopLatentExecution));
		MoveLocation = FindNavMeshPath(FinalDestination);
		
		if( MoveLocation != vect(0, 0, 0) )
		{
			MoveTo(MoveLocation, bUseMoveFocusActor ? MoveFocusActor : none);
		}
	}

	Sleep(0.01);
	goto('begin');
}


defaultproperties
{
	bIsPlayer=true

	bIsInCombat=false

	PathfindingInterval=0.5
	PathfindingFrontCollisionExtentMod=0.75
	PathfindingFrontCollisionRadiusMultiplier=2.5

	NeedManagerClass=class'BamNeedManager_Example'
	ActionManagerClass=class'BamAIActionManager'

	DefaultAction=(class=class'BamAIAction_Idle',Archetype=none)
	CombatAction=(class=class'BamAIAction_Idle',Archetype=none)

	FinalDestCollisionRadiusMod=1.0
}