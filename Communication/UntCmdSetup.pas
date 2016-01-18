unit UntCmdSetup;

interface

uses
  CommunicationConst,
  UntCommand;

type

  TSetupCommand = class (TCommand)
  private
  public
    constructor Create;
    procedure InitOverride;
  end;

implementation

{ TSetupCommand }

constructor TSetupCommand.Create;
begin

end;

procedure TSetupCommand.InitOverride;
begin
  AddParameter (CParamCommand, CCmdGetSession);
  AddVirtualParameter(CParamUserId, psCmdOnly);
end;

end.

