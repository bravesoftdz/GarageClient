unit UntAssignDevice;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  UntArduinoAdminData, FMX.Edit,
  UntDeviceAssignment;

type
  TFrmAssignDevice = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label6: TLabel;
    Label7: TLabel;

    EdtDeviceId: TEdit;
    EdtUserName: TEdit;
    EdtIpAddress: TEdit;
    EdtStatus: TEdit;

    BtnOK: TButton;
    BtnCancel: TButton;
    /// <summary>
    /// Start the assignment process
    /// </summary>
    procedure FormShow(Sender: TObject);
    /// <summary>
    /// Cancel the process
    /// </summary>
    procedure BtnCancelClick(Sender: TObject);
  private
    /// <summary>
    /// The object executing the assignment
    /// </summary>
    DeviceAssignment : TDeviceAssignment;
    /// <summary>
    /// Eventhandler, showing status change
    /// </summary>
    procedure StatusChangeHandler(Sender : TObject);
  public
    /// <summary>
    /// Executes the device assignment dialog
    /// </summary>
  	/// <param name="AdminData">The admin data used for assignment</param>
  	/// <param name="UserIdx">The index of the user to be assigned</param>
  	/// <returns>The hash as 16-char hex string</returns>
    function Execute (var AdminData : TArduinoAdminData; UserIdx : integer) : boolean;
  end;

var
  FrmAssignDevice: TFrmAssignDevice;

implementation

{$R *.fmx}

{ TFrmAssignDevice }

procedure TFrmAssignDevice.BtnCancelClick(Sender: TObject);
begin
  DeviceAssignment.Stop;
end;

function TFrmAssignDevice.Execute(var AdminData: TArduinoAdminData; UserIdx : integer): boolean;
begin
  EdtUserName.Text := AdminData.UserName[UserIdx];
  DeviceAssignment := TDeviceAssignment.Create(AdminData, UserIdx);
  try
    DeviceAssignment.OnStatusChanged := StatusChangeHandler;
    result := (ShowModal = mrOK);
    if result then
      AdminData.UserId[UserIdx] := DeviceAssignment.UserId;
  finally
    DeviceAssignment.Stop;
    DeviceAssignment.Free;
  end;
end;

procedure TFrmAssignDevice.FormShow(Sender: TObject);
begin
  DeviceAssignment.Start;
end;

procedure TFrmAssignDevice.StatusChangeHandler(Sender: TObject);
begin
  case DeviceAssignment.Status of
    asUnknown: EdtStatus.Text := 'unknown';
    asStarting: begin
      EdtStatus.Text    := 'starting';
      EdtIpAddress.Text := DeviceAssignment.IpAddress;
      BtnOK.Enabled     := false;
    end;
    asBound: begin
      EdtStatus.Text    := 'listening';
      EdtDeviceId.Text  := IntToStr(DeviceAssignment.UserId);
    end;
    asConnected: EdtStatus.Text := 'connected';
    asAssigned: begin
      EdtStatus.Text := 'done';
      BtnOK.Enabled  := true;
    end;
    asError: ShowMessage(DeviceAssignment.ErrorText);
  end;

end;

end.
