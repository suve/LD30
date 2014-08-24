unit enums;

interface
   uses SDL;

Type
   sInt = System.NativeInt;
   uInt = System.NativeUInt;
   
   TCreatureOrder = (
      CROR_PATROL, CROR_STAND, CROR_WALK,
      CROR_ATT_WALK, CROR_ATT_UNIT, CROR_ATT_BLDG,
      CROR_COL_CRYS, CROR_COL_TIMB, CROR_COL_META,
      CROR_LENGTH
   );
   
   TCreatureType = (
      CRTECH_WORK, CRTECH_WORK_CRYS, CRTECH_WORK_TIMB, CRTECH_WORK_META,
      CRTRIB_WORK, CRTRIB_WORK_CRYS, CRTRIB_WORK_TIMB, CRTRIB_WORK_META,
      CRTYPE_LENGTH
   );
   
   TBuildingType = (
      BUTECH_BASE, BUTECH_SENTRY,
      BUTRIB_BASE, BUTRIB_SENTRY,
      BUTYPE_LENGTH
   );
   
   TResourceType = (RSRC_CRYSTAL, RSRC_TIMBER, RSRC_METAL);
   
   TDir = (DIR_UP, DIR_RIGHT, DIR_DOWN, DIR_LEFT);
   
   TUIType = (UI_TECHNO, UI_TRIBAL);
   TUISprite = (UIS_CRYSTALS, UIS_METAL, UIS_TIMBER, UIS_SEL_L, UIS_SEL_M, UIS_SEL_R);
   
   TSelectionType = (SEL_NONE, SEL_MAKING, SEL_CREAT, SEL_BUILD);
   
   TMouseAction = (MOAC_SELECT, MOAC_PLACE, MOAC_TARGET);
   
Const
   DIR_RI = DIR_RIGHT;
   DIR_DO = DIR_DOWN;
   DIR_LE = DIR_LEFT;
   
   SDLK_RI = SDLK_RIGHT;
   SDLK_DO = SDLK_DOWN;
   SDLK_LE = SDLK_LEFT;

implementation

end.
