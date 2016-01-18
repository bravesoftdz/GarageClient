unit UntSimpleCommunication;

interface
uses
  CommunicationTypes,
  CommunicationConst,
  IntfClientConfig,
  UntSimpleCommand,
  UntArduinoCommunication,
  UntCommand;

type
  TSimpleCommunication = class
  private
  protected
    OnError    : TErrorEvent;
    Config     : IClientConfig;
    DeviceComm : TArduinoCommunication;
    Command    : TSimpleCommand;
    Canceled   : boolean;
    procedure ReplyHandler(Sender : TObject; ReplyResult : TReplyResult; var Reply : TResultDictionary);
    procedure ErrorHandler(Sender : TObject; Context : string; ErrorMessage : string);
    procedure GotReply(ReplyResult : TReplyResult; var Reply : TResultDictionary); virtual; abstract;
    procedure Run; virtual;
  public
    constructor Create(CommandKey : string; DeviceComm : TArduinoCommunication);
    destructor Destroy; override;
    procedure Cancel;
  end;

implementation

{ TSimpleCommunication }

constructor TSimpleCommunication.create(CommandKey : string; DeviceComm: TArduinoCommunication);
begin
  self.DeviceComm := DeviceComm;
  Command := TSimpleCommand.Create(CommandKey, false);
  Command.Init;
end;

destructor TSimpleCommunication.destroy;
begin
  inherited;
end;

procedure TSimpleCommunication.ErrorHandler(Sender: TObject; Context, ErrorMessage: string);
begin
  if Assigned(OnError) then
    OnError(self, Context, ErrorMessage);
end;

procedure TSimpleCommunication.Run();
begin
  Canceled := false;
  DeviceComm.ExecuteCommandAsync(Command, ReplyHandler, ErrorHandler);
end;

procedure TSimpleCommunication.ReplyHandler(Sender: TObject; ReplyResult: TReplyResult; var Reply: TResultDictionary);
var
  SStatus : string;
  Msg     : string;
  GarageState : TGarageDoorStatus;
  I           : TGarageDoorStatus;
begin
  if ReplyResult = rrOK then begin
    GotReply(ReplyResult, Reply);
  end
  else begin
    if not Reply.TryGetValue(CParamError, Msg) then
      Msg := CReplyResultText[ReplyResult];
    ErrorHandler(Self, 'Status error', Msg);
  end;
end;

procedure TSimpleCommunication.Cancel;
begin
  Canceled := true;
end;


end.
