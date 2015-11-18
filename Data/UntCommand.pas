unit UntCommand;

interface

implementation

uses
  System.SysUtils,
  System.Generics.Collections,
  UntSipHash;

type
  TCommandDict = TDictionary<String, String>;

  TCommand = class
  private
    FMessageIdx: word;
    FSessionId: cardinal;
    FUserId: word;
    FUserKey: word;
    FCommandDictionary: TCommandDict;
    FHashDictionary : TCommandDict;
    FHashData : TData;
    procedure SetMessageIdx(const Value: word);
    procedure SetSessionId(const Value: cardinal);
    procedure SetUserId(const Value: word);
    procedure SetUserKey(const Value: word);
    function GetCommandForSend: string;
    procedure AddHashData(Value: string);
    function GetHashData: TData;
  public
    constructor Create;
    destructor Destroy;

    procedure ParseReply(Reply : String); virtual;
    procedure AddParameter (Key, Value : string; HashOnly : boolean = false); overload;
    procedure AddParameter (Key : string; Value : cardinal; HashOnly : boolean = false); overload;

    procedure RepeatCmd(SessionId : integer);

    property SessionId  : cardinal read FSessionId write SetSessionId;
    property MessageIdx : word read FMessageIdx write SetMessageIdx;
    property UserId     : word read FUserId write SetUserId;
    property UserKey    : word read FUserKey write SetUserKey;

    property CommandForSend : string read GetCommandForSend;
    property HashData       : TData read GetHashData;
    property CommandDictionary : TCommandDict read FCommandDictionary;
    property HashDictionary : TCommandDict read FHashDictionary;

  end;


{ TCommand }

constructor TCommand.Create;
begin
  CommandDictionary := TCommandDict.Create();
  HashDictionary := TCommandDict.Create();
end;

destructor TCommand.Destroy;
begin
  CommandDictionary.Free;
  HashDictionary.Free;
end;

function TCommand.GetCommandForSend: string;
var
  Key : string;
  Value : string;
begin
  result := '';
  for Key in CommandDictionary.Keys do begin
    Value := CommandDictionary.Values[Key];
    if length(result) > 0 then
      result := result + '&';
    result := result + Key + '=' + Value;
  end;
end;

function TCommand.GetHashData: TData;
var
  Key : string;
  Value : string;
begin
  result := '';
  for Key in CommandDictionary.Keys do begin
    Value := CommandDictionary.Values[Key];
    AddHashData(Key);
    AddHashData(Value);
  end;
end;

procedure TCommand.AddHashData(Value: string);
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
  HashDataPos := Length(FHashData);
  SetLength(FHashData, HashDataPos + ValueLen);

  Move(ByteString[CFirstByte], FHashData[HashDataPos], ValueLen);
end;

procedure TCommand.AddParameter(Key: string; Value: cardinal; HashOnly: boolean);
begin
  AddParameter(Key, IntToStr(Value), HashOnly);
end;

procedure TCommand.AddParameter(Key, Value: string; HashOnly: boolean);
begin
  if not HashOnly then
    CommandDictionary.Add(Key, Value);

  AddHashData(Key);
  AddHashData(Value);
end;

procedure TCommand.ParseReply(Reply: String);
begin

end;

procedure TCommand.RepeatCmd(SessionId: integer);
begin
  if self.SessionId <> 0 then begin
    SetSessionId(SessionId);
    SetMessageIdx(1);

    HashDictionary[]

  end;

end;

procedure TCommand.SetMessageIdx(const Value: word);
begin
  FMessageIdx := Value;
end;

procedure TCommand.SetSessionId(const Value: cardinal);
begin
  FSessionId := Value;
end;

procedure TCommand.SetUserId(const Value: word);
begin
  FUserId := Value;
end;

procedure TCommand.SetUserKey(const Value: word);
begin
  FUserKey := Value;
end;

end.

