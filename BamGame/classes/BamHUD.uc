class BamHUD extends HUD;

var Texture2D Crosshair;

var BamAIPawn PawnToDebug;

event PostRender()
{
	local int q, debugLine;

	super.PostRender();
	Canvas.SetPos(int(Canvas.SizeX * 0.5 - Crosshair.SizeX * 0.5), int(Canvas.SizeY * 0.5 - Crosshair.SizeY * 0.5), 0);
	Canvas.DrawTexture(Crosshair, 1.0);

	if( PawnToDebug != none && PawnToDebug.IsAliveAndWell() )
	{
		debugLine = 10;

		DebugRect(Canvas.Project(PawnToDebug.Location), 80, 255, 0, 0, 127);
		DebugRect(Canvas.Project(PawnToDebug.BController.FinalDestination), 30, 0, 0, 255, 127);

		DebugStr("Debuging:" @ PawnToDebug.Name, debugLine);
		DebugStr("State: pwn (" $ PawnToDebug.GetStateName() $ "), ctrl (" $ PawnToDebug.BController.GetStateName() $ ")", debugLine);

		DebugStr("GroundSpeed:" @ PawnToDebug.GroundSpeed, debugLine);
		DebugStr("Awareness:" @ PawnToDebug.Awareness, debugLine);
		DebugStr("WeaponSpread:" @ PawnToDebug.WeaponSpread, debugLine);
		DebugStr("DTM:" @ PawnToDebug.DamageTakenMultiplier, debugLine);


		DebugStr("Location:" @ PawnToDebug.Location, debugLine);
		DebugStr("Final destination:" @ PawnToDebug.BController.FinalDestination, debugLine);
		DebugStr("Dist to final dest:" @ VSize2D(PawnToDebug.Location - PawnToDebug.BController.FinalDestination), debugLine);
		


		DebugStr("Needs:", debugLine);
		for(q = 0; q < PawnToDebug.BController.NeedManager.Needs.Length; ++q)
			DebugStr((q + 1) $ "." @ PawnToDebug.BController.NeedManager.Needs[q] @ "=" @ PawnToDebug.BController.NeedManager.Needs[q].GetFuzzyLevel(), debugLine, 20);

		DebugStr("Action stack:", debugLine);
		for(q = 0; q < PawnToDebug.BController.ActionManager.Actions.Length; ++q)
			DebugStr((q + 1) $ "." @ PawnToDebug.BController.ActionManager.Actions[q], debugLine, 20);

	}
}

function DebugRect(Vector pos, int size, byte R, byte G, byte B, byte A)
{
	Canvas.SetDrawColor(R, G, B, A);
	Canvas.SetPos(pos.X - int(size * 0.5), pos.Y - int(size * 0.5));
	Canvas.DrawRect(size, size);
}

function DebugStr(string str, out int lineY, optional int lineXOffset)
{
	Canvas.Font = class'Engine'.static.GetSmallFont();

	Canvas.SetDrawColor(0, 0, 0, 255);
	Canvas.SetPos(10 + lineXOffset + 1, lineY + 1, 0);
	Canvas.DrawText(str);

	Canvas.SetDrawColor(255, 255, 255, 255);
	Canvas.SetPos(10 + lineXOffset, lineY, 0);
	Canvas.DrawText(str);

	lineY += 15;
}

function DebugNextPawn()
{
	local array<BamAIPawn> allPawns;
	local BamAIPawn pwn;
	local int idx;


	foreach WorldInfo.DynamicActors(class'BamAIPawn', pwn)
	{
		if( pwn != none && pwn.IsAliveAndWell() )
			allPawns.AddItem(pwn);
	}

	if( allPawns.length == 0 )
	{
		`trace("No alive pawns to debug", `cyan);
		PawnToDebug = none;
		return;
	}

	idx = allPawns.Find(PawnToDebug);

	if( PawnToDebug == none || idx == INDEX_NONE || idx == allPawns.length - 1 )
	{
		PawnToDebug = allPawns[0];
		return;
	}
	else
	{
		PawnToDebug = allPawns[idx + 1];
		return;
	}
}

defaultproperties
{
	Crosshair=Texture2D'bam_hud_crosshair.Textures.crosshair'
}