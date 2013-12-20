class BamAnimNode_Covering extends AnimNodeBlendList;

enum BamAnimNodeCoveringState
{
	CoverState_OutOfCover,
	CoverState_StandingLeft,
	CoverState_StandingRight,
	CoverState_CrouchingLeft,
	CoverState_CrouchingRight
};

var BamAnimNodeCoveringState CurrentState;

var() float BlendDuration;

//native function SetBlendTarget( float BlendTarget, float BlendTime );
//native function SetActiveChild( INT ChildIndex, FLOAT BlendTime );

function SetState(BamAnimNodeCoveringState newState, optional float blendTime = BlendDuration)
{
	if( CurrentState == newState )
		return;

	SetActiveChild(newState, blendTime);
	CurrentState = newState;
}

defaultproperties
{
	Children(0)=(Name="Out of Cover",Weight=1.0)
	Children(1)=(Name="Standing Left")
	Children(2)=(Name="Standing Right")
	Children(3)=(Name="Crouching Left")
	Children(4)=(Name="Crouching Right")
	bFixNumChildren=true
	bSkipBlendWhenNotRendered=true

	CurrentState=CoverState_OutOfCover;
	BlendDuration=0.6
}