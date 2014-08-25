program ld30;

{$INCLUDE defines.inc}
{$IFDEF WINDOWS} {$APPTYPE GUI} {$ENDIF}

uses
   SysUtils,
   SDL, SDL_Image, //SDL_Mixer,
   Sour, GL,
   Globals, Enums,
   Resources, Bullets,
   Buildings, Creatures,
   Renderer, CameraUnit;

Procedure AdvanceTime();
   begin
      Time := SDL_GetTicks() - Ticks;
      If (Time = 0) then begin
         SDL_Delay(1);
         Time := SDL_GetTicks() - Ticks
      end;
      
      Ticks := Ticks + Time;
      dT := Time / SDL_TICKS_PER_SECOND
   end;

Procedure MakeSelection();
   Var 
      Idx : sInt;
      aX, aY, bX, bY, T : Double;
   begin
      aX := mSelX;
      aY := mSelY;
      
      bX := Camera.X + mX * CamScaleFactor;
      bY := Camera.Y + mY * CamScaleFactor;
      
      If (bX < aX) then begin T := aX; aX := bX; bX := T end;
      If (bY < aY) then begin T := aY; aY := bY; bY := T end;
      
      SelLen := 0; SelWorkers := False;
      If (CreatureNum > 0) then begin
         For Idx := 0 to (CreatureLen - 1) do
            If (Creature[Idx] <> NIL) and (Creature[Idx]^.Team = PlayerTeam) then
               If (EntityInBox(Creature[Idx],15,21,aX,aY,bX,bY)) then begin
                  If (CreatureStats[Creature[Idx]^.Typ].Build) then SelWorkers := True;
                  SelID[selLen] := Idx;
                  selLen += 1;
                  If (selLen = SEL_MAX) then Break;
               end;
         If (selLen > 0) then begin
            SelType := SEL_CREAT;
            Exit()
         end;
      end;
      If (BuildingNum > 0) then begin
         For Idx := 0 to (BuildingLen - 1) do
            If (Building[Idx] <> NIL) and (Building[Idx]^.Team = PlayerTeam)  then
               If (EntityInBox(Building[Idx],30,42,aX,aY,bX,bY)) then begin
                  If (BuildingStats[Building[Idx]^.Typ].Produce) then SelWorkers := True;
                  SelID[selLen] := Idx;
                  selLen += 1;
                  If (selLen = SEL_MAX) then Break;
               end;
         If (selLen > 0) then begin
            SelType := SEL_BUILD;
            Exit()
         end;
      end;
      SelType := SEL_NONE
   end;


Procedure IssueOrder();
   Var
      cX, cY, cCos, cSin, cDist, cAng, cC : Double;
      pl, Idx : uInt; Res : sInt;
   begin
      If (SelType < SEL_CREAT) or (SelLen <= 0) then Exit();
      cX := Camera.X + mX * CamScaleFactor;
      cY := Camera.Y + mY * CamScaleFactor;
      
      If(Sqrt(Sqr(cX - Planet[0].X) + Sqr(cY - Planet[0].Y)) < Planet[0].R) then Exit();
      If(Sqrt(Sqr(cX - Planet[1].X) + Sqr(cY - Planet[1].Y)) < Planet[1].R) then Exit();
      
      For pl := 0 to 1 do begin
         cCos := cX - Planet[pl].X; cSin := cY - Planet[pl].Y;
         cDist := Sqrt(Sqr(cCos) + Sqr(cSin));
         cCos /= cDist; cSin /= cDist;
         
         cAng := GetAngle(cSin,cCos) - Planet[pl].AngDelta;
         If (cAng < 0) then cAng += 2*Pi;
         cC := Planet[pl].Cmin + cAng * Planet[pl].R;
         
         Res := ResourceAvailable(cC,75);
         
         Writeln('Planet ',pl,' cC: ',Trunc(cC),' (',Trunc(Planet[pl].Cmin),' - ',Trunc(Planet[pl].Cmax),'); Res: ',Res);
         
         If (cC >= Planet[pl].Cmin) and (cC <= Planet[pl].Cmax) then begin
            If (SelType = SEL_CREAT) then
               For Idx:=0 to (SelLen - 1) do
                  If (SelID[Idx] >= 0) and (SelID[Idx] < CreatureLen) then
                     If (Creature[SelID[Idx]] <> NIL) then begin
                        If (Res >= 0) and (CreatureStats[Creature[SelID[Idx]]^.Typ].Collect > 0) then begin
                           Creature[SelID[Idx]]^.Order.Typ := TCreatureOrder(Ord(CROR_COL_CRYS) + Ord(Resource[Res]^.Typ));
                           Creature[SelID[Idx]]^.Order.Coll.Target := Res;
                        end else begin
                           Creature[SelID[Idx]]^.Order.Typ := CROR_WALK;
                           Creature[SelID[Idx]]^.Order.Dest := cC;
                        end;
                     end;
            Exit()
         end;
      end;
   end;


