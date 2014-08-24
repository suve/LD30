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


Procedure DrawSelBox(Const dX,dY,dW,dH,Rot:Double);
   Const BoxSize = 7;
   Var v,vN : uInt; vDest,vAng : Double;
       vD:Array[0..4] of TPoint;
       cX, cY, rNow, rChg: Double;
   begin
      vD[0].X := +dW / 2; vD[0].Y := -dH;
      vD[1].X := -dW / 2; vD[1].Y := -dH;
      vD[2].X := -dW / 2; vD[2].Y :=   0;
      vD[3].X := +dW / 2; vD[3].Y :=   0;
      
      For V:=0 to 3 do begin
         vDest := Sqrt(Sqr(vD[v].X) + Sqr(vD[v].Y));
         vAng := GetAngle(vD[v].Y / vDest, vD[v].X / vDest);
         
         cX := dX + vDest * Cos(Rot + vAng + Pi/2);
         cY := dY + vDest * Sin(Rot + vAng + Pi/2);
         
         If (v mod 2 = 0) then rChg := +Pi / 2 else rChg := -Pi / 2;
         If (v < 2) then rNow := Rot+Pi else rNow := Rot;
         
         glVertex2f(cX,cY);
         glVertex2f(cX + BoxSize * Cos(rNow), cY + BoxSize * Sin(rNow));
         
         glVertex2f(cX,cY);
         glVertex2f(cX + BoxSize * Cos(rNow + rChg), cY + BoxSize * Sin(rNow + rChg));
      end;
   end;


Procedure DrawSprite(Const Tex:Sour.PImage;Const sX,sY,sW,sH,dX,dY,dW,dH,Rot:Double);
   Var v : uInt; vDest,vAng : Double;
       vS,vD:Array[0..4] of TPoint;
   begin
      vS[1].X := sX; vS[1].Y := sY; 
      vS[3].X := sX + sW; vS[3].Y := sY + sH;
      
      vS[0].X := vS[3].X; vS[0].Y := vS[1].Y;
      vS[2].X := vS[1].X; vS[2].Y := vS[3].Y;
      
      vD[0].X := +dW / 2; vD[0].Y := -dH;
      vD[1].X := -dW / 2; vD[1].Y := -dH;
      vD[2].X := -dW / 2; vD[2].Y :=   0;
      vD[3].X := +dW / 2; vD[3].Y :=   0;
      
      For V:=0 to 3 do begin
         vDest := Sqrt(Sqr(vD[v].X) + Sqr(vD[v].Y));
         vAng := GetAngle(vD[v].Y / vDest, vD[v].X / vDest);
         
         glTexCoord2f(vS[v].X / Tex^.TexW, vS[v].Y / Tex^.TexH);
         glVertex2f(dX + vDest * Cos(Rot + vAng + Pi/2), dY + vDest * Sin(Rot + vAng + Pi/2));
      end;
   end;


Procedure DrawResources();
   Var R : uInt; ResPt : TPoint; ResAng : Double;
   begin
      If (ResourceNum <= 0) then Exit;
      
      Sour.TexEnable; Sour.TexBind(ResourceGfx^.Tex);
      glBegin(GL_QUADS);
      glColor4ub(255,255,255,255);
      For R := 0 to (ResourceLen - 1) do begin
         If (Resource[R] = NIL) then Continue;
         
         CH_to_XYA(Resource[R]^.C,0,@ResPt,@ResAng);
         
         DrawSprite(ResourceGfx,
            Trunc(Resource[R]^.Amount / 50) * 15, Ord(Resource[R]^.Typ) * 21,
            15, 21,
            ResPt.X, ResPt.Y,
            15 * 3, 21 * 3,
            ResAng
            ); 
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


Function Fork(Const Condition:Boolean;Const TrueVal,FalseVal : sInt):sInt; Inline;
   begin If(Condition) then Result := TrueVal else Result := FalseVal end;


