unit UntAdmin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  System.Rtti, FMX.Grid, FMX.Layouts, FMX.Edit, FMX.TabControl,
  system.StrUtils, system.IniFiles, System.IOUtils,
  IntfCommandHandler,
  CommunicationTypes,
  CommunicationConst,
  ConfigConst,
  UntFrmConnectArduino,
  UntFrmSendUsers,
  UntCmdConnect,
  UntCommand,
  UntCommunicationFactory,
  UntClientSession,
  UntArduinoCommunication,
  UntSipHash,
  UntStringHasher,
  UntArduinoAdminData,
  UntUserDlg,
  UntAssignDevice;

type
  /// <summary>
  /// Main form for Garage opener admin tool
  /// </summary>
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
    Label1: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Panel3: TGroupBox;
    RdbFixedIp: TRadioButton;
    RdbAutomatic: TRadioButton;
    EdtNetMask: TEdit;
    EdtGateway: TEdit;
    EdtDnsServer: TEdit;
    Label12: TLabel;
    EdtMacAddress: TEdit;
    BtnGenerateMac: TButton;
    LblConnectState: TLabel;
    GroupBox1: TGroupBox;
    GrdUsers: TGrid;
    ClmNo: TColumn;
    ClmName: TColumn;
    ClmState: TColumn;
    BtnEditUser: TButton;
    BtnAssignDevice: TButton;
    BtnSendUsers: TButton;
    /// <summary>
    /// Initialize form
    /// Load from local ini file
    /// </summary>
    procedure FormCreate(Sender: TObject);
    /// <summary>
    /// Save config data to local ini file
    /// Destroy owned objects
    /// </summary>
    procedure FormDestroy(Sender: TObject);
    /// <summary>
    /// Generate a random secret SIP key
    /// </summary>
    procedure BtnGenerateSipKeyClick(Sender: TObject);
    /// <summary>
    /// Save configuration to file - on SD card
    /// </summary>
    procedure BtnSaveToSDClick(Sender: TObject);
    /// <summary>
    /// Load configuration from file - on SD card
    /// </summary>
    procedure BtnLoadFromSDClick(Sender: TObject);
    /// <summary>
    /// Get user data record from current selection in user grid
    /// </summary>
    procedure GrdUsersGetValue(Sender: TObject; const Col, Row: Integer; var Value: TValue);
    /// <summary>
    /// Register change in current user selection - sets the CurrentUserRow field
    /// </summary>
    procedure GrdUsersSelChanged(Sender: TObject);
    /// <summary>
    /// DHCP/Fixed IP radio buttons have been set
    /// </summary>
    procedure RdbAutomaticClick(Sender: TObject);
    /// <summary>
    /// Generate a MAC address
    /// </summary>
    procedure BtnGenerateMacClick(Sender: TObject);
    /// <summary>
    /// Edit the currently selecte user
    /// </summary>
    procedure BtnEditUserClick(Sender: TObject);
    /// <summary>
    /// Assign a device to the currently selecte user
    /// Opens the device assinging dialog
    /// </summary>
    procedure BtnAssignDeviceClick(Sender: TObject);
    /// <summary>
    /// Send all user records to Arduino
    /// </summary>
    procedure BtnSendUsersClick(Sender: TObject);
    /// <summary>
    /// Open IP connection to Arduino and start a session
    /// </summary>
    procedure ConnectClick(Sender: TObject);
  private
    /// <summary>
    /// Index of currently selecte user record
    /// </summary>
    CurrentUserRow : integer;
    /// <summary>
    /// Has been successfully connected to the Arduino
    /// </summary>
    FConnected : boolean;
    /// <summary>
    /// The Admin data instance
    /// </summary>
    AdminData : TArduinoAdminData;{ Private declarations }
    /// <summary>
    /// The communication object
    /// </summary>
    ArduinoCommunication : TArduinoCommunication;
    /// <summary>
    /// The grid row has been changed - update display
    /// </summary>
    procedure UpdateGridRow(Row : integer);
    /// <summary>
    /// Get the local ini file for my configuration
    /// </summary>
    function GetIniFile: TCustomIniFile;
    /// <summary>
    /// Get the file name for the ini file
    /// </summary>
    function GetIniFileName: string;
    /// <summary>
    /// Send changed user data to the Arduino
    /// </summary>
    procedure SendUserChanged(UserIdx : integer);
    /// <summary>
    /// Update dialog controls from ConfigData object
    /// </summary>
    procedure ShowAdminData;
    /// <summary>
    /// Has been successfully connected to the Arduino
    /// </summary>
    property Connected : boolean read FConnected;
  public
    { Public declarations }
  end;

