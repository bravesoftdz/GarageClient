unit IntfMessageParser;

interface

uses
  System.Generics.Collections,
  CommunicationTypes,
  CommunicationConst;

type
  IMessageParser = interface
  ['{D2590AD3-B904-4B2D-943E-01DC5512D252}']
    function  GetXml: String;
    procedure SetXml(const Value: String);
    procedure Parse(ResultData : TResultDictionary);
    function  FindNextValuePair (var Key, Value : string) : boolean;
    function  TransferResult : TReplyResult;
    function  HasError: boolean;
    function  GetError: string;
    property  XML : String read GetXml write SetXml;
  end;


implementation

end.
