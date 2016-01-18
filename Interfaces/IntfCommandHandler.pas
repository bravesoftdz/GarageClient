unit IntfCommandHandler;

interface

uses
  CommunicationConst,
  CommunicationTypes;

type
  ICommandHandler = interface

    procedure CmdReplyHandler (Sender : TObject; ReplyResult : TReplyResult; var Reply : TResultDictionary);
    procedure CmdErrorHandler (Sender : TObject; Context : string; ErrorMessage : string);
  end;


implementation

end.
