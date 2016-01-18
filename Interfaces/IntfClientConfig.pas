unit IntfClientConfig;

interface

type
  IClientConfig = interface
    ['{E7C229C3-79E6-47BD-81FF-3B4B19CDC22A}']
    function GetDeviceIp : cardinal ;
    function GetUserId   : integer  ;
    function GetUserMode : integer  ;
    function GetUserName : string   ;
    function GetSipKey   : string   ;
    property DeviceIp : cardinal read GetDeviceIp;
    property UserId   : integer  read GetUserId;
    property UserMode : integer  read GetUserMode;
    property UserName : string   read GetUserName;
    property SipKey   : string   read GetSipKey;
  end;

implementation

end.
