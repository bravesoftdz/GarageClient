unit UntXmlMessageParser;

interface

uses
  System.SysUtils, System.Classes,
  Xml.xmldom, Xml.XMLIntf, Xml.adomxmldom, Xml.XMLDoc,
  IntfMessageParser;

type
  TMessageParser = class (TInterfacedObject, IMessageParser)
  private
    FXml           : String;
    function GetXml: String;
    procedure SetXml(const Value: String);
    function CurrentNodeIsDiv: boolean;
{
    function FindNext (NodeName: Ansistring) : boolean;
    function GetStrAttribute(AttrName: AnsiString): AnsiString;
    function GetIntAttribute(AttrName: AnsiString): integer;
    function XmlScan: boolean;}
  protected
    XmlDocument : IXmlDocument;
    CurrentNode : IXmlNode;
    function ScanNext : boolean;
    // Not used yet
//    function GetNextContent (NodeName: AnsiString) : AnsiString;
  public
    constructor Create (Parser : IXmlDocument);
    destructor Destroy; override;
    function   FindNextValuePair (var Key, Value : string) : boolean;
    procedure  StartScan;
    property   XML : String read GetXml write SetXml;
  end;


implementation

{ TMessageParser }

constructor TMessageParser.Create(Parser : IXmlDocument);
begin
  XmlDocument := Parser;
end;

destructor TMessageParser.Destroy;
begin
  inherited;
end;

function TMessageParser.FindNextValuePair(var Key, Value: string): boolean;
begin
  result := ScanNext;
  if not result then
    exit;

  if not CurrentNode.HasAttribute ('ID') then
    result := false
  else begin
    Key := CurrentNode.Attributes['ID'];
    Value := CurrentNode.NodeValue;
  end;
end;

function TMessageParser.GetXml: String;
begin
  result := XmlDocument.XML.Text;
end;

function TMessageParser.CurrentNodeIsDiv : boolean;
begin
  result := (CurrentNode <> nil) and SameText (CurrentNode.NodeName, 'DIV');
end;

function TMessageParser.ScanNext : boolean;
begin
  if CurrentNodeIsDiv then
    CurrentNode := CurrentNode.NextSibling;

  while (CurrentNode <> nil) and not SameText (CurrentNode.NodeName, 'DIV') do
    CurrentNode := CurrentNode.NextSibling;

  result := (CurrentNode <> nil);
end;

procedure TMessageParser.SetXml(const Value: String);
var
  Header : string;
begin
  XmlDocument.Active := false;
  XmlDocument.XML.Clear;
  if pos('<?xml ', Value) <> 1 then
    XmlDocument.XML.Add('<?xml version="1.0"?>');

  XmlDocument.XML.Add (Value);
  XmlDocument.Active := true;
end;

procedure TMessageParser.StartScan;
begin
  CurrentNode := XmlDocument.DocumentElement.ChildNodes.First;
end;

end.
