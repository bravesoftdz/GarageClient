program WinGarageOpener;

uses
  FMX.Forms,
  UntWinMainGarage in '..\Forms\UntWinMainGarage.pas' {Form2},
  UntArduinoCommunication in '..\Communication\UntArduinoCommunication.pas',
  IntfGarageCommunication in '..\Interfaces\IntfGarageCommunication.pas',
  IntfMessageParser in '..\Interfaces\IntfMessageParser.pas',
  UntXmlMessageParser in '..\lib\XmlDocument\UntXmlMessageParser.pas',
  ClientConfig in '..\Data\ClientConfig.pas',
  ConfigConst in '..\Data\ConfigConst.pas',
  UntSipHash in '..\lib\SipHash\UntSipHash.pas',
  CommunicationConst in '..\Communication\CommunicationConst.pas',
  UntCommand in '..\Communication\UntCommand.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
