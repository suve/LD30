unit entities;

interface
   uses Enums;

Type
   PEntity = ^TEntity;
   TEntity = object
      C, H : Double;
      
      HP : Double;
      Team : uInt;
      
      Procedure Calculate(); Virtual; Abstract;
      
      Destructor Destroy(); Virtual; Abstract;
   end;

implementation

end.
