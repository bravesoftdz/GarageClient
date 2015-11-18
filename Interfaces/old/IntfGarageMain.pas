unit IntfGarageMain;

interface

uses
  System.Classes;

type
  TGarageStatus = (gsUndefined, gsOpen, gsClosed, gsIntermediate);

const
  CGarageStatus_Key : array[TGarageStatus] of string = ('', 'Open', 'Closed', 'unknown');

type
  IGarageMain = interface
    ['{E7C229C3-79E6-47BD-81FF-3B4B19CDC21C}']
    function GetGarageStatus : TGarageStatus;
    procedure SetGarageStatus (const Value : TGarageStatus);
    function GetOnStatusChanged: TNotifyEvent;
    procedure SetOnStatusChanged(const Value: TNotifyEvent);
    procedure Open;
    procedure Close;
    property GarageStatus : TGarageStatus read GetGarageStatus write SetGarageStatus;
    property OnStatusChanged : TNotifyEvent read GetOnStatusChanged write SetOnStatusChanged;
  end;

implementation

end.
