unit UntOrderParser;

interface

uses
  SysUtils, StringX,
  ElmarBib,
  LibXmlParser;

type
  TArticleItem = record
    OrderCount : integer;
    ItemId : string;
    ItemAuxId : string;
    Description : string;
  end;

  TArticlesRec = record
    OrderId : string;
    Items : array of TArticleItem;
  end;

  TOrderRec = record
    WebID             : String;
    UserName          : String;
    Password          : string;
    CustomerEmail     : String;
    OrderTypeStr      : String;
    OrderExternalId   : String;
    OfferNo           : String;
    OrderKindStr      : String;
    PlateGroupingSt   : String;
    Comment           : String;
    AribaOrderId      : string;
    DataSheetByMail   : string;
    DataSheetMailAddr : string;
  end;

type
  TOrderParser = class
  private
    XmlParser : TXmlParser;
    FXml      : string;
    CurrentNodeTree : array of String;
    CurrentNodeIsEmpty  : boolean;
    procedure SetXml(const Value: string);
    function FindNext (NodeName: string) : boolean;
    procedure RemoveChildNode (NodeName : string);
    procedure AddChildNode (NodeName : string);
    function HasParent (NodeName: string) : boolean;
    function GetStrAttribute(AttrName: String): string;
    function GetIntAttribute(AttrName: String): integer;
    procedure ParseItem(var ArticlesRec: TArticlesRec; var OrderRec: TOrderRec);
    function XmlScan: boolean;
    procedure FillOrderValues(AuxIdLine : string; var OrderRec : TOrderRec);
  protected
    // Not used yet
    function GetNextContent (NodeName: string) : string;
  public
    constructor create;
    destructor destroy; override;
    procedure ParseOrder (var ArticlesRec: TArticlesRec; var OrderRec: TOrderRec);
    property XML : string read FXml write SetXml;
  end;

const
  CIdAuxLabel  = 'SupplierPartAuxiliaryID';
  CIdLabel     = 'SupplierPartID';
  CContentLabel= 'Description';
  CAttrOrderId = 'OrderId';
  COrderRequestHeader = 'OrderRequestHeader';
  CAttrQuantity = 'quantity';
  CItemLabel    = 'ItemOut';
  CArticleShortLabel= 'A';

{$ifndef NovartisPatch}
  CWebIdPos    = 1;
  CStateStrPos = 8;
  CShopTypePos = 4;
  CEMailPos    = 3;
  CUserNamePos = 2;

  CExtIdPos    = 5;
  COfferNoPos  = 6;
  COrderKindPos= 7;
  CPlateGrpPos = 9;
  CCommentPos  = 10;
{$else}
  CWebIdPos    = 2;
  CShopTypePos = 3;
  CStateStrPos = 4;
{
  CEMailPos    = 5;
  CUserNamePos = 4;

  CExtIdPos    = 6;
  COfferNoPos  = 7;
  COrderKindPos= 8;
  CPlateGrpPos = 9;
  CCommentPos  = 10;}
{$endif}




implementation

{

MyXml := TXmlParser.Create;
MyXml.LoadFromFile (Filename);
MyXml.StartScan;
WHILE MyXml.Scan DO
  CASE MyXml.CurPartType OF
 }
{ TOrderParser }

constructor TOrderParser.create;
begin
  XmlParser := TXmlParser.Create;
end;

destructor TOrderParser.destroy;
begin
  XmlParser.Free;
end;



procedure TOrderParser.ParseOrder(var ArticlesRec: TArticlesRec; var OrderRec: TOrderRec);
begin
  XmlParser.StartScan;
  FindNext (COrderRequestHeader);
  OrderRec.AribaOrderId := GetStrAttribute (CAttrOrderId);

  XmlParser.StartScan;
  while FindNext (CItemLabel) do begin
    ParseItem (ArticlesRec, OrderRec);
  end;
end;

procedure TOrderParser.FillOrderValues (AuxIdLine : string; var OrderRec : TOrderRec);
begin
  OrderRec.WebID           :=               StrListElem(AuxIdLine, ';', CWebIdPos);
  OrderRec.OrderTypeStr    := AnsiUpperCase(StrListElem(AuxIdLine, ';', CShopTypePos));
{$ifndef NovartisPatch}
  OrderRec.UserName        :=               StrListElem(AuxIdLine, ';', CUserNamePos);
  OrderRec.CustomerEmail   :=               StrListElem(AuxIdLine, ';', CEMailPos);
  OrderRec.OrderExternalId :=               StrListElem(AuxIdLine, ';', CExtIdPos);
  OrderRec.OfferNo         :=               StrListElem(AuxIdLine, ';', COfferNoPos);
  OrderRec.OrderKindStr    := AnsiUpperCase(StrListElem(AuxIdLine, ';', COrderKindPos));
  OrderRec.PlateGroupingSt := Trim(         StrListElem(AuxIdLine, ';', CPlateGrpPos));
  OrderRec.Comment         := Trim(         StrListElem(AuxIdLine, ';', CCommentPos));

  SplitString (OrderRec.UserName, ',', OrderRec.UserName, OrderRec.Password);
{$endif}
end;

procedure TOrderParser.ParseItem(var ArticlesRec: TArticlesRec; var OrderRec: TOrderRec);
var
  ItemIdx : integer;
  TempOrderRec : TOrderRec;
