unit UntArduinoAdminData;

interface
uses
  System.Classes, System.SysUtils, System.IniFiles,
  UntSipHash, UntIpAddress,
  ConfigConst;

type
  /// <summary>
  /// Record of configuration data
  /// Refering to Version 1 of the data layout
  /// Used to convert older files
  /// </summary>
  TEepromConfigV1 = packed record
    startKey        : word;
    configVersion   : word;
    ipAddress       : cardinal;
    wlanKey         : array [0..EE_CHAR_KEY_SIZE-1] of ansiChar;
    ssid            : array [0..EE_CHAR_KEY_SIZE-1] of ansiChar;
    sipKey          : TKey;
    endKey          : word;
  end;

  /// <summary>
  /// Record of configuration data
  /// Refering to Version 1 of the data layout
  /// Used to convert older files
  /// </summary>
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


  /// <summary>
  /// Record of configuration data
  /// Current version of the data layout
  /// </summary>
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

  /// <summary>
  /// Single user configuration record
  /// </summary>
  TUserConfig = packed record
    userId   : word;
    userKey  : word;
    userMode : word;
  end;

  TUsers       = array [0..EE_USER_COUNT-1] of TUserConfig;
  TUserNames   = array [0..EE_USER_COUNT-1] of String[30];
  TUserChanged = array [0..EE_USER_COUNT-1] of boolean;


    /// <summary>
    ///
    /// </summary>
  	/// <param name=""></param>
  	/// <returns></returns>


