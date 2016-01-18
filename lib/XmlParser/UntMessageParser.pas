unit UntMessageParser;

interface

uses
  System.SysUtils, System.Classes, System.Contnrs,
  CommunicationConst,
  CommunicationTypes,
  LibXmlParser,
  IntfMessageParser;

type
  TMessageParser = class (TInterfacedObject, IMessageParser)
  private
    XmlParser : TXmlParser;
    FXml      : AnsiString;
    function GetXml: String;
    procedure SetXml(const Value: String);
    function FindNext (NodeName: Ansistring) : boolean;
    function XmlScan: boolean;
  protected
    FHasError   : boolean;
    FError      : string;
    FResult     : TReplyResult;
    procedure Clear;
    function GetNextContent (NodeName: AnsiString) : AnsiString;
    function GetStrAttribute(AttrName: AnsiString): AnsiString;
    function GetIntAttribute(AttrName: AnsiString): integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure  Parse(ResultData : TResultDictionary);
    function   FindNextValuePair (var Key, Value : string) : boolean;
    function   FindNextNamedValuePair (var Key, Value : string; NodeName : string; AttributeName : string) : boolean;
    function   TransferResult : TReplyResult;
    function   HasError: boolean;
    function   GetError: string;
    property   XML : String read GetXml write SetXml;
  end;

const
  CDivLabel    = 'DIV';
  CIdLabel     = 'ID';

implementation

{

 }
{ TMessageParser }

procedure TMessageParser.Clear;
begin
  FHasError   := false;
  FError      := '';
  FResult     := rrUnknown;
end;

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
  result := FindNextNamedValuePair(Key, Value, CNodeData, CAttrId);
end;

function TMessageParser.FindNextNamedValuePair(var Key, Value: string; NodeName, AttributeName: string): boolean;
begin
  result := false;
  if FindNext (NodeName) then begin
    Key := GetStrAttribute (AttributeName);
    Value := GetNextContent (NodeName);
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

function TMessageParser.GetError: string;
begin
  result := FError;
end;

function TMessageParser.HasError: boolean;
begin
  result := FHasError;
end;

procedure TMessageParser.Parse(ResultData : TResultDictionary);
var
  Key, Value : string;
  ResultString : string;
  ReplyResult : TReplyResult;
begin
  Clear;
  ResultData.Clear;

  XmlParser.StartScan;
  while FindNextValuePair(Key, Value) do begin
    ResultData.Add(Key, Value);
  end;

  XmlParser.StartScan;
  if FindNextNamedValuePair(Key, Value, CNodeQueryResult, CAttrStatus) then begin
    FError       := Value;
    ResultString := Key;

    for ReplyResult := low(TReplyResult) to High(TReplyResult) do
      if SameText(CReplyResultKey[ReplyResult], ResultString) then begin
        FResult := ReplyResult;
        break;
      end;

    if FResult <> rrOK then
      FHasError := true;
  end
  else begin
    FHasError := true;
    FError := 'Incomplete reply';
  end;
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

  XmlParser.StartScan;
end;

function TMessageParser.TransferResult: TReplyResult;
begin
  result := FResult;
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