begin
  ItemIdx := length (ArticlesRec.Items);
  SetLength (ArticlesRec.Items, ItemIdx + 1);

  ArticlesRec.Items[ItemIdx].OrderCount := GetIntAttribute (CAttrQuantity);
  WHILE XmlScan and HasParent (CItemLabel) DO BEGIN
    if XmlParser.CurPartType <> ptContent then
      continue;

    if AnsiSameText (XmlParser.CurName, CIdLabel) then
      ArticlesRec.Items[ItemIdx].ItemId  := XmlParser.CurContent
    else  if AnsiSameText (XmlParser.CurName, CIdAuxLabel) then
      ArticlesRec.Items[ItemIdx].ItemAuxId  := XmlParser.CurContent
    else if AnsiSameText (XmlParser.CurName, CContentLabel) then
      ArticlesRec.Items[ItemIdx].Description  := XmlParser.CurContent;
  end;

  if OrderRec.WebId = '' then
    FillOrderValues(ArticlesRec.Items[ItemIdx].ItemId, OrderRec)
  else begin
    FillOrderValues(ArticlesRec.Items[ItemIdx].ItemId, TempOrderRec);
    if OrderRec.WebID <> TempOrderRec.WebID then 
      raise EMultiWebIdError.Create ('More than one WebId in order mail');

  end;
end;

function TOrderParser.GetStrAttribute (AttrName : String) : string;
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

function TOrderParser.GetIntAttribute (AttrName : String) : integer;
var
  value : string;
begin
  value := GetStrAttribute (AttrName);
  result := Round (StrToRealDef (Value, ',',-1));

  Assert (result >= 0);
end;

function TOrderParser.GetNextContent(NodeName: string): string;
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

procedure TOrderParser.SetXml(const Value: string);
begin
  FXml := value;
  XmlParser.LoadFromBuffer (pChar(FXml));
end;

function TOrderParser.XmlScan : boolean;
begin
  result := XmlParser.Scan;
  if result then begin
    CASE XmlParser.CurPartType OF
      ptStartTag  : begin
                      AddChildNode (XmlParser.CurName);
                      CurrentNodeIsEmpty := false;
                    end;
      ptEmptyTag  : begin
                      AddChildNode (XmlParser.CurName);
                      CurrentNodeIsEmpty := true;
                    end;
      ptEndTag    : begin
                      RemoveChildNode (XmlParser.CurName);
                      CurrentNodeIsEmpty := false;
                    end;
    end;
  end;
end;

function TOrderParser.FindNext(NodeName: string): boolean;
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
{
      ptXmlProlog : BEGIN
                      Node := TrvDoc.Items.AddChild (Parent, '<?xml?>');
                      Node.ImageIndex := Img_Prolog;
                      EN := TElementNode.Create (StrSFPas (XmlParser.CurStart, XmlParser.CurFinal), NIL);
                      Node.Data := EN;
                    END;
      ptDtdc      : BEGIN
                      Node := TrvDoc.Items.AddChild (Parent, 'DTD');
                      Node.ImageIndex := Img_Dtd;
                      EN := TElementNode.Create (StrSFPas (XmlParser.CurStart, XmlParser.CurFinal), NIL);
                      Node.Data := EN;
                    END;
      ptEndTag    : BREAK;
      ptContent,
      ptCData     : BEGIN
                      if Length (XmlParser.CurContent) > 40
                        then Strg := Copy (XmlParser.CurContent, 1, 40) + #133
                        else Strg := XmlParser.CurContent;
                      Node := TrvDoc.Items.AddChild (Parent, string (Strg));  // !!!
                      Node.ImageIndex := Img_Text;
                      EN := TElementNode.Create (XmlParser.CurContent, NIL);
                      Node.Data := EN;
                    END;
      ptComment   : BEGIN
                      Node := TrvDoc.Items.AddChild (Parent, 'Comment');
                      Node.ImageIndex := Img_Comment;
                      SetStringSF (Strg, XmlParser.CurStart+4, XmlParser.CurFinal-3);
                      EN := TElementNode.Create (TrimWs (Strg), NIL);
                      Node.Data := EN;
                    END;
      ptPI        : BEGIN
                      Node := TrvDoc.Items.AddChild (Parent, string (XmlParser.CurName) + ' ' + string (XmlParser.CurContent));
                      Node.ImageIndex := Img_PI;
                    END;}
    END;
  end;
  result := false;
END;


procedure TOrderParser.AddChildNode(NodeName: string);
var
  NodeCount : integer;
begin
  NodeCount := length (CurrentNodeTree);
  if not CurrentNodeIsEmpty then begin
    inc (NodeCount);
    SetLength (CurrentNodeTree, NodeCount);
  end;
  CurrentNodeTree[NodeCount-1] := NodeName;
end;

procedure TOrderParser.RemoveChildNode(NodeName: string);
var
  NodeCount : integer;
begin
  NodeCount := length (CurrentNodeTree);
  if CurrentNodeIsEmpty then
    dec (NodeCount);

  assert (AnsiSameText (CurrentNodeTree[NodeCount-1], NodeName), 'Node-End not found in tree');
  dec (NodeCount);
  assert (NodeCount >= 0);
  SetLength (CurrentNodeTree, NodeCount);
end;

function TOrderParser.HasParent(NodeName: string): boolean;
var
  n : integer;
begin
  result := true;
  for n := 0 to length (CurrentNodeTree) - 1 do begin
    if AnsiSameText (CurrentNodeTree[n], NodeName) then
      exit;
  end;
  result := false;
end;

end.
