unit UntClientSession;

interface

uses
  SysUtils,
  IdGlobal,
  UntSipHash;

type
  ESessionInitError = class (Exception) end;

// Keeps track with Session parameters and Session on Arduino

  TClientSession = class
  private
    FSipKey : TSipKey;
    FUserId: integer;
    FSessionId: integer;
    FUserPassword: integer;
    FInitialized : boolean;
    FMessageIdx: integer;
    FHasSession: boolean;
    constructor Create;
    function GetMessageIdx: integer;
    function GetSessionId: integer;
    function GetUserId: integer;
    function GetUserPassword: integer;
  public
    class function Instance : TClientSession;
    procedure Init (UserId : integer; SipKey : TSipKey);
    procedure Clear;
    procedure StartSession(SessionId : string; UserPassword : integer);
    procedure PrepareNextMessage;

    property SipKey       : TSipKey read FSipKey;
    property SessionId    : integer read GetSessionId;
    property MessageIdx   : integer read GetMessageIdx;
    property UserId       : integer read GetUserId;
    property UserPassword : integer read GetUserPassword;
    property Initialized  : boolean read FInitialized;
    property HasSession   : boolean read FHasSession;
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

constructor TClientSession.Create;
begin
  FInitialized := false;
  FHasSession  := false;
end;

function TClientSession.GetMessageIdx: integer;
begin
  if FHasSession then
    result := FMessageIdx
  else
    raise ESessionInitError.Create('Invalid session: Message idx not available');
end;

function TClientSession.GetSessionId: integer;
begin
  if FHasSession then
    result := FSessionId
  else
    raise ESessionInitError.Create('Invalid session: Message idx not available');
end;

function TClientSession.GetUserId: integer;
begin
  if FInitialized then
    result := FUserId
  else
    raise ESessionInitError.Create('Invalid init: User id not available');
end;

function TClientSession.GetUserPassword: integer;
begin
  if FHasSession then
    result := FUserPassword
  else
    raise ESessionInitError.Create('Invalid session: Password not available');
end;

procedure TClientSession.Init(UserId: integer; SipKey: TSipKey);
begin
  FUserId := SessionId;
  FSipKey := SipKey;
end;

procedure TClientSession.Clear;
begin
  FHasSession   := false;
  FSessionId    := 0;
  FMessageIdx   := 0;
  FUserPassword := 0;
end;

procedure TClientSession.PrepareNextMessage;
begin
  if HasSession then
    Inc(FMessageIdx)
  else
    raise ESessionInitError.Create('Invalid session: Cannot prepare next message');
end;

procedure TClientSession.StartSession(SessionId: string; UserPassword : integer);
begin
  FHasSession   := true;
  FUserPassword := UserPassword;
  FSessionId    := FSessionId;
end;

end.
