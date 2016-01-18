unit UntCmdGetStatus;

interface
uses
  System.SysUtils,
  IntfClientConfig,
  CommunicationTypes,
  CommunicationConst,
  UntArduinoCommunication,
  UntSimpleCommunication,
  UntSimpleCommand,
//  ConfigConst,
  UntCommand;

type
  TStatusSuccessEvent   = procedure(Sender : TObject; Status : TGarageDoorStatus) of object;

type
  TStatusCommunication = class(TSimpleCommunication)
  private
  protected
    OnFinish   : TStatusSuccessEvent;
    procedure GotReply(ReplyResult : TReplyResult; var Reply : TResultDictionary); override;
  public
    constructor Create(DeviceComm : TArduinoCommunication);
    destructor Destroy; override;
    procedure Init(Config: IClientConfig; OnError: TErrorEvent; OnFinish: TStatusSuccessEvent);
    procedure Execute;
  end;

implementation

constructor TStatusCommunication.create(DeviceComm: TArduinoCommunication);
begin
  inherited Create(CCmdGetStatus, DeviceComm);
end;

destructor TStatusCommunication.destroy;
begin
  inherited;
end;


procedure TStatusCommunication.Init(Config   : IClientConfig;
                                    OnError  : TErrorEvent;
                                    OnFinish : TStatusSuccessEvent);
begin
  self.Config    := Config;
  self.OnError   := OnError;
  self.OnFinish  := OnFinish;
end;

procedure TStatusCommunication.Execute;
begin
  Assert((Config <> nil) and Assigned(OnError) and Assigned(OnFinish), 'Initialization error');
  Run;
end;

procedure TStatusCommunication.GotReply(ReplyResult: TReplyResult; var Reply: TResultDictionary);
var
  SStatus : string;
  GarageState : TGarageDoorStatus;
  I           : TGarageDoorStatus;
begin
  GarageState := gdsVoid;
  if Reply.TryGetValue(CParamGarageState, SStatus) then begin
    for I := Low(TGarageDoorStatus) to High(TGarageDoorStatus) do begin

      if SameText(CGarageDoorStatusKey[i], SStatus) then begin
        GarageState := I;
        break;
      end;

    end;
  end;
  OnFinish(Self, GarageState);
end;

end.