type
  /// <summary>
  ///
  /// </summary>
  TArduinoAdminData = class
  private

    /// <summary>
    /// WiFi password
    /// </summary>
    FWLanKey: string;

    /// <summary>
    /// Secret SIP key
    /// </summary>
    FSipKey: TSipKey;

    /// <summary>
    /// Password für Administrator - not used yet
    /// </summary>
    FAdminPw: string;

    /// <summary>
    /// SSI of AP for Arduino WiFi device
    /// </summary>
    FSSID: string;

    /// <summary>
    /// User/Device array
    /// </summary>
    FUsers : TUsers;

    /// <summary>
    /// Flag showing that users are configured
    /// </summary>
    FUsersAvailable : boolean;

    /// <summary>
    /// List of user names referring to user array <seealso>Users</seealso>
    /// </summary>
    FUserNames   : array[0..EE_USER_COUNT-1] of string;

    /// <summary>
    /// List of changed users <seealso>Users</seealso>
    /// </summary>
    FUserChanged : TUserChanged;

    /// <summary>
    /// Fixed IP address for Arduino network device
    /// </summary>
    FIpAddress   : TIpAddress;

    /// <summary>
    /// Fixed DNS server address for Arduino network device
    /// </summary>
    FDnsServer   : TIpAddress;

    /// <summary>
    /// Network mask for fixed IP address on Arduino network device
    /// </summary>
    FNetMask     : TIpAddress;

    /// <summary>
    /// Gateway IP address for Arduino network device
    /// </summary>
    FGateway     : TIpAddress;

    /// <summary>
    /// Use DHCP - or fixed IP address on Arduino network device
    /// </summary>
    FUseDhcp     : boolean;

    /// <summary>
    /// MAC address of Arduino network device.
    /// Only used for Ethershield so far
    /// </summary>
    FMacAddress  : TMacAddress;

    /// <summary>
    /// Load config from a Version 1 - File
    /// </summary>
  	/// <param name="Stream">Filestream of config file</param>
    procedure LoadFromV1File (Stream : TFileStream);

    /// <summary>
    /// Load config from a Version 2 - File
    /// </summary>
  	/// <param name="Stream">Filestream of config file</param>
    procedure LoadFromV2File(Stream: TFileStream);
    /// <summary>
    /// Check whether a user with the given ID has been configured
    /// </summary>
  	/// <param name="Id">Id of the user to look up</param>
   	/// <returns>true, if the user is known</returns>
    function  UserIdExists(Id: integer): boolean;
  private
    // Getters and Setters
    procedure SetAdminPw(const Value: string);
    procedure SetSipKey(const Value: TSipKey);
    procedure SetSSID(const Value: string);
    procedure SetWLanKey(const Value: string);
    procedure SetUseDhcp(const Value: boolean);
    procedure SetMacAddress(const Value: TMacAddress);
    function  GetMacAddressString: string;
    procedure SetMacAddressString(const Value: string);

    //User Getters/Setters
    function  GetUserName(idx: integer): string;
    procedure SetUserName(idx: integer; const Value: string);
    function  GetUserExists(idx: integer): boolean;
    function  GetUserLevel(idx: integer): string;
    function  GetUserId(idx: integer): integer;
    procedure SetUserId(idx: integer; const Value: integer);
    function  GetUserKey(idx: integer): integer;
    procedure SetUserKey(idx: integer; const Value: integer);
    function  GetUserMode(idx: integer): integer;
    procedure SetUserMode(idx: integer; const Value: integer);
    function  GetUserChanged(idx: integer): boolean;
    procedure SetUserChanged(idx: integer; const Value: boolean);
  public
    constructor Create;
    destructor Destroy; override;
    // Save Load

    /// <summary>
    /// Save configuration to binary file
    /// </summary>
  	/// <param name="FileName">The file name</param>
    procedure SaveToFile (FileName : string);
    /// <summary>
    /// Load configuration from binary file
    /// </summary>
  	/// <param name="FileName">The file name</param>
    procedure LoadFromFile (FileName : string);
    /// <summary>
    /// Save configuration to ini file
    /// </summary>
  	/// <param name="IniFile">Ini file instance to use</param>
    procedure SaveToIniFile (IniFile : TCustomIniFile);
    /// <summary>
    /// Load configuration from ini file
    /// </summary>
  	/// <param name="IniFile">Ini file instance to use</param>
    procedure LoadFromIniFile (IniFile : TCustomIniFile);

    // Generate Values
    /// <summary>
    /// Generate a random SipKey
    /// </summary>
    procedure GenerateSipKey;
    /// <summary>
    /// Generate a random MAC address for a Ethershield
    /// </summary>
    procedure GenerateMacAddress;
    /// <summary>
    /// Generate a random user id
    /// </summary>
    function  GenerateUserid  : integer;

    /// <summary>
    /// Password für Administrator - not used yet
    /// </summary>
    property AdminPw          : string read FAdminPw write SetAdminPw;
    /// <summary>
    /// WiFi password
    /// </summary>
    property WLanKey          : string read FWLanKey write SetWLanKey;
    /// <summary>
    /// SSI of AP for Arduino WiFi device
    /// </summary>
    property SSID             : string read FSSID write SetSSID;
    /// <summary>
    /// MAC address of Arduino network device.
    /// Only used for Ethershield so far
    /// </summary>
    property MacAddress       : TMacAddress read FMacAddress write SetMacAddress;
    /// <summary>
    /// Use DHCP - or fixed IP address on Arduino network device
    /// </summary>
    property UseDhcp          : boolean read FUseDhcp write SetUseDhcp;
    /// <summary>
    /// Fixed IP address for Arduino network device
    /// </summary>
    property IpAddress        : TIpAddress read FIpAddress write FIpAddress;
    /// <summary>
    /// Network mask for fixed IP address on Arduino network device
    /// </summary>
    property NetMask          : TIpAddress read FNetMask   write FNetMask  ;
    /// <summary>
    /// Gateway IP address for Arduino network device
    /// </summary>
    property Gateway          : TIpAddress read FGateway   write FGateway  ;
    /// <summary>
    /// Fixed DNS server address for Arduino network device
    /// </summary>
    property DnsServer        : TIpAddress read FDnsServer write FDnsServer;
    /// <summary>
    /// Secret SIP key
    /// </summary>
    property SipKey           : TSipKey  read FSipKey    write SetSipKey;
    /// <summary>
    /// MAC address of Arduino network device - as string.
    /// </summary>
    property MacAddressString : string read GetMacAddressString write SetMacAddressString;

    /// <summary>
    /// Flag showing that users are configured
    /// </summary>
    property UsersAvailable   : boolean read FUsersAvailable;

    /// <summary>
    /// User/Device array
    /// </summary>
    property Users            : TUsers read FUsers;


    /// <summary>
    /// User name
    /// </summary>
  	/// <param name="idx">List index of user</param>
    property UserName        [idx : integer] : string  read GetUserName    write SetUserName;
    /// <summary>
    /// User ID number
    /// </summary>
  	/// <param name="idx">List index of user</param>
    property UserId          [idx : integer] : integer read GetUserId      write SetUserId;
    /// <summary>
    /// User password
    /// </summary>
  	/// <param name="idx">List index of user</param>
    property UserKey         [idx : integer] : integer read GetUserKey     write SetUserKey;
    /// <summary>
    /// User level (Admin/User/None) as integer value
    /// </summary>
  	/// <param name="idx">List index of user</param>
    property UserMode        [idx : integer] : integer read GetUserMode    write SetUserMode;
    /// <summary>
    /// User level (Admin/User/None) as integer
    /// </summary>
  	/// <param name="idx">List index of user</param>
    property UserLevel       [idx : integer] : string  read GetUserLevel;
    /// <summary>
    /// True, if user has been defined
    /// </summary>
  	/// <param name="idx">List index of user</param>
    property UserExists      [idx : integer] : boolean read GetUserExists;
    /// <summary>
    /// True, if user has been changed before last saving
    /// </summary>
  	/// <param name="idx">List index of user</param>
    property UserChanged     [idx : integer] : boolean read GetUserChanged write SetUserChanged;
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
  FIpAddress := TIpAddress.Create;
  FIpAddress.Force := true;
  FNetMask   := TIpAddress.Create;
  FGateway   := TIpAddress.Create;
  FDnsServer := TIpAddress.Create;
