unit UntWinMainGarage;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Edit,
  Xml.xmldom, Xml.XMLIntf, Xml.adomxmldom, Xml.XMLDoc,
  UntArduinoCommunication,
  UntXmlMessageParser,
  IntfMessageParser,
  IntfGarageCommunication;
type
  TForm2 = class(TForm)
    BtnOpen: TButton;
    EdtState: TEdit;
    BtnClose: TButton;
    Timer1: TTimer;
    XMLDocument1: TXMLDocument;
    procedure Timer1Timer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtnOpenClick(Sender: TObject);
    procedure BtnCloseClick(Sender: TObject);
  private
    GarageCommunication : TArduinoCommunication;
    procedure StatusChanged (Sender : TObject);
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.fmx}

procedure TForm2.BtnCloseClick(Sender: TObject);
begin
  GarageCommunication.Close;
end;

procedure TForm2.BtnOpenClick(Sender: TObject);
begin
  GarageCommunication.Open;
end;

procedure TForm2.FormShow(Sender: TObject);
var
  MessageParser : IMessageParser;
  XmlParser     : IXmlDocument;
begin
  XmlParser := TXmlDocument.Create(self);
  MessageParser := TMessageParser.Create (XmlParser);

  GarageCommunication := TGarageCommunication.Create(MessageParser);
  GarageCommunication.OnStatusChanged := StatusChanged;;
end;

procedure TForm2.StatusChanged(Sender: TObject);
begin
  EdtState.Text := CGarageStatus_Key[GarageCommunication.GarageStatus];
end;

procedure TForm2.Timer1Timer(Sender: TObject);
begin
  try
    GarageCommunication.LoadStatus;
  except
    on E:Exception do begin
      ShowMessage (E.Message);
    end;
  end;
end;

end.