var
  FrmMainAdmin: TFrmMainAdmin;

implementation

{$R *.fmx}

procedure TFrmMainAdmin.BtnAssignDeviceClick(Sender: TObject);
var
  Dlg : TFrmAssignDevice;
begin
  // Check index
  if not CurrentUserRow in [0..9] then
    exit;

  // Open Dialog for user assignment
  Dlg := TFrmAssignDevice.Create(self);
  try
    if Dlg.Execute (AdminData, CurrentUserRow) then begin
      // Send assignment data to Arduino
      SendUserChanged(CurrentUserRow);
      // Update grid
      UpdateGridRow(CurrentUserRow);
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TFrmMainAdmin.BtnEditUserClick(Sender: TObject);
var
  Dlg : TDlgUser;
  User : TUserConfig;
  Name : string;
begin
  // Check Index
  if not CurrentUserRow in [0..9] then
    exit;

  // Open Edit dialog
  Dlg := TDlgUser.Create(self);
  try
    User := AdminData.Users[CurrentUserRow];
    Name := AdminData.UserName[CurrentUserRow];

    if Dlg.Execute (User, Name) then begin
      AdminData.UserKey[CurrentUserRow]  := User.userKey;
      AdminData.UserMode[CurrentUserRow] := User.userMode;
      AdminData.UserName[CurrentUserRow] := Name;

      // Send changed data to Arduino
      SendUserChanged(CurrentUserRow);
      // Update display
      UpdateGridRow(CurrentUserRow);
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TFrmMainAdmin.BtnGenerateMacClick(Sender: TObject);
begin
  AdminData.GenerateMacAddress;
  EdtMacAddress.Text := AdminData.MacAddressString;
end;

procedure TFrmMainAdmin.BtnGenerateSipKeyClick(Sender: TObject);
begin
  AdminData.SipKey.Generate;
  EdtSipKey.Text := AdminData.SipKey.AsString;
end;

procedure TFrmMainAdmin.BtnLoadFromSDClick(Sender: TObject);
var
  FileName : string;
begin
  if DlgOpen.Execute then begin
    FileName := DlgOpen.FileName;
    AdminData.LoadFromFile(FileName);
    ShowAdminData;
  end;
end;

procedure TFrmMainAdmin.SendUserChanged(UserIdx: integer);
var
  AllUsers : boolean;
  Dlg : TFrmSendUsers;
begin
  // only send, if connection already existed
  if not Connected then
    exit;

  // Send all users, if index is 0
  AllUsers := (UserIdx < 0) or (Useridx >= EE_USER_COUNT);

  // Open Send dialog for progress display and selection of responsible admin user
  Dlg := TFrmSendUsers.Create(self);
  try
    Dlg.Execute(AdminData, ArduinoCommunication, UserIdx, AllUsers);
  finally
    Dlg.Free;
  end;    
end;

