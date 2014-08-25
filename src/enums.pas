unit enums;

interface
   uses SDL;

Type
   sInt = System.NativeInt;
   uInt = System.NativeUInt;
   
   TCreatureOrder = (
      CROR_PATROL, CROR_STAND, CROR_WALK,
      CROR_ATT_WALK, CROR_ATT_CREA, CROR_ATT_BLDG,
      CROR_COL_CRYS, CROR_COL_TIMB, CROR_COL_META,
      CROR_RET_CRYS, CROR_RET_TIMB, CROR_RET_META,
      CROR_LENGTH
   );
   
   TCollectInfo = record
      // ReTy : TResourceType;
      Target : sInt;
      Return : sInt;
   end;
   
   TOrderData = record
      Case Typ : TCreatureOrder of
         CROR_PATROL, CROR_STAND: (Pos : Double);
         CROR_WALK, CROR_ATT_WALK : (Dest : Double);
         CROR_ATT_CREA, CROR_ATT_BLDG : (Target : sInt);
         CROR_COL_CRYS .. CROR_RET_META: (Coll : TCollectInfo);
   end;
   
   TCreatureAnim = (CRAN_STAND, CRAN_ATTAK, CRAN_CRYST, CRAN_TIMBE, CRAN_METAL);
   
   TCreatureType = (
      CRTECH_WORK, CRTECH_SCOU, CRTECH_TANK, CRTECH_KATY,
      CRTRIB_WORK, CRTRIB_SPIT, CRTRIB_AXXE,
      CRTYPE_LENGTH
   );
   
   TBuildingType = (
      BUTECH_BASE, BUTECH_SENTRY,
      BUTRIB_BASE, BUTRIB_SENTRY,
      BUTYPE_LENGTH
   );
   
   TResourceType = (RSRC_CRYSTAL, RSRC_TIMBER, RSRC_METAL);
   
   TDir = (DIR_UP, DIR_RIGHT, DIR_DOWN, DIR_LEFT);
   TFacing = (FACE_LEFT, FACE_MIDDLE, FACE_RIGHT);
   
   TUIType = (UI_TECHNO, UI_TRIBAL);
   TUISprite = (UIS_CRYSTALS, UIS_METAL, UIS_TIMBER, UIS_SEL_L, UIS_SEL_M, UIS_SEL_R);
   
   TSelectionType = (SEL_NONE, SEL_MAKING, SEL_CREAT, SEL_BUILD);
   
   TMouseAction = (MOAC_SELECT, MOAC_PLACE, MOAC_TARGET);
   
   PPoint = ^TPoint;
   TPoint = record
      X, Y : Double
   end;
   
Const
   DIR_RI = DIR_RIGHT;
   DIR_DO = DIR_DOWN;
   DIR_LE = DIR_LEFT;
   
   FACE_LEF = FACE_LEFT;
   FACE_MID = FACE_MIDDLE;
   FACE_RIG = FACE_RIGHT;
   
   SDLK_RI = SDLK_RIGHT;
   SDLK_DO = SDLK_DOWN;
   SDLK_LE = SDLK_LEFT;
   
implementation

end.
