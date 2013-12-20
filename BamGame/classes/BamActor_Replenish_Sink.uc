class BamActor_Replenish_Sink extends BamActor_Replenish
	placeable;

DefaultProperties
{
	Begin Object Name=Sprite
		Sprite=Texture2D'bam_hud_icons.Needs.needs_thirst'
	End Object

	NeedReplenishmentRates[0]=(NeedClass=class'BamNeed_Thirst',ReplenishmentRate=30.0)

	ReplenishAnimationNames=(need_drink)
}