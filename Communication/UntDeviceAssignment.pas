unit UntDeviceAssignment;

interface
uses
  System.SysUtils, System.Classes,
  ActiveX, Xml.XmlDoc, Xml.XmlIntf,
  IdHTTP, IdHTTPServer, IdCustomHTTPServer, IdContext, IdComponent, IdGlobal, IdSocketHandle, IdStack,
  CommunicationConst,
  UntArduinoAdminData;

type
  TAssignmentStatus = (asUnknown, asStarting, asBound, asConnected, asAssigned, asError);

  // HTTP Server for providing
  TDeviceAssignment = class
  private
    AdminData : TArduinoAdminData;
    UserIdx   : integer;
    Server    : TIdHttpServer;
    FStatusChanged: TNotifyEvent;
    FIpAddress: string;
    FStatus: TAssignmentStatus;
    FErrorText: string;
    FUserId : integer;
    procedure HttpGetHandler (AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure HttpStatusHandler (ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
    procedure HttpErrorHandler (AContext: TIdContext; AException: Exception);
    procedure HttpAfterBindingHandler (ASender: TObject);
    procedure OnStatus;
    procedure EvaluateRequest(Document: string; Parameters: TStrings);
    function  GenerateReply (Valid : boolean; Msg : string): string;
  public
    constructor Create(AdminData : TArduinoAdminData; UserIdx : integer);
    procedure Start;
    procedure Stop;
    property  OnStatusChanged : TNotifyEvent      read FStatusChanged write FStatusChanged;
    property  IpAddress       : string            read FIpAddress;
    property  Status          : TAssignmentStatus read FStatus;
    property  ErrorText       : string            read FErrorText;
    property  UserId          : integer           read FUserId;
  end;


implementation

{ TDeviceAssignment }

constructor TDeviceAssignment.Create(AdminData: TArduinoAdminData; UserIdx: integer);
begin
  self.AdminData := AdminData;
  self.UserIdx   := UserIdx;

  Server := TIdHttpServer.Create(nil);
  Server.OnCommandGet := HttpGetHandler;
  Server.OnException  := HttpErrorHandler;
  Server.OnStatus     := HttpStatusHandler;
  Server.OnAfterBind  := HttpAfterBindingHandler;

  Server.DefaultPort  := CAssignPort;
  Server.MaxConnections := 1;
  Server.ReuseSocket  := rsTrue;
end;

procedure TDeviceAssignment.HttpAfterBindingHandler(ASender: TObject);
begin
  FUserId := AdminData.GenerateUserid;
  FStatus := asBound;
  OnStatus;
end;

procedure TDeviceAssignment.HttpErrorHandler(AContext: TIdContext; AException: Exception);
begin
  FStatus    := asError;
  FErrorText := AException.Message;
end;

procedure TDeviceAssignment.HttpGetHandler(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  Valid : boolean;
  Msg   : string;
begin
  if Status <> asError then begin
    try
      EvaluateRequest(ARequestInfo.Document, ARequestInfo.Params);
      Valid := true;
      Msg   := '';
    except
      on E:Exception do begin
        Valid := false;
        Msg   := E.Message;
      end;
    end;
  end
  else begin
    Valid := false;
    Msg   := ErrorText;
  end;

  AResponseInfo.ContentText := GenerateReply(Valid, Msg);
  AResponseInfo.ContentType := 'text/xml; charset=UTF-8';

  if Valid then
    FStatus := asAssigned
  else
    FStatus := asError;
  OnStatus;
end;

procedure TDeviceAssignment.EvaluateRequest(Document : string; Parameters : TStrings);
var
  DeviceId    : integer;
begin
  Parameters.NameValueSeparator := '=';

  DeviceId := StrToIntDef(Parameters.Values[CParamUserId], -1);

  if Pos('/', Document) = 1 then
    Delete(Document, 1, 1);

  if not SameText(Document, CDocAssign) then
    raise Exception.Create('Wrong document ' + Document);

  if DeviceId <> FUserId then
    raise Exception.Create('Parameter error');
end;

{
<Root>
  <RESULT Status="OK"/>
  <Data Id="IpAddress">172.16.1.177</Data>
  <Data Id="SipKey">EB3899DF5F5B79F775F59DB9F3FE9B8F</Data>
  <Data Id="UserId">7893</Data>
  <Data Id="UserMode">2</Data>
  <Data Id="UserName">Admin</Data>
</Root
}

function TDeviceAssignment.GenerateReply (Valid : boolean; Msg : string) : string;
var
  XMLCFG: TXMLDocument;
  RootNode  : IXMLNode;
  Node  : IXMLNode;
begin
  CoInitialize(nil);
  XMLCFG := TXMLDocument.Create(nil);
  try
    XMLCFG.Active := True;
    XMLCFG.Version := '1.0';
    XMLCFG.Encoding := 'UTF-8';
    XMLCFG.Options := [doNodeAutoIndent];

    RootNode := XMLCFG.AddChild(CNodeRoot);


    Node := RootNode.AddChild(CNodeQueryResult);
    if Valid then begin

      Node.SetAttribute(CAttrStatus, CResultOk);
      Node.NodeValue := Msg;

      Node := RootNode.AddChild(CNodeData);
      Node.SetAttribute(CAttrId, CNodeIpAddress);
      Node.NodeValue := AdminData.IpAddress.AsString;

      Node := RootNode.AddChild(CNodeData);
      Node.SetAttribute(CAttrId, CNodeSipKey);
      Node.NodeValue := AdminData.SipKey.AsString;

      Node := RootNode.AddChild(CNodeData);
      Node.SetAttribute(CAttrId, CNodeUserId);
      Node.NodeValue := UserId;

      Node := RootNode.AddChild(CNodeData);
      Node.SetAttribute(CAttrId, CNodeUserMode);
      Node.NodeValue := AdminData.UserMode[UserIdx];

      Node := RootNode.AddChild(CNodeData);
      Node.SetAttribute(CAttrId, CNodeUserName);
      Node.NodeValue := AdminData.UserName[UserIdx];
    end
    else begin
      Node.SetAttribute(CAttrStatus, CResultError);
      Node.NodeValue := Msg;
    end;

    result := XMLCFG.Xml.Text;
  finally
//    XMLCFG.Free;
    CoUninitialize;
  end;
end;

procedure TDeviceAssignment.HttpStatusHandler(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
begin

end;

procedure TDeviceAssignment.OnStatus;
begin
  if Assigned(OnStatusChanged) then
    OnStatusChanged(self);
end;

procedure TDeviceAssignment.Start;
var
  Addresses : TStringList;
begin
  Addresses := TStringList.Create;
  TIdStack.IncUsage;
  try
    GStack.AddLocalAddressesToList(Addresses);
    FIpAddress := Addresses.CommaText;
  finally
    TIdStack.DecUsage;
  end;

  FStatus := asStarting;
  OnStatus;
  Server.Active := true;
end;

procedure TDeviceAssignment.Stop;
begin
  Server.StopListening;
end;

end.