procedure TFrmMainAdmin.ShowAdminData;
begin
//      EdtAdminPassword.Text := AdminData.AdminPw ;
  EdtWlanKey.Text       := AdminData.WLanKey ;
  EdtSSID.Text          := AdminData.SSID;
  EdtIpAddress.Text     := AdminData.IpAddress.AsString;
  EdtNetMask.Text       := AdminData.NetMask.AsString  ;
  EdtGateway.Text       := AdminData.Gateway.AsString  ;
  EdtDnsServer.Text     := AdminData.DnsServer.AsString;
  EdtSipKey.Text        := AdminData.SipKey.AsString;
  EdtMacAddress.Text    := AdminData.MacAddressString;

  if AdminData.UseDhcp then
    RdbAutomatic.IsChecked := true
  else
    RdbFixedIp.IsChecked := true;

  UpdateGridRow(CurrentUserRow);
  GrdUsersSelChanged(GrdUsers);
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
    AdminData.IpAddress.AsString := EdtIpAddress.Text;
    AdminData.NetMask.AsString   := EdtNetMask.Text;
    AdminData.Gateway.AsString   := EdtGateway.Text;
    AdminData.DnsServer.AsString := EdtDnsServer.Text;
    AdminData.MacAddressString   := EdtMacAddress.Text;
    AdminData.SipKey.AsString    := EdtSipKey.Text;

    if DlgSave.Execute then begin
      FileName := DlgSave.FileName;
      AdminData.SaveToFile(FileName);
    end;

  except
    on E:Exception do
      ShowMessage(E.Message);
  end;
end;

procedure TFrmMainAdmin.BtnSendUsersClick(Sender: TObject);
begin
  // use -1 as ALL-USERS
  // ToDo usee constant here to indicate purpose
  SendUserChanged(-1);
end;

procedure TFrmMainAdmin.ConnectClick(Sender: TObject);
var
  Dlg : TFrmConnectArduino;
begin
  // Show Connect-Dialog
  Dlg := TFrmConnectArduino.Create(self);
  try
    if Dlg.Execute(AdminData, ArduinoCommunication) then begin
      FConnected := true;
      LblConnectState.Text := 'Connected';
    end
    else if not TClientSession.Instance.HasSession then begin
      FConnected := false;       
      LblConnectState.Text := 'Not connected';
    end;

  finally
    Dlg.Free;
  end;
end;

procedure TFrmMainAdmin.GrdUsersGetValue(Sender: TObject; const Col, Row: Integer; var Value: TValue);
begin
  case Col of
    0: Value := row+1;
    1: Value := AdminData.UserName[row];
    2: Value := AdminData.UserLevel[row];
  end;
end;

procedure TFrmMainAdmin.GrdUsersSelChanged(Sender: TObject);
begin
  CurrentUserRow := GrdUsers.Selected;
end;

function TFrmMainAdmin.GetIniFileName : string;
begin
  result := IncludeTrailingPathDelimiter(TPath.GetDocumentsPath()) + 'GarageAdmin.ini';
end;

function TFrmMainAdmin.GetIniFile : TCustomIniFile;
var
  FileName : string;
begin
  FileName := GetIniFileName;
  result := TIniFile.Create(FileName);
end;


procedure TFrmMainAdmin.FormCreate(Sender: TObject);
var
  IniFile : TCustomIniFile;
begin
  IniFile := GetIniFile;
  try
    AdminData := TArduinoAdminData.Create;
    if FileExists(GetIniFileName) then begin
      AdminData.LoadFromIniFile(IniFile);
      ShowAdminData;
    end;
  finally
    IniFile.Free;
  end;
  ArduinoCommunication := TCommunicatorFactory.GetCommunicator(AdminData);
end;

procedure TFrmMainAdmin.FormDestroy(Sender: TObject);
var
  IniFile : TCustomIniFile;
begin
  IniFile := GetIniFile;
  try
    AdminData.SaveToIniFile(IniFile);
  finally
    IniFile.Free;
  end;
  AdminData.Free;
end;


procedure TFrmMainAdmin.RdbAutomaticClick(Sender: TObject);
begin
  EdtNetMask.Enabled   := not RdbAutomatic.IsChecked;
  EdtGateway.Enabled   := not RdbAutomatic.IsChecked;
  EdtDnsServer.Enabled := not RdbAutomatic.IsChecked;
end;

procedure TFrmMainAdmin.UpdateGridRow(Row: integer);
begin
  GrdUsers.RealignContent;
end;

end.
