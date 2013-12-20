class BamSeqVar_Team extends SeqVar_Object
	hidecategories(SequenceVariable, SeqVar_Object)
	abstract;

var(BamSeqVar_Team) editconst string TeamType;

function BamActor_TeamManager GetTeamManager()
{
	return none;
}

function Object GetObjectValue()
{
	return GetTeamManager();
}

DefaultProperties
{
	VarName="Team"
	ObjName="Team"
	ObjCategory="Bam.Gameplay.Spawner"
	ObjValue=Team
	ObjColor=(R=127,G=127,B=255,A=255)
	SupportedClasses=(class'Object')
}