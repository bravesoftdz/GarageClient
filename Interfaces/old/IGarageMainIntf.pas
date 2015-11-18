unit IGarageMainIntf;

interface

type
  TGarageStatus = (gsUndefined, gsOpen, gsClosed, gsIntermediate);


  IGarageMain = interface
    ['{E7C229C3-79E6-47BD-81FF-3B4B19CDC21C}']
    function GetGarageStatus : TGarageStatus;
    procedure SetGarageStatus (const Value : TGarageStatus);
    procedure Open;
    procedure Close;
    property GarageStatus : TGarageStatus read GetGarageStatus write SetGarageStatus;
  end;

implementation

end.
