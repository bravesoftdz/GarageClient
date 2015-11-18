(**
===============================================================================================
Name    : Main
===============================================================================================
Project : XmlScannerDemo
===============================================================================================
Subject : Demonstration of the TXmlScanner VCL Component
===============================================================================================
Author  : Dipl.-Ing. (FH) Stefan Heymann, Softwaresysteme, Tübingen, Germany
===============================================================================================

This is a simple demonstration of the destructor.de TXmlScanner VCL Component.
TXmlScanner (unit LibXmlComps) is a VCL wrapper for TXmlParser (unit LibXmlParser).

NOTE:
If you read in large XML files with this demo, the TTreeView easily gets problems with
its own memory handling. So if the app crashes, blame TTreeView (i.e. the underlying
Windows common control) first.

The size of XML file which you can process with TXmlScanner or TXmlParser is
only limited by installed memory.

Please send remarks, questions, bug reports to xmlparser@destructor.de

The official site to get the parser, the documentation and this demo is
    http://www.destructor.de

===============================================================================================
Date        Author Changes
-----------------------------------------------------------------------------------------------
2000-07-27  HeySt  Creation
2000-07-29  HeySt  Used the new TNvpList methods from LibXmlParser
*)

unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, LibXmlComps, LibXmlParser;

type
  TFrmMain = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    EdtFilename: TEdit;
    DlgOpen: TOpenDialog;
    BtnFilename: TButton;
    BtnParse: TButton;
    TreeView: TTreeView;
    MmoLog: TMemo;
    BtnView: TButton;
    procedure BtnParseClick(Sender: TObject);
    procedure BtnFilenameClick(Sender: TObject);
    procedure XmlScannerXmlProlog(Sender: TObject; XmlVersion,
      Encoding: String; Standalone: Boolean);
    procedure XmlScannerPI(Sender: TObject; Target, Content: String; Attributes: TAttrList);
    procedure XmlScannerStartTag(Sender: TObject; TagName: String; Attributes: TAttrList);
    procedure XmlScannerEndTag(Sender: TObject; TagName: String);
    procedure XmlScannerEmptyTag(Sender: TObject; TagName: String; Attributes: TAttrList);
    procedure XmlScannerComment(Sender: TObject; Comment: String);
    procedure XmlScannerContent(Sender: TObject; Content: String);
    procedure XmlScannerDtdRead(Sender: TObject; RootElementName: String);
    procedure XmlScannerAttList(Sender: TObject; ElemDef: TElemDef);
    procedure XmlScannerElement(Sender: TObject; ElemDef: TElemDef);
    procedure XmlScannerEntity(Sender: TObject; EntityDef: TEntityDef);
    procedure XmlScannerNotation(Sender: TObject;
      NotationDef: TNotationDef);
    procedure BtnViewClick(Sender: TObject);
    procedure XmlScannerLoadExternal(Sender: TObject; SystemId, PublicId,
      NotationId: String; var Result: TXmlParser);
    procedure XmlScannerDtdError(Sender: TObject; ErrorPos: PAnsiChar);
  private
  public
    CurNode : TTreeNode;
  end;

var
  FrmMain: TFrmMain;

(*
===============================================================================================
implementation
===============================================================================================
*)

implementation

{$R *.DFM}

procedure TFrmMain.BtnParseClick(Sender: TObject);
begin
  // --- Clear Log
  MmoLog.Lines.Clear;

  Screen.Cursor := crHourGlass;
  TreeView.Items.BeginUpdate;
  TRY
    // --- Clear TreeView
    TreeView.Items.Clear;

    // --- Load and Scan XML document
    CurNode := NIL;
    XmlScanner.Filename := EdtFilename.Text;
    XmlScanner.Execute;

  FINALLY
    // --- Show Tree
    TreeView.Items.EndUpdate;
    Screen.Cursor := crDefault;
    END;
end;


procedure TFrmMain.BtnFilenameClick(Sender: TObject);
          // Show "Open File" dialog
begin
  IF DlgOpen.Execute THEN BEGIN
    EdtFilename.Text := DlgOpen.Filename;
    BtnParse.SetFocus;
    END;
end;


procedure TFrmMain.XmlScannerXmlProlog(Sender: TObject; XmlVersion, Encoding: String; Standalone: Boolean);
          // This is called when the scanner has read in the XML prolog
          // XmlVersion: XML version number
          // Encoding:   The encoding declared in the Prolog
          // Standalone: TRUE if 'yes' was specified in the Prolog
begin
  TreeView.Items.AddChild (CurNode, 'XML Prolog: Version='+XmlVersion+' Encoding='+Encoding);
end;


procedure TFrmMain.XmlScannerPI(Sender: TObject; Target, Content: String; Attributes: TAttrList);
          // This is called when the scanner has read a Processing Instruction (PI)
begin
  TreeView.Items.AddChild (CurNode, 'Processing Instruction: '+Content);
end;


