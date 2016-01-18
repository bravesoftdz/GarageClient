unit UntCommandParameter;

interface
uses
  System.Classes,
  System.Generics.Collections,
  System.SysUtils,
  CommunicationTypes;

type
  TCommandParameter = class
  private
    FName     : string;
    FScope    : TParameterScope;
    FValue    : string;
    FIsVirtual: boolean;
  public
    constructor Create;
    property Name       : string  read FName      write FName     ;
    property ParamValue : string  read FValue     write FValue    ;
    property IsVirtual  : boolean read FIsVirtual write FIsVirtual;
    property Scope      : TParameterScope  read FScope  write FScope ;
  end;

type
  // TDictionary<String, TCommandParameter>;
  TCommandDict = class
  private
    FContent : TStringList;
    function GetItem(Key: String): TCommandParameter;
    procedure SetItem(Key: String; const Value: TCommandParameter);

  public
    constructor Create;
    destructor Destroy; override;
    function ContainsKey (Key : string) : boolean;
    procedure Add(Key : string; Value : TCommandParameter);
    property Keys : TStringList read FContent;
    property Items[Key : String] : TCommandParameter read GetItem write SetItem; default;
  end;

//  TRepliedEvent = procedure (Sender : TObject; ReplyResult : TReplyResult; var Reply : TResultDictionary);
//  TErrorEvent   = procedure (Sender : TObject; Context : string; ErrorMessage : string);


implementation


{ TCommandParameter }

constructor TCommandParameter.Create;
begin
  FIsVirtual := false;
end;

{ TCommandDict }

procedure TCommandDict.Add(Key: string; Value: TCommandParameter);
begin
  if FContent.IndexOf(Key) >= 0 then
    raise Exception.Create('Key already exists ' + Key);

  FContent.AddObject(Key, Value);
end;

function TCommandDict.ContainsKey(Key: string): boolean;
var
  idx : integer;
begin
  Idx := FContent.IndexOf(Key);
  result := Idx >= 0;
end;

constructor TCommandDict.Create;
begin
  FContent := TStringList.Create;
end;

destructor TCommandDict.Destroy;
begin
  FContent.Free;
end;

function TCommandDict.GetItem(Key: String): TCommandParameter;
var
  idx : integer;
begin
  Idx := FContent.IndexOf(Key);

  if Idx < 0 then
    raise Exception.Create('No value for ' + Key);

  result := TCommandParameter(FContent.Objects[Idx]);
end;

procedure TCommandDict.SetItem(Key: String; const Value: TCommandParameter);
var
  idx : integer;
begin
  Idx := FContent.IndexOf(Key);

  if Idx < 0 then
    raise Exception.Create('No value for ' + Key);

  FContent.Objects[Idx] := Value;
end;

end.
