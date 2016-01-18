unit UntIpAddress;

interface

uses
  System.SysUtils, System.StrUtils;

type
  /// <summary>
  /// Byte representation of a V4 IP address
  /// </summary>
  TIpBytes = array[0..3] of byte;

  /// <summary>
  /// IP address - with string conversion methods
  /// </summary>
  TIpAddress = class
  private
    // Getters and Setters
    FAddress : cardinal;
    FForce: boolean;
    function GetAsString: string;
    procedure SetAsString(const Value: string);
    function GetIpBytes: TIpBytes;
    procedure SetIpBytes(const Value: TIpBytes);
  public
    /// <summary>
    /// Format an IP address as string
    /// </summary>
  	/// <param name="ipNumber">The numeric IP address</param>
  	/// <returns>IP as string</returns>
    class function Format(ipNumber : cardinal) : string;

    /// <summary>
    /// IP address is required - raise Exception, if conversion from string fails
    /// </summary>
    property Force    : boolean read FForce write FForce;
    /// <summary>
    /// Numeric IP address
    /// </summary>
    property Address  : cardinal read FAddress write FAddress;
    /// <summary>
    /// Byte representation of IP address
    /// </summary>
    property IpBytes  : TIpBytes read GetIpBytes write SetIpBytes;
    /// <summary>
    /// String representation of IP address
    /// </summary>
    property AsString : string read GetAsString write SetAsString;
  end;


implementation

{ TIpAddress }

class function TIpAddress.Format(ipNumber: cardinal): string;
var
  ip : TIpAddress;
begin
  ip := TIpAddress.Create;
  try
    ip.Force   := false;
    ip.Address := ipNumber;
    result := ip.AsString;
  finally
    ip.Free;
  end;
end;

function TIpAddress.GetAsString: string;
var
  n: Integer;
begin
  result := '';
  for n := 0 to 3 do begin
    result := result + IntToStr(IpBytes[n]);
    if n < 3 then
       result := result + '.';
  end;
end;

function TIpAddress.GetIpBytes: TIpBytes;
begin
  result := TIpBytes(FAddress);
end;

procedure TIpAddress.SetAsString(const Value: string);
var
  IP : array[0..3] of byte;
  iPart : integer;
  n  : integer;
  dotpos : integer;
  lastPos : integer;
  part : string;
begin
  try
    lastPos := 1;
    for n := 0 to 3 do begin
       if n < 3 then
         dotPos := system.strUtils.posEx('.', Value, lastPos)
       else
         dotPos := length(Value)+1;

       if dotpos = 0 then
         raise Exception.Create('Illegal IP address format');

       part := System.SysUtils.Trim(copy(Value, lastPos, dotPos - lastPos));
       iPart := System.SysUtils.StrToIntDef(part, -1);
       if (iPart < 0) or (iPart > 255) then
         raise Exception.Create('Illegal IP address format');
       IP[n] := iPart;
       lastPos := dotpos+1;
    end;
    FAddress := cardinal(IP);
  except
    on E:Exception do begin
      if Force then
        raise
      else
        FAddress := 0;
    end;

  end;
end;

procedure TIpAddress.SetIpBytes(const Value: TIpBytes);
begin
  FAddress := Cardinal(Value);
end;

end.
