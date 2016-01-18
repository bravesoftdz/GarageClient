unit UntGetAssignment;

interface
uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections,
  IdHTTP, IdGlobal,
  IntfMessageParser,
  CommunicationConst,
  CommunicationTypes,
  UntSimpleCommand,
  UntIpAddress,
  UntClientConfig,
  UntClientSession;


type
  TErrorEvent = procedure (Sender: TObject; ReplyResult : TReplyResult; ErrorMessage : string) of object;


  TGetAssignment = class
  private
    HttpClient   : TIdHttp;
    FReplyData   : TResultDictionary;
    FOnReplied   : TNotifyEvent;
    FOnError     : TErrorEvent;
    ErrorText    : string;
    FLastResult: TReplyResult;
  protected
    Host          : String;
    MessageParser : IMessageParser;
    function ParseMessage (Xml : String) : TReplyResult;
    function  IsExecutingAsync : boolean;
    procedure StopAsync;
  public
    constructor Create (AMessageParser : IMessageParser);
    destructor Destroy; override;

    function  ExecuteCommand(Host: string; UserId: integer): TReplyResult;
    procedure ExecuteCommandAsync(Host : string; UserId : integer; OnReplied : TNotifyEvent; OnError : TErrorEvent);

    procedure FillConfig (ClientConfig : TClientConfig);

    property  ReplyData : TResultDictionary read FReplyData;
    property  LastResult: TReplyResult read FLastResult;

    property  OnReplied : TNotifyEvent read FOnReplied write FOnReplied;
    property  OnError   : TErrorEvent read FOnError write FOnError;
  end;

implementation

{ TGetAssignment }

constructor TGetAssignment.Create(AMessageParser: IMessageParser);
begin
  FReplyData  := TResultDictionary.Create;
  HttpClient  := TIdHttp.Create (nil);

  Self.MessageParser := AMessageParser;
end;

destructor TGetAssignment.Destroy;
begin
  HttpClient.Free;
  FReplyData.Free;
end;

function TGetAssignment.ExecuteCommand(Host: string; UserId: integer): TReplyResult;
var
  ReplyHtml : string;
  Url      : String;
begin
  try
    Url := 'http://' + Host + ':' + IntToStr(CAssignPort) + '/' + CDocAssign + '?' + CNodeUserId + '=' + IntToStr(UserId);
    ReplyHtml := HttpClient.Get(Url);

    Result := ParseMessage (ReplyHtml);

  except
    on E:Exception do begin
      ErrorText := e.Message;
      result := rrUnknown;
    end;
  end;
end;

procedure TGetAssignment.ExecuteCommandAsync(Host : string; UserId : integer; OnReplied : TNotifyEvent; OnError : TErrorEvent);
begin
  FLastResult := rrUnknown;
  ErrorText   := '';

  TThread.CreateAnonymousThread (
     procedure()
     begin
       try
         FLastResult := ExecuteCommand(Host, UserId);
         TThread.Synchronize (TThread.CurrentThread,
           procedure ()
           begin
             if LastResult = rrOK then begin
               if Assigned(OnReplied) then
                 OnReplied(self);
             end
             else begin
               if Assigned(OnError) then
                 OnError(self, LastResult, ErrorText);
             end;
           end
         );
       except
         on E: Exception do
           TThread.Synchronize (TThread.CurrentThread,
            procedure ()
            begin
              if Assigned(OnError) then
                OnError(self, LastResult, MessageParser.GetError);
            end
           );
       end;
     end
  ).Start;

end;

procedure TGetAssignment.FillConfig(ClientConfig : TClientConfig);
var
  IpAddress : TIpAddress;
begin
  IpAddress := TIpAddress.Create;
  try
    IpAddress.Force        := false;
    IpAddress.AsString     := ReplyData[CNodeIpAddress];
    ClientConfig.DeviceIp  := IpAddress.Address;
  finally
    IpAddress.Free;
  end;

  ClientConfig.UserId   := StrToIntDef(ReplyData[CNodeUserId],   0);
  ClientConfig.UserMode := StrToIntDef(ReplyData[CNodeUserMode], 0);
  ClientConfig.UserName :=             ReplyData[CNodeUserName];
  ClientConfig.SipKey   :=             ReplyData[CNodeSipKey];
end;

function TGetAssignment.IsExecutingAsync: boolean;
begin
  raise Exception.Create('Not Implemented');
end;

function TGetAssignment.ParseMessage(Xml: String): TReplyResult;
begin
  if ReplyData = nil then
    raise Exception.Create('Internal error ReplyData');
  if MessageParser = nil then
    raise Exception.Create('Internal error parser');

  ReplyData.Clear;
  MessageParser.XML := Xml;
  MessageParser.Parse(ReplyData);

  Result := MessageParser.TransferResult;
  ErrorText := MessageParser.GetError;
end;

procedure TGetAssignment.StopAsync;
begin

end;

end.
