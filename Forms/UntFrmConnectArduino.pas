unit UntFrmConnectArduino;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.ListBox,
  CommunicationTypes, CommunicationConst, ConfigConst,
  UntCommand, UntCmdConnect,
  UntClientSession,
  UntArduinoAdminData,
  UntArduinoCommunication;

type
  TFrmConnectArduino = class(TForm)
    CmbUser: TComboBox;
    Label1: TLabel;
    BtnConnect: TButton;
    BtnCancel: TButton;
    procedure BtnConnectClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
  private
    AdminUserId : integer;
    AdminUserKey : integer;
    AdminData: TArduinoAdminData;
    DeviceComm : TArduinoCommunication;
    FConnecting : boolean;
    FConnected : boolean;
    FInputEnabled: boolean;
    FCanceled : boolean;
    function InitUserList: boolean;
    procedure DoCancel;
    procedure Connect;
    procedure SetInputEnabled(const Value: boolean);
    function GetSelectedUserIdx: integer;
    property Connecting : boolean read fConnecting;
    property Connected : boolean read fConnected;
    property Canceled : boolean read fCanceled;
    property InputEnabled : boolean read FInputEnabled write SetInputEnabled;
    property SelectedUserIdx : integer read GetSelectedUserIdx;
  private
    procedure CmdReplyHandler (Sender : TObject; ReplyResult : TReplyResult; var Reply : TResultDictionary);
    procedure CmdErrorHandler (Sender : TObject; Context : string; ErrorMessage : string);
  public
    function Execute(AdminData : TArduinoAdminData;
                     DeviceComm : TArduinoCommunication) : boolean;
  end;

var
  FrmConnectArduino: TFrmConnectArduino;

implementation

{$R *.fmx}

procedure TFrmConnectArduino.BtnCancelClick(Sender: TObject);
begin
  if Connecting then
    DoCancel
  else
    ModalResult := mrCancel;
end;

procedure TFrmConnectArduino.BtnConnectClick(Sender: TObject);
begin
  if Connected then
    ModalResult := mrOk
  else
    Connect;
end;

procedure TFrmConnectArduino.CmdErrorHandler(Sender: TObject; Context, ErrorMessage: string);
begin
  InputEnabled := true;
  FConnecting  := false;
  if not Canceled then
    ShowMessage(Context + ': ' + ErrorMessage);
end;

procedure TFrmConnectArduino.CmdReplyHandler(Sender: TObject; ReplyResult: TReplyResult; var Reply: TResultDictionary);
var
  SessionId : string;
begin
  FConnected := (ReplyResult = rrOK);

  if Connected then
    FConnected := Reply.TryGetValue(CParamSessionId, SessionId);

  if Connected then begin
    TClientSession.Instance.StartSession(SessionId, AdminUserKey);
    ModalResult := mrOk;
  end
  else if ReplyResult = rrOK then begin
    ReplyResult := rrNoSession;
  end;

  if not FConnected then begin
    ShowMessage(CReplyResultText[ReplyResult]);
    ModalResult := mrNone;
  end;
  InputEnabled := true;
  FConnecting  := false;
end;

procedure TFrmConnectArduino.Connect;
var
  Cmd   : TCommand;
begin
  if Connecting then
    exit;

  FCanceled    := false;
  AdminUserId  := AdminData.UserId[SelectedUserIdx];
  AdminUserKey := AdminData.UserKey[SelectedUserIdx];

  TClientSession.Instance.Init(AdminUserId, AdminData.SipKey);

  Cmd := DeviceComm.ConnectingCommand;
  InputEnabled := false;
  FConnecting   := true;

  DeviceComm.ExecuteCommandAsync(Cmd, CmdReplyHandler, CmdErrorHandler);
end;

procedure TFrmConnectArduino.DoCancel;
begin
  FCanceled := true;
  DeviceComm.StopAsync;
end;

function TFrmConnectArduino.Execute(AdminData : TArduinoAdminData;
                        DeviceComm : TArduinoCommunication{;
                        var CommunicationResult: TReplyResult;
                        var ReplyMsg: string}): boolean;
begin
  result := false;
  self.AdminData := AdminData;
  self.DeviceComm := DeviceComm;
  if not InitUserList then begin
    ShowMessage('No admin account defined');
    exit;
  end;
  result := ShowModal = mrOK;
end;

function TFrmConnectArduino.GetSelectedUserIdx: integer;
begin
  result := integer (CmbUser.Items.Objects[CmbUser.ItemIndex]);
end;

function TFrmConnectArduino.InitUserList : boolean;
var
  n : integer;
begin
  CmbUser.BeginUpdate;
  try
    CmbUser.Clear;
    for n := 0 to EE_USER_COUNT-1 do begin
      if AdminData.UserMode[n] <> UM_ADMIN then
        continue;
      CmbUser.Items.AddObject(AdminData.UserName[n], TObject(n));
    end;
  finally
    CmbUser.EndUpdate;
  end;

  result := CmbUser.Items.Count > 0;
  if result then
    CmbUser.ItemIndex := 0;
end;


procedure TFrmConnectArduino.SetInputEnabled(const Value: boolean);
var
  i : integer;
  c : TComponent;
begin
  FInputEnabled := Value;
  for i := 0 to self.ComponentCount - 1 do begin
    c := Components[i];
    if (c is TButton) or (c is TComboBox) then
      (c as TControl).Enabled := Value;
  end;
  BtnCancel.Enabled := true;
end;

end.
