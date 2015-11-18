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
    constructor Create;
    procedure SetUserPassword(const Value: string);
  public
    class function Instance : TClientSession;
    class procedure Init (SessionId : string; Key : TSipKey);
    class procedure Clear;
    property SessionId    : string read FSessionId;
    property UserId       : string read FUserId;
    property UserPassword : string read FUserPassword write SetUserPassword;
    property Initialized  : boolean read FInitialized;
    property PreviousHash : string read FPreviousHash;

    function GetHash (Command : string) : string;
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

class procedure TClientSession.Init(SessionId: string; Key: TSipKey);
begin
  Instance.FSessionId := SessionId;
  Instance.FKey       := Key;
end;

class procedure TClientSession.Clear;
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

procedure TClientSession.SetUserPassword(const Value: string);
begin
  FUserPassword := Value;
end;

end.
