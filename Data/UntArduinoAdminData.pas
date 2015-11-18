unit UntArduinoAdminData;

interface
uses
  System.Classes, System.SysUtils,
  UntSipHash,
  ConfigConst;

type
  TEepromConfigV1 = packed record
    startKey        : word;
    configVersion   : word;
    ipAddress       : cardinal;
    wlanKey         : array [0..EE_CHAR_KEY_SIZE-1] of ansiChar;
    ssid            : array [0..EE_CHAR_KEY_SIZE-1] of ansiChar;
    sipKey          : TKey;
    endKey          : word;
  end;

  TEepromConfigV2 = packed record
    startKey        : word;
    configVersion   : word;
    useDHCP         : boolean;
    ipAddress,
    netMask,
    gateway,
    dnsServer       : cardinal;
    wlanKey         : array [0..EE_CHAR_KEY_SIZE-1] of ansiChar;
    ssid            : array [0..EE_CHAR_KEY_SIZE-1] of ansiChar;
    sipKey          : TKey;
    endKey          : word;
  end;


  TEepromConfig = packed record
    startKey        : word;
    configVersion   : word;
    useDHCP         : boolean;
    ipAddress,
    netMask,
    gateway,
    dnsServer       : cardinal;
    macAddress      : TMacAddress;
    wlanKey         : array [0..EE_CHAR_KEY_SIZE-1] of ansiChar;
    ssid            : array [0..EE_CHAR_KEY_SIZE-1] of ansiChar;
    sipKey          : TKey;
    endKey          : word;
  end;

  TUserConfig = packed record
    userId   : word;
    userKey  : word;
    userMode : word;
  end;

  TUsers = array [0..EE_USER_COUNT-1] of TUserConfig;
  TUserNames = array [0..EE_USER_COUNT-1] of String[30];

type
  TArduinoAdminData = class
  private
    FWLanKey: string;
    FSipKey: TSipKey;
    FIpAddress: cardinal;
    FAdminPw: string;
    FSSID: string;
    FUsers : TUsers;
    FUsersAvailable : boolean;
    FUserNames : array[0..EE_USER_COUNT-1] of string;
    FDnsServer: cardinal;
    FNetMask: cardinal;
    FGateway: cardinal;
    FUseDhcp: boolean;
    FMacAddress: TMacAddress;
    procedure SetAdminPw(const Value: string);
    procedure SetIpAddress(const Value: cardinal);
    procedure SetSipKey(const Value: TSipKey);
    procedure SetSSID(const Value: string);
    procedure SetWLanKey(const Value: string);
    function GetUserName(idx: integer): string;
    procedure SetUserName(idx: integer; const Value: string);
    function GetUserExists(idx: integer): boolean;
    function GetUserState(idx: integer): string;
    function GetUserId(idx: integer): integer;
    function GetUserKey(idx: integer): integer;
    procedure SetUserId(idx: integer; const Value: integer);
    procedure SetUserKey(idx: integer; const Value: integer);
    function GetUserMode(idx: integer): integer;
    procedure SetUserMode(idx: integer; const Value: integer);
    procedure SetDnsServer(const Value: cardinal);
    procedure SetGateway(const Value: cardinal);
    procedure SetNetMask(const Value: cardinal);
    procedure LoadFromV1File (Stream : TFileStream);
    procedure LoadFromV2File(Stream: TFileStream);
    procedure SetMacAddress(const Value: TMacAddress);
  public
    constructor Create;
    destructor Destroy; override;
    procedure SaveToFile (FileName : string);
    procedure LoadFromFile (FileName : string);
    procedure CreateSipKey;

    property AdminPw   : string read FAdminPw write SetAdminPw;
    property WLanKey   : string read FWLanKey write SetWLanKey;
    property SSID      : string read FSSID write SetSSID;
    property MacAddress: TMacAddress read FMacAddress write SetMacAddress;
    property UseDhcp   : boolean read FUseDhcp write FUseDhcp;
    property IpAddress : cardinal read FIpAddress write SetIpAddress;
    property NetMask   : cardinal read FNetMask   write SetNetMask  ;
    property Gateway   : cardinal read FGateway   write SetGateway  ;
    property DnsServer : cardinal read FDnsServer write SetDnsServer;
    property SipKey    : TSipKey read FSipKey write SetSipKey;

    property UsersAvailable : boolean read FUsersAvailable;
    property Users          : TUsers read FUsers;
    property UserName  [idx : integer] : string  read GetUserName write SetUserName;
    property UserId    [idx : integer] : integer read GetUserId write SetUserId;
    property UserKey   [idx : integer] : integer read GetUserKey write SetUserKey;
    property UserMode  [idx : integer] : integer read GetUserMode write SetUserMode;
    property UserState [idx : integer] : string  read GetUserState;
    property UserExists[idx : integer] : boolean read GetUserExists;
  end;

