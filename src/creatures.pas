unit creatures;

{$INCLUDE defines.inc}

interface
   uses Enums, Entities;

Type
   TCreatureStats = record
      W, H : uInt;
      MaxHP, Speed : Double;
      Collect: sInt;
      Build : Boolean;
      Cost : Array[TResourceType] of Double
   end;

Const
   CreatureStats : Array[TCreatureType] of TCreatureStats = (
      (W: 15; H: 21; MaxHP: 120; Speed: 180; Collect: 12; Build:  True; Cost:(50,  0, 20)),
      (W: 15; H: 21; MaxHP: 150; Speed: 360; Collect:  0; Build: False; Cost:(72,  0, 50)),
      (W: 15; H: 21; MaxHP: 250; Speed: 250; Collect:  0; Build: False; Cost:(80,  0, 70)),
      (W: 15; H: 21; MaxHP: 170; Speed: 285; Collect:  0; Build: False; Cost:(75,  0, 70)),
      (W: 15; H: 21; MaxHP:  90; Speed: 170; Collect: 10; Build:  True; Cost:(35,  0,  0)),
      (W: 15; H: 21; MaxHP: 100; Speed: 270; Collect:  0; Build: False; Cost:(47,  5,  0)),
      (W: 15; H: 21; MaxHP: 142; Speed: 222; Collect:  0; Build: False; Cost:(55, 10,  5)),
      ()
   );

Type
   PCreature = ^TCreature;
   TCreature = object(TEntity)
      
      Typ : TCreatureType;
      Anim : TCreatureAnim;
      Facing : TFacing;

      Order : TOrderData;
      
      CarryType : TResourceType;
      CarryAmount : Double;
      
      Procedure WalkTowards(Const dest:Double);
      Procedure Calculate(); Virtual;
      
      Constructor Create();
      Destructor Destroy(); Virtual;
   end;

Var
   Creature : Array of PCreature;
   CreatureNum, CreatureLen : uInt;

implementation
   uses Globals, Resources, Buildings;

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
   Const MINING_SPEED = 4;
   begin
      Case (Self.Order.Typ) of
         
         CROR_PATROL: Self.Facing := FACE_MID;
         
         CROR_STAND: Self.Facing := FACE_MID;
         
         CROR_WALK: begin
            WalkTowards(Self.Order.Dest);

            If (CDist(Self.C, Order.Dest) < 10) 
               then Self.Order.Typ := CROR_PATROL
         end;
         
         CROR_COL_CRYS, CROR_COL_TIMB, CROR_COL_META: begin
            If (Order.Coll.Target < 0) or (Order.Coll.Target >= ResourceLen) or 
            {} (Resource[Order.Coll.Target] = NIL) or (Resource[Order.Coll.Target]^.Amount <= 0) then begin
               Order.Coll.Target := NearestResource(Self.C, TResourceType(Ord(Self.Order.Typ) - Ord(CROR_COL_CRYS)));
               If (Order.Target < 0) then begin
                  Self.Order.Typ := CROR_PATROL;
                  Exit()
               end;
            end;
            
            If (CDist(Self.C, Resource[Order.Coll.Target]^.C) < 10) then begin
            
               If (Self.CarryType <> Resource[Order.Coll.Target]^.Typ) then begin
                  Self.CarryType := Resource[Order.Coll.Target]^.Typ;
                  Self.CarryAmount := 0.0
               end;
               Self.CarryAmount += dt * MINING_SPEED;
               
               Self.Anim := TCreatureAnim(Ord(CRAN_CRYST) + Ord(Self.CarryType));
               
               If (Self.CarryAmount >= CreatureStats[Self.Typ].Collect) then
                  Self.Order.Typ := TCreatureOrder(Ord(Self.Order.Typ) + 3);
               
               MineResource(Order.Coll.Target, dt * MINING_SPEED);
               
            end else Self.WalkTowards(Resource[Order.Coll.Target]^.C)
         end;
         
         CROR_RET_CRYS, CROR_RET_TIMB, CROR_RET_META: begin
            //Writeln('Order.Coll.Return: ',Order.Coll.Return);
            If (Order.Coll.Return < 0) or (Order.Coll.Return >= BuildingLen) or (Building[Order.Coll.Return] = NIL) or
            {} (Building[Order.Coll.Return]^.Team <> Self.Team) or (Not BuildingStats[Building[Order.Coll.Return]^.Typ].Collect)  then begin
               Order.Coll.Return := NearestCollector(Self.C, Self.Team);
               If (Order.Coll.Return < 0) then begin
                  Self.Order.Typ := CROR_PATROL;
                  Exit()
               end;
            end;
            
            If (CDist(Self.C, Building[Order.Coll.Return]^.C) < 30) then begin
            
               PlayerResources[Self.Team][Self.CarryType] += Self.CarryAmount;
               
               Self.Order.Typ := TCreatureOrder(Ord(Self.Order.Typ) - 3);
               
               Self.Anim := CRAN_STAND;
               Self.CarryAmount := 0;
               
            end else Self.WalkTowards(Building[Order.Coll.Return]^.C)
         end;
            
         
      end
   end;

end.