Procedure DrawCreatures();
   Var C:uInt; crPt : TPoint; crAn : Double;
   begin
      If (CreatureNum <= 0) then Exit;
      
      Sour.TexEnable; Sour.TexBind(CreatureGfx^.Tex);
      glBegin(GL_QUADS);
      glColor4ub(255,255,255,255);
      For C:=0 to (CreatureLen - 1) do begin
         If (Creature[C] = NIL) then Continue;
         
         CH_to_XYA(Creature[C]^.C, 0, @crPt, @crAn);
         
         DrawSprite(CreatureGfx,
            Fork(Creature[C]^.Typ >= CRTRIB_WORK, 45, 0),
            Fork(Creature[C]^.Typ >= CRTRIB_WORK, Ord(Creature[C]^.Typ) - Ord(CRTRIB_WORK), Ord(Creature[C]^.Typ))*21,
            15, 21,
            crPt.X, crPt.Y,
            15 * 2, 21 * 2,
            crAn
            ); 
      end;
      glEnd();
   end;


Procedure DrawSelection();
   Var
      Idx : sInt; pt : TPoint; rot : Double;
   begin
      If (SelType = SEL_CREAT) then begin
         Sour.TexDisable();
         glBegin(GL_LINES);
         glColor4ub(0,255,0,255);
         For Idx := 0 to (SelLen - 1) do
            If (SelID[Idx] > 0) and (SelID[Idx] < CreatureLen) then
               If (Creature[SelID[Idx]] <> NIL) then begin
                  CH_to_XYA(Creature[SelID[Idx]]^.C, 0, @pt, @rot);
                  DrawSelBox(pt.X,pt.Y,30,42,Rot);
               end;
         glEnd();
      end else
      If (SelType = SEL_BUILD) then begin
         Sour.TexDisable();
         glBegin(GL_LINES);
         glColor4ub(0,255,0,255);
         For Idx := 0 to (SelLen - 1) do
            If (SelID[Idx] > 0) and (SelID[Idx] < BuildingLen) then
               If (Building[SelID[Idx]] <> NIL) then begin
                  CH_to_XYA(Building[SelID[Idx]]^.C, 0, @pt, @rot);
                  DrawSelBox(pt.X,pt.Y,30,42,Rot);
               end;
         glEnd();
      end else
   end;


Procedure DrawUI_Windows(Const UIType:TUIType;Const UI_Space:uInt);
   Const UI_GAP = 10;
   Var Crd:Sour.TCrd;
   begin
      Crd.X := Screen^.W - 1;
      Crd.Y := UI_GAP;
      
      Crd.X -= UI_GAP + UIGfx[UIType][UIS_METAL]^.W;
      Sour.DrawImage(UIGfx[UIType][UIS_METAL],NIL,@Crd);
      Sour.PrintText(
         '0',
         FontA,
         Crd.X + UIGfx[UIType][UIS_METAL]^.W - UI_Space,
         Crd.Y + 6,
         ALIGN_RIGHT
         );
      
      Crd.X -= UI_GAP + UIGfx[UIType][UIS_TIMBER]^.W;
      Sour.DrawImage(UIGfx[UIType][UIS_TIMBER],NIL,@Crd);
      Sour.PrintText(
         '0',
         FontA,
         Crd.X + UIGfx[UIType][UIS_TIMBER]^.W - UI_Space,
         Crd.Y + 6,
         ALIGN_RIGHT
         );
      
      Crd.X -= UI_GAP + UIGfx[UIType][UIS_CRYSTALS]^.W;
      Sour.DrawImage(UIGfx[UIType][UIS_CRYSTALS],NIL,@Crd);
      Sour.PrintText(
         '0',
         FontA,
         Crd.X + UIGfx[UIType][UIS_CRYSTALS]^.W - UI_Space,
         Crd.Y + 6,
         ALIGN_RIGHT
         );
   end;


