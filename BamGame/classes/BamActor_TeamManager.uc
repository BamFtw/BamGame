class BamActor_TeamManager extends BamActor
	placeable
	dependson(BamAIController)
	hidecategories(Object, Debug, Collision, Mobile, Advanced, Attachment, Physics);

/** */
var() string TeamName;

/** */
var() bool bIsPlayerTeam<EditCondition=!bIsNeutralTeam>;

/** */
var() bool bIsNeutralTeam<EditCondition=!bIsPlayerTeam>;

/** List of all the teams that are friendly */
var() array<BamActor_TeamManager> Friends;
/** List of all the teams that are hostile */
var() array<BamActor_TeamManager> Enemies;
/** */
var array<BamAIController> Members;

/**  */
var array<BamHostilePawnData> EnemyData;

var float MaxEnemyOutOfSightDuration;

function Tick(float DeltaTime)
{
	local int q;
	super.Tick(DeltaTime);
	
	for(q = 0; q < EnemyData.Length; ++q)
	{
		if( EnemyData[q].Pawn == none || !EnemyData[q].Pawn.IsAliveAndWell() )
		{
			EnemyData.Remove(q--, 1);
			continue;
		}

		// DrawDebugBox(EnemyData[q].Pawn.Location, vect(6, 6, 40), 255, 255, 255, false);
		// DrawDebugBox(EnemyData[q].LastSeenLocation, vect(6, 6, 40), 255, 0, 0, false);
		// DrawDebugLine(EnemyData[q].Pawn.Location, EnemyData[q].LastSeenLocation, 255, 255, 255, false); 
	}


}

function bool IsInCombat()
{
	return HasEnemies();
}

function bool HasEnemies()
{
	return EnemyData.Length > 0;
}


function array<Vector> GetEnemyLocations()
{
	local array<Vector> locations;
	local int q;
	
	for(q = 0; q < EnemyData.Length; ++q)
	{

		/**if( `TimeSince(EnemyData[q].LastSeenTime) < MaxEnemyOutOfSightDuration )
		{
		}*/

		locations.AddItem(EnemyData[q].LastSeenLocation);
	}

	return locations;
}

function bool GetEnemyData(Pawn enemyPwn, out BamHostilePawnData data)
{
	local int q;

	if( EnemyData.Length == 0 )
		return false;

	for(q = 0; q < EnemyData.Length; ++q)
	{
		if( EnemyData[q].Pawn == enemyPwn )
		{
			data = EnemyData[q];
			return true;
		}
	}

	return false;
}

function bool EnemySpotted(Pawn pwn)
{
	local int q;
	local BamHostilePawnData data;

	if( pwn == none )
	{
		return false;
	}

	for (q = 0; q < EnemyData.length; ++q)
	{
		if( EnemyData[q].Pawn == pwn )
		{
			EnemyData[q].LastSeenLocation = pwn.Location;
			return false;
		}
	}

	data.Pawn = pwn;
	data.LastSeenLocation = pwn.Location;
	data.LastSeenTime = WorldInfo.TimeSeconds;

	`trace(self @"Someone spotted"@pwn, `cyan);
	EnemyData.AddItem(data);

	return true;
}	

event PostBeginPlay()
{
	super.PostBeginPlay();

	if( TeamName == "" )
	{
		TeamName = string(self.name);
	}
}

function bool Join(BamAIController ctrl)
{
	if( ctrl == none )
		return false;
	
	if( Members.Find(ctrl) != INDEX_NONE )
		return true;
	
	Members.AddItem(ctrl);

	ctrl.Team = self;

	return true;
}

function bool Quit(BamAIController ctrl)
{
	local int idx;

	if( ctrl == none || Members.Length == 0 )
		return false;

	idx = Members.Find(ctrl);

	if( idx != INDEX_NONE )
	{
		Members.Remove(idx, 1);
		
		if( ctrl.Team == self )
		{
			ctrl.Team = none;
		}

		return true;
	}

	return false;
}

/** 
 * Returns relation of the pawn given as parameter to this team
 *
 * @return (0) - neutral, (-1) - hostile, (1) - friendly
 */
function int RelationToPawn(Pawn pwn)
{
	local BamAIPawn aiPwn;
	local BamActor_TeamManager team;

	if( pwn == none || !pwn.IsAliveAndWell() )
		return 0;

	aiPwn = BamAIPawn(pwn);
	if( aiPwn != none )
	{
		team = aiPwn.BController.Team;
	}
	else if( pwn.IsPlayerPawn() )
	{
		team = Game.PlayerTeam;
	}

	return RelationToTeam(team);
}

/** 
 * Returns relation of the controller given as parameter to this team
 *
 * @return (0) - neutral, (-1) - hostile, (1) - friendly
 */
function int RelationToController(Controller C)
{
	local BamActor_TeamManager team;

	if( PlayerController(C) != none )
	{
		team = Game.PlayerTeam;
	}
	else if( BamAIController(C) != none )
	{
		team = BamAIController(C).Team;
	}

	return RelationToTeam(team);
}

/** 
 * Returns relation of the team given as parameter to this team
 *
 * @return (0) - neutral, (-1) - hostile, (1) - friendly
 */
function int RelationToTeam(BamActor_TeamManager team)
{
	if( team != none && team != Game.NeutralTeam )
	{
		if( Friends.Find(team) != INDEX_NONE )
		{
			return 1;
		}
		else if( Enemies.Find(team) != INDEX_NONE )
		{
			return -1;
		}
	}

	return 0;
}


DefaultProperties
{
	Components.Remove(Arrow);
	Components.Remove(MyCylinderComponent);

	CollisionComponent=none

	Begin Object Name=Sprite
		Sprite=Texture2D'bam_hud_icons.teamManager'
		Scale=0.5
	End Object

	bStatic=false
	bNoDelete=false

	TeamName=""
	bIsPlayerTeam=false

	MaxEnemyOutOfSightDuration=7.0
}