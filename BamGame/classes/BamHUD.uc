class BamHUD extends HUD;

/** Crosshair texture */
var Texture2D Crosshair;

/** Pawn that should be debugged */
var BamAIPawn PawnToDebug;



event PostRender()
{
	super.PostRender();
	DrawCrosshair();

`if(`notdefined(FINAL_RELEASE))
	DrawPawnDebug();
`endif
}




/** Draws CrosshairTexture at the center of the screen */
function DrawCrosshair()
{
	Canvas.SetDrawColor(255, 255, 255, 255);
	Canvas.SetPos(int(Canvas.SizeX * 0.5 - Crosshair.SizeX * 0.5), int(Canvas.SizeY * 0.5 - Crosshair.SizeY * 0.5), 0);
	Canvas.DrawTexture(Crosshair, 1.0);
}


`if(`notdefined(FINAL_RELEASE))

/** Draws information about PawnToDebug on the screen */
function DrawPawnDebug()
{
	local int q, debugLine, height, width;
	local string str;


	if( PawnToDebug != none && PawnToDebug.IsAliveAndWell() )
	{
		str = "X";
		Canvas.Font = Font'bam_hud_font_ubuntuMono.Fonts.ubuntu_mono_22';

		Canvas.Font.GetStringHeightAndWidth(str, height, width);

		debugLine = 10;

		// draw rectangles at the pawns location and its final destination
		if( Vector(GetALocalPlayerController().Rotation) dot (PawnToDebug.Location - GetALocalPlayerController().Pawn.Location) > 0 )
		{
			DebugRect(Canvas.Project(PawnToDebug.Location), 80, 255, 0, 0, 127);
			DebugRect(Canvas.Project(PawnToDebug.BController.FinalDestination), 30, 0, 0, 255, 127);
		}

		Canvas.SetDrawColor(255,255,255,255);
		
		DebugStr("Pawn:" @ PawnToDebug.Name, debugLine, , height);
		DebugStr("Health:" @ PawnToDebug.Health @ "/" @ PawnToDebug.HealthMax, debugLine, , height);
		// DebugStr("State: pwn (" $ PawnToDebug.GetStateName() $ "), ctrl (" $ PawnToDebug.BController.GetStateName() $ ")", debugLine);
		// DebugStr("", debugLine);

		DebugStr("Team:" @ PawnToDebug.BController.Team.TeamName, debugLine, , height);	
		DebugStr("", debugLine);

		DebugStr("Predkosc ruchu       :" @ PawnToDebug.GroundSpeed, debugLine, , height);
		DebugStr("Czujosc              :" @ PawnToDebug.Awareness, debugLine, , height);
		DebugStr("Rozrzut broni        :" @ PawnToDebug.WeaponSpread, debugLine, , height);
		DebugStr("Modyfikator obrazen  :" @ PawnToDebug.DamageTakenMultiplier, debugLine, , height);
		DebugStr("", debugLine, , height);


		// DebugStr("Location:" @ PawnToDebug.Location, debugLine, , height);
		// DebugStr("Final destination:" @ PawnToDebug.BController.FinalDestination, debugLine, , height);
		// DebugStr("Dist to final dest:" @ VSize2D(PawnToDebug.Location - PawnToDebug.BController.FinalDestination), debugLine, , height);
		// DebugStr("", debugLine, , height);


		DebugStr("Potrzeby:", debugLine, , height);
		for(q = 0; q < PawnToDebug.BController.NeedManager.Needs.Length; ++q)
		{
			DebugStr((q + 1) $ "." @ PawnToDebug.BController.NeedManager.Needs[q] @ "=", debugLine, , 0);

			switch(PawnToDebug.BController.NeedManager.Needs[q].GetFuzzyLevel())
			{
				case 0: Canvas.SetDrawColor(255,0,0,255); break;
				case 1: Canvas.SetDrawColor(255,128,0,255); break;
				case 2: Canvas.SetDrawColor(255,255,0,255); break;
				case 3: Canvas.SetDrawColor(120,204,184,255); break;
				case 4: Canvas.SetDrawColor(0,255,0,255); break;
				default: Canvas.SetDrawColor(255,255,255,255);
			}

			DebugStr("                       " @ PawnToDebug.BController.NeedManager.Needs[q].GetFuzzyLevel(), debugLine, , height);
			Canvas.SetDrawColor(255,255,255,255);
		}

		// DebugStr("Action stack:", debugLine, , height);
		// for(q = 0; q < PawnToDebug.BController.ActionManager.Actions.Length; ++q)
		// {
		// 	DebugStr((q + 1) $ "." @ PawnToDebug.BController.ActionManager.Actions[q] @ PawnToDebug.BController.ActionManager.Actions[q].IsBlocked() ? "  [blocked]" : "", debugLine, , height);
		// }
	}
}

/**
 * Draws rectangle centered at pos parameter
 * @param pos Screen position at which rect will be centered
 * @param size half of the width/height of the rectangle
 */
function DebugRect(Vector pos, int size, byte R, byte G, byte B, byte A)
{
	Canvas.SetDrawColor(R, G, B, A);
	Canvas.SetPos(pos.X - int(size * 0.5), pos.Y - int(size * 0.5));
	Canvas.DrawRect(size, size);
}

/**
 * [DebugStr description]
 * @param str string to print out
 * @param lineY horizontal offset from the top edge of the screen that will be incremented by lineIncrementationValue after string is drawn
 * @param lineXOffset vertical offset from the left edge of the screen
 * @param lineIncrementationValue (optional, 15 by default) value by which lineY will be incremented
 */
function DebugStr(string str, out int lineY, optional int lineXOffset, optional int lineIncrementationValue = 15)
{
	local Color c;
	c = Canvas.DrawColor;

	Canvas.SetDrawColor(0, 0, 0, 255);
	Canvas.SetPos(10 + lineXOffset + 1, lineY + 1, 0);
	Canvas.DrawText(str);

	//Canvas.SetDrawColor(255, 255, 255, 255);
	Canvas.SetDrawColorStruct(c);
	Canvas.SetPos(10 + lineXOffset, lineY, 0);
	Canvas.DrawText(str);

	lineY += lineIncrementationValue;
}

/** Selects next Pawn to debug */
function DebugNextPawn()
{
	local array<BamAIPawn> allPawns;
	local BamAIPawn pwn;
	local int idx;

	// get all alive pawns into allPawn array
	foreach WorldInfo.DynamicActors(class'BamAIPawn', pwn)
	{
		if( pwn != none && pwn.IsAliveAndWell() && GetALocalPlayerController().Pawn != pwn )
		{
			allPawns.AddItem(pwn);
		}
	}

	if( allPawns.length == 0 )
	{
		`trace("No alive pawns to debug", `yellow);
		PawnToDebug = none;
		return;
	}

	// get index of currently debugged Pawn
	idx = allPawns.Find(PawnToDebug);

	// select next pawn
	if( PawnToDebug == none || idx == INDEX_NONE || idx == allPawns.length - 1 )
	{
		PawnToDebug = allPawns[0];
		return;
	}
	// first if current pawn is last in the array
	else
	{
		PawnToDebug = allPawns[idx + 1];
		return;
	}
}

`endif

defaultproperties
{
	Crosshair=Texture2D'bam_hud_crosshair.Textures.crosshair'
}