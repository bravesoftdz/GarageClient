unit UntGarageCommunication;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Generics.Collections,
  IdHTTP,
  UntArduinoCommunication,
  IntfGarageCommunication, IntfMessageParser;

type
  TGarageCommunication = class (TInterfacedObject, IGarageCommunication)
  private
    FOnStatusChanged: TNotifyEvent;
    function  GetGarageStatus: TGarageStatus;
    procedure SetGarageStatus(const Value: TGarageStatus);
    function  GetOnStatusChanged: TNotifyEvent;
    procedure SetOnStatusChanged(const Value: TNotifyEvent);
  protected
    StatusStrg : string;
    FGarageStatus : TGarageStatus;
    Arduino : TArduinoCommunication;
  public
    constructor Create (URL : string);
    destructor Destroy; override;
    procedure Open;
    procedure Close;
    procedure LoadStatus;
    property OnStatusChanged : TNotifyEvent read GetOnStatusChanged write SetOnStatusChanged;
    property GarageStatus : TGarageStatus read GetGarageStatus write SetGarageStatus;
  end;

function KeyToStatus (Status : string) : TGarageStatus;

implementation

{ TGarageCommunication }

constructor TGarageCommunication.Create (URL : string);
begin
  Arduino := TArduinoCommunication.Create(Url, nil);
//  MessageParser := aMessageParser;
  URL := 'http://172.16.1.177/command';
end;

destructor TGarageCommunication.Destroy;
begin
  Arduino.Free;
end;

procedure TGarageCommunication.Close;
begin
  Arduino.ExecuteCommand('CLOSE');
end;

procedure TGarageCommunication.Open;
begin
  Arduino.ExecuteCommand('OPEN');
end;


function TGarageCommunication.GetGarageStatus: TGarageStatus;
begin
  result := FGarageStatus;
end;

function TGarageCommunication.GetOnStatusChanged: TNotifyEvent;
begin
  result := FOnStatusChanged;
end;


procedure TGarageCommunication.LoadStatus;
var
  Status : string;
begin
  Status := Arduino.ExecuteQuery('GETSTATUS');

  if not SameText (Status, StatusStrg) then begin
    StatusStrg := Status;
    FGarageStatus := KeyToStatus (Status);
    if Assigned (OnStatusChanged) then
      OnStatusChanged (self);
  end;
end;

procedure TGarageCommunication.SetGarageStatus(const Value: TGarageStatus);
begin

end;

procedure TGarageCommunication.SetOnStatusChanged(const Value: TNotifyEvent);
begin
  FOnStatusChanged := value;
end;

function KeyToStatus (Status : string) : TGarageStatus;
begin
  for result := low(TGarageStatus) to High(TGarageStatus) do
    if SameText (CGarageStatus_Key[result], Status) then
      exit;

  result := low(TGarageStatus);
end;


end.
