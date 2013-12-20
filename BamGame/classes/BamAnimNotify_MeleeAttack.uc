class BamAnimNotify_MeleeAttack extends AnimNotify_Scripted;

event Notify(Actor Owner, AnimNodeSequence AnimSeqInstigator)
{
	if( BamPawn(Owner) == none )
		return;

	BamPawn(Owner).DealMeleeDamage();
}