program GarageAdmin;

uses
  FMX.Forms,
  UntAdmin in 'Forms\UntAdmin.pas' {FrmMainAdmin},
  UntArduinoAdminData in 'Data\UntArduinoAdminData.pas',
  UntClientSession in 'Communication\UntClientSession.pas',
  UntArduinoCommunication in 'Communication\UntArduinoCommunication.pas',
  UntSipHash in 'lib\SipHash\UntSipHash.pas',
  IntfMessageParser in 'Interfaces\IntfMessageParser.pas',
  IntfClientConfig in 'Interfaces\IntfClientConfig.pas',
  UntCommand in 'Communication\UntCommand.pas',
  CommunicationConst in 'Communication\CommunicationConst.pas',
  ConfigConst in 'Data\ConfigConst.pas',
  UntCmdConnect in 'Communication\UntCmdConnect.pas',
  UntCmdSetUser in 'Communication\UntCmdSetUser.pas',
  UntSimpleCommand in 'Communication\UntSimpleCommand.pas',
  UntIpAddress in 'Data\UntIpAddress.pas',
  UntUserDlg in 'Forms\UntUserDlg.pas' {DlgUser},
  UntAssignDevice in 'Forms\UntAssignDevice.pas' {FrmAssignDevice},
  UntDeviceAssignment in 'Communication\UntDeviceAssignment.pas',
  UntCommunicationFactory in 'Communication\UntCommunicationFactory.pas',
  LibXmlComps in 'lib\XmlParser\LibXmlComps.pas',
  LibXmlParser in 'lib\XmlParser\LibXmlParser.pas',
  UntMessageParser in 'lib\XmlParser\UntMessageParser.pas',
  UntClientConfig in 'Data\UntClientConfig.pas',
  IntfCommandHandler in 'Interfaces\IntfCommandHandler.pas',
  CommunicationTypes in 'Communication\CommunicationTypes.pas',
  UntCommandParameter in 'Communication\UntCommandParameter.pas',
  UntFrmConnectArduino in 'Forms\UntFrmConnectArduino.pas' {FrmConnectArduino},
  UntFrmSendUsers in 'Forms\UntFrmSendUsers.pas' {FrmSendUsers},
  UntStringHasher in 'Data\UntStringHasher.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmMainAdmin, FrmMainAdmin);
  Application.Run;
end.
