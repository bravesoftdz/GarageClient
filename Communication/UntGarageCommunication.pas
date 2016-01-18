unit UntGarageCommunication;

interface
uses
  System.SysUtils, System.Classes,
  IntfClientConfig,
  CommunicationTypes,
  CommunicationConst,
  UntArduinoCommunication,
  UntSimpleCommunication,
  UntSimpleCommand,
//  ConfigConst,
  UntCommand;

type
  TGarageCommunication = class(TSimpleCommunication)
  private
  protected
    OnFinish   : TNotifyEvent;
    procedure GotReply(ReplyResult : TReplyResult; var Reply : TResultDictionary); override;
  public
    constructor Create(DeviceComm : TArduinoCommunication);
    destructor Destroy; override;
    procedure Init(Config: IClientConfig; OnError: TErrorEvent; OnFinish: TNotifyEvent);
    procedure Execute;
    procedure Open;
    procedure Close;
  end;

implementation

constructor TGarageCommunication.create(DeviceComm: TArduinoCommunication);
begin
  inherited Create(CCmdGetStatus, DeviceComm);
end;

destructor TGarageCommunication.destroy;
begin
  inherited;
end;


procedure TGarageCommunication.Init(Config   : IClientConfig;
                                    OnError  : TErrorEvent;
                                    OnFinish : TNotifyEvent);
begin
  self.Config    := Config;
  self.OnError   := OnError;
  self.OnFinish  := OnFinish;
end;

procedure TGarageCommunication.Open;
begin
  if DeviceComm.IsExecutingAsync then
    exit;

  Command.Command := CCmdOpen;
  Execute;
end;

procedure TGarageCommunication.Close;
begin

  if DeviceComm.IsExecutingAsync then
    exit;

  Command.Command := CCmdClose;
  Execute;
end;

procedure TGarageCommunication.Execute;
begin
  Assert((Config <> nil) and Assigned(OnError) and Assigned(OnFinish), 'Initialization error');
  Run;
end;

procedure TGarageCommunication.GotReply(ReplyResult: TReplyResult; var Reply: TResultDictionary);
var
  SStatus : string;
  GarageState : TGarageDoorStatus;
  I           : TGarageDoorStatus;
begin
  OnFinish(Self);
end;

end.
