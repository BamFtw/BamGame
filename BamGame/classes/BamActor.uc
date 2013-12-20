class BamActor extends Actor
	abstract
	placeable;

var BamGameInfo Game;

event PreBeginPlay()
{
	super.PreBeginPlay();

	Game = BamGameInfo(class'WorldInfo'.static.GetWorldInfo().Game);
}

DefaultProperties
{
	Begin Object class=CylinderComponent name=MyCylinderComponent
		CollisionHeight=45.0
		CollisionRadius=20.0
		bAlwaysRenderIfSelected=true
		BlockActors=false
		BlockZeroExtent=false
		BlockNonZeroExtent=false
	End Object
	Components.Add(MyCylinderComponent)
	CollisionComponent=MyCylinderComponent

	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=none
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Pawns"
		Scale=0.3
	End Object
	Components.Add(Sprite)

	Begin Object class=ArrowComponent name=Arrow
		Scale=1.0
		ArrowSize=0.8
	End Object
	Components.Add(Arrow)

	bEdShouldSnap=true
}