end;

destructor TArduinoAdminData.Destroy;
begin
  FSipKey.Free;
  FIpAddress.Free;
  FNetMask.Free;
  FGateway.Free;
  FDnsServer.Free;
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

     // Check keys first and eventually load from previous version files
    if (Config.startKey <> EE_CONFIG_START_KEY) or (Config.endKey <> EE_CONFIG_END_KEY) then begin
      HasConfig := false;
      if (Config.startKey = EE_CONFIG_START_KEY) and (Config.configVersion = 1) then
        LoadFromV1File (Stream)
      else if (Config.startKey = EE_CONFIG_START_KEY) and (Config.configVersion = 2) then
        LoadFromV2File (Stream)
      else
        raise Exception.Create('Config mismatch');
    end;

    // Load user records
    if Stream.Size - Stream.Position >= SizeOf(TUsers) then begin
      ReadSize := Stream.Read(FUsers, SizeOf(TUsers));

      if ReadSize <> SizeOf(TUsers)  then
        raise Exception.Create('Config size mismatch');

      ReadSize := Stream.Read(EndKey, 2);

      if (ReadSize = 0) or (EndKey <> EE_USER_END_KEY) then
        raise Exception.Create('Config mismatch');

      FUsersAvailable := true;

      // add user names
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

  // Initialize data, if no config was found
  if Hasconfig then begin

    StrData := @Config.wlanKey;
    FWLanKey := StrData;

    StrData := @Config.ssid;
    FSSID := StrData;

    FUseDhcp           := Config.useDHCP;
    FIpAddress.Address := Config.IpAddress;
    FNetMask.Address   := Config.NetMask  ;
    FGateway.Address   := Config.Gateway  ;
    FDnsServer.Address := Config.DnsServer;
    FMacAddress        := Config.MacAddress;
    SipKey.CopyFrom(Config.sipKey);
  end;
end;

procedure TArduinoAdminData.LoadFromIniFile(IniFile: TCustomIniFile);
var
  n : integer;
  Mode : integer;
  UserSect : string;
  Valid    : boolean;
