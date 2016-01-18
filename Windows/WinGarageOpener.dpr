program WinGarageOpener;

uses
  FMX.Forms,
  UntWinMainGarage in '..\Forms\UntWinMainGarage.pas' {FrmMain},
  UntArduinoCommunication in '..\Communication\UntArduinoCommunication.pas',
  IntfGarageCommunication in '..\Interfaces\IntfGarageCommunication.pas',
  UntClientConfig in '..\Data\UntClientConfig.pas',
  ConfigConst in '..\Data\ConfigConst.pas',
  UntSipHash in '..\lib\SipHash\UntSipHash.pas',
  CommunicationConst in '..\Communication\CommunicationConst.pas',
  UntCommand in '..\Communication\UntCommand.pas',
  UntGetAssignment in '..\Communication\UntGetAssignment.pas',
  UntFrmGetAssigned in '..\Forms\UntFrmGetAssigned.pas' {FrmGetAssignment},
  UntClientSession in '..\Communication\UntClientSession.pas',
  UntCmdConnect in '..\Communication\UntCmdConnect.pas',
  UntSimpleCommand in '..\Communication\UntSimpleCommand.pas',
  IntfMessageParser in '..\Interfaces\IntfMessageParser.pas',
  LibXmlComps in '..\lib\XmlParser\LibXmlComps.pas',
  LibXmlParser in '..\lib\XmlParser\LibXmlParser.pas',
  UntMessageParser in '..\lib\XmlParser\UntMessageParser.pas',
  UntIpAddress in '..\Data\UntIpAddress.pas',
  UntCommunicationFactory in '..\Communication\UntCommunicationFactory.pas',
  CommunicationTypes in '..\Communication\CommunicationTypes.pas',
  UntCommandParameter in '..\Communication\UntCommandParameter.pas',
  UntArduinoAdminData in '..\Data\UntArduinoAdminData.pas',
  UntStringHasher in '..\Data\UntStringHasher.pas',
  IntfClientConfig in '..\Interfaces\IntfClientConfig.pas',
  IntfCommandHandler in '..\Interfaces\IntfCommandHandler.pas',
  UntCmdGetStatus in '..\Communication\UntCmdGetStatus.pas',
  UntSimpleCommunication in '..\Communication\UntSimpleCommunication.pas',
  UntGarageCommunication in '..\Communication\UntGarageCommunication.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
