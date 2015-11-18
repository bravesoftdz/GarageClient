unit UntAdmin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  System.Rtti, FMX.Grid, FMX.Layouts, FMX.Edit, FMX.TabControl;

type
  TFrmMainAdmin = class(TForm)
    TabControl1: TTabControl;
    tiMobileDevices: TTabItem;
    tiArduino: TTabItem;
    Label1: TLabel;
    EdtAdminPassword: TEdit;
    EdtIpAddress: TEdit;
    Label2: TLabel;
    EdtSipKey: TEdit;
    Label3: TLabel;
    EdtSSID: TEdit;
    Label4: TLabel;
    EdtWlanKey: TEdit;
    Label5: TLabel;
    Button1: TButton;
    BtnLoadFromSD: TButton;
    Connect: TButton;
    sgDevices: TStringGrid;
    scId: TStringColumn;
    scName: TStringColumn;
    scState: TStringColumn;
    btnActivate: TButton;
    btnInactivate: TButton;
    btnRemove: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmMainAdmin: TFrmMainAdmin;

implementation

{$R *.fmx}

end.
