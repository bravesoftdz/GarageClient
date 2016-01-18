unit UntFrmGetAssigned;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit,
  UntGetAssignment,
  UntClientConfig,
  CommunicationConst,
  CommunicationTypes,
  IntfMessageParser,
  UntMessageParser;

type
  TFrmGetAssignment = class(TForm)
    Label6: TLabel;
    Label7: TLabel;
    EdtDeviceId: TEdit;
    EdtUserName: TEdit;
    Label2: TLabel;
    EdtIpAddress: TEdit;
    Label1: TLabel;
    EdtStatus: TEdit;
    BtnOK: TButton;
    BtnCancel: TButton;
    Label3: TLabel;

    BtnAssign: TButton;
    procedure BtnAssignClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    ClientConfig : TClientConfig;
    Parser       : IMessageParser;
    AssignmentTransfer : TGetAssignment;
    procedure RepliedHandler (Sender : TObject);
    procedure ErrorHandler (Sender: TObject; ReplyResult : TReplyResult; ErrorMessage : string);

  public
    function Execute (ClientConfig : TClientConfig) : boolean;

  end;

var
  FrmGetAssignment: TFrmGetAssignment;

implementation

{$R *.fmx}

function TFrmGetAssignment.Execute(ClientConfig: TClientConfig): boolean;
begin
  if ClientConfig = nil then
    raise Exception.Create('Empty Client Config');

  self.ClientConfig := ClientConfig;

  result := ShowModal = mrOK;

  if result then begin
    AssignmentTransfer.FillConfig(ClientConfig);
  end;
end;

procedure TFrmGetAssignment.FormCreate(Sender: TObject);
begin
  Parser := TMessageParser.Create;
  AssignmentTransfer := TGetAssignment.Create(Parser);
end;

procedure TFrmGetAssignment.FormDestroy(Sender: TObject);
begin
  AssignmentTransfer.Free;
//  (Parser as TMessageParser).Free;
end;

procedure TFrmGetAssignment.ErrorHandler(Sender: TObject; ReplyResult: TReplyResult; ErrorMessage: string);
begin
  BtnOk.Enabled := false;
  ShowMessage(ErrorMessage);
end;

procedure TFrmGetAssignment.RepliedHandler(Sender: TObject);
begin
  BtnAssign.Enabled := true;
  BtnOk.Enabled     := true;
  EdtStatus.Text    := CReplyResultKey[AssignmentTransfer.LastResult];
  try
    EdtUserName.Text:= AssignmentTransfer.ReplyData[CNodeUserName];
  except
    EdtUserName.Text:= '- Unknown -';
  end;
end;

procedure TFrmGetAssignment.BtnAssignClick(Sender: TObject);
var
  DeviceId : integer;
  Host     : string;
begin
  DeviceId := StrToIntDef(EdtDeviceId.Text, 0);
  if DeviceId = 0 then begin
    ShowMessage('Please enter Device ID');
    exit;
  end;

  Host := EdtIpAddress.Text;
  if Host = '' then begin
    ShowMessage('Please enter Hostname or IP address for Admin tool');
    exit;
  end;

  BtnAssign.Enabled := false;
  AssignmentTransfer.ExecuteCommandAsync(Host, DeviceId, RepliedHandler, ErrorHandler);
end;

end.
