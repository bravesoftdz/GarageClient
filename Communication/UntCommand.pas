unit UntCommand;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  UntSipHash,
  UntClientSession,
  CommunicationConst;

type
  TCommandParameter = class
  private
    FName     : string;
    FScope    : TParameterScope;
    FValue    : string;
    FIsVirtual: boolean;
  public
    constructor Create;
    property Name       : string  read FName      write FName     ;
    property ParamValue : string  read FValue     write FValue    ;
    property IsVirtual  : boolean read FIsVirtual write FIsVirtual;
    property Scope      : TParameterScope  read FScope  write FScope ;
  end;


  TCommandDict = TDictionary<String, TCommandParameter>;

// Wrapper for compiling a command to be sent to arduino

  TCommand = class
  private
    FCommandDictionary: TCommandDict;
    function  GetSendString: string;
    procedure AddHashData(var HashData : TData; Value: string);
    function GetHashData: TData;
    function GetMessageIdx: word;
    function GetSessionId: cardinal;
    function GetUserId: word;
    function GetUserKey: word;
    function GetParamValue (Param : TCommandParameter) : string;
    function GetCommandHash: string;
  protected
    property HashData          : TData        read GetHashData;

    procedure InitSessionParams;
    procedure InitUserParams;
  public
    constructor Create;
    destructor Destroy;

    procedure Init; virtual;

    function AddParameter(Key: string; Value: cardinal; Scope : TParameterScope = psAll): TCommandParameter; overload;
    function AddParameter(Key: string; Value: string;   Scope : TParameterScope = psAll): TCommandParameter; overload;
    function AddVirtualParameter(Key: string; Scope : TParameterScope): TCommandParameter;

    property SessionId  : cardinal read GetSessionId;
    property MessageIdx : word     read GetMessageIdx;
    property UserId     : word     read GetUserId;
    property UserKey    : word     read GetUserKey;
    property CommandHash: string   read GetCommandHash;

    property SendString        : string       read GetSendString;
    property CommandDictionary : TCommandDict read FCommandDictionary;

  end;

implementation


{ TCommand }

constructor TCommand.Create;
begin
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
begin
  result := '';
  for Key in CommandDictionary.Keys do begin
    Param := CommandDictionary[Key];
    if Param.Scope = psHashOnly then
      continue;
    if length(result) > 0 then
      result := result + '&';
    result := result + Key + '=' + Param.ParamValue;
  end;
end;

function TCommand.GetHashData: TData;
var
  Key : string;
  Param : TCommandParameter;
  HashData : TData;
begin
  SetLength(HashData, 0);
  for Key in CommandDictionary.Keys do begin
    Param := CommandDictionary[Key];
    if Param.Scope = psCmdOnly then
      continue;

    AddHashData(HashData, Key);
    AddHashData(HashData, Param.ParamValue);
  end;
  result := HashData;
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

end;

procedure TCommand.InitSessionParams;
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
  Hash : uint64;
  HashData : TData;
  HashKey  : TSipKey;
begin
  HashKey  := TClientSession.Instance.SipKey;
  HashData := GetHashData;

  Hash := TSipHash.Digest(HashKey, HashData);

  result := IntToStr(Hash);
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

procedure TCommand.AddHashData(var HashData : TData; Value: string);
var
  ByteString : AnsiString;
  HashDataPos : integer;
  ValueLen    : integer;
const
  {$IFDEF ANDROID}
  CFirstByte = 0;
  {$ELSE}
  CFirstByte = 1;
  {$ENDIF ANDROID}

begin
  ByteString := Value;

  ValueLen    := Length(ByteString);
  HashDataPos := Length(HashData);
  SetLength(HashData, HashDataPos + ValueLen);

  Move(ByteString[CFirstByte], HashData[HashDataPos], ValueLen);
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

{ TCommandParameter }

constructor TCommandParameter.Create;
begin

end;

end.