procedure TFrmMain.XmlScannerStartTag(Sender: TObject; TagName: String; Attributes: TAttrList);
          // This is called when the scanner has read a Start Tag
          // TagName:    Name of the Start Tag (case sensitive)
          // Attributes: List of Attributes (TAttr Objects)
VAR
  i : integer;
begin
  CurNode := TreeView.Items.AddChild (CurNode, 'Element "'+TagName+'"');
  FOR i := 0 TO Attributes.Count-1 DO
    TreeView.Items.AddChild (CurNode, '  * Attribute ' + string (Attributes.Name (i)) + '= ' +string (Attributes.Value(i)));
end;


procedure TFrmMain.XmlScannerEndTag(Sender: TObject; TagName: String);
          // This is called when the scanner has read an End tag
          // TagName: Name of the End Tag (case sensitive)
begin
  IF CurNode <> NIL THEN
    CurNode := CurNode.Parent;
end;


procedure TFrmMain.XmlScannerEmptyTag(Sender: TObject; TagName: String; Attributes: TAttrList);
          // This is called when the scanner has read an XML Empty-Element Tag (e.g. <BR/>
          // TagName: Name of the Tag (case sensitive)
          // Attributes: List of Attributes (TAttr Objects)
VAR
  i : integer;
begin
  CurNode := TreeView.Items.AddChild (CurNode, 'Element "'+TagName+'" (Empty)');
  FOR i := 0 TO Attributes.Count-1 DO
    TreeView.Items.AddChild (CurNode, '  * Attribute ' + string (Attributes.Name (i)) + '=' + string (Attributes.Value(i)));
  CurNode := CurNode.Parent;
end;


procedure TFrmMain.XmlScannerComment(Sender: TObject; Comment: String);
          // This is called when the scanner has read a Comment
begin
  TreeView.Items.AddChild (CurNode, 'Comment');
end;


procedure TFrmMain.XmlScannerContent(Sender: TObject; Content: String);
          // This is called when the scanner has read element text content
          // The "OnCData" event of XmlScanner also points to this routine
          // Content: The text content
begin
  Content := StringReplace (Content, #13, ' ', [rfReplaceAll]);
  Content := StringReplace (Content, #10, '',  [rfReplaceAll]);
  TreeView.Items.AddChild  (CurNode, Content);
end;

procedure TFrmMain.XmlScannerDtdRead(Sender: TObject;
  RootElementName: String);
begin
  TreeView.Items.AddChild (CurNode, 'DTD: '+RootElementName);
end;

procedure TFrmMain.XmlScannerAttList(Sender: TObject; ElemDef: TElemDef);
VAR
  I  : INTEGER;
  AD : TAttrDef;
  S  : STRING;
begin
  MmoLog.Lines.Add ('OnAttList: ' + string (ElemDef.Name) + ': ' + string (ElemDef.Definition));
  FOR I := 0 TO ElemDef.Count-1 DO BEGIN
    AD := TAttrDef (ElemDef [I]);
    IF AD.AttrType IN [atNotation, atEnumeration] THEN
      S  := '  - ' + string (AD.Name) + ': ' + string (AD.TypeDef) +
            ' Default='+AnsiQuotedStr (string (AD.Value), '''')
    ELSE
      S  := '  - ' + string (AD.Name) + ': ' + string (CAttrType_Name [AD.AttrType])+
            ' Default='+AnsiQuotedStr (string (AD.Value), '''');
    MmoLog.Lines.Add (S);
    END;
end;

procedure TFrmMain.XmlScannerElement(Sender: TObject; ElemDef: TElemDef);
begin
  MmoLog.Lines.Add ('OnElement: ' + string (ElemDef.Name) + ': ' + string (ElemDef.Definition));
end;

procedure TFrmMain.XmlScannerEntity(Sender: TObject;
  EntityDef: TEntityDef);
begin
  MmoLog.Lines.Add ('OnEntity: ' + string (EntityDef.Name) + ' = ' + AnsiQuotedStr (string (EntityDef.Value), ''''));
end;

procedure TFrmMain.XmlScannerNotation(Sender: TObject;  NotationDef: TNotationDef);
begin
  MmoLog.Lines.Add ('OnNotation: ' + string (NotationDef.Name) + ': ' + string (NotationDef.Value));
end;

procedure TFrmMain.BtnViewClick(Sender: TObject);
begin
  WinExec (PAnsiChar ('NOTEPAD '+AnsiString (EdtFilename.Text)), sw_ShowNormal);
end;

procedure TFrmMain.XmlScannerLoadExternal(Sender: TObject; SystemId, PublicId, NotationId: String; var Result: TXmlParser);
begin
  Result := TXmlParser.Create;
  IF FileExists (SystemID)
    THEN Result.LoadFromFile (SystemID)
    ELSE ShowMessage ('LoadExternal: This code is unable to load "' + SystemId + '" but you can change the OnLoadExternal event handler method to do it.');
end;

procedure TFrmMain.XmlScannerDtdError(Sender: TObject; ErrorPos: PAnsiChar);
begin
  MmoLog.Lines.Add ('OnDtdError: ' + Copy (String (ErrorPos), 1, 50));
end;

end.


