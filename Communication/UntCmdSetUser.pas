unit UntCmdSetUser;

interface
uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  IntfCommandHandler,
  UntArduinoCommunication,
  UntArduinoAdminData,
  Untcommand,
  CommunicationTypes,
  CommunicationConst,
  ConfigConst;

type
  TUserProgressHandler = procedure(Sender : TObject; UserName : string) of object;
  TUserFinishHandler   = procedure(Sender : TObject; Success : boolean; ErrorMsg : string) of object;


  TUserCommunication = class
  private
    OnProgress : TUserProgressHandler;
    OnFinish   : TUserFinishHandler;
    AdminData  : TArduinoAdminData;
    DeviceComm : TArduinoCommunication;
    Canceled   : boolean;
    procedure Run(UserIdx: integer; AllUsers: boolean);
  public
    constructor Create(DeviceComm : TArduinoCommunication);
    destructor Destroy; override;
    procedure Cancel;
    procedure Execute(AdminData : TArduinoAdminData;
                      UserIdx : integer;
                      AllUsers : boolean;
                      OnProgress : TUserProgressHandler;
                      OnFinish   : TUserFinishHandler);

  end;

  TCmdSetUser = class(TCommand)
  protected
  public
    constructor Create();
    destructor Destroy; override;
    procedure Init; override;
    procedure InitUserFields(UserIdx : integer; User : TUserConfig);
  end;


implementation

{ TUserCommunication }

procedure TUserCommunication.Cancel;
begin
  Canceled := true;
end;

constructor TUserCommunication.create(DeviceComm: TArduinoCommunication);
begin
  self.DeviceComm := DeviceComm;
end;

destructor TUserCommunication.destroy;
begin
  inherited;
end;

procedure TUserCommunication.Execute(AdminData: TArduinoAdminData;
  UserIdx: integer; AllUsers: boolean; OnProgress: TUserProgressHandler;
  OnFinish: TUserFinishHandler);
begin
  self.AdminData  := AdminData;
  self.OnProgress := OnProgress;
  self.OnFinish   := OnFinish;

  Assert((AdminData <> nil) and Assigned(OnProgress) and Assigned(OnFinish), 'Initialization error');

  Canceled := false;

  TThread.CreateAnonymousThread (
     procedure()
     begin
       Run(UserIdx, AllUsers);
     end
    ).start;
end;

procedure TUserCommunication.Run(UserIdx: integer; AllUsers: boolean);
var
  First, Last : integer;
  ReplyResult : TReplyResult;
  Reply       : TResultDictionary;
  Command     : TCmdSetUser;
  I           : Integer;
  Success     : boolean;
  ErrorMsg    : string;
begin
  Reply   := TResultDictionary.Create;
  Command := TCmdSetUser.Create;
  Command.Init;

  ReplyResult := rrUnknown;
  Success     := true;
  try
    if AllUsers then begin
      First := 0;
      Last  := EE_USER_COUNT-1;
    end
    else begin
      First := UserIdx;
      Last  := UserIdx;
    end;

    for I := first to last do begin
      if canceled then
        exit;

      TThread.Synchronize (TThread.CurrentThread,
       procedure ()
       begin
         OnProgress(self, AdminData.UserName[i]);
       end
      );
      try

        Command.InitUserFields(i, AdminData.Users[i]);

        ReplyResult := DeviceComm.ExecuteCommand(Command, Reply);

      except
        on E: Exception do begin
          Success := false;
          ErrorMsg := E.Message;
          exit;
        end;
      end;
      if ReplyResult <> rrOK then begin
        Success := false;
        ErrorMsg := CReplyResultText[ReplyResult];
        exit;
      end;
    end;
  finally
    TThread.Synchronize (TThread.CurrentThread,
     procedure ()
     begin
       OnFinish(self, Success, ErrorMsg);
     end
    );
    Reply.Free;
  end;
end;


{ TCmdSetUser }

constructor TCmdSetUser.Create;
begin
  inherited Create;
  Command := CCmdUser;
end;

destructor TCmdSetUser.destroy;
begin
  inherited destroy;
end;

procedure TCmdSetUser.Init;
begin
  inherited Init;
end;

procedure TCmdSetUser.InitUserFields(UserIdx : integer; User : TUserConfig);
begin
  AddParameter(CParamUUserIdx,  IntToStr(UserIdx      ), psAll);
  AddParameter(CParamUUserId,   IntToStr(User.UserId  ), psAll);
  AddParameter(CParamUUserKey,  IntToStr(User.UserKey ), psAll);
  AddParameter(CParamUUserMode, IntToStr(User.UserMode), psAll);
  AddSessionParams;
end;

end.
