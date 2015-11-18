unit ClientConfig;

interface

uses
  System.IniFiles,
  ConfigConst,
  UntSipHash;

type
  TClientConfig = class
  private
    FRepository: TCustomIniFile;

  public
    constructor Create(IniFile : TCustomIniFile);
    property Repository : TCustomIniFile read FRepository;
    property DeviceIp : cardinal;
    property UserId   : integer;
    property SipKey   : TKey;
  end;

implementation

{ TClientConfig }

constructor TClientConfig.Create(IniFile: TCustomIniFile);
begin
  FRepository := IniFile;
end;

end.

