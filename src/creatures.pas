unit creatures;

{$INCLUDE defines.inc}

interface
   uses Enums, Entities;

Type
   TCreatureStats = record
      W, H : uInt;
      MaxHP, Speed : Double;
      Collect, Build : Boolean;
   end;

Const
   CreatureStats : Array[TCreatureType] of TCreatureStats = (
      (W: 15; H: 21; MaxHP: 120; Speed: 180; Collect: True; Build: True),
      (W: 15; H: 21; MaxHP: 150; Speed: 360; Collect: False; Build: False),
      (W: 15; H: 21; MaxHP: 250; Speed: 250; Collect: False; Build: False),
      (W: 15; H: 21; MaxHP: 170; Speed: 285; Collect: False; Build: False),
      (W: 15; H: 21; MaxHP:  90; Speed: 170; Collect: True; Build: True),
      ()
   );

Type
   PCreature = ^TCreature;
   TCreature = object(TEntity)
      
      Typ : TCreatureType;
      Anim : TCreatureAnim;
      Facing : TFacing;

      Order : TCreatureOrder;
      OrderTarget : sInt;
      
      // Function X():Double;
      // Function Y():Double;
      
      Procedure WalkTowards(Const dest:Double);
      Procedure Calculate(); Virtual;
      
      Constructor Create();
      Destructor Destroy(); Virtual;
   end;

Var
   Creature : Array of PCreature;
   CreatureNum, CreatureLen : uInt;

implementation
   uses Globals, Resources;

Constructor TCreature.Create();
   begin
   
   end;

Destructor TCreature.Destroy();
   begin
   
   end;

Procedure TCreature.WalkTowards(Const dest:Double);
   Var distMin, distPlu : Double;
   begin
      If (dest >= Self.C) then begin
         distPlu := dest - Self.C;
         distMin := Planet[1].Cmax - distPlu;
      end else begin
         distMin := Self.C - dest;
         distPlu := Planet[1].Cmax - distMin;
      end;
      
      If (distPlu < distMin) then begin
         Self.Facing := FACE_RIG;
         Self.C += dT * CreatureStats[Self.Typ].Speed;
         If (Self.C > Planet[1].Cmax)
            then Self.C -= Planet[1].Cmax
      end else begin 
         Self.Facing := FACE_LEF;
         Self.C -= dT * CreatureStats[Self.Typ].Speed;
         If (Self.C < 0)
            then Self.C += Planet[1].Cmax
      end;
   end;

Procedure TCreature.Calculate();
   begin
      Case (Self.Order) of
         
         CROR_PATROL: Self.Facing := FACE_MID;
         
         CROR_STAND: Self.Facing := FACE_MID;
         
         CROR_WALK: begin
            WalkTowards(Self.OrderTarget);

            If (Abs(Self.C - OrderTarget) < 10) 
               then Self.Order := CROR_PATROL
         end;
         
         CROR_COL_CRYS, CROR_COL_TIMB, CROR_COL_META: begin
            If (Resource[OrderTarget] = NIL) or (Resource[OrderTarget]^.Amount <= 0) then begin
               OrderTarget := NearestResource(@Self, TResourceType(Ord(Self.Order) - Ord(CROR_COL_CRYS)));
               If (OrderTarget < 0) then begin
                  Self.Order := CROR_PATROL
               end;
            end;
            
            If (CDist(Self.C, Resource[OrderTarget]^.C) < 5) then begin
               
               
            end else Self.WalkTowards(Resource[OrderTarget]^.C)
         end;
         
      end
   end;

end.
