unit siphash;

interface

uses
  SysUtils,
  IdGlobal;

type
  TKey = array [0..15] of byte;
  TData =  TIdBytes; // array of byte;

  TSipKey = class
  private
    key : TKey;
    FToString: string;
    function getHighHalf: uint64;
    function getLowHalf: uint64;
    function GetToString: string;
  public
    constructor create (key : TKey);
    property ToString  : string read GetToString;
    property LeftHalf  : uint64 read getLowHalf;
    property RightHalf : uint64 read getHighHalf;
  end;

  TSipHash = class
  private
    class function lastBlock (data : TData; iteration : integer) : uint64;
  public
    class function digest(SipKey : TSipKey; Data : TData) : uint64;
  end;

implementation

type
  TState = class
  private
    v0 : uint64;
    v1 : uint64;
    v2 : uint64;
    v3 : uint64;
    procedure compress;
    procedure compressTimes (times : integer);
  public
    constructor create (SipKey : TSipKey);
    procedure processBlock(m : uint64);
    procedure finish;
    function digest : uint64;
  end;

{ TSipKey }

constructor TSipKey.create(key: TKey);
begin
  self.key := key;
end;

function TSipKey.getHighHalf: uint64;
begin
  move (key[8], result, 8);
end;

function TSipKey.getLowHalf: uint64;
begin
  move (key[0], result, 8);
end;

function TSipKey.GetToString: string;
begin
  result := IntToHex (getLowHalf, 16) + '-' + IntToHex (getHighHalf, 16);
end;


{ TSipHash }

class function TSipHash.digest(SipKey: TSipKey; data: TData): uint64;
var
  DataBlock : uint64;
  i         : integer;
  dataPtr   : integer;
  state     : TState;
  Iterations : integer;
begin
  state := TState.Create(SipKey);
  try
    iterations := length(data) div 8;

    for i := 0 to iterations-1 do begin
      dataPtr   := i * 8;
      move (data[dataPtr], datablock, 8);
      state.processBlock (datablock);
    end;

    datablock := lastBlock(data, Iterations);
    state.processBlock (datablock);

    state.finish;

    result := state.digest;

  finally
    state.free;
  end;
end;

class function TSipHash.lastBlock(data: TData; iteration: integer): uint64;
var
  last : uint64;
  dataLen : uint64;
  offset : integer;
  lastBlockLen : integer;
begin
  dataLen := length(data);
  last    := dataLen shl 56;

  lastBlockLen := datalen mod 8;
  offset  := iteration * 8;

  if lastBlockLen > 0 then
    move (data[offset], last, lastBlockLen);

  result := last;
end;

{ TState }

function RotateLeft (value : uint64; steps : integer) : uint64;
begin
  result := (value shl steps) or (value shl (64-steps));
end;

procedure TState.compress;
begin
  v0 := v0 + v1;
  v2 := v2 + v3;
  v1 := rotateLeft(v1, 13);
  v3 := rotateLeft(v3, 16);
  v1 := v1 xor v0;
  v3 := v3 xor v2;
  v0 := rotateLeft(v0, 32);
  v2 := v2 + v1;
  v0 := v0 + v3;
  v1 := rotateLeft(v1, 17);
  v3 := rotateLeft(v3, 21);
  v1 := v1 xor v2;
  v3 := v3 xor v0;
  v2 := rotateLeft(v2, 32);
end;

procedure TState.compressTimes(times: integer);
var
  n : integer;
begin
  for n := 1 to times do
    compress;
end;

constructor TState.create(SipKey: TSipKey);
var
  k0, k1 : uint64;
begin
  v0 := $736f6d6570736575;
  v1 := $646f72616e646f6d;
  v2 := $6c7967656e657261;
  v3 := $7465646279746573;

  k0 := SipKey.LeftHalf;
  k1 := SipKey.RightHalf;

  v0 := v0 xor k0;
  v1 := v1 xor k1;
  v2 := v2 xor k0;
  v3 := v3 xor k1;
end;

function TState.digest: uint64;
begin
  result := v0 xor
            v1 xor
            v2 xor
            v3;
end;

procedure TState.finish;
begin
  v2 := v2 xor $ff;
  compressTimes(4);
end;

procedure TState.processBlock(m: uint64);
begin
  v3 := v3 xor m;
  compressTimes(2);
  v0 := v0 xor m;
end;

end.