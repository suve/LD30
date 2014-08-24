unit renderer;

{$INCLUDE defines.inc}

interface

Procedure DrawFrame();


implementation
   uses
      SysUtils,
      SDL, Sour, GL,
      Globals, Enums,
      Resources, Buildings, Creatures;


Procedure DrawPlanets();
   Var Pl, Points, Pt : uInt; Angle : Double;
   begin
      For Pl := 0 to 1 do begin
         Points := Trunc(Planet[Pl].Circu / PLANET_GRANULARITY);
         
         glBegin(GL_LINE_LOOP);
            glColor4ub(255,255,255,255);
            For Pt := 0 to (Points-1) do begin
               Angle := 2 * Pi * Pt / Points;
               glVertex2f(
                  Planet[Pl].X + Cos(Angle)*Planet[Pl].R,
                  Planet[Pl].Y + Sin(Angle)*Planet[Pl].R
               );
            end;
         glEnd()
      end
   end;

Procedure DrawCrystal(Const Pt:PPoint;Const Ang:PDouble);
   begin
      glColor4ub(0,255,255,255);
      glVertex2f(Pt^.X + 5 * Cos(Ang^ - Pi / 2), Pt^.Y + 5 * Sin(Ang^ - Pi / 2));
      glVertex2f(Pt^.X + 8 * Cos(Ang^ - Pi / 4), Pt^.Y + 8 * Sin(Ang^ - Pi / 4));
      
      glVertex2f(Pt^.X + 8 * Cos(Ang^ - Pi / 4), Pt^.Y + 8 * Sin(Ang^ - Pi / 4));
      glVertex2f(Pt^.X + 12 * Cos(Ang^), Pt^.Y + 12 * Sin(Ang^));
      
      glVertex2f(Pt^.X + 12 * Cos(Ang^), Pt^.Y + 12 * Sin(Ang^));
      glVertex2f(Pt^.X + 8 * Cos(Ang^ + Pi / 4), Pt^.Y + 8 * Sin(Ang^ + Pi / 4));
      
      glVertex2f(Pt^.X + 8 * Cos(Ang^ + Pi / 4), Pt^.Y + 8 * Sin(Ang^ + Pi / 4));
      glVertex2f(Pt^.X + 5 * Cos(Ang^ + Pi / 2), Pt^.Y + 5 * Sin(Ang^ + Pi / 2));
   end;

Procedure DrawMetal(Const Pt:PPoint;Const Ang:PDouble);
   begin
      glColor4ub(128,128,128,255);
      glVertex2f(Pt^.X + 6 * Cos(Ang^ - Pi/2), Pt^.Y + 6 * Sin(Ang^ - Pi/2));
      glVertex2f(Pt^.X + 6*Sqrt(2) * Cos(Ang^ - Pi/4), Pt^.Y + 6*Sqrt(2) * Sin(Ang^ - Pi/4));
      
      glVertex2f(Pt^.X + 6*Sqrt(2) * Cos(Ang^ - Pi/4), Pt^.Y + 6*Sqrt(2) * Sin(Ang^ - Pi/4));
      glVertex2f(Pt^.X + 6*Sqrt(2) * Cos(Ang^ + Pi/4), Pt^.Y + 6*Sqrt(2) * Sin(Ang^ + Pi/4));
      
      glVertex2f(Pt^.X + 6*Sqrt(2) * Cos(Ang^ + Pi/4), Pt^.Y + 6*Sqrt(2) * Sin(Ang^ + Pi/4));
      glVertex2f(Pt^.X + 6 * Cos(Ang^ + Pi/2), Pt^.Y + 6 * Sin(Ang^ + Pi/2));
   end;

Procedure DrawWood(Const Pt:PPoint;Const Ang:PDouble);
   Var old, new : TPoint;
   begin
      glColor4ub(140,60,10,255);
      glVertex2f(Pt^.X + 6 * Cos(Ang^ - Pi/2), Pt^.Y + 6 * Sin(Ang^ - Pi/2));
      glVertex2f(Pt^.X + 6*Sqrt(2) * Cos(Ang^ - Pi/4), Pt^.Y + 6*Sqrt(2) * Sin(Ang^ - Pi/4));
      
      glColor4ub(0,180,0,255);
      glVertex2f(Pt^.X + 6*Sqrt(2) * Cos(Ang^ - Pi/4), Pt^.Y + 6*Sqrt(2) * Sin(Ang^ - Pi/4));
      glVertex2f(Pt^.X + 12 * Cos(Ang^ - Pi/3), Pt^.Y + 12 * Sin(Ang^ - Pi/3));
      
      glVertex2f(Pt^.X + 12 * Cos(Ang^ - Pi/3), Pt^.Y + 12 * Sin(Ang^ - Pi/3));
      glVertex2f(Pt^.X + 15 * Cos(Ang^), Pt^.Y + 15 * Sin(Ang^));
      
      glVertex2f(Pt^.X + 15 * Cos(Ang^), Pt^.Y + 15 * Sin(Ang^));
      glVertex2f(Pt^.X + 12 * Cos(Ang^ + Pi/3), Pt^.Y + 12 * Sin(Ang^ + Pi/3));
      
      glVertex2f(Pt^.X + 12 * Cos(Ang^ + Pi/3), Pt^.Y + 12 * Sin(Ang^ + Pi/3));
      glVertex2f(Pt^.X + 6*Sqrt(2) * Cos(Ang^ + Pi/4), Pt^.Y + 6*Sqrt(2) * Sin(Ang^ + Pi/4));
      
      glColor4ub(140,60,10,255);
      glVertex2f(Pt^.X + 6*Sqrt(2) * Cos(Ang^ + Pi/4), Pt^.Y + 6*Sqrt(2) * Sin(Ang^ + Pi/4));
      glVertex2f(Pt^.X + 6 * Cos(Ang^ + Pi/2), Pt^.Y + 6 * Sin(Ang^ + Pi/2));
   end;

