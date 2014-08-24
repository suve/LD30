unit globals;

{$INCLUDE defines.inc}

interface
   uses
      SDL, Sour, Enums,
      Entities, Buildings, Creatures
      ;

Const
   GAME_NAME = 'TechnoTumor';
   GAME_VMAJOR = 0;
   GAME_VMINOR = 3;
   GAME_VBUGFX = 0;
   GAME_VERSION = Chr(48+GAME_VMAJOR) + '.' + Chr(48+GAME_VMINOR) + '.' + Chr(48+GAME_VBUGFX);

   SDL_TICKS_PER_SECOND = 1000;
   PLANET_GRANULARITY = 10;
   CAMERA_SPEED = 500;
   
   ARRAY_RESIZE_STEP = 8;
   SEL_MAX = 30;

Type
   PPoint = ^TPoint;
   TPoint = record
      X, Y : Double
   end;
   
   PPlanet = ^TPlanet;
   TPlanet = record
      X, Y, R : Double;
      Circu, Cmin, Cmax, AngDelta : Double;
      Points : uInt;
   end;

Var
   Screen : PSDL_Surface = NIL;
   Terminate : Boolean = FALSE;
   Ev : TSDL_Event;
   
   FontA : Sour.PFont;
   TechnoUI, TribalUI : Array[TUISprite] of Sour.PImage;
   Icon : PSDL_Surface;
   
   ResourceGfx, CreatureGfx, BuildingGfx : Sour.PImage;
   
   Ticks, Time : uInt;
   dT : Double;
   
   Frames : uInt = 0;
   FrameTime : uInt = 0;
   FrameStr : AnsiString = 'FPS: ???';
   
   Planet : Array[0..1] of TPlanet;
   
   mX, mY : sInt;
   mSelX, mSelY : sInt;
   
   Camera : TPoint = (X:0.0; Y:0.0);
   CamMove : Array[TDir] of Boolean = (False,False,False,False);

   CamScale : sInt = 10;
   CamScaleFactor : Double = 1;

   SelType : TSelectionType;
   SelID : Array[0..SEL_MAX-1] of sInt;
   SelLen : uInt;


Function GetAngle(Const Sin,Cos:Double):Double;
Procedure CalcPlanetZones();

Procedure CH_to_XYA(Const C,H:Double;Const Point:PPoint;Const Angle:PDouble);
Procedure CH_to_XY(Const C,H:Double;Const Point:PPoint);
Function CH_to_XY(Const C,H:Double):TPoint;

Function EntityInBox(Const en:PEntity;Const eW,eH,aX,aY,bX,bY:Double):Boolean;

Procedure FinishProduction(Const Build:PBuilding);



implementation
   uses Math;

Function GetAngle(Const Sin,Cos:Double):Double;
   begin
      If (Sin > 0)
         then GetAngle:=ArcCos(Cos)
         else GetAngle:=2*Pi-ArcCos(Cos)
   end;

Function GetAngle(Const aX,aY,bX,bY:Double):Double;
   Var diffX, diffY, dist : Double;
   begin
      diffX := bX - aX;
      diffY := bY - aY;
      dist := Sqrt(Sqr(diffX) + Sqr(diffY));
      Exit(GetAngle(diffY / dist, diffX / dist))
   end;

Procedure CalcPlanetZones();
   Var
      ctrD : Array[0..1] of Double;
      ctrCos, ctrSin, ctrAngle, ctrDist : Double;
      
      ptCos, ptSin, ptAngle : Double;
      
      ptA, ptB : TPoint;
   begin
      // Calculate X and Y difference between planets
      ctrCos := Planet[1].X - Planet[0].X;
      ctrSin := Planet[1].Y - Planet[0].Y;
      
      // Calculate distance and cos/sin
      ctrDist := Sqrt(Sqr(ctrCos) + Sqr(ctrSin));
      ctrCos /= ctrDist; ctrSin /= ctrDist;
      
      // Calculate angle between planets
      ctrAngle := GetAngle(ctrSin, ctrCos);
      
      // Calculate distance from planet centres to radical line
      ctrD[0] := Sqr(ctrDist) - Sqr(Planet[1].R) + Sqr(Planet[0].R); 
      ctrD[1] := Sqr(ctrDist) - Sqr(Planet[0].R) + Sqr(Planet[1].R); 
      ctrD[0] /= 2 * ctrDist; ctrD[1] /= 2 * ctrDist;
      
      ptCos := ctrD[0] / Planet[0].R;
      ptSin := Sqrt(1 - Sqr(ptCos));
      
      ptAngle := GetAngle(+ptSin, ptCos);
      ptA.X := Planet[0].X + Cos(ptAngle + ctrAngle) * Planet[0].R;
      ptA.Y := Planet[0].Y + Sin(ptAngle + ctrAngle) * Planet[0].R;
      Writeln('ptA: ',PtA.X:8:3,':',PtA.Y:8:3,'; angle: ',Trunc(ptAngle*180/Pi));
      
      Planet[0].Cmin := 0;
      Planet[0].Cmax := (2*(Pi - ptAngle)) * Planet[0].R;
      
      Planet[0].Circu := 2 * Pi * Planet[0].R;
      Planet[0].AngDelta := GetAngle(Planet[0].X,Planet[0].Y,ptA.X,ptA.Y);
      
      //ptAngle := GetAngle(-ptSin, ptCos);
      ptAngle := -ptAngle;
      ptB.X := Planet[0].X + Cos(ptAngle + ctrAngle) * Planet[0].R;
      ptB.Y := Planet[0].Y + Sin(ptAngle + ctrAngle) * Planet[0].R;
      Writeln('ptB: ',PtB.X:8:3,':',PtB.Y:8:3,'; angle: ',Trunc(ptAngle*180/Pi));
      
      ptCos := ctrD[1] / Planet[1].R;
      ptSin := Sqrt(1 - Sqr(ptCos));
      ptAngle := GetAngle(+ptSin, ptCos);
      
      Planet[1].Cmin := Planet[0].Cmax;
      Planet[1].Cmax := Planet[0].Cmax + (2*(Pi - ptAngle)) * Planet[1].R;
      
      Planet[1].Circu := 2 * Pi * Planet[1].R;
      Planet[1].AngDelta := GetAngle(Planet[1].X,Planet[1].Y,ptB.X,ptB.Y);
      
      Writeln('Planet[0]: ',Trunc(Planet[0].Cmin):5,' - ',Trunc(Planet[0].Cmax):5,'; delta: ',Trunc(Planet[0].AngDelta*180/Pi));
      Writeln('Planet[1]: ',Trunc(Planet[1].Cmin):5,' - ',Trunc(Planet[1].Cmax):5,'; delta: ',Trunc(Planet[1].AngDelta*180/Pi));
   end;

