unit UntAdmin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  System.Rtti, FMX.Grid, FMX.Layouts, FMX.Edit, FMX.TabControl,
  system.StrUtils,
  UntSipHash,
  UntArduinoAdminData;

type
  TFrmMainAdmin = class(TForm)
    DlgSave: TSaveDialog;
    DlgOpen: TOpenDialog;
    BtnSaveToSD: TButton;
    BtnLoadFromSD: TButton;
    BtnGenerateSipKey: TButton;
    EdtSipKey: TEdit;
    Label3: TLabel;
    EdtWlanKey: TEdit;
    Label5: TLabel;
    Label4: TLabel;
    Label2: TLabel;
    EdtIpAddress: TEdit;
    Connect: TButton;
    EdtSSID: TEdit;
    Panel2: TPanel;
    Label9: TLabel;
    EdtName: TEdit;
    Label10: TLabel;
    Label11: TLabel;
    GrdUsers: TGrid;
    ClmNo: TColumn;
    ClmName: TColumn;
    ClmState: TColumn;
    EdtPassword: TNumberBox;
    EdtId: TNumberBox;
    Label1: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Panel1: TGroupBox;
    RdbUnused: TRadioButton;
    RdbUser: TRadioButton;
    RdbAdmin: TRadioButton;
    Panel3: TGroupBox;
    RdbFixedIp: TRadioButton;
    RdbAutomatic: TRadioButton;
    EdtNetMask: TEdit;
    EdtGateway: TEdit;
    EdtDnsServer: TEdit;
    procedure BtnSaveToSDClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnGenerateSipKeyClick(Sender: TObject);
    procedure BtnLoadFromSDClick(Sender: TObject);
    procedure GrdUsersGetValue(Sender: TObject; const Col, Row: Integer;
      var Value: TValue);
    procedure GrdUsersSelChanged(Sender: TObject);
    procedure EdtNameChange(Sender: TObject);
    procedure EdtPasswordChange(Sender: TObject);
    procedure EdtIdChange(Sender: TObject);
    procedure RdbUnusedClick(Sender: TObject);
    procedure RdbAutomaticClick(Sender: TObject);
  private
    CurrentUserRow : integer;
    AdminData : TArduinoAdminData;{ Private declarations }
    function ExtractIP (IpText : string; Force : boolean = true) : Cardinal;
    function IpToText(Ip: Cardinal): string;
    procedure UpdateGridRow(Row : integer);
  public
    { Public declarations }
  end;

var
  FrmMainAdmin: TFrmMainAdmin;

implementation

{$R *.fmx}

procedure TFrmMainAdmin.BtnGenerateSipKeyClick(Sender: TObject);
begin
  AdminData.SipKey.Generate;
  EdtSipKey.Text := AdminData.SipKey.ToString;
end;

procedure TFrmMainAdmin.BtnLoadFromSDClick(Sender: TObject);
var
  FileName : string;
begin
    if DlgOpen.Execute then begin
      FileName := DlgOpen.FileName;
      AdminData.LoadFromFile(FileName);

//      EdtAdminPassword.Text := AdminData.AdminPw ;
      EdtWlanKey.Text       := AdminData.WLanKey ;
      EdtSSID.Text          := AdminData.SSID;
      EdtIpAddress.Text     := IpToText(AdminData.IpAddress);
      EdtNetMask.Text       := IpToText(AdminData.NetMask  );
      EdtGateway.Text       := IpToText(AdminData.Gateway  );
      EdtDnsServer.Text     := IpToText(AdminData.DnsServer);
      EdtSipKey.Text        := AdminData.SipKey.ToString;

      if AdminData.UseDhcp then
        RdbAutomatic.IsChecked := true
      else
        RdbFixedIp.IsChecked := true;

      UpdateGridRow(CurrentUserRow);
      GrdUsersSelChanged(GrdUsers);
    end;
end;

procedure TFrmMainAdmin.BtnSaveToSDClick(Sender: TObject);
var
  FileName : string;
begin
  try
//    AdminData.AdminPw   := EdtAdminPassword.Text;
    AdminData.WLanKey   := EdtWlanKey.Text;
    AdminData.SSID      := EdtSSID.Text;
    AdminData.UseDhcp   := RdbAutomatic.IsChecked;
    AdminData.IpAddress := ExtractIP (EdtIpAddress.Text);
    AdminData.NetMask   := ExtractIP (EdtNetMask.Text,   not AdminData.UseDhcp);
    AdminData.Gateway   := ExtractIP (EdtGateway.Text,   not AdminData.UseDhcp);
    AdminData.DnsServer := ExtractIP (EdtDnsServer.Text, not AdminData.UseDhcp);
    AdminData.SipKey.ToString := EdtSipKey.Text;

    if DlgSave.Execute then begin
      FileName := DlgSave.FileName;
      AdminData.SaveToFile(FileName);
    end;

  except
    on E:Exception do
      ShowMessage(E.Message);
  end;
