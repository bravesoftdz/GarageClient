unit UntArduinoCommunication;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.SyncObjs,
  System.Generics.Collections,
  IdHTTP, IdGlobal,
  IntfMessageParser,
  IntfCommandHandler,
  CommunicationTypes,
  CommunicationConst,
  UntCommandParameter,
  UntCommand, UntCmdConnect,
  UntSimpleCommand,
  UntClientSession;

type
// Wrapper object to allow the ICommandHandler to be used
// Interface methods cannot be assigned as Method Pointers
  TCommandWrapper = class
  private
    FCommand : TCommand;
    Owner : TObject;
    OnReplied: TRepliedEvent;
    OnError: TErrorEvent;
    Handler : ICommandHandler;
    procedure Init(Command: TCommand; Owner: TObject);
  public
    constructor Create(Command : TCommand; Owner : TObject; OnReplied: TRepliedEvent; OnError: TErrorEvent); overload;
    constructor Create(Command : TCommand; Owner : TObject; Handler : ICommandHandler); overload;
    procedure DoError(Context : string; ErrorMessage : string);
    procedure DoReply(ReplyResult : TReplyResult; var Reply : TResultDictionary);
    property  Command : TCommand read FCommand;
  end;



  TArduinoCommunication = class
  private
    HttpClient  : TIdHttp;
    FOnReplied  : TRepliedEvent;
    FOnError    : TErrorEvent;
    FUserPassword: integer;
    FIsExecuting  : boolean;
    CommandCriticalSection : TCriticalSection;
    function  QueryDevice (Cmd : TCommand) : string;
    function  ExecuteQuery(Cmd : TCommand): TReplyResult;
    procedure ExecuteCommandWrapper(Wrapper: TCommandWrapper);
  protected
    Host          : String;
    MessageParser : IMessageParser;
    FConnectingCommand : TCommand;
    function ParseMessage (Xml : String; Reply : TResultDictionary) : TReplyResult;
  public
    constructor Create (Host : string; AMessageParser : IMessageParser; ConnectingCommand : TCommand);
    destructor Destroy; override;
    procedure Quit;
    function  ConnectDevice(var RepeatNo : integer) : TReplyResult;
    function  ExecuteCommand     (Cmd : TCommand; Reply : TResultDictionary) : TReplyResult;

    procedure ExecuteCommandAsync(Cmd: TCommand; OnReplied: TRepliedEvent; OnError: TErrorEvent); overload;
    procedure ExecuteCommandAsync(Cmd: TCommand; Handler : ICommandHandler); overload;
    function  IsExecutingAsync : boolean;
    procedure StopAsync;

    property  UserPassword      : integer       read FUserPassword write FUserPassword;
    property  ConnectingCommand : TCommand      read FConnectingCommand;
    property  OnReplied         : TRepliedEvent read FOnReplied write FOnReplied;
    property  OnError           : TErrorEvent   read FOnError write FOnError;
  end;

implementation


{ TGarageCommunication }

constructor TArduinoCommunication.Create (Host : string; AMessageParser : IMessageParser; ConnectingCommand : TCommand);
begin
  MessageParser           := aMessageParser;
  self.Host               := Host;
  self.FConnectingCommand := ConnectingCommand;
  CommandCriticalSection  := TCriticalSection.Create;
end;

destructor TArduinoCommunication.Destroy;
begin
  CommandCriticalSection.Free;
end;

function TArduinoCommunication.ExecuteCommand(Cmd: TCommand; Reply : TResultDictionary) : TReplyResult;
var
  ReplyHtml : string;
  Done      : boolean;
  SessionRepeat : integer;
begin
  if not Cmd.IsInitialized then
    raise ECommandException.Create('Command not initialized');

  FIsExecuting := true;
  SessionRepeat := 0;
  try
    try
      repeat
        while not TClientSession.Instance.HasSession and (Cmd <> FConnectingCommand) do begin
          ConnectDevice(SessionRepeat);
        end;

        TClientSession.Instance.PrepareNextMessage;

        ReplyHtml := QueryDevice (Cmd);

        Result := ParseMessage (ReplyHtml, Reply);

        if result = rrNoSession then begin
          TClientSession.Instance.ClearSession;
          Done := false;
        end
        else begin
          Done := true;
        end;

      until Done;
    except
      on E:Exception do begin
        result := rrCommunication;
        Reply.AddOrSetValue(CParamError, E.Message);
      end;
    end;
  finally
    FIsExecuting := false;
  end;
end;

procedure TArduinoCommunication.ExecuteCommandAsync(Cmd: TCommand; OnReplied: TRepliedEvent; OnError: TErrorEvent);
var
  Wrapper : TCommandWrapper;
begin
  Wrapper := TCommandWrapper.Create(Cmd, self, OnReplied, OnError);
  ExecuteCommandWrapper(Wrapper);
end;

procedure TArduinoCommunication.ExecuteCommandAsync(Cmd: TCommand; Handler: ICommandHandler);
var
  Wrapper : TCommandWrapper;
begin
  Wrapper := TCommandWrapper.Create(Cmd, self, Handler);
  ExecuteCommandWrapper(Wrapper);
end;

