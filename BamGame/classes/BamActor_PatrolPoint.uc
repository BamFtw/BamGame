class BamActor_PatrolPoint extends BamActor
	placeable;

var() float MinWaitTime;

var() float MaxWaitTime;


function float GetWaitTime()
{
	return FMax(0, RandRange(MinWaitTime, MaxWaitTime));
}

DefaultProperties
{
	Begin Object Name=Sprite
		Sprite=Texture2D'bam_hud_icons.PatrolPoint'
	End Object

	Begin Object Name=MyCylinderComponent
		CollisionRadius=20.0
		CollisionHeight=45.0
		bAlwaysRenderIfSelected=true
		BlockNonZeroExtent=false
		BlockZeroExtent=false
		BlockActors=false
		CollideActors=false
	End Object
	Components.Add(MyCylinderComponent)
	CollisionComponent=MyCylinderComponent

	MinWaitTime=1.0
	MaxWaitTime=1.0
}