Procedure DrawUI_Selection(Const UIType:TUIType;Const UI_Space:uInt);
   Var
      Idx : sInt; pt : TPoint; rot : Double;
      aX, aY, bX, bY : Double;
      Rekt : Sour.TCrd;
   begin
      If (SelType = SEL_CREAT) then begin
         Rekt.X := 3; Rekt.Y := 3;
         Sour.DrawImage(UIGfx[UIType][UIS_SEL_L],NIL,@Rekt);
         
         Rekt.X += UI_Space;
         For Idx := 0 to (SelLen - 1) do begin
            Sour.DrawImage(UIGfx[UIType][UIS_SEL_M],NIL,@Rekt);
            Rekt.X += 17;
         end;
         
         Sour.DrawImage(UIGfx[UIType][UIS_SEL_R],NIL,@Rekt);
         
         Sour.TexBind(CreatureGfx^.Tex);
         Rekt.X := 3 + UI_Space + 1; Rekt.Y += 7;
         
         glBegin(GL_QUADS);
         For Idx := 0 to (SelLen - 1) do
            If (SelID[Idx] > 0) and (SelID[Idx] < CreatureLen) then
               If (Creature[SelID[Idx]] <> NIL) then begin
                  
                  If (Creature[SelID[Idx]]^.Typ >= CRTRIB_WORK) then begin
                     aX := 45 + 15;
                     aY := (Ord(Creature[SelID[Idx]]^.Typ) - Ord(CRTRIB_WORK)) * 21;
                  end else begin
                     aX := 0 + 15;
                     aY := Ord(Creature[SelID[Idx]]^.Typ) * 21;
                  end;
                  bX := aX + 15; bY := aY + 21;
                  
                  aX /= CreatureGfx^.TexW; bX /= CreatureGfx^.TexW;
                  aY /= CreatureGfx^.TexH; bY /= CreatureGfx^.TexH;
                  
                  glTexCoord2f(aX,aY); glVertex2f(Rekt.X   ,Rekt.Y   );
                  glTexCoord2f(aX,bY); glVertex2f(Rekt.X   ,Rekt.Y+21);
                  glTexCoord2f(bX,bY); glVertex2f(Rekt.X+15,Rekt.Y+21);
                  glTexCoord2f(bX,aY); glVertex2f(Rekt.X+15,Rekt.Y   );
                  
                  Rekt.X += 17
               end;
         glEnd()
         
      end else
      If (SelType = SEL_BUILD) then begin
         glBegin(GL_LINES);
         glColor4ub(0,255,0,255);
         For Idx := 0 to (SelLen - 1) do
            If (SelID[Idx] > 0) and (SelID[Idx] < BuildingLen) then
               If (Building[SelID[Idx]] <> NIL) then begin
                  CH_to_XYA(Building[SelID[Idx]]^.C, 0, @pt, @rot);
                  DrawSelBox(pt.X,pt.Y,30,42,Rot);
               end;
         glEnd();
      end else
      If (SelType = SEL_MAKING) then begin
         aX := (mSelX - Camera.X) / CamScaleFactor;
         aY := (mSelY - Camera.Y) / CamScaleFactor;
         bX := mX; bY := mY;
         
         Sour.TexDisable();
         glBegin(GL_QUADS);
            glColor4ub(0,255,0,64);
            glVertex2f(aX,aY);
            glVertex2f(aX,bY);
            glVertex2f(bX,bY);
            glVertex2f(bX,aY);
         glEnd();
         
         glBegin(GL_LINE_LOOP);
            glColor4ub(0,255,0,255);
            glVertex2f(aX,aY);
            glVertex2f(aX,bY);
            glVertex2f(bX,bY);
            glVertex2f(bX,aY);
         glEnd();
      end
   end;


Procedure DrawUI_Techno();
   begin
      DrawUI_Windows(UI_TECHNO, 6);
      DrawUI_Selection(UI_TECHNO, 5);
   end;


Procedure DrawUI_Tribal();
   begin
      DrawUI_Windows(UI_TRIBAL, 8);
      DrawUI_Selection(UI_TRIBAL, 7);
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
      DrawBuildings();
      DrawCreatures();
      
      DrawSelection();
      
      Sour.SetVisibleArea(0, 0, Screen^.W, Screen^.H);
      
      DrawUI_Tribal();
      Sour.PrintText(
         [
            FrameStr,
            UpperCase(GAME_NAME) + ' V.' + GAME_VERSION
         ],
         FontA,3,Screen^.H - 3, ALIGN_BOTTOM);
      
   Sour.FinishFrame();
   end;


end.
