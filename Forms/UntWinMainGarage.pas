unit UntWinMainGarage;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, SHFolder,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Edit,
  Xml.xmldom, Xml.XMLIntf, Xml.adomxmldom, Xml.XMLDoc,
  IniFiles,
  CommunicationTypes,
  UntIpAddress,
  UntCommunicationFactory,
  UntArduinoCommunication,
  UntGarageCommunication,
  UntMessageParser,
  UntClientConfig,
  UntCmdGetStatus,
  IntfMessageParser,
//  IntfGarageCommunication,
  UntFrmGetAssigned;

type
  TFrmMain = class(TForm)
    BtnOpen: TButton;
    EdtState: TEdit;
    BtnClose: TButton;
    Timer1: TTimer;
    BtnAssign: TButton;
    LblUsernameL: TLabel;
    LblConnectionL: TLabel;
    LblUsername: TLabel;
    LblConnection: TLabel;
    ChbAutoRefresh: TCheckBox;
    BtnRefresh: TButton;
    procedure Timer1Timer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtnOpenClick(Sender: TObject);
    procedure BtnCloseClick(Sender: TObject);
    procedure BtnAssignClick(Sender: TObject);
    procedure ChbAutoRefreshChange(Sender: TObject);
    procedure BtnRefreshClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    ClientConfig : TClientConfig;
    StatusCommunication : TStatusCommunication;
    GarageCommunication : TGarageCommunication;
    DeviceComm : TArduinoCommunication;
    CurrentStatus : TGarageDoorStatus;
    procedure StatusReceived(Sender : TObject; Status : TGarageDoorStatus);
    procedure StatusError(Sender : TObject; Context : string; ErrorMessage : string);
    procedure GarageButtonError(Sender : TObject; Context : string; ErrorMessage : string);
    procedure GarageButtonDone(Sender : TObject);

    function  GetConfigFileName: string;
    function  GetClientConfig : TCustomIniFile;
    procedure ShowAssignment;
  public
    property ConfigFileName : string read GetConfigFileName;
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.fmx}

procedure TFrmMain.BtnAssignClick(Sender: TObject);
var
  Dlg : TFrmGetAssignment;
begin
  Dlg := TFrmGetAssignment.Create(self);
  try
    Dlg.Execute(ClientConfig);
    ShowAssignment;
  finally
    Dlg.Free;
  end;
end;

procedure TFrmMain.BtnCloseClick(Sender: TObject);
begin
  GarageCommunication.Close;
end;

procedure TFrmMain.BtnOpenClick(Sender: TObject);
begin
  GarageCommunication.Open;
end;

procedure TFrmMain.ChbAutoRefreshChange(Sender: TObject);
begin
  BtnRefresh.Visible := not ChbAutoRefresh.IsChecked;
  if ChbAutoRefresh.IsChecked then
    Timer1.Enabled := True;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(GarageCommunication);
  FreeAndNil(StatusCommunication);
  FreeAndNil(DeviceComm);
end;

procedure TFrmMain.FormShow(Sender: TObject);
var
  MessageParser : IMessageParser;
  XmlParser     : IXmlDocument;
begin
//  XmlParser := TXmlDocument.Create(self);
  MessageParser := TMessageParser.Create ();
  ClientConfig  := TClientConfig.Create(GetClientConfig);

  ShowAssignment;

  if ClientConfig.IsValid then begin
    DeviceComm := TCommunicatorFactory.GetDeviceCommunicator(ClientConfig);
    StatusCommunication := TStatusCommunication.Create(DeviceComm);
    StatusCommunication.Init(ClientConfig, StatusError, StatusReceived);
    GarageCommunication := TGarageCommunication.Create(DeviceComm);
    GarageCommunication.Init(ClientConfig, GarageButtonError, GarageButtonDone);
    BtnRefresh.Visible       := False;
    ChbAutoRefresh.IsChecked := True;
    Timer1.Enabled           := True;
  end;
end;

function GetSpecialFolderPath(folder : integer) : string;
const
  SHGFP_TYPE_CURRENT = 0;
var
  path: array [0..255] of char;
  Return : integer;
begin
  return := SHGetFolderPath(0,folder,0,SHGFP_TYPE_CURRENT,@path[0]);
  if return = 0 then
    Result := path
  else
    Result := '';
end;

function TFrmMain.GetClientConfig: TCustomIniFile;
begin
  result := TIniFile.Create(ConfigFileName);
end;

function TFrmMain.GetConfigFileName: string;
var
  Path : string;
begin
  Path := GetSpecialFolderPath(CSIDL_COMMON_APPDATA);
  if Path = '' then
    raise Exception.Create('No path found');

  result := IncludeTrailingPathDelimiter(Path) + 'GarageClient.cfg'
end;

procedure TFrmMain.ShowAssignment;
begin
  if ClientConfig.IsValid then begin
    LblUsername.Text   := ClientConfig.UserName;
    LblConnection.Text := TIpAddress.Format(ClientConfig.DeviceIp);
  end
  else begin
    LblUsername.Text   := '-';
    LblConnection.Text := '-';
  end;
end;

procedure TFrmMain.GarageButtonDone(Sender: TObject);
begin
  if not ChbAutoRefresh.IsChecked then
    BtnRefreshClick(self);
end;

procedure TFrmMain.GarageButtonError(Sender: TObject; Context, ErrorMessage: string);
begin
  ShowMessage(ErrorMessage);
end;

procedure TFrmMain.StatusError(Sender: TObject; Context, ErrorMessage: string);
begin
  ShowMessage(ErrorMessage);
  Timer1.Enabled := False;
  ChbAutoRefresh.IsChecked := false;
end;

procedure TFrmMain.StatusReceived(Sender: TObject; Status: TGarageDoorStatus);
begin
  EdtState.Text := CGarageDoorStatusText[Status];
  if ChbAutoRefresh.IsChecked then
    Timer1.Enabled := True;

  if CurrentStatus = Status then
    exit;

  CurrentStatus := Status;

  BtnOpen.Enabled := false;
  BtnClose.Enabled := false;
  if Status = gdsOpen then
    BtnClose.Enabled := true
  else if Status = gdsClosed then
    BtnOpen.Enabled := true;
end;

procedure TFrmMain.Timer1Timer(Sender: TObject);
begin
  try
    Timer1.Enabled := False;
    StatusCommunication.Execute();
  except
    on E:Exception do begin
      ShowMessage (E.Message);
    end;
  end;
end;

procedure TFrmMain.BtnRefreshClick(Sender: TObject);
begin
  StatusCommunication.Execute;
end;


end.