(*
struct t_eeprom_config
{
	unsigned int  startKey;
	unsigned int  configVersion;
	unsigned long ipAddress;
	char          wlanKey      [EE_CHAR_KEY_SIZE];
	char          ssid         [EE_CHAR_KEY_SIZE];
	byte          sipKey       [EE_SIP_KEY_SIZE];
	unsigned int  endKey;
	};
*)


implementation

{ TArduinoAdminData }

constructor TArduinoAdminData.Create;
begin
  SipKey := TSipKey.create();
end;

procedure TArduinoAdminData.CreateSipKey;
begin

end;

destructor TArduinoAdminData.Destroy;
begin
  SipKey.Free;
end;

procedure TArduinoAdminData.LoadFromFile(FileName: string);
var
  Stream : TFileStream;
  Config : TEepromConfig;
  ReadSize : Longint;
  EndKey   : word;
  StrData  : PAnsiChar;
  UserNames: TUserNames;
  i        : integer;
  Hasconfig: boolean;
begin
  FUsersAvailable := false;
  HasConfig := true;
  Stream := TFileStream.Create(FileName, fmOpenRead);
  try
    ReadSize := Stream.Read(Config, SizeOf(Config));

    if ReadSize <> SizeOf(Config)  then
      raise Exception.Create('Config size mismatch');

    if (Config.startKey <> EE_CONFIG_START_KEY) or (Config.endKey <> EE_CONFIG_END_KEY) then begin
      HasConfig := false;
      if (Config.startKey = EE_CONFIG_START_KEY) and (Config.configVersion = 1) then
        LoadFromV1File (Stream)
      else if (Config.startKey = EE_CONFIG_START_KEY) and (Config.configVersion = 1) then
        LoadFromV2File (Stream)
      else
        raise Exception.Create('Config mismatch');
    end;

    if Stream.Size - Stream.Position >= SizeOf(TUsers) then begin
      ReadSize := Stream.Read(FUsers, SizeOf(TUsers));

      if ReadSize <> SizeOf(TUsers)  then
        raise Exception.Create('Config size mismatch');

      ReadSize := Stream.Read(EndKey, 2);

      if (ReadSize = 0) or (EndKey <> EE_USER_END_KEY) then
        raise Exception.Create('Config mismatch');

      FUsersAvailable := true;

      if Stream.Size - Stream.Position >= SizeOf(TUserNames) then begin
        ReadSize := Stream.Read(UserNames, SizeOf(TUserNames));
        if ReadSize <> SizeOf(TUserNames)  then
          raise Exception.Create('Config size mismatch');

        for i := 0 to EE_USER_COUNT-1 do
          if FUsers[i].userMode <> 0 then
            self.UserName[i] := UserNames[i];


      end;
    end;
  finally
    Stream.Free;
  end;
  if Hasconfig then begin

    StrData := @Config.wlanKey;
    FWLanKey := StrData;

    StrData := @Config.ssid;
    FSSID := StrData;

    FUseDhcp   := Config.useDHCP;
    FIpAddress := Config.IpAddress;
    FNetMask   := Config.NetMask  ;
    FGateway   := Config.Gateway  ;
    FDnsServer := Config.DnsServer;
    FMacAddress:= Config.MacAddress;
    SipKey.CopyFrom(Config.sipKey);
  end;
end;

procedure TArduinoAdminData.LoadFromV1File(Stream : TFileStream);
var
  Config : TEepromConfigV1;
  ReadSize : Longint;
  StrData  : PAnsiChar;
begin
  Stream.Position := 0;
  ReadSize := Stream.Read(Config, SizeOf(Config));

  if ReadSize <> SizeOf(Config)  then
    raise Exception.Create('Config size mismatch');

  if (Config.startKey <> EE_CONFIG_START_KEY) or (Config.endKey <> EE_CONFIG_END_KEY) then
    raise Exception.Create('Config mismatch');

  StrData := @Config.wlanKey;
  FWLanKey := StrData;

  StrData := @Config.ssid;
  FSSID := StrData;

  FUseDhcp   := false;
  FIpAddress := Config.IpAddress;
  FNetMask   := 0;
  FGateway   := 0;
  FDnsServer := 0;

  FillChar(FMacAddress, 0, SizeOf(FMacAddress));

  SipKey.CopyFrom(Config.sipKey);
end;

procedure TArduinoAdminData.LoadFromV2File(Stream : TFileStream);
var
  Config : TEepromConfigV2;
  ReadSize : Longint;
  StrData  : PAnsiChar;
begin
  Stream.Position := 0;
  ReadSize := Stream.Read(Config, SizeOf(Config));

  if ReadSize <> SizeOf(Config)  then
    raise Exception.Create('Config size mismatch');

  if (Config.startKey <> EE_CONFIG_START_KEY) or (Config.endKey <> EE_CONFIG_END_KEY) then
    raise Exception.Create('Config mismatch');

  StrData := @Config.wlanKey;
  FWLanKey := StrData;

  StrData := @Config.ssid;
  FSSID := StrData;

  FUseDhcp   := Config.useDHCP;
  FIpAddress := Config.IpAddress;
  FNetMask   := Config.netMask;
  FGateway   := Config.gateway;
  FDnsServer := Config.dnsServer;

  SipKey.CopyFrom(Config.sipKey);