Procedure ChangeTeam(Const NewTeam : uInt);
   begin
      If (SelType >= SEL_CREAT) then SelType := SEL_NONE;
      PlayerTeam := NewTeam
   end;


Procedure ProcessEvents();
   begin
      While (SDL_PollEvent(@Ev) > 0) do
         Case (Ev.Type_) of
         
            SDL_QuitEv: Terminate := True;
            
            SDL_KeyDown:
               Case (Ev.Key.Keysym.Sym) of
                  SDLK_ESCAPE: Terminate := True;
                  SDLK_MINUS: CameraZoom(-1, ZOOM_KEYBOARD);
                  SDLK_EQUALS: CameraZoom(+1, ZOOM_KEYBOARD);
                  
                  SDLK_1: ChangeTeam(0);
                  SDLK_2: ChangeTeam(1);
                  
                  SDLK_UP: CamMove[DIR_UP] := True;
                  SDLK_RI: CamMove[DIR_RI] := True;
                  SDLK_DO: CamMove[DIR_DO] := True;
                  SDLK_LE: CamMove[DIR_LE] := True;
               end;
            
            SDL_KeyUp:
               Case (Ev.Key.Keysym.Sym) of
                  SDLK_UP: CamMove[DIR_UP] := False;
                  SDLK_RI: CamMove[DIR_RI] := False;
                  SDLK_DO: CamMove[DIR_DO] := False;
                  SDLK_LE: CamMove[DIR_LE] := False;
               end;
            
            SDL_MouseMotion: begin
               mX := Ev.Motion.X;
               mY := Ev.Motion.Y;
            end;
            
            SDL_MouseButtonDown: begin
               mX := Ev.Button.X;
               mY := Ev.Button.Y;
               
               Case (Ev.Button.Button) of
                  SDL_BUTTON_LEFT: begin
                     SelType := SEL_MAKING;
                     mSelX := Trunc(Camera.X + mX * CamScaleFactor);
                     mSelY := Trunc(Camera.Y + mY * CamScaleFactor);
                  end;
                  
                  SDL_BUTTON_RIGHT: IssueOrder();
                  
                  SDL_BUTTON_WHEELDOWN: CameraZoom(-1, ZOOM_MOUSE);
                  SDL_BUTTON_WHEELUP: CameraZoom(+1, ZOOM_MOUSE);
               end;
            end;
            
            SDL_MouseButtonUp: begin
               mX := Ev.Button.X;
               mY := Ev.Button.Y;
               
               Case (Ev.Button.Button) of
                  SDL_BUTTON_LEFT: MakeSelection();
               end;
            end;
            
         end;
   end;


Procedure CalculateBuildings();
   Var C:uInt;
   begin
      If (BuildingNum = 0) then Exit();
      For C:=0 to (BuildingLen - 1) do begin
         If (Building[C] = NIL) then Continue;
         
         Building[C]^.Calculate()
      end;
   end;


