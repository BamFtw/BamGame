class BAmAIAction_ZombieAttack extends BamAIAction;

var() Pawn Target;

/** Names of animation */
var() array<name> AnimationNames;

function Tick(float DeltaTime)
{
	local Rotator rot;

	if( Target == none || !Target.IsAliveAndWell() )
	{
		Finish();
		return;
	}

	rot = Rotator(Target.Location - Manager.Controller.Pawn.Location);
	rot.Roll = 0;
	rot.Pitch = 0;

	Manager.Controller.Pawn.SetDesiredRotation(rot);
}

function OnBegin()
{
	local float AnimDuration;

	if( AnimationNames.Length == 0 )
	{
		`trace("AnimationNames array is empty", `red);
		return;
	}

	AnimDuration = Manager.Controller.BPawn.CharacterFullBodySlot.PlayCustomAnim(AnimationNames[Rand(AnimationNames.Length)], 1.0, 0.1, 0.1, false, true);
	
	if( AnimDuration <= 0 )
	{
		`trace("Animation duration is 0", `red);
		Finish();
	}

	Manager.Controller.Begin_Idle();
	SetDuration(AnimDuration);
	Manager.BlockActionClass(class'BamAIAction', AnimDuration);
}

function OnEnd()
{
	Manager.Controller.Pawn.LockDesiredRotation(false);
	Manager.UnblockActionClass(class'BamAIAction');
	Manager.Controller.BPawn.CharacterFullBodySlot.StopCustomAnim(0.1);
}

function OnBlocked()
{
	Finish();
}





static function BAmAIAction_ZombieAttack Create_ZombieAttack(Pawn inTarget)
{
	local BAmAIAction_ZombieAttack action;
	action = new class'BAmAIAction_ZombieAttack';
	action.Target = inTarget;
	return action;
}

DefaultProperties
{
	bIsBlocking=true
	bBlockAllLanes=true

	AnimationNames=(zombie_melee_attack)
}