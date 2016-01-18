unit UntStringHasher;

interface
uses
  System.SysUtils, System.Classes, System.ByteStrings,
  UntSipHash;

type

	/// <summary>
	/// Wrapper class to convert widestring to ansi string and pass byte by byte to SipHash.
	/// </summary>
  TStringHasher = class
  private
    /// <summary>
    /// Byte aray for current data to be hashed
    /// </summary>
    HashData : TData;

    /// <summary>
    /// Logging container
    /// </summary>
    Log : TStringList;

    /// <summary>
    /// Initialize SipHash logger
    /// </summary>
    Procedure SetLog;

    /// <summary>
    /// Remove Logger from sipHash
    /// </summary>
    procedure RemoveLog;

    /// <summary>
    /// Hash this string
    /// </summary>
    procedure TransferString(Value : string);
  public
    constructor Create;
    destructor Destroy; override;

    /// <summary>
    /// Clear current hashData
    /// </summary>
    procedure Clear;

    /// <summary>
    /// Hash a single string
    /// </summary>
  	/// <param name="Value">Value to hash</param>
    procedure AddString(Value : String);

    /// <summary>
    /// Hash this key - value pair
    /// </summary>
  	/// <param name="Key">Key to hash</param>
  	/// <param name="Value">Value to hash</param>
    procedure AddKeyValuePair(Key, Value : String);

    /// <summary>
    /// Calculate the hash value from the data added so far
    /// </summary>
  	/// <param name="HashKey">The secret hash key</param>
  	/// <returns>The hash as 16-char hex string</returns>
    function GetHash(HashKey: TSipKey): string;
  end;


implementation

{ TStringHasher }

constructor TStringHasher.Create;
begin
  Log := TStringList.Create;
end;

destructor TStringHasher.Destroy;
begin
  Log.Free;
end;

procedure TStringHasher.Clear;
begin
  Log.Clear;
  SetLength(HashData, 0);
end;

procedure TStringHasher.AddKeyValuePair(Key, Value: String);
begin
  SetLog;
  try
    Log.Add('Hashing ' + Key + ' ' + Value);
    TransferString(Key);
    TransferString(Value);
  finally
    RemoveLog;
  end;
end;

procedure TStringHasher.AddString(value: String);
begin
  SetLog;
  try
    Log.Add('Hashing ' + Value );
    TransferString(Value);
  finally
    RemoveLog;
  end;
end;

procedure TStringHasher.TransferString(Value : string);
var
  ByteString  : AnsiString;
  HashDataPos : integer;
  ValueLen    : integer;
  FirstByte   : integer;
begin
  //ToDo Use delphi library methods to convert to AnsiString
  ByteString  := Value;
  FirstByte   := Low(ByteString);
  ValueLen    := Length(ByteString);
  HashDataPos := Length(HashData);
  SetLength(HashData, HashDataPos + ValueLen);

  Move(ByteString[FirstByte], HashData[HashDataPos], ValueLen);
end;

function TStringHasher.GetHash(HashKey: TSipKey): string;
var
  Hash : uint64;
begin
  SetLog;
  try
    Hash := TSipHash.Digest(HashKey, HashData);
  finally
    RemoveLog;
  end;

//  Log.SaveToFile ('c:\temp\Hash.txt');

  result := IntToHex(Hash, 16);
end;

procedure TStringHasher.RemoveLog;
begin
  if UntSipHash.Log = self.Log then
    UntSipHash.Log := nil;
end;

procedure TStringHasher.SetLog;
begin
  if UntSipHash.Log = nil then
    UntSipHash.Log := self.Log;
end;


end.
