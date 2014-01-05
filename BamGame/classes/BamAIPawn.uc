class BamAIPawn extends BamPawn;

/** Reference to BamAIController */
var BamAIController BController;

/** Percent of default GroundSpeed that should be used */
var float GroundSpeedPct;


/** Takes into account Controllers ViewPitch */
simulated function Rotator GetAdjustedAimFor(Weapon W, vector StartFireLoc)
{
	local Rotator rot;

	rot.Yaw = Rotation.Yaw;
	rot.Pitch = GetViewPitch();

	return rot;
}

/** Returns controllers ViewPitch */
function float GetViewPitch()
{
	return BController.ViewPitch;
}

/**  */
event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	// to prevent bouncing
	Velocity.Z = 0;

	if( BController != none && BController.Team != none )
	{
		DrawDebugCylinder(Location + vect(0, 0, 1) * GetCollisionHeight(), Location + vect(0, 0, 6) * GetCollisionHeight(), 4, 12, BController.Team.EditorIconColor.R, BController.Team.EditorIconColor.G, BController.Team.EditorIconColor.B, false);
	}
}



/** Sets ground speed multiplier */
function SetGroundSpeedPct(float pct)
{
	GroundSpeedPct = FMax(0, pct);
}

/** Sets reference to BamAIController */
function PossessedBy(Controller C, bool bVehicleTransition)
{
	super.PossessedBy(C, bVehicleTransition);
	BController = BamAIController(C);
}

/** Spawns default controller */
event PostBeginPlay()
{
	super.PostBeginPlay();

	if( Controller == none )
	{
		SpawnDefaultController();
	}
}

/** Changes taken damage depending on DamageTakenMultiplier, informs controller about taken damage */
event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	// modify damage value by GameIntensity
	if( GetALocalPlayerController().Pawn != self && BController != none )
	{
		// check if player team
		if( BController.Team == Game.PlayerTeam )
		{
			Damage *= Game.GameIntensity.GetParamValue(class'BamGIParam_DamageTakenMultiplier_Friendly');
		}
		// check if hostile team
		else if( Game.PlayerTeam.IsTeamHostile(BController.Team) )
		{
			Damage *= Game.GameIntensity.GetParamValue(class'BamGIParam_DamageTakenMultiplier_Hostile');
		}
		// not friendly nor friendly, must be neutral
		else
		{
			Damage *= Game.GameIntensity.GetParamValue(class'BamGIParam_DamageTakenMultiplier_Neutral');
		}
	}
	
	super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	
	if( IsAliveAndWell() && BController != none )
	{
		BController.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	}
}


/** Returns whether pawn given as parameter is hostile */
function bool IsPawnHostile(Pawn pwn)
{
	return BController.IsPawnHostile(pwn);
}


State Dying
{
	ignores TakeDamage;

	event BeginState(Name PreviousStateName)
	{
		if( ProjectileCatcher != none )
		{
			ProjectileCatcher.Destroy();
			ProjectileCatcher = none;
		}

		if( Controller != none )
		{
			Controller.Destroy();
		}

		super.BeginState(PreviousStateName);
	}
}



defaultproperties
{
	ControllerClass=class'BamAIController'
	Physics=PHYS_Falling
	CollisionType=COLLIDE_BlockAllButWeapons

	GroundSpeedPct=1.0
}