begin
  // Check, if ini file contains valid data
  Valid               := IniFile.ReadBool  (SectAdmin,   KeyValidData, false);
  if not Valid then
    exit;

  AdminPw             := IniFile.ReadString(SectAdmin,   KeyPassword,  '');
  WLanKey             := IniFile.ReadString(SectArduino, KeyWLanKey   ,'');
  SSID                := IniFile.ReadString(SectArduino, KeySSID      ,'');
  MacAddressString    := IniFile.ReadString(SectArduino, KeyMacAddress,'');
  UseDhcp             := IniFile.ReadBool  (SectArduino, KeyUseDhcp, false);
  IpAddress.AsString  := IniFile.ReadString(SectArduino, KeyIpAddress,'');
  NetMask.AsString    := IniFile.ReadString(SectArduino, KeyNetMask  ,'');
  Gateway.AsString    := IniFile.ReadString(SectArduino, KeyGateway  ,'');
  DnsServer.AsString  := IniFile.ReadString(SectArduino, KeyDnsServer,'');
  SipKey.AsString     := IniFile.ReadString(SectArduino, KeySipKey,   '');

  for n := 0 to EE_USER_COUNT - 1 do begin
    Mode := IniFile.ReadInteger(SectUsers, SectUser + IntToStr(n + 1), 0);
    if Mode > 0 then begin
      UserSect := SectUser + IntToStr(n);
      UserId[n]   := IniFile.ReadInteger(UserSect, KeyUserId, 0);
      UserKey[n]  := IniFile.ReadInteger(UserSect, KeyKey, 0);
      UserMode[n] := Mode; //IniFile.ReadInteger(UserSect, KeyMode, 0);
      UserName[n] := IniFile.ReadString (UserSect, KeyName, '');
    end
    else begin
      UserId[n]   := 0;
      UserMode[n] := 0;
    end;
  end;
end;

procedure TArduinoAdminData.SaveToIniFile(IniFile: TCustomIniFile);
var
  n : integer;
  Mode     : integer;
  UserSect : string;
begin
  // Set valid data flag in file first
  IniFile.WriteBool  (SectAdmin,   KeyValidData, true              );
  IniFile.WriteString(SectAdmin,   KeyPassword,  AdminPw           );
  IniFile.WriteString(SectArduino, KeyWLanKey,   WLanKey           );
  IniFile.WriteString(SectArduino, KeySSID,      SSID              );
  IniFile.WriteString(SectArduino, KeyMacAddress,MacAddressString  );
  IniFile.WriteBool  (SectArduino, KeyUseDhcp,   UseDhcp           );
  IniFile.WriteString(SectArduino, KeyIpAddress, IpAddress.AsString);
  IniFile.WriteString(SectArduino, KeyNetMask,   NetMask.AsString  );
  IniFile.WriteString(SectArduino, KeyGateway,   Gateway.AsString  );
  IniFile.WriteString(SectArduino, KeyDnsServer, DnsServer.AsString);
  IniFile.WriteString(SectArduino, KeySipKey,    SipKey.AsString   );

  for n := 0 to EE_USER_COUNT - 1 do begin
    Mode := UserMode[n];
    UserSect := SectUser + IntToStr(n);
    IniFile.WriteInteger(SectUsers, SectUser + IntToStr(n + 1), Mode);
    if Mode > 0 then begin
      IniFile.WriteInteger(UserSect, KeyUserId,UserId[n]);
      IniFile.WriteInteger(UserSect, KeyKey,   UserKey[n] );
      IniFile.WriteInteger(UserSect, KeyMode,  UserMode[n]);
      IniFile.WriteString (UserSect, KeyName,  UserName[n]);
    end
    else
      IniFile.EraseSection(UserSect);
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
  FIpAddress.Address := Config.IpAddress;
  FNetMask.Address   := 0;
  FGateway.Address   := 0;
  FDnsServer.Address := 0;

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

  FUseDhcp           := Config.useDHCP;
  FIpAddress.Address := Config.IpAddress;
  FNetMask.Address   := Config.netMask;
  FGateway.Address   := Config.gateway;
  FDnsServer.Address := Config.dnsServer;

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

  Move (SipKey.Key, Config.SipKey, SizeOf (TKey));

  Config.useDHCP     := UseDhcp;
  Config.IpAddress   := FIpAddress.Address;
  Config.netMask     := FNetMask.Address  ;
  Config.gateway     := FGateway.Address  ;
  Config.dnsServer   := FDnsServer.Address;
  Config.MacAddress  := MacAddress;

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
    for i := 0 to EE_USER_COUNT-1 do begin
      UserNames[i] := self.UserName[i];

    end;

    Stream.Write(UserNames, SizeOf(TUserNames));

  finally
    Stream.Free;
  end;
