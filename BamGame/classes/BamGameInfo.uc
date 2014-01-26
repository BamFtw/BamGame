class BamGameInfo extends SimpleGame;

/** Reference to players team */
var BamActor_TeamManager PlayerTeam;

/** Reference to neutral team */
var BamActor_TeamManager NeutralTeam;

/** Class of game intensity that should be used */
var class<BamGameIntensity> GameIntensityClass;

/** reference to game intensity object */
var BamGameIntensity GameIntensity;

/** Copy of default function with one extra check */
function Killed(Controller Killer, Controller KilledPlayer, Pawn KilledPawn, class<DamageType> damageType)
{
	if( KilledPlayer != None && KilledPlayer.bIsPlayer && KilledPlayer.PlayerReplicationInfo != none /* added check */ )
	{
		KilledPlayer.PlayerReplicationInfo.IncrementDeaths();
		KilledPlayer.PlayerReplicationInfo.SetNetUpdateTime(FMin(KilledPlayer.PlayerReplicationInfo.NetUpdateTime, WorldInfo.TimeSeconds + 0.3 * FRand()));
		BroadcastDeathMessage(Killer, KilledPlayer, damageType);
	}

	if( KilledPlayer != None )
	{
		ScoreKill(Killer, KilledPlayer);
	}

	DiscardInventory(KilledPawn, Killer);
	NotifyKilled(Killer, KilledPlayer, KilledPawn, damageType);
}

/**  */
function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	if( GameIntensity != none )
	{
		GameIntensity.Tick(DeltaTime);
	}
}


/** Caches references to player and neutral teams and creates GameIntensity object */
event PreBeginPlay()
{
	super.PreBeginPlay();
	
	CreateGameIntensity();

	GetDefaultTeams();
}

function CreateGameIntensity()
{
	if( GameIntensityClass == none )
	{
		`trace("GameIntensity class is not set, spawning default", `yellow);
		GameIntensity = new class'BamGameIntensity';
		return;
	}

	GameIntensity = new GameIntensityClass;

	if( GameIntensity == none )
	{
		`trace("Failed to spawn GameIntensity, spawning default", `yellow);
		GameIntensity = new class'BamGameIntensity';
		return;
	}
}

/** Finds player and neutral team managers on the map, if not found creates them */
function GetDefaultTeams()
{
	local BamActor_TeamManager tm;
	local bool bPlayerTeamFound, bNeutralTeamFound;

	bPlayerTeamFound = false;
	bNeutralTeamFound = false;

	// go through all TeamManagers on the map and find Player and Neutral teams
	foreach class'WorldInfo'.static.GetWorldInfo().AllActors(class'BamActor_TeamManager', tm)
	{
		if( !bPlayerTeamFound && tm.bIsPlayerTeam && NeutralTeam != tm )
		{
			`trace("Found player team" @ tm @ tm.TeamName, `green);
			PlayerTeam = tm;
			bPlayerTeamFound = true;
		}

		if( !bNeutralTeamFound && tm.bIsNeutralTeam && PlayerTeam != tm )
		{
			`trace("Found neutral team" @ tm @ tm.TeamName, `green);
			NeutralTeam = tm;
			bNeutralTeamFound = true;
		}
	}

	// if player team was not found create it
	if( PlayerTeam == none )
	{
		`trace("Player team not found. Creating it.", `yellow);
		PlayerTeam = CreateTeam("PlayerTeam");
		PlayerTeam.bIsPlayerTeam = true;
		PlayerTeam.bIsNeutralTeam = false;
	}

	// if neutral team was not found create it
	if( NeutralTeam == none )
	{
		`trace("Neutral team not found. Creating it.", `yellow);
		NeutralTeam = CreateTeam("NeutralTeam");
		NeutralTeam.bIsPlayerTeam = false;
		NeutralTeam.bIsNeutralTeam = true;
	}
}

/**
 * Spawns team manager
 * @param teamName name of the team used for easy identification
 * @param teamClass class of team manager
 * @param teamMembers controllers that belong to this team
 */
function BamActor_TeamManager CreateTeam(string teamName, optional class<BamActor_TeamManager> teamClass = class'BamActor_TeamManager', optional array<BamAIController> teamMembers)
{
	local BamActor_TeamManager team;
	local int q;

	if( teamClass == none )
	{
		return none;
	}

	team = Spawn(teamClass);

	team.TeamName = (Len(teamName) == 0 ? string(team.Name) : teamName);

	for(q = 0; q < teamMembers.Length; ++q)
	{
		team.Join(teamMembers[q]);
	}

	return team;
}

/** Kills Pawns by dealing damage to them */
exec function BamKillPawns()
{
	local BamPawn pwn;

	foreach WorldInfo.AllPawns(class'BamPawn', pwn)
	{
		if( GetALocalPlayerController().Pawn != pwn )
		{
			pwn.TakeDamage(9999999, GetALocalPlayerController(), vect(0,0,0), vect(0,0,0), class'DamageType');
		}
	}
}

function Logout( Controller Exiting )
{
	local PlayerController PC;
	local int PCIndex;

	PC = PlayerController(Exiting);
	if ( PC != None )
	{
		if (AccessControl != None &&
			AccessControl.AdminLogout( PlayerController(Exiting) ))
		{
			AccessControl.AdminExited( PlayerController(Exiting) );
		}

		if ( PC.PlayerReplicationInfo != none && PC.PlayerReplicationInfo.bOnlySpectator )
		{
			NumSpectators--;
		}
		else
		{
			if (WorldInfo.IsInSeamlessTravel() || PC.HasClientLoadedCurrentWorld())
			{
				NumPlayers--;
			}
			else
			{
				NumTravellingPlayers--;
			}
			// Tell the online subsystem the number of players in the game
			UpdateGameSettingsCounts();
		}
		// This person has left during an arbitration period
		if (bUsingArbitration && bHasArbitratedHandshakeBegun && !bHasEndGameHandshakeBegun && PC.PlayerReplicationInfo != none)
		{
			`Log("Player "$PC.PlayerReplicationInfo.PlayerName$" has dropped");
		}
		// Unregister the player from the online layer
		UnregisterPlayer(PC);
		// Remove from the arbitrated PC list if in an arbitrated match
		if (bUsingArbitration)
		{
			// Find the PC in the list and remove it if found
			PCIndex = ArbitrationPCs.Find(PC);
			if (PCIndex != INDEX_NONE)
			{
				ArbitrationPCs.Remove(PCIndex,1);
			}
		}
	}
	//notify mutators that a player exited
	if (BaseMutator != None)
	{
		BaseMutator.NotifyLogout(Exiting);
	}
	if ( PC != None )
	{
		UpdateNetSpeeds();
	}
}

defaultproperties
{
	HUDType=class'BamHUD'
	DefaultPawnClass=class'BamAIPawn'
	PlayerControllerClass=class'BamPlayerController'
	GameIntensityClass=class'BamGameIntensity'
}