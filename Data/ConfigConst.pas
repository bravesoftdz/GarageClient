unit ConfigConst;

interface

const
  EE_CHAR_KEY_SIZE = 30;
  EE_SIP_KEY_SIZE  = 16;
  EE_MAC_KEY_SIZE =  6;

  EE_USER_COUNT    = 10;

  EE_CONFIG_VERSION    = 2;
  EE_CONFIG_START_KEY  = $F1A5;
  EE_CONFIG_END_KEY    = $5A1F;
  EE_USER_END_KEY      = $A5F1;

  UM_INACTIVE = 0;
  UM_USER  = 1;
  UM_ADMIN = 2;

  SM_DENIED = 0;
  SM_USER = 1;
  SM_ADMIN = 2;

type
  TMacAddress = array [0..EE_MAC_KEY_SIZE-1] of byte;


implementation

end.

