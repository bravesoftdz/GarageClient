unit UntArduinoAdminData;

interface
uses
  UntSipHash;

type
  TArduinoAdminData = class
  private
    FWLanKey: string;
    FSipKey: TSipKey;
    FIpAddress: string;
    FAdminPw: string;
    FSSID: string;
    procedure SetAdminPw(const Value: string);
    procedure SetIpAddress(const Value: string);
    procedure SetSipKey(const Value: TSipKey);
    procedure SetSSID(const Value: string);
    procedure SetWLanKey(const Value: string);
  public
    constructor Create;
    procedure SaveToFile (FileName : string);
    procedure LoadFromFile (FileName : string);
    procedure CreateSipKey;

    property AdminPw   : string read FAdminPw write SetAdminPw;
    property WLanKey   : string read FWLanKey write SetWLanKey;
    property SSID      : string read FSSID write SetSSID;
    property IpAddress : string read FIpAddress write SetIpAddress;
    property SipKey    : TSipKey read FSipKey write SetSipKey;
  end;

implementation

{ TArduinoAdminData }

constructor TArduinoAdminData.Create;
begin

end;

procedure TArduinoAdminData.CreateSipKey;
begin

end;

procedure TArduinoAdminData.LoadFromFile(FileName: string);
begin

end;

procedure TArduinoAdminData.SaveToFile(FileName: string);
begin

end;

procedure TArduinoAdminData.SetAdminPw(const Value: string);
begin
  FAdminPw := Value;
end;

procedure TArduinoAdminData.SetIpAddress(const Value: string);
begin
  FIpAddress := Value;
end;

procedure TArduinoAdminData.SetSipKey(const Value: TSipKey);
begin
  FSipKey := Value;
end;

procedure TArduinoAdminData.SetSSID(const Value: string);
begin
  FSSID := Value;
end;

procedure TArduinoAdminData.SetWLanKey(const Value: string);
begin
  FWLanKey := Value;
end;

end.
