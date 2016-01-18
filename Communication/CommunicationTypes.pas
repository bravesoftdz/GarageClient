unit CommunicationTypes;

interface
uses
  System.Generics.Collections,
  System.SysUtils;


type
  TReplyResult    = (rrOK,
                     rrNoUser,
                     rrNoSession,
                     rrNoCommand,
                     rrFailed,
                     rrCommunication,
                     rrUnknown);

  TGarageDoorStatus = (gdsVoid,
                       gdsOpen,
                       gdsIntermediate,
                       gdsClosed);


  TParameterScope = (psAll, psCmdOnly, psHashOnly);


  ECommandException = class (Exception)
  end;

  TResultDictionary = TDictionary<String, String>;

  TRepliedEvent = procedure (Sender : TObject; ReplyResult : TReplyResult; var Reply : TResultDictionary) of object;
  TErrorEvent   = procedure (Sender : TObject; Context : string; ErrorMessage : string) of object;

const
  CReplyResultKey : array[TReplyResult] of string =
                    ('OK',            //  rrOK,
                     'NO_USER',       //  rrNoUser,
                     'NO_SESSION',    //  rrNoSession
                     'NO_CMD',        //  rrNoCommand,
                     'FAILED',        //  rrFailed,
                     'COMMUNICATION', //  rrCommunication
                     'UNDEF');        //  rrUnknown);

  CReplyResultText : array[TReplyResult] of string =
                    ('OK',                      //  rrOK,
                     'No user given',           //  rrNoUser,
                     'No session available',    //  rrNoSession
                     'No command found',        //  rrNoCommand,
                     'Command failed',          //  rrFailed,
                     'Communication error',     //  rrCommunication
                     'Unknown result');         //  rrUnknown);

  CGarageDoorStatusKey : array[TGarageDoorStatus] of string =
                    ('void',    // gdsVoid, , ,
                     'open',    // gdsOpen
                     'unknown', // gdsIntermediate
                     'closed'   // gdsClosed
                     );

  CGarageDoorStatusText : array[TGarageDoorStatus] of string =
                    ('unknown',      // gdsVoid,
                     'open',         // gdsOpen
                     'intermediate', // gdsIntermediate
                     'closed'        // gdsClosed
                     );

implementation

end.
