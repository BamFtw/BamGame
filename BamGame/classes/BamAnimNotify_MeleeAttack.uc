class BamAnimNotify_MeleeAttack extends AnimNotify_Scripted;

/** Calls owners DealMeleeDamage function if owner is BamPawn */
event Notify(Actor Owner, AnimNodeSequence AnimSeqInstigator)
{
	if( BamPawn(Owner) == none )
		return;

	BamPawn(Owner).DealMeleeDamage();
}