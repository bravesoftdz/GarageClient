unit CommunicationConst;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes;

const
  CCmdGetSession  = 'GETSESSION';
  CCmdQuitSession = 'QUIT';
  CParamCommand   = 'COMMAND';

  // Virtual parameters
  CParamSessionId = 'SESSIONID';  //  Seq 1
  CParamMessageIdx= 'MESSAGEIDX'; //  Seq 2
  CParamUserId    = 'USER';       //  Seq 3
  CParamPassword  = 'PASSWORD';   //  Seq 4
  CParamCmdHash   = 'HASH';       //  Seq 5


  CParamResult    = 'RESULT';
  CParamReply     = 'REPLY';
  CResultOk       = 'OK';

type
  TReplyResult    = (rrOK,
                     rrNoUser,
                     rrNoSession,
                     rrNoCommand,
                     rrFailed,
                     rrUnknown);

const
  CReplyResultKey : array[TReplyResult] of string =
                    ('OK',          //  rrOK,
                     'NO_USER',     //  rrNoUser,
                     'NO_SESSION',  //  rrNoSession
                     'NO_CMD',      //  rrNoCommand,
                     'FAILED',      //  rrFailed,
                     'UNDEF');      //  rrUnknown);

type
  TParameterScope = (psAll, psCmdOnly, psHashOnly);


type
  TCommandException = class (Exception)


  end;


implementation

end.

