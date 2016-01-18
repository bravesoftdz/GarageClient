program SipTest;

uses
  FMX.Forms,
  UntSipTest in 'lib\SipHash\UntSipTest.pas' {Form2},
  UntSipHash in 'lib\SipHash\UntSipHash.pas',
  UntStringHasher in 'Data\UntStringHasher.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
