{ $define SIP_DEBUG}
{ $define SIP_DEBUG_B}
{ $define SIP_DEBUG_R}
{ $define SIP_DEBUG_C}
unit UntSipHash;

interface


uses
//  Windows,
  System.SysUtils, Classes,
  IdGlobal;

type
  TKey      = array [0..15] of byte;
  T64BitKey = array[0..1] of uint64;
  TData     =  TIdBytes; // array of byte;

  TSipKey = class
  private
    FKey   : TKey;
    FIsEmpty: boolean;
    function GetRightHalf: uint64;
    function GetLeftLalf: uint64;
    function GetString: string;
    procedure SetString(const Value: string);
    function GetHalfAt(idx: integer): uint64;
    function GetKey64Bit: T64BitKey;
    function GetReversedKey: TKey;
    function GetEntryptionHalf(idx: integer): uint64;
  public
    constructor create (key : TKey); overload;
    constructor create (); overload;
    procedure CopyFrom (other : TSipKey); overload;
    procedure CopyFrom (key : TKey); overload;
    procedure Generate;
    procedure Clear;
    procedure Revert;
    property IsEmpty     : boolean read FIsEmpty;
    property AsString    : string  read GetString write SetString;
    property LeftHalf    : uint64  read GetLeftLalf;
    property RightHalf   : uint64  read GetRightHalf;
    property Key         : TKey    read FKey;
    property ReversedKey : TKey    read FKey;
    property EncryptionPart[idx : integer] : uint64 read GetEntryptionHalf;
  end;

  TSipHash = class
  private
    class function LastBlock (data : TData; iteration : integer) : uint64;
  public
    class function Digest(SipKey : TSipKey; Data : TData) : uint64;
  end;

var
  Log : TStrings = nil;

implementation

procedure print64(name : string; value: uint64);
begin
  if Log <> nil then log.Add(Name + ': ' + IntToHex(value, 16));
end;



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
  self.Fkey := key;
end;

procedure TSipKey.CopyFrom(other: TSipKey);
begin
  CopyFrom(other.key);
end;

procedure TSipKey.CopyFrom(key: TKey);
begin
  move (key, self.Fkey, sizeOf(TKey));
end;

constructor TSipKey.create;
begin
  FIsEmpty := true;
end;

procedure TSipKey.Generate;
var
  n: Integer;
begin
  for n := 0 to 15 do
    FKey[n] := System.Random(256);

  FIsEmpty := false;
end;

procedure TSipKey.Clear;
var
  n: Integer;
begin
  for n := 0 to 15 do
    FKey[n] := 0;
  FIsEmpty := true;
end;

function TSipKey.GetRightHalf: uint64;
begin
  move (key[8], result, 8);
end;

function TSipKey.GetLeftLalf: uint64;
begin
  move (key[0], result, 8);
end;

function TSipKey.GetEntryptionHalf(idx: integer): uint64;
//this SipHash implementation needs the keys in reverse order
begin
  if idx in [0..1] then
    result := GetHalfAt((1-idx) * 8)
  else
    raise Exception.Create('ilegal index');

end;

function TSipKey.GetHalfAt(idx : integer) : uint64;
var
  ResultParts : array[0..7] of byte absolute result;
  n: Integer;
begin
  result := 0;
//this SipHash implementation needs the keys in reverse order
  for n := 0 to 7 do
    ResultParts[7-n] := Fkey[n + idx];
end;

function TSipKey.GetKey64Bit: T64BitKey;
begin

end;

function TSipKey.GetString: string;
var
  lowHalf, highHalf : uint64;
begin
  LowHalf  := GetLeftLalf;
  HighHalf := GetRightHalf;

  result := IntToHex (HighHalf, 16) + IntToHex (LowHalf, 16);
end;


function TSipKey.GetReversedKey: TKey;
var
  n : integer;
begin
  for n := 0 to 15 do
    result[15-n] := Fkey[n];
end;

procedure TSipKey.Revert;
begin
  CopyFrom(ReversedKey);
end;

procedure TSipKey.SetString(const Value: string);
var
  n : integer;
  part : string;
begin
  if Value = '' then begin
    Clear;
    exit;
  end;

  if length(Value) <> 32 then
    raise Exception.Create('Illegal Sip key');

  for n := 0 to 15 do begin
    part := '$' + copy (Value, 31-(n * 2), 2);
    Fkey[n] := StrToInt(part);
  end;
  FIsEmpty := false;
