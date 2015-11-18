unit UntArduinoCommunication;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Generics.Collections,
  IdHTTP, IdGlobal,
  IntfMessageParser,
  CommunicationConst,
  UntClientSession, UntSipHash;


type

  TArduinoCommunication = class
  private
    HttpClient : TIdHttp;
    FOnStatusChanged: TNotifyEvent;
    function  QueryDevice (Cmd : string; Params : TStringList) : string;
  protected
    Url       : String;
    UserId    : integer;
    MessageParser : IMessageParser;
    KeyWords : TDictionary<String, String>;
    StatusStrg : string;
    Session    : TClientSession;
    HashKey    : TSipKey;
    procedure ParseMessage (Xml : String);
  public
    constructor Create (Url : string; AMessageParser : IMessageParser);
    destructor Destroy; override;
    procedure Init;
    procedure Quit;
    procedure ExecuteCommand (Cmd : string);
    function  ExecuteQuery (Cmd : string) : string;
  end;

implementation

{ TGarageCommunication }

constructor TArduinoCommunication.Create (Url : string; AMessageParser : IMessageParser);
begin
  HttpClient := TIdHttp.Create (nil);
  MessageParser := aMessageParser;
  KeyWords := TDictionary<String, String>.create;
  self.Url  := Url;
  self.Session := TClientSession.Instance;
end;

destructor TArduinoCommunication.Destroy;
begin
  KeyWords.Free;
  HttpClient.Free;
end;

procedure TArduinoCommunication.ExecuteCommand(Cmd: string);
var
  Parameters: TStringList;
  ReplyHtml : string;
  Status    : string;
begin
  Parameters := TStringList.Create;
  try
    Parameters.Add(CParamCommand + '=' + Cmd);

    ReplyHtml := QueryDevice (Cmd, Parameters);

    ParseMessage (ReplyHtml);

    Status := KeyWords[CParamResult];

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

function TArduinoCommunication.QueryDevice(Cmd : string; Params: TStringList): string;
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
