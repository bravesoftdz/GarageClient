unit UntCommand;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  UntClientSession,
  UntSipHash,
  UntStringHasher,
  CommunicationTypes,
  CommunicationConst,
  UntCommandParameter;

type
// Wrapper for compiling a command to be sent to arduino

  TCommand = class
  private
    FStringHasher : TStringHasher;
    FCommand: string;
    FCommandDictionary: TCommandDict;
    FIsInitialized: boolean;
    function  GetSendString: string;
    function GetMessageIdx: word;
    function GetSessionId: cardinal;
    function GetUserId: word;
    function GetUserKey: word;
    function GetParamValue (Param : TCommandParameter) : string;
    function GetCommandHash: string;
    procedure FillHashData;
  protected
    procedure AddSessionParams;
    procedure InitUserParams;
    property StringHasher : TStringHasher read FStringHasher;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Init; virtual;

    function AddParameter(Key: string; Value: cardinal; Scope : TParameterScope = psAll): TCommandParameter; overload;
    function AddParameter(Key: string; Value: string;   Scope : TParameterScope = psAll): TCommandParameter; overload;
    function AddVirtualParameter(Key: string; Scope : TParameterScope): TCommandParameter;

    property Command    : string   read FCommand write FCommand;

    property SessionId  : cardinal read GetSessionId;
    property MessageIdx : word     read GetMessageIdx;
    property UserId     : word     read GetUserId;
    property UserKey    : word     read GetUserKey;
    property CommandHash: string   read GetCommandHash;

    property SendString        : string       read GetSendString;
    property CommandDictionary : TCommandDict read FCommandDictionary;
    property IsInitialized     : boolean      read FIsInitialized;

  end;

implementation


{ TCommand }

constructor TCommand.Create;
begin
  FStringHasher      := TStringHasher.Create;
  FCommandDictionary := TCommandDict.Create();
end;

destructor TCommand.Destroy;
begin
  FCommandDictionary.Free;
end;

function TCommand.GetSendString: string;
var
  Key : string;
  Param : TCommandParameter;
  FirstParam : boolean;
begin
  result := Self.Command;
  if length(result) > 0 then
    result := result + '?';
  FirstParam := true;

  for Key in CommandDictionary.Keys do begin
    Param := CommandDictionary[Key];
    if Param.Scope = psHashOnly then
      continue;
    if FirstParam then
      FirstParam := false
    else
      result := result + '&';
    result := result + Key + '=' + GetParamValue(Param);
  end;
end;

procedure TCommand.FillHashData;
var
  Key : string;
  Param : TCommandParameter;
begin
  StringHasher.Clear;

  StringHasher.AddKeyValuePair(CParamCommand, Command);

  for Key in CommandDictionary.Keys do begin
    Param := CommandDictionary[Key];
    if Param.Scope = psCmdOnly then
      continue;

    StringHasher.AddKeyValuePair(Key, GetParamValue(Param));
  end;
end;

function TCommand.GetSessionId: cardinal;
begin
  result := TClientSession.Instance.SessionId;
end;

function TCommand.GetUserId: word;
begin
  result := TClientSession.Instance.UserId;
end;

function TCommand.GetUserKey: word;
begin
  result := TClientSession.Instance.UserPassword;
end;

procedure TCommand.Init;
begin
  FIsInitialized := true;
end;

procedure TCommand.AddSessionParams;
begin
  AddVirtualParameter(CParamSessionId,  psHashOnly);
  AddVirtualParameter(CParamMessageIdx, psHashOnly);
  AddVirtualParameter(CParamUserId,     psHashOnly);
  AddVirtualParameter(CParamPassword,   psHashOnly);
  AddVirtualParameter(CParamCmdHash,    psCmdOnly);
end;

procedure TCommand.InitUserParams;
begin
end;

function TCommand.GetCommandHash: string;
var
  HashKey  : TSipKey;
begin
  FillHashData;
  HashKey := TClientSession.Instance.SipKey;
  result  := StringHasher.GetHash(HashKey);
end;

function TCommand.GetMessageIdx: word;
begin
  result := TClientSession.Instance.MessageIdx;
end;

function TCommand.GetParamValue(Param: TCommandParameter): string;
begin
  if not Param.IsVirtual then
    result := Param.ParamValue
  else if Param.Name = CParamUserId then
    result := IntToStr(UserId)
  else if Param.Name = CParamPassword then
    result := IntToStr(UserKey)
  else if Param.Name = CParamSessionId then
    result := IntToStr(SessionId)
  else if Param.Name = CParamMessageIdx then
    result := IntToStr(MessageIdx)
  else if Param.Name = CParamCmdHash then
    result := CommandHash
end;

function TCommand.AddParameter(Key: string; Value: cardinal; Scope : TParameterScope) : TCommandParameter;
begin
  result := AddParameter(Key, IntToStr(Value), Scope);
end;

function TCommand.AddParameter(Key, Value: string; Scope : TParameterScope) : TCommandParameter;
begin
  if CommandDictionary.ContainsKey(Key) then
    result := CommandDictionary[Key]
  else begin
    result := TCommandParameter.Create();
    CommandDictionary.Add(Key, result);
  end;

  result.Name       := Key;
  result.ParamValue := Value;
  result.Scope      := Scope;
  result.IsVirtual  := false;
end;

function TCommand.AddVirtualParameter(Key: string; Scope : TParameterScope) : TCommandParameter;
begin
  result := AddParameter(Key, '', Scope);
  result.IsVirtual := true;
end;


end.

