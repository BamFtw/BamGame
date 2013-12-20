class BamSeqVar_Team_Neutral extends BamSeqVar_Team;

function BamActor_TeamManager GetTeamManager()
{
	local BamGameInfo Game;

	Game = BamGameInfo(class'WorldInfo'.static.GetWorldInfo().Game);

	if( Game == none )
	{
		`trace("Game is not BamGameInfo", `red);
		return none;
	}

	return Game.NeutralTeam;
}

DefaultProperties
{
	TeamType="Neutral"
	VarName="Team - Neutral"
	ObjName="Team - Neutral"
	ObjCategory="Bam.Gameplay.Spawner"
}