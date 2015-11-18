program GarageOpener;

uses
  System.StartUpCopy,
  FMX.MobilePreview,
  FMX.Forms,
  GarageMain in 'Forms\GarageMain.pas' {Form1},
  UntArduinoCommunication in 'Communication\UntArduinoCommunication.pas',
  IntfGarageCommunication in 'Interfaces\IntfGarageCommunication.pas',
  UntXmlMessageParser in 'lib\XmlDocument\UntXmlMessageParser.pas',
  UntSipHash in 'lib\SipHash\UntSipHash.pas',
  UntClientSession in 'Communication\UntClientSession.pas',
  CommunicationConst in 'Communication\CommunicationConst.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
