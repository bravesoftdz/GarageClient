unit UntGetAssigned;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit,
  UntGetAssignment,
  UntClientConfig,
  CommunicationConst,
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
    procedure RepliedHandler (Sender : TObject);
    procedure ErrorHandler (Sender: TObject; ReplyResult : TReplyResult; ErrorMessage : string);

  public
  end;

var
  FrmGetAssignment: TFrmGetAssignment;

implementation

{$R *.fmx}

procedure TFrmGetAssignment.ErrorHandler(Sender: TObject; ReplyResult: TReplyResult; ErrorMessage: string);
begin
  ShowMessage(ErrorMessage);
end;

procedure TFrmGetAssignment.FormCreate(Sender: TObject);
begin
  Parser := TMessageParser.Create;
end;

procedure TFrmGetAssignment.RepliedHandler(Sender: TObject);
begin
  (Parser as TMessageParser).Free;
end;

procedure TFrmGetAssignment.FormDestroy(Sender: TObject);
begin
  ShowMessage('Reply received');
  BtnOk.Enabled := true;
end;

procedure TFrmGetAssignment.BtnAssignClick(Sender: TObject);
var
  DeviceId : integer;
  AssignmentTransfer : TGetAssignment;
begin
  DeviceId := StrToIntDef(EdtDeviceId.Text, 0);
  if DeviceId = 0 then begin
    ShowMessage('Please enter Device ID');
  end;

  AssignmentTransfer := TGetAssignment.Create(EdtIpAddress.Text, ClientConfig, Parser);

  AssignmentTransfer.ExecuteCommandAsync(DeviceId, RepliedHandler, ErrorHandler);
end;

end.