Procedure CalculateCreatures();
   Var C:uInt;
   begin
      If (CreatureNum = 0) then Exit();
      For C:=0 to (CreatureLen - 1) do begin
         If (Creature[C] = NIL) then Continue;
         
         Creature[C]^.Calculate()
      end;
   end;


Procedure CalculateBullets();
   Var B,C,i:sInt; RemBul : Boolean;
   begin
      If (BulletLen = 0) then Exit();
      For i:=0 to (BulletLen - 1) do
         If (Bullet[i] <> NIL) then begin
            Bullet[i]^.X += Bullet[i]^.XVel * dT;
            Bullet[i]^.Y += Bullet[i]^.YVel * dT;
            
            For C:=0 to (CreatureLen - 1) do
               If (Creature[C] <> NIL) and (Creature[C]^.Team <> Bullet[i]^.Team) then
                  If (EntityInBox(Creature[C],30,42,Bullet[i]^.X-2.5,Bullet[i]^.Y-2.5,5,5)) then begin
                     DamageCreature(C, Bullet[i]^.Pow);
                     RemBul := True;
                     Break
                  end;
            
            If(Not RemBul) then
            For B:=0 to (BuildingLen - 1) do
               If (Building[B] <> NIL) and (Building[B]^.Team <> Bullet[i]^.Team) then
                  If (EntityInBox(Building[B],90,63,Bullet[i]^.X-2.5,Bullet[i]^.Y-2.5,5,5)) then begin
                     DamageBuilding(B, Bullet[i]^.Pow);
                     RemBul := True;
                     Break
                  end;
            
            If(RemBul) then begin
               Dispose(Bullet[i]);
               Bullet[i] := NIL;
               BulletNum -= 1
            end
         end;
   end;


Procedure CountFrames();
   Var WindowName : AnsiString;
   begin
      Frames += 1;
      
      FrameTime += Time;
      If (FrameTime < 1000) then Exit;
      
      WriteStr(FrameStr,'FPS: ',Frames);
      WriteStr(WindowName, GAME_NAME, ' v.', GAME_VERSION, ' (', Frames, ' FPS)');
      SDL_WM_SetCaption(PChar(WindowName), PChar(WindowName));
      
      FrameTime -= 1000;
      Frames := 0
   end;