end;

procedure TArduinoAdminData.SaveToFile(FileName: string);
var
  Stream : TFileStream;
  Config : TEepromConfig;
  EndKey   : word;
  StrData  : AnsiString;
  UserNames: TUserNames;
  i        : integer;
begin
  FillChar(Config, SizeOf(Config), 0);

  Config.startKey := EE_CONFIG_START_KEY;
  Config.endKey   := EE_CONFIG_END_KEY;
  Config.configVersion := EE_CONFIG_VERSION;

  StrData := WLanKey;
  Move (StrData[1], Config.wlanKey, Length(StrData) + 1);

  StrData := SSID;
  Move (StrData[1], Config.ssid, Length(StrData) + 1);

  Move (SipKey.Key, Config.sipKey, SizeOf (TKey));

  Config.useDHCP   := UseDhcp;
  Config.IpAddress := IpAddress;
  Config.NetMask   := NetMask  ;
  Config.Gateway   := Gateway  ;
  Config.DnsServer := DnsServer;
  Config.macAddress:= MacAddress;

  Stream := TFileStream.Create(FileName, fmCreate);
  try
    Stream.Position := 0;
    Stream.Write(Config, SizeOf(Config));

    if UsersAvailable then begin
      Stream.Write(Users, SizeOf(Users));

      EndKey := EE_USER_END_KEY;
      Stream.Write(EndKey, 2);
    end;

    FillChar(UserNames, SizeOf(TUserNames), 0);
    for i := 0 to EE_USER_COUNT-1 do
      UserNames[i] := self.UserName[i];

    Stream.Write(UserNames, SizeOf(TUserNames));

  finally
    Stream.Free;
  end;
end;

procedure TArduinoAdminData.SetAdminPw(const Value: string);
begin
  FAdminPw := Value;
end;

procedure TArduinoAdminData.SetDnsServer(const Value: cardinal);
begin
  FDnsServer := Value;
end;

procedure TArduinoAdminData.SetGateway(const Value: cardinal);
begin
  FGateway := Value;
end;

procedure TArduinoAdminData.SetIpAddress(const Value: cardinal);
begin
  FIpAddress := Value;
end;

procedure TArduinoAdminData.SetMacAddress(const Value: TMacAddress);
begin
  FMacAddress := Value;
end;

procedure TArduinoAdminData.SetNetMask(const Value: cardinal);
begin
  FNetMask := Value;
end;

procedure TArduinoAdminData.SetSipKey(const Value: TSipKey);
begin
  FSipKey := Value;
end;

procedure TArduinoAdminData.SetSSID(const Value: string);
begin
  FSSID := Value;
end;

function TArduinoAdminData.GetUserExists(idx: integer): boolean;
begin
  result := (idx in [0..9]) and (FUsers[Idx].userMode in [UM_USER, UM_ADMIN]);
end;

function TArduinoAdminData.GetUserId(idx: integer): integer;
begin
  if idx in [0..9] then
    result := FUsers[Idx].userId
  else
    result := 0;
end;

function TArduinoAdminData.GetUserKey(idx: integer): integer;
begin
  if idx in [0..9] then
    result := FUsers[Idx].userKey
  else
    result := 0;

end;

function TArduinoAdminData.GetUserMode(idx: integer): integer;
begin
  if idx in [0..9] then
    result := FUsers[Idx].userMode
  else
    result := 0;

end;

procedure TArduinoAdminData.SetUserId(idx: integer; const Value: integer);
begin
  if idx in [0..9] then
    FUsers[Idx].userId := Value;
end;

procedure TArduinoAdminData.SetUserKey(idx: integer; const Value: integer);
begin
  if idx in [0..9] then
    FUsers[Idx].userKey := Value;
end;

procedure TArduinoAdminData.SetUserMode(idx: integer; const Value: integer);
begin
  if idx in [0..9] then
    FUsers[Idx].userMode := Value;

  FUsersAvailable := FUsersAvailable or (Value <> 0);
end;

function TArduinoAdminData.GetUserName(idx: integer): string;
begin
  if idx in [0..9] then
    result := FUserNames[idx]
  else
    result := '';
end;

function TArduinoAdminData.GetUserState(idx: integer): string;
begin
  if idx in [0..9] then
    case FUsers[Idx].userMode of
      0: result := '';
      1: result := 'user';
      2: result := 'admin';
    end
  else
    result := '';
end;

procedure TArduinoAdminData.SetUserName(idx: integer; const Value: string);
begin
  if idx <= 9 then
    FUserNames[idx] := Value;
end;

procedure TArduinoAdminData.SetWLanKey(const Value: string);
begin
  FWLanKey := Value;
end;

end.
