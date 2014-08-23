unit creatures;

{$INCLUDE defines.inc}

interface
   uses Enums;

Type
   PCreature = ^TCreature;
   TCreature = object
      C, H : Double;
      
      HP, MaxHP : Double;
      Speed : Double;
      
      Typ : TCreatureType;
      Team : uInt;
      
      IntoCrystal, IntoMetal, IntoWood : Boolean;
      IntoBuild, IntoRepair : Boolean;
      
      Order : TCreatureOrder;
      OrderTarget : uInt;
      
      // Function X():Double;
      // Function Y():Double;
      
      Procedure Calculate();
      
      Constructor Create();
      Destructor Destroy();
   end;

Var
   Creature : Array of PCreature;
   CreatureNum, CreatureLen : uInt;

implementation
   uses Globals;

Constructor TCreature.Create();
   begin
   
   end;

Destructor TCreature.Destroy();
   begin
   
   end;

Procedure TCreature.Calculate();
   Var distMin, distPlu : Double;
   begin
      Case (Self.Order) of
         
         CROR_STAND: ;
         
         CROR_WALK: begin
            If (OrderTarget >= Self.C) then begin
               distPlu := OrderTarget - Self.C;
               distMin := Planet[1].Cmax - distPlu;
            end else begin
               distMin := Self.C - OrderTarget;
               distPlu := Planet[1].Cmax - distMin;
            end;
            
            If (distPlu < distMin) then begin
               Self.C += dT * Self.Speed;
               If (Self.C > Planet[1].Cmax)
                  then Self.C -= Planet[1].Cmax
            end else begin 
               Self.C -= dT * Self.Speed;
               If (Self.C < 0)
                  then Self.C += Planet[1].Cmax
            end;

            If (Abs(Self.C - OrderTarget) < 10) 
               then Self.Order := CROR_PATROL
         end;
         
      end
   end;

end.
