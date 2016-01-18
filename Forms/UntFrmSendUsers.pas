unit UntFrmSendUsers;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.ListBox,
  CommunicationTypes, CommunicationConst, ConfigConst,
  UntCommand, UntCmdConnect,
  UntClientSession,
  UntCmdSetUser,
  UntArduinoAdminData,
  UntArduinoCommunication;

type
  TFrmSendUsers = class(TForm)
    Label1: TLabel;
    BtnCancel: TButton;
    LblUserName: TLabel;
    procedure BtnCancelClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    AdminData: TArduinoAdminData;
    DeviceComm : TArduinoCommunication;
    UserCommunication : TUserCommunication;
    Startup : boolean;
    FConnecting : boolean;
    UserIdx : integer;
    AllUsers : boolean;
    procedure DoCancel;
    procedure Connect;
    property Connecting : boolean read fConnecting;
    procedure Progress (Sender : TObject; UserName : string);
    procedure Finished (Sender : TObject; Success : boolean; ErrorMsg : string);
  public
    function Execute(AdminData : TArduinoAdminData;
                     DeviceComm : TArduinoCommunication;
                     UserIdx : integer;
                     AllUsers : boolean) : boolean;
  end;

var
  FrmSendUsers: TFrmSendUsers;

implementation

{$R *.fmx}

function TFrmSendUsers.Execute(AdminData : TArduinoAdminData;
                        DeviceComm : TArduinoCommunication;
                        UserIdx : integer;
                        AllUsers : boolean): boolean;
begin
  self.AdminData := AdminData;
  self.DeviceComm := DeviceComm;
  self.UserIdx := UserIdx;
  self.AllUsers := AllUsers;

  result := ShowModal = mrOK;
end;

procedure TFrmSendUsers.FormActivate(Sender: TObject);
begin
  if not Startup then
    exit;

  Startup := false;

  Connect;
end;

procedure TFrmSendUsers.FormCreate(Sender: TObject);
begin
  Startup := true;
end;

procedure TFrmSendUsers.Finished(Sender: TObject; Success: boolean; ErrorMsg: string);
begin
  if not Success then
    ShowMessage(ErrorMsg);
  modalResult := mrOK;
end;

procedure TFrmSendUsers.Progress(Sender: TObject; UserName: string);
begin
  LblUserName.Text := UserName;
end;

procedure TFrmSendUsers.BtnCancelClick(Sender: TObject);
begin
  if Connecting then
    DoCancel
  else
    ModalResult := mrCancel;
end;


procedure TFrmSendUsers.Connect();
begin
  if Connecting or not TClientSession.Instance.HasSession then
    exit;

  FConnecting := true;
  UserCommunication := TUserCommunication.create(DeviceComm);

  UserCommunication.Execute(AdminData, UserIdx, AllUsers, Progress, Finished);
end;

procedure TFrmSendUsers.DoCancel;
begin
  DeviceComm.StopAsync;
  try
    UserCommunication.Cancel;
  except
  end;
end;

end.
