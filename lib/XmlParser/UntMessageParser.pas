unit UntMessageParser;

interface

uses
  System.SysUtils, System.Classes,
  LibXmlParser,
  IntfMessageParser;

type
  TMessageParser = class (TInterfacedObject, IMessageParser)
  private
    XmlParser : TXmlParser;
    FXml      : Ansistring;
    function GetXml: String;
    procedure SetXml(const Value: String);
    function FindNext (NodeName: Ansistring) : boolean;
    function GetStrAttribute(AttrName: AnsiString): AnsiString;
    function GetIntAttribute(AttrName: AnsiString): integer;
    function XmlScan: boolean;
  protected
    // Not used yet
    function GetNextContent (NodeName: AnsiString) : AnsiString;
  public
    constructor Create;
    destructor Destroy; override;
    function   FindNextValuePair (var Key, Value : string) : boolean;
    procedure  StartScan;
    property   XML : String read GetXml write SetXml;
  end;

const
  CDivLabel    = 'DIV';
  CIdLabel     = 'ID';

implementation

{

 }
{ TMessageParser }

constructor TMessageParser.create;
begin
  XmlParser := TXmlParser.Create;
end;

destructor TMessageParser.destroy;
begin
  XmlParser.Free;
end;

function TMessageParser.FindNextValuePair(var Key, Value: string): boolean;
begin
  result := false;
  if FindNext (CDivLabel) then begin
    Key := GetStrAttribute (CIdLabel);
    Value := GetNextContent (CDivLabel);
    result := true;
  end;
end;

function TMessageParser.GetStrAttribute (AttrName : AnsiString) : AnsiString;
var
  n : integer;
  Attr : TAttr;
begin
  for n := 0 to XmlParser.CurAttr.Count - 1 do begin
    Attr := TAttr (XmlParser.CurAttr[n]);
    if AnsiSameText (AttrName, Attr.Name) then begin
      result := Attr.Value;
      exit;
    end;
  end;
  result := '';
  Assert (result <> '');
end;

function TMessageParser.GetXml: String;
begin
  result := FXMl;
end;

function TMessageParser.GetIntAttribute (AttrName : AnsiString) : integer;
var
  value : AnsiString;
begin
  value := GetStrAttribute (AttrName);
  result := StrToIntDef (Value, -1);

  Assert (result >= 0);
end;

function TMessageParser.GetNextContent(NodeName: AnsiString): AnsiString;
begin
  WHILE XmlScan DO BEGIN
    if XmlParser.CurPartType <> ptContent then
      continue;

    if AnsiSameText (XmlParser.CurName, NodeName) then begin
      result := XmlParser.CurContent;
      exit;
    end;
  end;
  result := '';
end;

procedure TMessageParser.SetXml(const Value: String);
begin
  FXml := value;
  XmlParser.LoadFromBuffer (pAnsiChar(FXml));
end;

procedure TMessageParser.StartScan;
begin
  XmlParser.StartScan;
end;

function TMessageParser.XmlScan : boolean;
begin
  result := XmlParser.Scan;
end;

function TMessageParser.FindNext(NodeName: AnsiString): boolean;
BEGIN
  WHILE XmlScan DO BEGIN
    CASE XmlParser.CurPartType OF
      ptStartTag,
      ptEmptyTag  : begin
                      if AnsiSameText (XmlParser.CurName, NodeName) then begin
                        result := true;
                        exit;
                      end;
                    end;
    END;
  end;
  result := false;
END;



end.