end;

procedure TArduinoAdminData.SetAdminPw(const Value: string);
begin
  FAdminPw := Value;
end;

procedure TArduinoAdminData.SetMacAddress(const Value: TMacAddress);
begin
  FMacAddress := Value;
end;

procedure TArduinoAdminData.GenerateSipKey;
begin
  SipKey.Generate;
end;

function TArduinoAdminData.GenerateUserid: integer;
begin
  repeat
    result := random(9998) + 1;
  until not UserIdExists(result);
end;

procedure TArduinoAdminData.SetMacAddressString(const Value: string);
var
  n : integer;
  ByptePos : integer;
  part : string;
begin
  if length(Value) <> 17 then
    raise Exception.Create('MAC Address format error: xx-xx-xx-xx-xx-xx');

  ByptePos := 1;
  for n := 0 to EE_MAC_KEY_SIZE-1 do begin
    part := '$' + Copy(Value, ByptePos, 2);
    inc (ByptePos, 3);

    FMacAddress[n] := StrToInt(part);
  end;
end;

procedure TArduinoAdminData.GenerateMacAddress;
const
  GEHO_Prefix : array [0..2] of byte = ($90, $A2, $DA);
var
  n: Integer;
begin
  for n := 0 to  5 do begin
    case n of
      0..2 : FMacAddress[n] := GEHO_Prefix[n];
      3..4 : FMacAddress[n] := Random(255);
         5 : FMacAddress[n] := Random(255) and $FE{Individual} or $02{Local};
    end;
  end;
end;

function TArduinoAdminData.GetMacAddressString: string;
var
  n : integer;
begin
  for n := 0 to EE_MAC_KEY_SIZE-1 do
    if n = 0 then
      result := IntToHex(MacAddress[n], 2)
    else
      result := result + '-' + IntToHex(MacAddress[n], 2);
end;

procedure TArduinoAdminData.SetSipKey(const Value: TSipKey);
begin
  FSipKey := Value;
end;

procedure TArduinoAdminData.SetSSID(const Value: string);
begin
  FSSID := Value;
end;

function TArduinoAdminData.GetUserChanged(idx: integer): boolean;
begin
  if idx in [0..9] then
    result := FUserChanged[Idx]
  else
    result := false;
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

function TArduinoAdminData.UserIdExists(Id : integer) : boolean;
var
  i : integer;
begin
  for i := 0 to EE_USER_COUNT-1 do
    if UserId[i] = Id then begin
      result := true;
      exit;
    end;

  result := false;
end;

function TArduinoAdminData.GetUserMode(idx: integer): integer;
begin
  if idx in [0..9] then
    result := FUsers[Idx].userMode
  else
    result := 0;

end;

procedure TArduinoAdminData.SetUseDhcp(const Value: boolean);
begin
  FUseDhcp := Value;
  NetMask.Force := Value;
  Gateway.Force := Value;
  DnsServer.Force := Value;
end;

procedure TArduinoAdminData.SetUserChanged(idx: integer; const Value: boolean);
begin
  if idx in [0..9] then
    FUserChanged[Idx] := Value;
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

function TArduinoAdminData.GetUserLevel(idx: integer): string;
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

{ // Yet unused
    FDeviceNames : array[0..EE_USER_COUNT-1] of string;

function TArduinoAdminData.GetDeviceName(idx: integer): string;
begin
  if idx in [0..9] then
    result := FDeviceNames[idx]
  else
    result := '';
end;

procedure TArduinoAdminData.SetDeviceName(idx: integer; const Value: string);
begin
  if idx <= 9 then
    FDeviceNames[idx] := Value;
end;

}



end.
