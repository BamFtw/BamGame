class BamActor_Replenish_Bed extends BamActor_Replenish
	placeable;

DefaultProperties
{
	Begin Object Name=Sprite
		Sprite=Texture2D'bam_hud_icons.Needs.needs_tiredness'
	End Object

	NeedReplenishmentRates[0]=(NeedClass=class'BamNeed_Tiredness',ReplenishmentRate=10.0)

	ReplenishAnimationNames=(need_sleep)
}