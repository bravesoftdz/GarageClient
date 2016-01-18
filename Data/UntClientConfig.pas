unit UntClientConfig;

interface

uses
  System.SysUtils, System.IniFiles,
  ConfigConst,
  IntfClientConfig,
  UntSipHash;

type
  /// <summary>
  /// Class to represent the configuration of a client app to access the Arduino server
  /// </summary>
  TClientConfig = class  (TInterfacedObject, IClientConfig)
  private
    // property variables
    FRepository: TCustomIniFile;
    FUserMode: integer;
    FDeviceIp: cardinal;
    FUserId: integer;
    FSipKey: TSipKey;
    FUserName: string;
  private
    // property getters and setters
    procedure SetDeviceIp(const Value: cardinal);
    procedure SetSipKey(const Value: string);
    procedure SetUserId(const Value: integer);
    procedure SetUserMode(const Value: integer);
    procedure SetUserName(const Value: string);
    function GetSipKey: string;
    function GetDeviceIp: cardinal;
    function GetUserId: integer;
    function GetUserMode: integer;
    function GetUserName: string;
  public
    /// <summary>
    /// Constructor - initializing from ini file
    /// </summary>
  	/// <param name="IniFile">The ini file to load from - or to save to</param>
    constructor Create(IniFile : TCustomIniFile);

    /// <summary>
    /// Destroys contained objects
    /// </summary>
    destructor  Destroy; override;

    /// <summary>
    /// Determines, wether the configuration data is valid
    /// </summary>
  	/// <returns>True, if data is valid</returns>
    function IsValid : boolean;

    /// <summary>
    /// Secret SIP key as object <seealso>TSipKey</seealso>
    /// </summary>
    property SipKeyObject : TSipKey read FSipKey;

    /// <summary>
    /// The ini file to load from - or to save to
    /// </summary>
    property Repository : TCustomIniFile read FRepository;
    /// <summary>
    /// IP address of Arduino
    /// </summary>
    property DeviceIp : cardinal read GetDeviceIp write SetDeviceIp;
    /// <summary>
    /// User/Device ID used by this instance
    /// </summary>
    property UserId   : integer  read GetUserId   write SetUserId;
    /// <summary>
    /// User level
    /// </summary>
    property UserMode : integer  read GetUserMode write SetUserMode;
    /// <summary>
    /// Name of user/device for this instance
    /// </summary>
    property UserName : string   read GetUserName write SetUserName;
    /// <summary>
    /// Secret SIP key as string
    /// </summary>
    property SipKey   : string   read GetSipKey write SetSipKey;
  end;

implementation

{ TClientConfig }

constructor TClientConfig.Create(IniFile: TCustomIniFile);
begin
  FRepository := IniFile;
  FSipKey     := TSipKey.create();

  FSipKey.AsString := Repository.ReadString (SectArduino, KeySipKey,   '');
  FDeviceIp        := Repository.ReadInteger(SectArduino, KeyIpAddress, 0);
  FUserId          := Repository.ReadInteger(SectUser,    KeyUserId,    0);
  FUserMode        := Repository.ReadInteger(SectUser,    KeyMode,      0);
  FUserName        := Repository.ReadString (SectUser,    KeyName,     '');
end;


destructor TClientConfig.destroy;
begin
  FSipKey.Free;
end;

function TClientConfig.IsValid: boolean;
begin
  result := not FSipKey.IsEmpty and
            (DeviceIp > 0) and
            (UserId > 0) and
            (UserName <> '');
end;

//---------------------------- Getters / Setters ----------------------------

function TClientConfig.GetDeviceIp: cardinal;
begin
  result := FDeviceIp;
end;

function TClientConfig.GetSipKey: string;
begin
  result := FSipKey.ToString;
end;

function TClientConfig.GetUserId: integer;
begin
    result := FUserId;
end;

function TClientConfig.GetUserMode: integer;
begin
  result := FUserMode;
end;

function TClientConfig.GetUserName: string;
begin
  result := FUserName;
end;

procedure TClientConfig.SetDeviceIp(const Value: cardinal);
begin
  FDeviceIp := Value;
  Repository.WriteInteger(SectArduino, KeyIpAddress, Value);
  Repository.UpdateFile
end;

procedure TClientConfig.SetSipKey(const Value: string);
begin
  FSipKey.AsString := Value;
  Repository.WriteString(SectArduino, KeySipKey, Value);
  Repository.UpdateFile;
end;

procedure TClientConfig.SetUserId(const Value: integer);
begin
  FUserId := Value;
  Repository.WriteInteger(SectUser, KeyUserId, Value);
  Repository.UpdateFile
end;

procedure TClientConfig.SetUserMode(const Value: integer);
begin
  FUserMode := Value;
  Repository.WriteInteger(SectUser, KeyMode, Value);
  Repository.UpdateFile
end;

procedure TClientConfig.SetUserName(const Value: string);
begin
  FUserName := Value;
  Repository.WriteString (SectUser, KeyName, Value);
  Repository.UpdateFile;
end;

end.

