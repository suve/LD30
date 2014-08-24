unit entities;

interface
   uses Enums;

Type
   PEntity = ^TEntity;
   TEntity = object
      C, H : Double;
      
      HP : Double;
      Team : uInt;
      
      SightRange : Double;
      
      FireRange : Double;
      FireInterval : sInt;
      
      Procedure Calculate(); Virtual; Abstract;
      
      Destructor Destroy(); Virtual; Abstract;
   end;

implementation

end.
