class BamSeqVar_Team_Player extends BamSeqVar_Team;

function BamActor_TeamManager GetTeamManager()
{
	local BamGameInfo Game;

	Game = BamGameInfo(class'WorldInfo'.static.GetWorldInfo().Game);

	if( Game == none )
	{
		`trace("Game is not BamGameInfo", `red);
		return none;
	}

	return Game.PlayerTeam;
}

DefaultProperties
{
	TeamType="Player"
	VarName="Team - Player"
	ObjName="Team - Player"
	ObjCategory="Bam.Gameplay.Spawner"
}