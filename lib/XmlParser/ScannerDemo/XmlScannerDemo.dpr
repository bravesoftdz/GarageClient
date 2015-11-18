program XmlScannerDemo;

uses
  Forms,
  Main in 'Main.pas' {FrmMain},
  LibXmlComps in '..\LibXmlComps.pas',
  LibXmlParser in '..\LibXmlParser.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
