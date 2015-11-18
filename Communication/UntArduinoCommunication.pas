unit UntArduinoCommunication;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections,
  IdHTTP, IdGlobal,
  IntfMessageParser,
  CommunicationConst,
  UntCommand, UntSetupCommand,
  UntClientSession;


type

  TArduinoCommunication = class
  private
    HttpClient : TIdHttp;
    FOnReplyReceived : TNotifyEvent;
    function QueryDevice (Cmd : string; Params : TStringList) : string;
    function ExecuteQuery(Cmd: string): string;
    procedure SetupDelay (var RepeatNo : integer);
  protected
    Url           : String;
    MessageParser : IMessageParser;
    KeyWords      : TResultDictionary;
    FSetupCommand : TCommand;
    StatusStrg    : string;
    procedure ParseMessage (Xml : String);
    function SetupSession : TReplyResult;
  public
    constructor Create (Url : string; AMessageParser : IMessageParser; SetupCommand : TCommand);
    destructor Destroy; override;
    procedure Init;
    procedure Quit;
    procedure ExecuteCommand (Cmd : TCommand);
    property  SetupCommand : TCommand read FSetupCommand;
  end;

implementation

{ TGarageCommunication }

constructor TArduinoCommunication.Create (Url : string; AMessageParser : IMessageParser; SetupCommand : TCommand);
begin
  HttpClient := TIdHttp.Create (nil);
  MessageParser := aMessageParser;
  KeyWords := TResultDictionary.create;
  self.Url  := Url;
end;

destructor TArduinoCommunication.Destroy;
begin
  KeyWords.Free;
  HttpClient.Free;
end;

procedure TArduinoCommunication.ExecuteCommand(Cmd: TCommand);
var
  Parameters: String;
  ReplyHtml : string;
  Status    : string;
  Done      : boolean;
  QueryResult : TReplyResult;
  SessionRepeat : integer;
begin
  Done := false;
  SessionRepeat := 0;
  try
    repeat
      if not TClientSession.Instance.HasSession then begin
        SetupDelay(SessionRepeat);
        SetupSession;
      end;
      Parameters := Cmd.SendString;

      ReplyHtml := QueryDevice (Parameters);

      ParseMessage (ReplyHtml);

      Status := KeyWords[CParamResult];

    until Done;
  except
    on E:Exception do begin

    end;
  end;

    if not SameText (Status, CResultOk) then begin
      raise TCommandException.Create(Cmd + '=' + Status);
    end;
  finally
    Parameters.Free;
  end;
end;

function TArduinoCommunication.ExecuteQuery(Cmd: string): string;
begin
  ExecuteCommand(Cmd);
  result := Keywords[CParamReply];
end;


procedure TArduinoCommunication.Init;
var
  Retries : integer;
  Reply : string;
begin
  Retries := 0;
  while (Retries < 4) and (not Session.Initialized) do begin
    try
      if Retries > 0  then
        Sleep (500);
      Reply := ExecuteQuery(CCmdGetSession);
      Session.Init (Reply, HashKey);
    except
      if Retries >= 4 then
        raise;
      Inc (Retries);
    end;
  end;
end;

procedure TArduinoCommunication.Quit;
begin
  ExecuteCommand(CCmdQuitSession);
  Session.Clear;
end;

function TArduinoCommunication.SetupSession: TReplyResult;
begin

end;

procedure TArduinoCommunication.ParseMessage(Xml: String);
var
  Key, Value : string;
begin
  KeyWords.Clear;
  MessageParser.XML := Xml;
  MessageParser.StartScan;
  while MessageParser.FindNextValuePair(Key, Value) do begin
    KeyWords.Add(Key, Value);
  end;
end;

function TArduinoCommunication.QueryDevice(Cmd : string; Params: string): string;
var
  Response : TStringStream;
  Hash     : String;
begin
  Response := TStringStream.Create;
  try
    if Session.Initialized then begin
      Params.Add(CParamSessionId + '=' + Session.SessionId);
      Hash := Session.GetHash(Cmd);
      Params.Add(CParamCmdHash + '=' + Hash);
    end
    else
      Params.Add(CParamUserId + '=' + IntToStr(UserId));

    HttpClient.Post(URL, Params, response);
    Result := Response.DataString;
  finally
    Response.Free;
  end;
end;

end.