Procedure DrawResources();
   Var R, v : uInt; ResPt : TPoint; ResAng,vDest,vAng : Double;
       vS,vD:Array[0..4] of TPoint;
   begin
      If (ResourceNum <= 0) then Exit;
      
      Sour.TexEnable; Sour.TexBind(ResourceGfx^.Tex);
      glBegin(GL_QUADS);
      glColor4ub(255,255,255,255);
      For R := 0 to (ResourceLen - 1) do begin
         If (Resource[R] = NIL) then Continue;
         
         CH_to_XYA(Resource[R]^.C,0,@ResPt,@ResAng);
         
         vS[1].X := Trunc(Resource[R]^.Amount / 50) * 15; vS[1].Y := Ord(Resource[R]^.Typ) * 21; 
         vS[3].X := vS[1].X + 15; vS[3].Y := vS[1].Y + 21;
         
         vS[0].X := vS[3].X; vS[0].Y := vS[1].Y;
         vS[2].X := vS[1].X; vS[2].Y := vS[3].Y;
         
         
         
         vD[0].X := +7.5 * 2; vD[0].Y := -21 * 2;
         vD[1].X := -7.5 * 2; vD[1].Y := -21 * 2;
         vD[2].X := -7.5 * 2; vD[2].Y :=   0 * 2;
         vD[3].X := +7.5 * 2; vD[3].Y :=   0 * 2;
         
         ResAng += Pi/2;
         For V:=0 to 3 do begin
            //Write(Trunc(vS[v].X),':',Trunc(vS[v].Y),' - ');
            
            vDest := Sqrt(Sqr(vD[v].X) + Sqr(vD[v].Y));
            vAng := GetAngle(vD[v].Y / vDest, vD[v].X / vDest);
            
            //glColor4ub(0,(V mod 2)*255,(V div 2)*255,255);
            glTexCoord2f(vS[v].X / ResourceGfx^.TexW, vS[v].Y / ResourceGfx^.TexH);
            glVertex2f(ResPt.X + vDest * Cos(ResAng + vAng), ResPt.Y + vDest * Sin(ResAng + vAng));
         end;
         //Writeln
      end;
      glEnd()
   end;


Procedure DrawBuildings();
   const SIZE = 12;
   Var B:uInt; buPt : TPoint; buAn : Double;
   begin
      If (BuildingNum <= 0) then Exit;
      
      glBegin(GL_QUADS);
      glColor4ub(255,127,63,255);
      For B:=0 to (BuildingLen - 1) do begin
         If (Building[B] = NIL) then Continue;
         
         CH_to_XYA(Building[B]^.C, 0, @buPt, @buAn);
         
         glVertex2f(buPt.X - SIZE * Cos(buAn + 1*Pi/4), buPt.Y - SIZE * Sin(buAn + 1*Pi/4));
         glVertex2f(buPt.X - SIZE * Cos(buAn + 3*Pi/4), buPt.Y - SIZE * Sin(buAn + 3*Pi/4));
         glVertex2f(buPt.X - SIZE * Cos(buAn + 5*Pi/4), buPt.Y - SIZE * Sin(buAn + 5*Pi/4));
         glVertex2f(buPt.X - SIZE * Cos(buAn + 7*Pi/4), buPt.Y - SIZE * Sin(buAn + 7*Pi/4));
      end;
      glEnd();
   end;