Procedure LoadGfx();
   begin
      FontA := Sour.LoadFont('gfx/font.png',$000000,7,9,#32);
      Sour.SetFontSpacing(FontA,1,2);
      
      UIGfx[UI_TECHNO][UIS_CRYSTALS] := Sour.LoadImage('gfx/techno-crystal.png',$000000);
      UIGfx[UI_TECHNO][UIS_TIMBER  ] := Sour.LoadImage('gfx/techno-timber.png',$000000);
      UIGfx[UI_TECHNO][UIS_METAL   ] := Sour.LoadImage('gfx/techno-metal.png',$000000);
      
      UIGfx[UI_TECHNO][UIS_SEL_L] := Sour.LoadImage('gfx/techno-sel-l.png',$000000);
      UIGfx[UI_TECHNO][UIS_SEL_M] := Sour.LoadImage('gfx/techno-sel-m.png',$000000);
      UIGfx[UI_TECHNO][UIS_SEL_R] := Sour.LoadImage('gfx/techno-sel-r.png',$000000);
      
      UIGfx[UI_TRIBAL][UIS_CRYSTALS] := Sour.LoadImage('gfx/tribal-crystal.png',$000000);
      UIGfx[UI_TRIBAL][UIS_TIMBER  ] := Sour.LoadImage('gfx/tribal-timber.png',$000000);
      UIGfx[UI_TRIBAL][UIS_METAL   ] := Sour.LoadImage('gfx/tribal-metal.png',$000000);
      
      UIGfx[UI_TRIBAL][UIS_SEL_L] := Sour.LoadImage('gfx/tribal-sel-l.png',$000000);
      UIGfx[UI_TRIBAL][UIS_SEL_M] := Sour.LoadImage('gfx/tribal-sel-m.png',$000000);
      UIGfx[UI_TRIBAL][UIS_SEL_R] := Sour.LoadImage('gfx/tribal-sel-r.png',$000000);
      
      ResourceGfx := Sour.LoadImage('gfx/resources.png',$000000);
      CreatureGfx := Sour.LoadImage('gfx/creatures.png',$000000);
      BuildingGfx := Sour.LoadImage('gfx/buildings.png',$000000);
   end;

begin // MAIN
   Randomize();
   
   SDL_Init(SDL_INIT_VIDEO or SDL_INIT_AUDIO or SDL_INIT_TIMER);
   
   Icon := IMG_Load('gfx/iconA.png');
   SDL_WM_SetIcon(Icon, NIL);
   
   Sour.SetGLAttributes(8,8,8,1);
   Screen := Sour.OpenWindow(800,600);
   
   SDL_WM_SetCaption(PChar(GAME_NAME),PChar(GAME_NAME));
   Sour.SetClearColour(Sour.MakeColour(0,0,0));
   
   LoadGfx();
   
   With Planet[0] do begin
      X := 2000; Y := 2000; R := 2000
   end;
   
   With Planet[1] do begin
      X := 3500; Y := 3500; R := 1500
   end;
   
   CalcPlanetZones();
   
   ResourceLen := 50;
   SetLength(Resource, ResourceLen);
   For ResourceNum := 0 to (ResourceLen-1) do begin
      New(Resource[ResourceNum]);
      
      Resource[ResourceNum]^.Typ := TResourceType(Random(3));
      Resource[ResourceNum]^.Amount := 40+Random(81);
      
      Resource[ResourceNum]^.C := Random() * Planet[1].Cmax
   end;
   ResourceNum := ResourceLen;
   
   BuildingLen := 2;
   SetLength(Building, BuildingLen);
   For BuildingNum := 0 to (BuildingLen - 1) do begin
      New(Building[BuildingNum],Create());
      
      Building[BuildingNum]^.C := Random() * Planet[1].Cmax;
      Building[BuildingNum]^.Typ := TBuildingType(2 * BuildingNum);
      
      Building[BuildingNum]^.Team := BuildingNum;
      Building[BuildingNum]^.SightRange := 222
   end;
   BuildingNum := BuildingLen;
   
   CreatureLen := 40;
   SetLength(Creature, CreatureLen);
   For CreatureNum := 0 to (CreatureLen-1) do begin
      New(Creature[CreatureNum],Create());
      
      Creature[CreatureNum]^.C := Random() * Planet[1].Cmax;
      
      Creature[CreatureNum]^.Order.Typ := CROR_WALK;
      Creature[CreatureNum]^.Order.Dest := Random() * Planet[1].Cmax;
      
      Creature[CreatureNum]^.Typ := TCreatureType(Random(7));
      Creature[CreatureNum]^.Anim := CRAN_STAND;
      
      If (Creature[CreatureNum]^.Typ < CRTRIB_WORK)
         then Creature[CreatureNum]^.Team := 0
         else Creature[CreatureNum]^.Team := 1;
      Creature[CreatureNum]^.SightRange := CreatureStats[Creature[CreatureNum]^.Typ].Speed / 1.5;
   end;
   CreatureNum := CreatureLen;
   
   PlayerResources[0] := BuildingStats[BUTECH_BASE].Cost;
   PlayerResources[1] := BuildingStats[BUTRIB_BASE].Cost;
   
   SelType := SEL_NONE;
   SelLen := 0;
   
   Repeat
      
      AdvanceTime();
      
      ProcessEvents();
      MoveCamera();
      
      CalculateBuildings();
      CalculateCreatures();
      CalcSightZones();
      
      DrawFrame();
      CountFrames()
      
   Until Terminate;
   
   SDL_Quit()
end.
