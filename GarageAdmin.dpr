program GarageAdmin;

uses
  FMX.Forms,
  UntAdmin in 'Forms\UntAdmin.pas' {FrmMainAdmin},
  UntArduinoAdminData in 'Data\UntArduinoAdminData.pas',
  UntClientSession in 'Communication\UntClientSession.pas',
  UntArduinoCommunication in 'Communication\UntArduinoCommunication.pas',
  UntSipHash in 'lib\SipHash\UntSipHash.pas',
  IntfMessageParser in 'Interfaces\IntfMessageParser.pas',
  UntCommand in 'Communication\UntCommand.pas',
  CommunicationConst in 'Communication\CommunicationConst.pas',
  ConfigConst in 'Data\ConfigConst.pas',
  UntSetupCommand in 'Communication\UntSetupCommand.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmMainAdmin, FrmMainAdmin);
  Application.Run;
end.
