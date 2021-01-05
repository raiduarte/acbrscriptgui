unit acbrfunctions;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  Graphics,
  SysUtils,
  strutils,
  Forms,
  ComCtrls,
  FileUtil,
  StdCtrls,
  IniFiles,
  EditBtn,
  Interfaces;

procedure CheckFiles(Tree : TTreeView; ADirectory : TEditButton);
procedure ReadConfigFile( Tree : TTreeView; nameINI : string; LazarusPath, ACBrPath : TEditButton);
procedure WriteConfigFile( Tree : TTreeView; nameINI : string; LazarusPath, ACBrPath : TEditButton);
procedure OpenForm(aClasseForm: TComponentClass; aForm: TForm);
function envInfo (APath, AFile , AKey, AValue : string) : string;
function IfThen(AValue: boolean; const ATrue: integer; const AFalse: integer = 0): integer; overload;
function packInfo (APath, AFile , AKey : string) : boolean;

implementation

function IfThen(AValue: boolean; const ATrue: integer; const AFalse: integer = 0): integer;
begin
  if AValue then
    Result:=ATrue
  else
    Result:=AFalse;
end;

procedure OpenForm(aClasseForm: TComponentClass; aForm: TForm);
begin
  Application.CreateForm(aClasseForm, aForm);
  try
    aForm.ShowModal;
  finally
    FreeAndNil(aForm);
  end;
end;

procedure CheckFiles(Tree: TTreeView; ADirectory: TEditButton);
var
  i                 : integer;
  pkgName           : TStringList;
  PathACBrDirectory : string;
begin
  PathACBrDirectory := IncludeTrailingPathDelimiter(ADirectory.Caption);
  for i := 0 to Pred(Tree.Items.Count) do
  begin
    pkgName := TStringList.Create;
    pkgName := FindAllFiles(PathACBrDirectory, (Tree.Items[i].Text+'.lpk') , True);
    //**
    if not ( pkgName.Count = 0 )then
      Tree.Items[i].Text := Tree.Items[i].Text
    else
      Tree.Items[i].Text := Tree.Items[i].Text + '.' ;
  end;
end;

procedure ReadConfigFile( Tree : TTreeView; nameINI : string; LazarusPath, ACBrPath : TEditButton);
var
  i: integer;
  configINI : TIniFile;
begin
  configINI := TIniFile.Create(ExtractFilePath(Application.ExeName) + nameINI) ;
  try
    begin
      LazarusPath.Text := configINI.ReadString('PathOfApplications','LazarusIde','');
      ACBrPath.Text    := configINI.ReadString('PathOfApplications','ACBrFrameWork','');
      for i := 0 to Pred(Tree.Items.Count) do
        Tree.Items[i].StateIndex := configINI.ReadInteger('ACBrPackages',Tree.Items[i].Text,0);
    end;
  finally
    configINI.Free;
  end;
end;

procedure WriteConfigFile( Tree : TTreeView; nameINI : string; LazarusPath, ACBrPath : TEditButton);
var
  configINI: TIniFile;
  i: integer;
begin
  configINI := TIniFile.Create(ExtractFilePath(Application.ExeName)+nameINI);
  try
    begin
      configINI.WriteString('PathOfApplications', 'LazarusIde', LazarusPath.Text);
      configINI.WriteString('PathOfApplications', 'ACBrFrameWork', ACBrPath.Text);
      //*
      for i := 0 to Pred(Tree.Items.Count) do
        configINI.WriteInteger('ACBrPackages', StringReplace(Tree.Items[i].Text,'.','',[rfReplaceAll, rfIgnoreCase]), Tree.Items[i].StateIndex);
    end;
    //*
  finally
    configINI.Free;
  end;
end;

function envInfo (APath, AFile , AKey, AValue : string) : string;
var
  f : TextFile;
  sFile :string;
  FullPath :string;
begin
  FullPath:= Concat(APath, AFile);

  if FileExists(PChar(FullPath)) then
  begin
    AssignFile(f,PChar(FullPath));
    Reset(f);
    //*
    try
      while not EOF(f) do
      begin
        Readln(f, sFile);
        if AnsiPos( AKey, sFile ) > 0 then
          if AValue.IsEmpty then
            Result := ReplaceStr( Copy(sFile,AnsiPos(AKey,sFile),15), '=',' ')
          else
            Result := ReplaceStr( Copy(sFile,AnsiPos(AValue,sFile),ifthen(AValue='fpc',9,10)),'\',' ');
      end;
    finally
      CloseFile(f);
    end;
  end
  else
    Result := 'Arquivo de Configuração NAO Localizado!!!';
end;

function packInfo (APath, AFile , AKey : string) : boolean;
var
  f : TextFile;
  sFile :string;
  FullPath :string;
begin
  Result := False;
  FullPath:= Concat(APath, AFile);

  if FileExists(PChar(FullPath)) then
  begin
    AssignFile(f,PChar(FullPath));
    Reset(f);
    //*
    try
      while not EOF(f) do
      begin
        Readln(f, sFile);
        if AnsiContainsText( sFile, AKey) then
        begin
          Result := True;
          Exit;
        end;
      end;
    finally
      CloseFile(f);
    end;
  end;
end;

end.