Procedure CH_to_XYA(Const C,H:Double;Const Point:PPoint;Const Angle:PDouble);
   Var pl : sInt;
   begin
      If (C <= Planet[0].Cmax) then begin
         Angle^ := C / Planet[0].Circu;
         pl := 0;
      end else begin
         Angle^ := (C - Planet[1].Cmin) / Planet[1].Circu;
         pl := 1;
      end;
      Angle^ *= 2 * Pi;
      Angle^ := Planet[pl].AngDelta + Angle^;
      
      Point^.X := Planet[pl].X + Cos(Angle^) * Planet[pl].R;
      Point^.Y := Planet[pl].Y + Sin(Angle^) * Planet[pl].R;
   end;

Procedure CH_to_XY(Const C,H:Double;Const Point:PPoint);
   Var Angle:Double;
   begin
      CH_to_XYA(C,H,Point,@Angle)
   end;

Function CH_to_XY(Const C,H:Double):TPoint;
   begin
      CH_to_XY(C,H,@Result)
   end;


Procedure InsertCreature(Const Crea:PCreature);
   Var Idx:uInt;
   begin
      If (CreatureNum < CreatureLen) then begin
         Idx := 0;
         While (Creature[Idx] <> NIL) do Idx += 1
      end else begin
         Idx := CreatureLen;
         CreatureLen += ARRAY_RESIZE_STEP;
         SetLength(Creature, CreatureLen)
      end;
      
      Creature[Idx] := Crea;
      CreatureNum += 1
   end;


Procedure FinishProduction(Const Build:PBuilding);
   Var Crea:PCreature;
   begin
      New(Crea,Create());
      
      Crea^.C := Build^.C;
      Crea^.H := Build^.H;
      
      Crea^.HP := 100;
      Crea^.MaxHP := 100;
      
      Crea^.Speed := 300 + Random() * 150;
      
      Crea^.Typ := Build^.Production.crType;
      Crea^.Team := Build^.Team;
      
      Crea^.Order := CROR_PATROL;
      
      InsertCreature(Crea);
      
      Build^.Production.Active := False;
      Build^.Production.Progress := 0.0
   end;


Function EntityInBox(Const en:PEntity;Const eW,eH,aX,aY,bX,bY:Double):Boolean;
   Var
      enPt : TPoint; enAn : Double;
      eV : Array[0..3] of TPoint;
      v : sInt; vAng, vDist : Double;
      eXa, eYa, eXb, eYb : Double;
   begin
      CH_to_XYA(en^.C, 0, @enPt, @enAn);
      
      eV[0].X := +eW / 2; eV[0].Y := -eH;
      eV[1].X := -eW / 2; eV[1].Y := -eH;
      eV[2].X := -eW / 2; eV[2].Y :=   0;
      eV[3].X := +eW / 2; eV[3].Y :=   0;
      
      eXa := +1000000; eYa := +1000000;
      eXb := -1000000; eYb := -1000000;
      
      For V:=0 to 3 do begin
         vDist := Sqrt(Sqr(eV[v].X) + Sqr(eV[v].Y));
         vAng := GetAngle(eV[v].Y / vDist, eV[v].X / vDist);
         
         eV[v].X := enPt.X + vDist * Cos(enAn + vAng + Pi/2);
         eV[v].Y := enPt.Y + vDist * Sin(enAn + vAng + Pi/2);
         
         If (eV[v].X < eXa) then eXa := eV[v].X;
         If (eV[v].X > eXb) then eXb := eV[v].X;
         
         If (eV[v].Y < eYa) then eYa := eV[v].Y;
         If (eV[v].Y > eYb) then eYb := eV[v].Y;
      end;
      
      If (eXa > bX) then Exit(False);
      If (eYa > bY) then Exit(False);
      If (eXb < aX) then Exit(False);
      If (eYb < aY) then Exit(False);
      
      Result := True
   end;


end.
