unit renderer;

{$INCLUDE defines.inc}

interface

Procedure DrawFrame();


implementation
   uses
      SysUtils,
      SDL, Sour, GL,
      Globals, Enums,
      Resources, Buildings, Creatures,
      CameraUnit;


Procedure DrawPlanets();
   Var Pl, sz, Points, Pt : sInt; nowC, Diff, Angle : Double;
   begin
      (*
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
      *)
      For sz := 0 to (SightZoneNum - 1) do begin
         Diff := SightZone[sz].Cmax - SightZone[sz].Cmin;
         Points := Trunc(Diff / PLANET_GRANULARITY);
         
         glBegin(GL_LINE_STRIP);
            glColor4ub(255,255,255,255);
            For Pt := 0 to Points do begin
               
               nowC := SightZone[sz].Cmin + Diff * pt / Points;
               If (nowC < Planet[0].Cmax) then begin
                  Pl := 0;
                  Angle := 2 * Pi * nowC / Planet[Pl].Circu;
               end else begin
                  Pl := 1;
                  nowC -= Planet[0].Cmax;
                  Angle := 2 * Pi * nowC / Planet[Pl].Circu;
               end;
               
               glVertex2f(
                  Planet[Pl].X + Cos(Angle + Planet[Pl].AngDelta)*Planet[Pl].R,
                  Planet[Pl].Y + Sin(Angle + Planet[Pl].AngDelta)*Planet[Pl].R
               );
            end;
         glEnd()
      end
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
         If (Not InSight(Resource[R]^.C)) then Continue;
         
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
   Var B:uInt; buPt : TPoint; buAn : Double;
   begin
      If (BuildingNum <= 0) then Exit;
      
      Sour.TexEnable; Sour.TexBind(BuildingGfx^.Tex);
      glBegin(GL_QUADS);
      glColor4ub(255,255,255,255);
      For B:=0 to (BuildingLen - 1) do begin
         If (Building[B] = NIL) then Continue;
         If (Building[B]^.Team <> PlayerTeam) and (Not InSight(Building[B]^.C)) then Continue;
         
         CH_to_XYA(Building[B]^.C, 0, @buPt, @buAn);
         
         DrawSprite(BuildingGfx,
            0,
            Ord(Building[B]^.Typ)*21,
            30, 21,
            buPt.X, buPt.Y,
            30 * 3, 21 * 3,
            buAn
            ); 
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
         If (Creature[C]^.Team <> PlayerTeam) and (Not InSight(Creature[C]^.C)) then Continue;
         
         CH_to_XYA(Creature[C]^.C, 0, @crPt, @crAn);
         
         DrawSprite(CreatureGfx,
            15 * (Ord(Creature[C]^.Facing) + 3 * Ord(Creature[C]^.Anim)),
            Ord(Creature[C]^.Typ)*21,
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
            If (SelID[Idx] >= 0) and (SelID[Idx] < CreatureLen) then
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
            If (SelID[Idx] >= 0) and (SelID[Idx] < BuildingLen) then
               If (Building[SelID[Idx]] <> NIL) then begin
                  CH_to_XYA(Building[SelID[Idx]]^.C, 0, @pt, @rot);
                  DrawSelBox(pt.X,pt.Y,30*3,21*3,Rot);
               end;
         glEnd();
      end else
   end;


Procedure DrawRay();
   Var
      cX, cY, cCos, cSin, cDist, cAng, cC : Double;
      pl, Idx : uInt; pt:TPoint;
   begin
      cX := Camera.X + mX * CamScaleFactor;
      cY := Camera.Y + mY * CamScaleFactor;
      
      Sour.TexDisable();
      glBegin(GL_LINES);
      
      glColor4ub(255,0,0,255);
      glVertex2f(cX,cY);
      glVertex2f(Planet[0].X,Planet[0].Y);
      
      glColor4ub(255,255,0,255);
      glVertex2f(cX,cY);
      glVertex2f(Planet[1].X,Planet[1].Y);
      
      glEnd();
      
      If(Sqrt(Sqr(cX - Planet[0].X) + Sqr(cY - Planet[0].Y)) < Planet[0].R) then Exit();
      If(Sqrt(Sqr(cX - Planet[1].X) + Sqr(cY - Planet[1].Y)) < Planet[1].R) then Exit();
      
      For pl := 0 to 1 do begin
         cCos := cX - Planet[pl].X; cSin := cY - Planet[pl].Y;
         cDist := Sqrt(Sqr(cCos) + Sqr(cSin));
         cCos /= cDist; cSin /= cDist;
         
         cAng := GetAngle(cSin,cCos) - Planet[pl].AngDelta;
         If (cAng < 0) then cAng += 2*Pi;
         cC := Planet[pl].Cmin + cAng * Planet[pl].R;
         
         //Writeln('Planet ',pl,' cC: ',Trunc(cC),' (',Trunc(Planet[pl].Cmin),' - ',Trunc(Planet[pl].Cmax),')');
         
         If (cC >= Planet[pl].Cmin) and (cC <= Planet[pl].Cmax) then begin
            CH_to_XY(cC,0,@pt);
            glBegin(GL_QUADS);
               
               glColor4ub(255,0,255,255);
               glVertex2f(pt.X - 5, pt.Y - 5);
               glVertex2f(pt.X - 5, pt.Y + 5);
               glVertex2f(pt.X + 5, pt.Y + 5);
               glVertex2f(pt.X + 5, pt.Y - 5);
               
            glEnd();
            Exit()
         end;
      end;
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
         IntToStr(Trunc(PlayerResources[PlayerTeam][RSRC_METAL])),
         FontA,
         Crd.X + UIGfx[UIType][UIS_METAL]^.W - UI_Space,
         Crd.Y + 6,
         ALIGN_RIGHT
         );
      
      Crd.X -= UI_GAP + UIGfx[UIType][UIS_TIMBER]^.W;
      Sour.DrawImage(UIGfx[UIType][UIS_TIMBER],NIL,@Crd);
      Sour.PrintText(
         IntToStr(Trunc(PlayerResources[PlayerTeam][RSRC_TIMBER])),
         FontA,
         Crd.X + UIGfx[UIType][UIS_TIMBER]^.W - UI_Space,
         Crd.Y + 6,
         ALIGN_RIGHT
         );
      
      Crd.X -= UI_GAP + UIGfx[UIType][UIS_CRYSTALS]^.W;
      Sour.DrawImage(UIGfx[UIType][UIS_CRYSTALS],NIL,@Crd);
      Sour.PrintText(
         IntToStr(Trunc(PlayerResources[PlayerTeam][RSRC_CRYSTAL])),
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
         Rekt.X := 10; Rekt.Y := 10;
         Sour.DrawImage(UIGfx[UIType][UIS_SEL_L],NIL,@Rekt);
         
         Rekt.X += UI_Space;
         For Idx := 0 to (SelLen - 1) do begin
            Sour.DrawImage(UIGfx[UIType][UIS_SEL_M],NIL,@Rekt);
            Rekt.X += 17;
         end;
         
         Sour.DrawImage(UIGfx[UIType][UIS_SEL_R],NIL,@Rekt);
         
         Sour.TexBind(CreatureGfx^.Tex);
         Rekt.X := 10 + UI_Space + 1; Rekt.Y += 7;
         
         glBegin(GL_QUADS);
         For Idx := 0 to (SelLen - 1) do
            If (SelID[Idx] >= 0) and (SelID[Idx] < CreatureLen) then
               If (Creature[SelID[Idx]] <> NIL) then begin
                  
                  aX := 45 * Ord(Creature[SelID[Idx]]^.Anim) + 15;
                  aY := Ord(Creature[SelID[Idx]]^.Typ) * 21;
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
         Rekt.X := 10; Rekt.Y := 10;
         Sour.DrawImage(UIGfx[UIType][UIS_SEL_L],NIL,@Rekt);
         
         Rekt.X += UI_Space;
         For Idx := 0 to (SelLen - 1) do begin
            Sour.DrawImage(UIGfx[UIType][UIS_SEL_M],NIL,@Rekt);
            Rekt.X += 17;
            Sour.DrawImage(UIGfx[UIType][UIS_SEL_M],NIL,@Rekt);
            Rekt.X += 17;
         end;
         
         Sour.DrawImage(UIGfx[UIType][UIS_SEL_R],NIL,@Rekt);
         
         Sour.TexBind(BuildingGfx^.Tex);
         Rekt.X := 10 + UI_Space + 2; Rekt.Y += 7;
         
         glBegin(GL_QUADS);
         For Idx := 0 to (SelLen - 1) do
            If (SelID[Idx] >= 0) and (SelID[Idx] < BuildingLen) then
               If (Building[SelID[Idx]] <> NIL) then begin
                  
                  aX := 0;
                  aY := Ord(Building[SelID[Idx]]^.Typ) * 21;
                  bX := aX + 30; bY := aY + 21;
                  
                  aX /= BuildingGfx^.TexW; bX /= BuildingGfx^.TexW;
                  aY /= BuildingGfx^.TexH; bY /= BuildingGfx^.TexH;
                  
                  glTexCoord2f(aX,aY); glVertex2f(Rekt.X   ,Rekt.Y   );
                  glTexCoord2f(aX,bY); glVertex2f(Rekt.X   ,Rekt.Y+21);
                  glTexCoord2f(bX,bY); glVertex2f(Rekt.X+30,Rekt.Y+21);
                  glTexCoord2f(bX,aY); glVertex2f(Rekt.X+30,Rekt.Y   );
                  
                  Rekt.X += 34
               end;
         glEnd()
         
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


Procedure DrawUI_Production(Const UIType:TUIType;Const UI_Space:uInt);
   Const
        Red : Sour.TColour = (R: 128; G:   0; B: 0; A: 255);
      Green : Sour.TColour = (R:   0; G: 128; B: 0; A: 255);
   Var
      aX, aY, bX, bY : Double; Col : Sour.PColour; Rekt : Sour.TCrd;
      ctMin, ctMax, crtp : TCreatureType;
      btMin, btMax, butp : TBuildingType;
      DrawCost : Boolean; Costs : Array[TResourceType] of Double;
   begin
      If (SelType < SEL_CREAT) or (Not SelWorkers) then Exit();
      DrawCost := False; 
      
      If (SelType = SEL_CREAT) then begin
         
         If (UIType = UI_TECHNO) then begin
            btMin := BUTECH_BASE;
            btMax := BUTRIB_BASE;
         end else begin
            btMin := BUTRIB_BASE;
            btMax := BUTYPE_LENGTH;
         end;
         
         Sour.TexEnable(); Sour.TexBind(UIGfx[UIType][UIS_SEL_L]^.Tex);
         butp := btMin; Rekt.X := 10; Rekt.Y := 60;
         While (butp < btMax) do begin
            If (EnoughResources(BuildingStats[butp].Cost))
               then Col := @Green
               else Col := @Red;
            
            Sour.DrawImage(UIGfx[UIType][UIS_SEL_L],NIL,@Rekt,Col); Rekt.X += UI_Space;
            Sour.DrawImage(UIGfx[UIType][UIS_SEL_M],NIL,@Rekt,Col); Rekt.X += 17;
            Sour.DrawImage(UIGfx[UIType][UIS_SEL_M],NIL,@Rekt,Col); Rekt.X += 17;
            Sour.DrawImage(UIGfx[UIType][UIS_SEL_R],NIL,@Rekt,Col); Rekt.X += UI_Space + 10;
            
            Inc(butp)
         end;
         
         Sour.TexBind(BuildingGfx^.Tex);
         glBegin(GL_QUADS);
         glColor4ub(255,255,255,255);
         butp := btMin; Rekt.X := 10 + UI_Space + 2; Rekt.Y := 60 + 7;
         While (butp < btMax) do begin
            aX := 0;
            aY := Ord(butp) * 21;
            bX := aX + 30; bY := aY + 21;
            
            aX /= BuildingGfx^.TexW; bX /= BuildingGfx^.TexW;
            aY /= BuildingGfx^.TexH; bY /= BuildingGfx^.TexH;
            
            glTexCoord2f(aX,aY); glVertex2f(Rekt.X   ,Rekt.Y   );
            glTexCoord2f(aX,bY); glVertex2f(Rekt.X   ,Rekt.Y+21);
            glTexCoord2f(bX,bY); glVertex2f(Rekt.X+30,Rekt.Y+21);
            glTexCoord2f(bX,aY); glVertex2f(Rekt.X+30,Rekt.Y   );
            
            If (mX >= Rekt.X) and (mY >= Rekt.Y) and (mX < Rekt.X+30) and (my < Rekt.Y+21) then begin
               DrawCost := True;
               Costs := BuildingStats[butp].Cost;
            end;
            
            Rekt.X += 17 + 17 + UI_Space + 10 + UI_Space;
            Inc(butp)
         end;
         glEnd()
         
      end else begin
         
         If (UIType = UI_TECHNO) then begin
            ctMin := CRTECH_WORK;
            ctMax := CRTRIB_WORK;
         end else begin
            ctMin := CRTRIB_WORK;
            ctMax := CRTYPE_LENGTH;
         end;
         
         Sour.TexEnable(); Sour.TexBind(UIGfx[UIType][UIS_SEL_L]^.Tex);
         crtp := ctMin; Rekt.X := 10; Rekt.Y := 60;
         While (crtp < ctMax) do begin
            If (EnoughResources(CreatureStats[crtp].Cost))
               then Col := @Green
               else Col := @Red;
            
            Sour.DrawImage(UIGfx[UIType][UIS_SEL_L],NIL,@Rekt,Col); Rekt.X += UI_Space;
            Sour.DrawImage(UIGfx[UIType][UIS_SEL_M],NIL,@Rekt,Col); Rekt.X += 17;
            Sour.DrawImage(UIGfx[UIType][UIS_SEL_R],NIL,@Rekt,Col); Rekt.X += UI_Space + 10;
            
            Inc(crtp)
         end;
         
         Sour.TexBind(CreatureGfx^.Tex);
         glBegin(GL_QUADS);
         glColor4ub(255,255,255,255);
         crtp := ctMin; Rekt.X := 10 + UI_Space + 1; Rekt.Y := 60 + 7;
         While (crtp < ctMax) do begin
            aX := 15;
            aY := Ord(crtp) * 21;
            bX := aX + 15; bY := aY + 21;
            
            aX /= CreatureGfx^.TexW; bX /= CreatureGfx^.TexW;
            aY /= CreatureGfx^.TexH; bY /= CreatureGfx^.TexH;
            
            glTexCoord2f(aX,aY); glVertex2f(Rekt.X   ,Rekt.Y   );
            glTexCoord2f(aX,bY); glVertex2f(Rekt.X   ,Rekt.Y+21);
            glTexCoord2f(bX,bY); glVertex2f(Rekt.X+15,Rekt.Y+21);
            glTexCoord2f(bX,aY); glVertex2f(Rekt.X+15,Rekt.Y   );
            
            If (mX >= Rekt.X) and (mY >= Rekt.Y) and (mX < Rekt.X+15) and (my < Rekt.Y+21) then begin
               DrawCost := True;
               Costs := CreatureStats[crtp].Cost;
            end;
            
            Rekt.X += 17 + UI_Space + 10 + UI_Space;
            Inc(crtp)
         end;
         glEnd()
         
      end;
      
      If (DrawCost) then begin
         Rekt.X := Screen^.W - 1;
         Rekt.Y := 42;
         
         If(PlayerResources[PlayerTeam][RSRC_METAL] >= Costs[RSRC_METAL])
            then Col := @Green else Col := @Red;
         
         Rekt.X -= 10 + UIGfx[UIType][UIS_METAL]^.W;
         Sour.DrawImage(UIGfx[UIType][UIS_METAL],NIL,@Rekt,Col);
         Sour.PrintText(
            IntToStr(Trunc(Costs[RSRC_METAL])),
            FontA,
            Rekt.X + UIGfx[UIType][UIS_METAL]^.W - (UI_Space + 1),
            Rekt.Y + 6,
            ALIGN_RIGHT
            );
         
         If(PlayerResources[PlayerTeam][RSRC_METAL] >= Costs[RSRC_METAL])
            then Col := @Green else Col := @Red;
         
         Rekt.X -= 10 + UIGfx[UIType][UIS_TIMBER]^.W;
         Sour.DrawImage(UIGfx[UIType][UIS_TIMBER],NIL,@Rekt,Col);
         Sour.PrintText(
            IntToStr(Trunc(Costs[RSRC_TIMBER])),
            FontA,
            Rekt.X + UIGfx[UIType][UIS_TIMBER]^.W - (UI_Space + 1),
            Rekt.Y + 6,
            ALIGN_RIGHT
            );
         
         If(PlayerResources[PlayerTeam][RSRC_METAL] >= Costs[RSRC_METAL])
            then Col := @Green else Col := @Red;
         
         Rekt.X -= 10 + UIGfx[UIType][UIS_CRYSTALS]^.W;
         Sour.DrawImage(UIGfx[UIType][UIS_CRYSTALS],NIL,@Rekt,Col);
         Sour.PrintText(
            IntToStr(Trunc(Costs[RSRC_CRYSTAL])),
            FontA,
            Rekt.X + UIGfx[UIType][UIS_CRYSTALS]^.W - (UI_Space + 1),
            Rekt.Y + 6,
            ALIGN_RIGHT
            );
      end;
   end;


Procedure DrawUI_Techno();
   begin
      DrawUI_Windows(UI_TECHNO, 6);
      DrawUI_Selection(UI_TECHNO, 5);
      DrawUI_Production(UI_TECHNO, 5);
   end;


Procedure DrawUI_Tribal();
   begin
      DrawUI_Windows(UI_TRIBAL, 8);
      DrawUI_Selection(UI_TRIBAL, 7);
      DrawUI_Production(UI_TRIBAL, 7);
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
      //DrawRay();
      
      Sour.SetVisibleArea(0, 0, Screen^.W, Screen^.H);
      
      If (PlayerTeam = 0)
         then DrawUI_Techno()
         else DrawUI_Tribal();
      
      Sour.PrintText(
         [
            FrameStr,
            UpperCase(GAME_NAME) + ' V.' + GAME_VERSION
         ],
         FontA,3,Screen^.H - 3, ALIGN_BOTTOM);
      
   Sour.FinishFrame();
   end;


end.
