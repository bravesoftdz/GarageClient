unit UntCmdConnect;

interface

uses
  CommunicationConst,
  CommunicationTypes,
  UntCommand;

type

  TConnectCommand = class (TCommand)
  private
  public
    constructor Create;
    procedure Init; override;
  end;

implementation

{ TSetupCommand }

constructor TConnectCommand.Create;
begin
  inherited Create;
  Self.Command := CCmdConnect;
end;

procedure TConnectCommand.Init;
begin
  inherited Init;

  AddVirtualParameter(CParamUserId, psCmdOnly);
end;

end.

