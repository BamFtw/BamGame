class BAmAIAction_ZombieAttack extends BamAIAction;

var() Pawn Target;

var() name AnimationName;

function Tick(float DeltaTime)
{
	local Rotator rot;

	rot = Rotator(Target - Manager.Controller.Pawn.Location);
	rot.Roll = 0;
	rot.Pitch = 0;

	Manager.Controller.Pawn.SetDesiredRotation(rot, true);
}

function OnBegin()
{
	local float AnimDuration;
	AnimDuration = Manager.Controller.BPawn.CharacterFullBodySlot.PlayCustomAnim(AnimationName, 1.0, 0.1, 0.1, false, true);
	
	if( AnimDuration <= 0 )
	{
		bIsFinished = true;
	}

	Manager.Controller.Begin_Idle();
	SetDuration(AnimDuration);
	Manager.BlockActionClass(class'BamAIAction', AnimDuration);
}

function OnEnd()
{
	Manager.UnblockActionClass(class'BamAIAction');
	Manager.Controller.BPawn.CharacterFullBodySlot.StopCustomAnim(0.1);
}

function OnBlocked()
{
	bIsFinished = true;
}

static function BAmAIAction_ZombieAttack Create(Pawn inTarget)
{
	local BAmAIAction_ZombieAttack action;
	action = new default.class;
	action.Target = inTarget;
	return action;
}

DefaultProperties
{
	bIsBlocking=true
	bBlockAllLanes=true
	
	AnimationName=zombie_melee_attack
}