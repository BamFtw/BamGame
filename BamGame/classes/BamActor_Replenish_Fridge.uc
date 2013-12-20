class BamActor_Replenish_Fridge extends BamActor_Replenish
	placeable;

DefaultProperties
{
	Begin Object Name=Sprite
		Sprite=Texture2D'bam_hud_icons.Needs.needs_hunger'
	End Object

	NeedReplenishmentRates[0]=(NeedClass=class'BamNeed_Thirst',ReplenishmentRate=10.0)
	NeedReplenishmentRates[1]=(NeedClass=class'BamNeed_Hunger',ReplenishmentRate=25.0)

	ReplenishAnimationNames=(need_eat)	
}