procedure TArduinoCommunication.ExecuteCommandWrapper(Wrapper : TCommandWrapper);
begin
  TThread.CreateAnonymousThread (
     procedure()
     var
       ReplyResult : TReplyResult;
       Reply       : TResultDictionary;
     begin
       Reply := TResultDictionary.Create;
       try
         CommandCriticalSection.Enter;
         try
           ReplyResult := ExecuteCommand(Wrapper.Command, Reply);
         finally
           CommandCriticalSection.Release;
         end;
         TThread.Synchronize (TThread.CurrentThread,
          procedure ()
          begin
            Wrapper.DoReply(ReplyResult, Reply);
          end
         );
       except
         on E: Exception do
           TThread.Synchronize (TThread.CurrentThread,
            procedure ()
            begin
              Wrapper.DoError('Command Execution', E.Message);
            end
           );
       end;
       Reply.Free;
       Wrapper.Free;
     end
  ).Start;
end;

function TArduinoCommunication.ExecuteQuery(Cmd: TCommand): TReplyResult;
var
  Reply : TResultDictionary;
begin
  Reply := TResultDictionary.Create();
  try
    result := ExecuteCommand(Cmd, Reply);
  finally
    Reply.Free;
  end;
end;

function TArduinoCommunication.IsExecutingAsync: boolean;
begin
  result := FIsExecuting;
end;

procedure TArduinoCommunication.Quit;
var
  Cmd : TSimpleCommand;
begin
  Cmd := TSimpleCommand.Create(CCmdQuitSession, false);
  try
    ExecuteQuery(Cmd);
    TClientSession.Instance.Clear;
  finally
    Cmd.Free;
  end;
end;

procedure TArduinoCommunication.StopAsync;
begin
  if IsExecutingAsync and Assigned(HttpClient) then
    HttpClient.Disconnect;
end;

function TArduinoCommunication.ConnectDevice(var RepeatNo: integer): TReplyResult;
var
  Delay        : integer;
  ConnectReply : TResultDictionary;
  SessionId    : string;
  ConnectMsg   : string;
begin
  if RepeatNo > 0 then begin
    Delay := Random(CMaxConnectDelay-CMinConnectDelay) + CMinConnectDelay;
    Sleep(Delay);
  end;

  ConnectReply := TResultDictionary.Create;
  try
    result := ExecuteCommand(ConnectingCommand, ConnectReply);

    if Result = rrOK then begin
      SessionId := ConnectReply[CParamSessionId];
      if StrToIntDef(SessionId, 0) = 0  then begin
        result := rrNoSession;
        exit;
      end;

      TClientSession.Instance.StartSession(SessionId);
    end;

    inc(RepeatNo);
    if RepeatNo > CMaxConnectRepeats then begin
      if not ConnectReply.TryGetValue(CParamError, ConnectMsg) then
        ConnectMsg := 'Could not connect';
      raise ECommandException.Create('Connecting: ' + ConnectMsg);
    end;
  finally
    ConnectReply.Free;
  end;
end;

function TArduinoCommunication.ParseMessage(Xml: String; Reply : TResultDictionary) : TReplyResult;
begin
  if Reply = nil then
    raise Exception.Create('Internal error reply');

  Reply.Clear;
  MessageParser.XML := Xml;
  MessageParser.Parse(Reply);

  Result := MessageParser.TransferResult;
end;

function TArduinoCommunication.QueryDevice(Cmd : TCommand): string;
var
  Response : TStringStream;
  Url      : String;
begin
  HttpClient := TIdHttp.Create (nil);
  HttpClient.ConnectTimeout := 1000;
  HttpClient.ReadTimeout    := 1000;
  Response  := TStringStream.Create;
  try
    Url := 'http://' + Host + '/' + Cmd.SendString;

    HttpClient.Get(Url, response);

    Result := Response.DataString;
  finally
    FreeAndNil(HttpClient);
    Response.Free;
  end;
end;

{ THandlerWrapper }

procedure TCommandWrapper.Init(Command : TCommand; Owner: TObject);
begin
  if (not Command.IsInitialized) or (Command = nil) then
    raise ECommandException.Create('Command not initialized');

  Self.FCommand  := Command;
  Self.Owner     := Owner;
  Self.OnReplied := nil;
  Self.OnError   := nil;
  Self.Handler   := nil;
end;

constructor TCommandWrapper.Create(Command : TCommand; Owner: TObject; OnReplied: TRepliedEvent; OnError: TErrorEvent);
begin
  Init (Command, Owner);
  Self.OnReplied := OnReplied;
  Self.OnError   := OnError;
end;

constructor TCommandWrapper.Create(Command : TCommand; Owner: TObject; Handler: ICommandHandler);
begin
  Init (Command, Owner);
  Self.Handler   := Handler;
end;

procedure TCommandWrapper.DoError(Context, ErrorMessage: string);
begin
  if Handler <> nil then
    Handler.CmdErrorHandler(Owner, Context, ErrorMessage)
  else if Assigned(OnError) then
    OnError(Owner, Context, ErrorMessage);
end;

procedure TCommandWrapper.DoReply(ReplyResult: TReplyResult; var Reply: TResultDictionary);
begin
  if Handler <> nil then
    Handler.CmdReplyHandler(Owner, ReplyResult, Reply)
  else if Assigned(OnReplied) then
    OnReplied(Owner, ReplyResult, Reply);
end;

end.
