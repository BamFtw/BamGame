class BamSeqAction_SetAIAction extends BamSeqAction
	hidecategories(SequenceAction);


event Activated()
{
	local BamAIPawn pwn;
	local BamAIController ctrl;
	local BamAIAction aiAction;
	local SeqVar_Object svObj;

	if( VariableLinks.Length >= 1 && VariableLinks[0].LinkedVariables.Length > 0 && VariableLinks[0].LinkedVariables[0] != none )
	{
	 	svObj = SeqVar_Object(VariableLinks[0].LinkedVariables[0]);

		pwn = BamAIPawn(svObj.GetObjectValue());
		ctrl = BamAIController(svObj.GetObjectValue());
	}

	if( pwn == none && ctrl == none )
	{
		`trace("Object conmected to Pawn/Controller link contains object of incorrect class", `red);
		return;
	}

	if( VariableLinks.Length >= 2 && VariableLinks[1].LinkedVariables.Length > 0 && VariableLinks[1].LinkedVariables[0] != none )
	{
	 	aiAction = BamSeqVar_AIAction(VariableLinks[1].LinkedVariables[0]).GetAIAction();
	}

	if( aiAction == none )
	{
		`trace("AIAction is none", `red);
		return;
	}

	if( pwn != none )
	{
		ctrl = pwn.BController;
		if( ctrl == none )
		{
			`trace("Pawn has wrong controller", `red);
			return;
		}
	}

	ctrl.ActionManager.PushFront(aiAction);

	ActivateOutputLink(0);
}


DefaultProperties
{
	ObjCategory="Bam.Gameplay.AI"
	ObjName="Set AI Action"

	ObjColor=(R=63,G=160,B=63,A=255)

	VariableLinks.Empty
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Pawn/Controller",bWriteable=false,MaxVars=1)
	VariableLinks(1)=(ExpectedType=class'BamSeqVar_AIAction',LinkDesc="Initial Action",bWriteable=false,MaxVars=1)
}