Procedure DrawCreatures();
   const SIZE = 12;
   Var C:uInt; crPt : TPoint; crAn : Double;
   begin
      If (CreatureNum <= 0) then Exit;
      
      glBegin(GL_QUADS);
      glColor4ub(255,0,0,255);
      For C:=0 to (CreatureLen - 1) do begin
         If (Creature[C] = NIL) then Continue;
         
         CH_to_XYA(Creature[C]^.C, 0, @crPt, @crAn);
         
         glVertex2f(crPt.X - SIZE * Cos(crAn + 1*Pi/4), crPt.Y - SIZE * Sin(crAn + 1*Pi/4));
         glVertex2f(crPt.X - SIZE * Cos(crAn + 3*Pi/4), crPt.Y - SIZE * Sin(crAn + 3*Pi/4));
         glVertex2f(crPt.X - SIZE * Cos(crAn + 5*Pi/4), crPt.Y - SIZE * Sin(crAn + 5*Pi/4));
         glVertex2f(crPt.X - SIZE * Cos(crAn + 7*Pi/4), crPt.Y - SIZE * Sin(crAn + 7*Pi/4));
      end;
      glEnd();
   end;


Procedure DrawUI_Techno();
   Const UI_GAP = 10;
   Var Crd:Sour.TCrd;
   begin
      Crd.X := Screen^.W - 1;
      Crd.Y := UI_GAP;
      
      Crd.X -= UI_GAP + TechnoUI[UIS_METAL]^.W;
      Sour.DrawImage(TechnoUI[UIS_METAL],NIL,@Crd);
      Sour.PrintText(
         '0',
         FontA,
         Crd.X + TechnoUI[UIS_METAL]^.W - 6,
         Crd.Y + 6,
         ALIGN_RIGHT
         );
      
      Crd.X -= UI_GAP + TechnoUI[UIS_TIMBER]^.W;
      Sour.DrawImage(TechnoUI[UIS_TIMBER],NIL,@Crd);
      Sour.PrintText(
         '0',
         FontA,
         Crd.X + TechnoUI[UIS_TIMBER]^.W - 6,
         Crd.Y + 6,
         ALIGN_RIGHT
         );
      
      Crd.X -= UI_GAP + TechnoUI[UIS_CRYSTALS]^.W;
      Sour.DrawImage(TechnoUI[UIS_CRYSTALS],NIL,@Crd);
      Sour.PrintText(
         '0',
         FontA,
         Crd.X + TechnoUI[UIS_CRYSTALS]^.W - 6,
         Crd.Y + 6,
         ALIGN_RIGHT
         );
   end;


Procedure DrawUI_Tribal();
   Const UI_GAP = 10;
   Var Crd:Sour.TCrd;
   begin
      Crd.X := Screen^.W - 1;
      Crd.Y := UI_GAP;
      
      Crd.X -= UI_GAP + TribalUI[UIS_METAL]^.W;
      Sour.DrawImage(TribalUI[UIS_METAL],NIL,@Crd);
      Sour.PrintText(
         '0',
         FontA,
         Crd.X + TribalUI[UIS_METAL]^.W - 8,
         Crd.Y + 6,
         ALIGN_RIGHT
         );
      
      Crd.X -= UI_GAP + TribalUI[UIS_TIMBER]^.W;
      Sour.DrawImage(TribalUI[UIS_TIMBER],NIL,@Crd);
      Sour.PrintText(
         '0',
         FontA,
         Crd.X + TribalUI[UIS_TIMBER]^.W - 8,
         Crd.Y + 6,
         ALIGN_RIGHT
         );
      
      Crd.X -= UI_GAP + TribalUI[UIS_CRYSTALS]^.W;
      Sour.DrawImage(TribalUI[UIS_CRYSTALS],NIL,@Crd);
      Sour.PrintText(
         '0',
         FontA,
         Crd.X + TribalUI[UIS_CRYSTALS]^.W - 8,
         Crd.Y + 6,
         ALIGN_RIGHT
         );
   end;


Procedure DrawSelection();
   Var Idx : sInt;
   begin
      If (SelType = SEL_CREAT) then begin
         For Idx := Low(SelID) to High(SelID) do
            If (Idx < CreatureLen) then
               If (Creature[Idx] <> NIL) then
                  
      end else
      If (SelType = SEL_BUILD) then begin
         For Idx := Low(SelID) to High(SelID) do
            If (Idx < BuildingLen) then
               If (Building[Idx] <> NIL) then
      end else
   end;


Procedure DrawFrame();
   begin
   Sour.BeginFrame();
      
      Sour.TexDisable();
      
      Sour.SetVisibleArea(
         Trunc(Camera.X), Trunc(Camera.Y),
         Trunc(Screen^.W * CamScaleFactor), Trunc(Screen^.H * CamScaleFactor)
      );
      
      DrawPlanets();
      DrawResources();
      
      Sour.TexDisable();
      DrawBuildings();
      DrawCreatures();
      
      Sour.SetVisibleArea(0, 0, Screen^.W, Screen^.H);
      
      DrawUI_Tribal();
      Sour.PrintText(
         [
            UpperCase(GAME_NAME) + ' V.' + GAME_VERSION,
            FrameStr
         ],
         FontA,3,3);
      
   Sour.FinishFrame();
   end;


end.