end;

{ TSipHash }



class function TSipHash.Digest(SipKey: TSipKey; data: TData): uint64;
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
  result := (value shr steps) or (value shl (64-steps));
end;

function RotateRight (value : uint64; steps : integer) : uint64;
begin
  result := (value shl steps) or (value shr (64-steps));
end;

procedure TState.compress;
begin
  v0 := v0 + v1;
  v2 := v2 + v3;
{$ifdef SIP_DEBUG_C}
  print64('v0_h1', v0);
  print64('v1_h1', v1);
  print64('v2_h1', v2);
  print64('v3_h1', v3);
{$endif SIP_DEBUG_C}
  v1 := RotateRight(v1, 13);
  v3 := rotateRight(v3, 16);
{$ifdef SIP_DEBUG_C}
  print64('v1_h2', v1);
  print64('v3_h2', v3);
{$endif SIP_DEBUG_C}
  v1 := v1 xor v0;
  v3 := v3 xor v2;
{$ifdef SIP_DEBUG_C}
  print64('v0_h3', v0);
  print64('v1_h3', v1);
  print64('v2_h3', v2);
  print64('v3_h3', v3);
{$endif SIP_DEBUG_C}
  v0 := rotateRight(v0, 32);
{$ifdef SIP_DEBUG_C}
  print64('v0_h4', v0);
{$endif SIP_DEBUG_C}
  v2 := v2 + v1;
  v0 := v0 + v3;
  v1 := rotateRight(v1, 17);
  v3 := rotateRight(v3, 21);
{$ifdef SIP_DEBUG_C}
  print64('v0_h5', v0);
  print64('v1_h5', v1);
  print64('v2_h5', v2);
  print64('v3_h5', v3);
{$endif SIP_DEBUG_C}
  v1 := v1 xor v2;
  v3 := v3 xor v0;
{$ifdef SIP_DEBUG_C}
  print64('v0_h6', v0);
  print64('v1_h6', v1);
  print64('v2_h6', v2);
  print64('v3_h6', v3);
{$endif SIP_DEBUG_C}
  v2 := rotateRight(v2, 32);
{$ifdef SIP_DEBUG_C}
  print64('v2_h7', v2);
{$endif SIP_DEBUG_C}
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
{$ifdef SIP_DEBUG_B}
	if Log <> nil then Log.Add('Key: ' + SipKey.AsString);
{$endif SIP_DEBUG_B}

  v0 := $736f6d6570736575;
  v1 := $646f72616e646f6d;
  v2 := $6c7967656e657261;
  v3 := $7465646279746573;

{$ifdef SIP_DEBUG_A}
  print64('v0_1', v0);
  print64('v1_1', v1);
  print64('v2_1', v2);
  print64('v3_1', v3);
{$endif SIP_DEBUG}

  k0 := SipKey.EncryptionPart[0];
  k1 := SipKey.EncryptionPart[1];

{$ifdef SIP_DEBUG_B}
  print64('m1', k0);
  print64('m2', k1);
{$endif SIP_DEBUG_B}

  v0 := v0 xor k0;
  v1 := v1 xor k1;
  v2 := v2 xor k0;
  v3 := v3 xor k1;

{$ifdef SIP_DEBUG}
  print64('v0_2', v0);
  print64('v1_2', v1);
  print64('v2_2', v2);
  print64('v3_2', v3);
{$endif SIP_DEBUG}
end;

function TState.digest: uint64;
begin
  result := v0 xor
            v1 xor
            v2 xor
            v3;
{$ifdef SIP_DEBUG_R}
	print64('Result', result);
{$endif SIP_DEBUG_R}

end;

procedure TState.finish;
begin
  v2 := v2 xor $ff;
  compressTimes(4);

{$ifdef SIP_DEBUG}
	print64('v0_e', v0);
	print64('v1_e', v1);
	print64('v2_e', v2);
	print64('v3_e', v3);
{$endif SIP_DEBUG}

end;

procedure TState.processBlock(m: uint64);
begin
{$ifdef SIP_DEBUG_B}
	print64('Hash', m);
{$endif SIP_DEBUG_B}

  v3 := v3 xor m;
  compressTimes(2);
  v0 := v0 xor m;

{$ifdef SIP_DEBUG}
	print64('v0_h', v0);
	print64('v1_h', v1);
	print64('v2_h', v2);
	print64('v3_h', v3);
{$endif SIP_DEBUG}

end;

end.
