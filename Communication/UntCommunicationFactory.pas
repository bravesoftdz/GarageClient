unit UntCommunicationFactory;

interface
uses
  System.SysUtils,
  UntArduinoCommunication,
  CommunicationConst,
  UntArduinoAdminData,
  UntMessageParser,
  UntClientSession,
  UntClientConfig,
  UntIpAddress,
  UntCommand,
  UntCmdConnect;

type
  TCommunicatorFactory = class
  private
  public
    class function GetCommunicator(AdminData: TArduinoAdminData): TArduinoCommunication;
    class function GetDeviceCommunicator(ClientConfig : TClientConfig) : TArduinoCommunication;
  end;


implementation

class function TCommunicatorFactory.GetCommunicator(AdminData : TArduinoAdminData) : TArduinoCommunication;
var
  Host : string;
  Parser : TMessageParser;
  Cmd    : TConnectCommand;
begin
  Host := AdminData.IpAddress.AsString;
  Parser := TMessageParser.Create;
  Cmd    := TConnectCommand.Create;
  Cmd.Init;

  result := TArduinoCommunication.Create(Host, Parser, Cmd);
end;



{ TCommunicatorFactory }

class function TCommunicatorFactory.GetDeviceCommunicator(ClientConfig: TClientConfig): TArduinoCommunication;
var
  Ip     : TIpAddress;
  Host   : string;
  Parser : TMessageParser;
  Cmd    : TConnectCommand;
begin
  if not TClientSession.Instance.Initialized then begin
    TClientSession.Instance.Init(Clientconfig.UserId, ClientConfig.SipKeyObject);
  end;

  Ip     := TIpAddress.Create();
  Ip.Address := ClientConfig.DeviceIp;
  Host   := Ip.AsString;

  Parser := TMessageParser.Create;
  Cmd    := TConnectCommand.Create;
  Cmd.Init;

  result := TArduinoCommunication.Create(Host, Parser, Cmd);
end;

end.
