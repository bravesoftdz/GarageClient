unit GarageMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit,
  FMX.Platform.Android,
  Xml.xmldom, Xml.XMLIntf, Xml.adomxmldom, Xml.XMLDoc,
  IdException,
  IntfGarageCommunication,
  IntfMessageParser,
  UntArduinoCommunication,
  UntGarageCommunication;

type
  /// <summary>
  /// Mobile device form for Garage opener
  /// Not complete yet
  /// </summary>
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    EdtStatus: TEdit;
    BtnOpen: TButton;
    BtnClose: TButton;
    Timer1: TTimer;
    BtnExit: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure BtnOpenClick(Sender: TObject);
    procedure BtnCloseClick(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
  private
    GarageCommunication : TArduinoCommunication;
    procedure StatusChanged (Sender : TObject);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.BtnCloseClick(Sender: TObject);
begin
  GarageCommunication.Close;
end;

procedure TForm1.BtnExitClick(Sender: TObject);
begin
  MainActivity.finish;
end;

procedure TForm1.BtnOpenClick(Sender: TObject);
begin
  GarageCommunication.Open;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  MessageParser : IMessageParser;
  XmlDocument : IXmlDocument;
begin
  XmlDocument := TXmlDocument.Create(self);
  MessageParser := TMessageParser.Create(XmlDocument);

  GarageCommunication := TArduinoCommunication.Create(MessageParser);
  GarageCommunication.OnStatusChanged := StatusChanged;;
end;

procedure TForm1.StatusChanged(Sender: TObject);
begin
  EdtStatus.Text := CGarageStatus_Key[GarageCommunication.GarageStatus];
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := false;
  try
    GarageCommunication.LoadStatus;
  except
    on E:EIdConnClosedGracefully do begin
    end;
    on E:Exception do begin
      EdtStatus.Text := E.Message;
    end;
  end;
  Timer1.Enabled := true;
end;

end.
