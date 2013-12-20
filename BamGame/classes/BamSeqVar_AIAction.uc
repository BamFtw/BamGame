class BamSeqVar_AIAction extends SeqVar_Object
	hidecategories(SequenceVariable, SeqVar_Object);

var() editinline BamAIAction Action;

function BamAIAction GetAIAction()
{
	if( Action == none )
	{
		`trace("Action is none", `yellow);
		return none;
	}

	return new Action.Class(Action);
}

DefaultProperties
{
	VarName="AIAction"

	ObjName="AIAction"
	ObjCategory="Bam.Gameplay.Spawner"
	ObjValue=BamAIAction
	ObjColor=(R=127,G=255,B=127,A=255)
	SupportedClasses=(class'Object')
}