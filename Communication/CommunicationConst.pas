unit CommunicationConst;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes;

const
  // Arduino commands
  CCmdConnect        = 'CONNECT';
  CCmdQuitSession    = 'QUIT';
  CCmdGetStatus      = 'GETSTATE';
  CCmdUser           = 'USER';
  CCmdDeactivateUser = 'DEACTIVATEUSER';
  CCmdActivateUser   = 'ACTIVATEUSER';
  CCmdOpen           = 'OPEN';
  CCmdClose          = 'CLOSE';
  CParamCommand      = 'COMMAND';

  // Virtual parameters
  CParamSessionId    = 'SESSIONID';  //  Seq 1
  CParamMessageIdx   = 'MESSAGEIDX'; //  Seq 2
  CParamUserId       = 'USERID';     //  Seq 3
  CParamPassword     = 'USERKEY';    //  Seq 4
  CParamCmdHash      = 'HASH';       //  Seq 5

  //  User-Command
  CParamUUserIdx     = 'USERIDX';    //  Seq 1
  CParamUUserId      = 'SETUSERID';  //  Seq 2
  CParamUUserKey     = 'SETUSERKEY'; //  Seq 3
  CParamUUserMode    = 'USERMODE';   //  Seq 4

  //Reply node names
  CParamResult       = 'RESULT';
  CParamReply        = 'REPLY';
  CParamError        = 'ERROR';
  CParamGarageState  = 'STATE';
  CResultOk          = 'OK';
  CResultError       = 'ERROR';

  // Device assignment
  //CParamUserId     = 'USERID'; duplicate
  CDocAssign         = 'ASSIGN';

  //XML-Nodes
  CNodeRoot          = 'Root';
  CNodeData          = 'Data';
  CNodeQueryResult   = CParamResult;
  CNodeIpAddress     = 'IpAddress';
  CNodeConfiguration = 'Configuration';
  CNodeSipKey        = 'SipKey';
  CNodeUserId        = 'UserId';
  CNodeUserMode      = 'UserMode';
  CNodeUserName      = 'UserName';

  //XML Attributes
  CAttrStatus        = 'Status';
  CAttrId            = 'Id';

const
  // Port for Device Assignment
  CAssignPort     = 59863;


const
  CMaxConnectRepeats =   3;
  CMaxConnectDelay   = 500;
  CMinConnectDelay   =  10;


implementation

end.

