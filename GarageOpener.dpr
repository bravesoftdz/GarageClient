program GarageOpener;

uses
  System.StartUpCopy,
  FMX.MobilePreview,
  FMX.Forms,
  GarageMain in 'Forms\GarageMain.pas' {Form1},
  IntfGarageCommunication in 'Interfaces\IntfGarageCommunication.pas',
  UntSipHash in 'lib\SipHash\UntSipHash.pas',
  CommunicationConst in 'Communication\CommunicationConst.pas',
  CommunicationTypes in 'Communication\CommunicationTypes.pas',
  UntArduinoCommunication in 'Communication\UntArduinoCommunication.pas',
  UntClientSession in 'Communication\UntClientSession.pas',
  UntCmdConnect in 'Communication\UntCmdConnect.pas',
  UntCmdGetStatus in 'Communication\UntCmdGetStatus.pas',
  UntCommand in 'Communication\UntCommand.pas',
  UntCommandParameter in 'Communication\UntCommandParameter.pas',
  UntCommunicationFactory in 'Communication\UntCommunicationFactory.pas',
  UntGarageCommunication in 'Communication\UntGarageCommunication.pas',
  UntSimpleCommand in 'Communication\UntSimpleCommand.pas',
  UntSimpleCommunication in 'Communication\UntSimpleCommunication.pas',
  IntfMessageParser in 'interfaces\IntfMessageParser.pas',
  UntMessageParser in 'lib\XmlParser\UntMessageParser.pas',
  LibXmlComps in 'lib\XmlParser\LibXmlComps.pas',
  LibXmlParser in 'lib\XmlParser\LibXmlParser.pas',
  UntStringHasher in 'Data\UntStringHasher.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
