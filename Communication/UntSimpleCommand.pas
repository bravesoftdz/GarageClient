unit UntSimpleCommand;

interface
uses
  CommunicationTypes,
  CommunicationConst,
  IntfClientConfig,
  UntCommand;

type

  TSimpleCommand = class (TCommand)
  protected
    NeedsUserKey : Boolean;
  public
    constructor Create(Command : string; NeedsUserKey : Boolean);
    procedure Init; override;
  end;


implementation


{ TSimpleCommand }

constructor TSimpleCommand.Create(Command: string; NeedsUserKey : Boolean);
begin
  inherited Create();
  self.Command      := Command;
  self.NeedsUserKey := NeedsUserKey;
end;

procedure TSimpleCommand.Init;
begin
  inherited init;

  AddVirtualParameter(CParamSessionId , psHashOnly);
  AddVirtualParameter(CParamMessageIdx, psHashOnly);
  AddVirtualParameter(CParamUserId    , psHashOnly);
  if NeedsUserKey then
    AddVirtualParameter(CParamPassword  , psHashOnly);
  AddVirtualParameter(CParamCmdHash   , psCmdOnly);
end;

end.
