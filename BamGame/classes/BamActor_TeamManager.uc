class BamActor_TeamManager extends BamActor
	placeable
	dependson(BamAIController)
	hidecategories(Object, Debug, Collision, Mobile, Advanced, Attachment, Physics);

/** Name of the team */
var() string TeamName;

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

/** Returns whether pawn given as parameter is hostile to this team */
function bool IsPawnHostile(Pawn pwn)
{
	if( BamAIPawn(pwn) == none || BamAIPAwn(pwn).BController.Team == none )
	{
		return false;
	}

	return (Enemies.Find(BamAIPAwn(pwn).BController.Team) != INDEX_NONE);
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
			EnemyData[q].LastSeenLocation = pwn.Location;
			return false;
		}
	}

	data.Pawn = pwn;
	data.LastSeenLocation = pwn.Location;
	data.LastSeenTime = WorldInfo.TimeSeconds;

	`trace(self @"Someone spotted" @ pwn, `cyan);
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