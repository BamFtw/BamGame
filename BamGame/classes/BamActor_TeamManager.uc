class BamActor_TeamManager extends BamActor
	placeable
	dependson(BamAIController)
	hidecategories(Object, Debug, Collision, Mobile, Advanced, Attachment, Physics);

/** Name of the team */
var() string TeamName;

/** Certain debug information use this for easy identifiaction */
var() Color TeamColor;

/** Whether this is the team player belongs to */
var() bool bIsPlayerTeam<EditCondition=!bIsNeutralTeam>;

/** Whether this is the neutral team */
var() bool bIsNeutralTeam<EditCondition=!bIsPlayerTeam>;

/** List of all the teams that are hostile */
var() array<BamActor_TeamManager> Enemies;

/** List of controllers that belong to this team */
var array<BamAIController> Members;

/** List of the enemies that this team knows about */
var array<BamHostilePawnData> EnemyData;




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
	}
}

/** Returns whether pawn given as parameter is capable of dealing damage from distance */
function bool IsEnemyRanged(Pawn pwn)
{
	local BamWeapon bWpn;

	if( pwn == none )
	{
		return false;
	}

	bWpn = BamWeapon(pwn.Weapon);

	if( bWpn == none )
	{
		return pwn.Weapon != none;
	}

	return !bWpn.bIsStrictlyMeleeWeapon;
}

/** Returns whether team is currently in combat */
function bool IsInCombat()
{
	return HasEnemies();
}

/** Returns whether team knows about any enemy */
function bool HasEnemies()
{
	return EnemyData.Length > 0;
}

/** Returns whether team know about any enemy that is capable of dealing damge from distance */
function bool HasRangedEnemies()
{
	local int q;

	for(q = 0; q < EnemyData.Length; ++q)
	{
		if( IsEnemyRanged(EnemyData[q].Pawn) )
		{
			return true;
		}
	}

	return false;
}

/** Returns whether pawn given as parameter is hostile to this team */
function bool IsPawnHostile(Pawn pwn)
{
	local BamActor_TeamManager team;

	if( BamPlayerPawn(pwn) != none )
	{
		team = Game.PlayerTeam;
	}
	else if( BamAIPawn(pwn) == none || BamAIPAwn(pwn).BController == none || BamAIPAwn(pwn).BController.Team == none )
	{
		return false;
	}
	else
	{
		team = BamAIPAwn(pwn).BController.Team;
	}

	return (team != none && Enemies.Find(team) != INDEX_NONE);
}

/** Returns whether team given as parameter is hostile toward this one */
function bool IsTeamHostile(BamActor_TeamManager mgr)
{
	return Enemies.Find(mgr) != INDEX_NONE;
}

/** Returns list of vestors representing last known locations of all of the enemies */
function array<Vector> GetEnemyLocations()
{
	local array<Vector> locations;
	local int q;
	
	for(q = 0; q < EnemyData.Length; ++q)
	{
		locations.AddItem(EnemyData[q].LastSeenLocation);
	}

	return locations;
}

/** Sums all of the LastSeenLocations and returns average of those */
function Vector GetAverageEnemyLocation()
{
	local Vector sum;
	local int q;

	for(q = 0; q < EnemyData.Length; ++q)
	{
		sum += EnemyData[q].LastSeenLocation;
	}

	return sum / EnemyData.Length;
}

/** Returns list of vestors representing last known locations of all of the enemies that are capable of dealing damage from distance */
function array<Vector> GetRangedEnemyLocations()
{
	local array<Vector> locations;
	local int q;
	
	for(q = 0; q < EnemyData.Length; ++q)
	{
		if( !IsEnemyRanged(EnemyData[q].Pawn) )
		{
			continue;
		}

		locations.AddItem(EnemyData[q].LastSeenLocation);
	}

	return locations;
}

/**  */
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
			if( BamPawn(pwn) == none )
			{
				EnemyData[q].LastSeenLocation = pwn.Location;
			}
			else
			{
				EnemyData[q].LastSeenLocation = BamPawn(pwn).GetCenterLocation();
			}
			return false;
		}
	}

	data.Pawn = pwn;
	data.LastSeenLocation = pwn.Location;
	data.LastSeenTime = WorldInfo.TimeSeconds;

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
	{
		return false;
	}
	
	if( Members.Find(ctrl) != INDEX_NONE )
	{
		return true;
	}
	
	if( ctrl.Team != none )
	{
		ctrl.Team.Quit(ctrl);
	}

	Members.AddItem(ctrl);
	ctrl.Team = self;

	return true;
}

function bool Quit(BamAIController ctrl)
{
	local int idx;

	if( ctrl == none || Members.Length == 0 )
	{
		return false;
	}

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
}