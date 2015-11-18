unit UntClientSession;

interface

uses
  SysUtils,
  IdGlobal,
  UntSipHash;

type
  TClientSession = class
  private
    FKey : TSipKey;
    FUserId: string;
    FSessionId: string;
    FUserPassword: string;
    FInitialized : boolean;
    FPreviousHash: string;
    FMessageIdx: integer;
    constructor Create;
    procedure SetUserPassword(const Value: string);
    function TranslateString(Input: string): string;
    procedure Clear;
  public
    class function Instance : TClientSession;
    procedure Init (UserId : string; Key : TSipKey);
    procedure StartSession(SessionId : string);
    procedure StartMessage;
    procedure HashParameter(Key, Value : string);
    function  GetHash : string;

    property SessionId    : string read FSessionId;
    property MessageIdx   : integer read FMessageIdx;
    property UserId       : string read FUserId;
    property UserPassword : string read FUserPassword write SetUserPassword;
    property Initialized  : boolean read FInitialized;
    property PreviousHash : string read FPreviousHash;
  end;

implementation

{ TClientSession }

var
  FInstance : TClientSession = nil;

class function TClientSession.Instance: TClientSession;
begin
  if FInstance = nil then
    FInstance := TClientSession.Create;

  result := FInstance;
end;

procedure TClientSession.Init(UserId: string; UserKey: string; Key: TSipKey);
begin
  Instance.FSessionId := SessionId;
  Instance.FKey       := Key;
end;

procedure TClientSession.Clear;
begin
  Instance.FInitialized := false;
  Instance.FSessionId   := '';
end;

constructor TClientSession.Create;
begin
  FInitialized := false;
end;

function TClientSession.GetHash(Command: string): string;
var
  HashedString : string;
  HashedBytes  : TData;
  Hash         : UInt64;
begin
  if not Initialized then
    raise Exception.Create('Not initialized');

  HashedString := SessionId + PreviousHash + UserId + UserPassword + Command;
  HashedBytes  := IdGlobal.ToBytes (HashedString, Length(HashedString));
  Hash         := TSipHash.digest(FKey, HashedBytes);

  result       := IntToHex (Hash, 16);
  FPreviousHash:= result;
end;

procedure TClientSession.HashParameter(Key, Value: string);
begin

end;

function TClientSession.TranslateString (Input : string) : string;
var
  ByteCount: Longint;
  Bytes: TBytes;
begin
  ByteCount := length(Input);
  if ByteCount = 0 then
  begin
    Result := '';
    exit;
  end;

  SetLength(Bytes, ByteCount);
//  FStream.Read(Pointer(Bytes)^, ByteCount);
  Result := TEncoding.UTF8.GetString(Bytes);
end;

procedure TClientSession.SetUserPassword(const Value: string);
begin
  FUserPassword := Value;
end;

end.
