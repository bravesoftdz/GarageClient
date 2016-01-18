unit UntUserDlg;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit,
  UntArduinoAdminData;

type
  TDlgUser = class(TForm)
    Panel2: TPanel;
    Label9: TLabel;
    EdtName: TEdit;
    Label10: TLabel;
    Label11: TLabel;
    EdtPassword: TNumberBox;
    EdtId: TNumberBox;
    Panel1: TGroupBox;
    RdbUnused: TRadioButton;
    RdbUser: TRadioButton;
    RdbAdmin: TRadioButton;
    BtnCancel: TButton;
    BtnOK: TButton;
    procedure RdbAdminClick(Sender: TObject);
  private
    UserMode : integer;
    procedure FillData(User: TUserConfig; Name: string);
    procedure SaveData(var User: TUserConfig; var Name: string);
  public
    function Execute(var User : TUserConfig; var Name : string) : boolean;
  end;

var
  DlgUser: TDlgUser;

implementation

{$R *.fmx}

function TDlgUser.Execute(var User: TUserConfig; var Name: string) : boolean;
begin
  FillData(User, Name);
  result := self.ShowModal = mrOK;
  if result then begin
    SaveData(User, Name);
  end;
end;

procedure TDlgUser.FillData(User : TUserConfig; Name : string);

begin
  EdtName.Text := Name;
  EdtPassword.Value := User.userKey;
  EdtId.Value := User.userId;

  case User.userMode of
    0: RdbUnused.IsChecked := true;
    1: RdbUser.IsChecked := true;
    2: RdbAdmin.IsChecked := true;
  end;
  UserMode := User.userMode;
end;


procedure TDlgUser.RdbAdminClick(Sender: TObject);
begin
  UserMode := TRadioButton(Sender).Tag;
end;

procedure TDlgUser.SaveData(var User: TUserConfig; var Name: string);
begin
  Name          := EdtName.Text;
  User.userKey  := Round(EdtPassword.Value);
  User.userMode := UserMode;
end;

end.