end;

function TFrmMainAdmin.ExtractIP(IpText: string; Force : boolean = true): Cardinal;
var
  IP : array[0..3] of byte;
  n  : integer;
  dotpos : integer;
  lastPos : integer;
  part : string;
begin
  try
    lastPos := 1;
    for n := 0 to 3 do begin
       if n < 3 then
         dotPos := system.strUtils.posEx('.', IpText, lastPos)
       else
         dotPos := length(IpText)+1;

       if dotpos = 0 then
         raise Exception.Create('Illegal IP address format');

       part := System.SysUtils.Trim(copy(IpText, lastPos, dotPos - lastPos));
       IP[3-n] := System.SysUtils.StrToIntDef(part, -1);
       if IP[3-n] < 0 then
         raise Exception.Create('Illegal IP address format');
       lastPos := dotpos+1;
    end;
    result := cardinal(IP);
  except
    on E:Exception do begin
      if Force then
        raise
      else
        result := 0;
    end;

  end;
end;

function TFrmMainAdmin.IpToText (Ip : Cardinal) : string;
var
  IpBytes : array[0..3] of byte absolute IP;
  n: Integer;
begin
  result := '';
  for n := 3 downto 0 do begin
    result := result + IntToStr(IpBytes[n]);
    if n > 0 then
       result := result + '.';
  end;

end;

procedure TFrmMainAdmin.GrdUsersGetValue(Sender: TObject; const Col, Row: Integer; var Value: TValue);
begin
  case Col of
    0: Value := row+1;
    1: Value := AdminData.UserName[row];
    2: Value := AdminData.UserState[row];
  end;
end;

procedure TFrmMainAdmin.GrdUsersSelChanged(Sender: TObject);
begin
  CurrentUserRow := GrdUsers.Selected;

  if not (CurrentUserRow in [0..9]) then
    exit;

  EdtName.Text := AdminData.UserName[CurrentUserRow];
  EdtPassword.Value := AdminData.Users[CurrentUserRow].userKey;
  EdtId.Value := AdminData.Users[CurrentUserRow].userId;

  case AdminData.Users[CurrentUserRow].userMode of
    0: RdbUnused.IsChecked := true;
    1: RdbUser.IsChecked := true;
    2: RdbAdmin.IsChecked := true;
  end;
end;

procedure TFrmMainAdmin.FormCreate(Sender: TObject);
begin
  AdminData := TArduinoAdminData.Create;
end;

procedure TFrmMainAdmin.FormDestroy(Sender: TObject);
begin
  AdminData.Free;
end;

procedure TFrmMainAdmin.EdtIdChange(Sender: TObject);
var
  Value : integer;
begin
  if not (CurrentUserRow in [0..9]) then
    exit;

  Value := Round (TNumberBox(Sender).Value);
  AdminData.UserId[CurrentUserRow] := Value;
  UpdateGridRow(CurrentUserRow);
end;

procedure TFrmMainAdmin.EdtNameChange(Sender: TObject);
begin
  if not (CurrentUserRow in [0..9]) then
    exit;

  AdminData.UserName[CurrentUserRow] := EdtName.Text;
  UpdateGridRow(CurrentUserRow);
end;

procedure TFrmMainAdmin.EdtPasswordChange(Sender: TObject);
var
  Value : integer;
begin
  if not (CurrentUserRow in [0..9]) then
    exit;

  Value := Round (TNumberBox(Sender).Value);
  AdminData.UserKey[CurrentUserRow] := Value;
  UpdateGridRow(CurrentUserRow);
end;

procedure TFrmMainAdmin.RdbAutomaticClick(Sender: TObject);
begin
  EdtNetMask.Enabled   := not RdbAutomatic.IsChecked;
  EdtGateway.Enabled   := not RdbAutomatic.IsChecked;
  EdtDnsServer.Enabled := not RdbAutomatic.IsChecked;
end;

procedure TFrmMainAdmin.RdbUnusedClick(Sender: TObject);
begin
  if not (CurrentUserRow in [0..9]) then
    exit;

  AdminData.UserMode[CurrentUserRow] := TCheckBox(Sender).Tag;
  UpdateGridRow(CurrentUserRow);
end;



procedure TFrmMainAdmin.UpdateGridRow(Row: integer);
begin
  GrdUsers.RealignContent;
end;

end.
