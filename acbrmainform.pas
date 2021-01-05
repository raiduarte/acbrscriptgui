unit acbrmainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, strutils, Graphics, Dialogs, ExtCtrls, ComCtrls,
  Buttons, StdCtrls, EditBtn, LazFileUtils, typinfo, Windows,
  //*
  acbraboutform,
  libBinRes, RichView, RVStyle;

type

  { TACBrForm }
  TACBrForm = class(TForm)
    btnNext                : TBitBtn;
    btnPrevious            : TBitBtn;
    btnCheckFiles          : TBitBtn;
    acbrImages             : TImageList;
    edtACBrPath            : TEditButton;
    edtLazPath             : TEditButton;
    imgLazarus             : TImage;
    lblVerticalTitle       : TLabel;
    lblLazarusDirectory    : TLabel;
    lblACBrDirectory       : TLabel;
    lblLazarusVersion      : TLabel;
    Memo1                  : TMemo;
    NoteBookManager        : TNotebook;
    acbrTabExecute         : TPage;
    acbrTabSelection       : TPage;
    acbrLazarusInformation : TPage;
    panelManageFiles       : TPanel;
    panelTop               : TPanel;
    panelLeft              : TPanel;
    panelBottom            : TPanel;
    panelDash              : TPanel;
    rcvACBrInformation     : TRichView;
    acbrStyles             : TRVStyle;
    sdd                    : TSelectDirectoryDialog;
    StatusBar1             : TStatusBar;
    TreeView1              : TTreeView;
    procedure acbrTabExecuteBeforeShow(ASender: TObject; ANewPage: TPage; ANewIndex: integer);
    procedure acbrTabSelectionBeforeShow(ASender: TObject; ANewPage: TPage; ANewIndex: integer);
    procedure btnNextClick(Sender: TObject);
    procedure btnPreviousClick(Sender: TObject);
    procedure btnCheckFilesClick(Sender: TObject);
    procedure edtACBrPathButtonClick(Sender: TObject);
    procedure edtLazPathButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TreeView1AdvancedCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage;      var PaintImages, DefaultDraw: boolean);
    procedure TreeView1Click(Sender: TObject);
  private
    procedure changeButtonAndExecute(Sender: TObject);
    procedure checkAndDisplayEnvironment;
  public
    procedure DisplayLazarusInformation;
  end;

var
  ACBrForm: TACBrForm;
  pathACBr, pathIDELaz, pathCFGLaz : string;

implementation

{$R *.lfm}

uses
  LCLIntf,
  FileUtil,
  acbrfunctions ;

const
  ImgIndexChecked   = 0;
  ImgIndexUnchecked = 1;

procedure CheckNode(Node: TTreeNode; Checked:boolean);
begin
  if Assigned(Node) then
    if Checked then
      Node.StateIndex := ImgIndexChecked
    else
      Node.StateIndex := ImgIndexUnchecked;
end;

procedure ToggleTreeViewCheckBoxes(Node: TTreeNode);
begin
  if Assigned(Node) then
  begin
    if Node.StateIndex = ImgIndexUnchecked then
      Node.StateIndex := ImgIndexChecked
    else
    if Node.StateIndex = ImgIndexChecked then
      Node.StateIndex := ImgIndexUnchecked;
  end;
end;

function NodeChecked(ANode:TTreeNode): boolean;
begin
  Result := (ANode.StateIndex = ImgIndexChecked);
end;

//*********************   Let´s Go   **********************
procedure TACBrForm.checkAndDisplayEnvironment;
var
  dummyPath : TStringList;
begin
  dummyPath  := TStringList.Create;
  dummyPath := FindAllFiles(edtLazPath.Text, 'lazarus.exe' , True);
  if not ( dummyPath.Count = 0 )then
    pathIDELaz :=
      LowerCase(IncludeTrailingPathDelimiter(ExtractFileDir(ReplaceStr(dummyPath.Text,#13#10,''))));
  //*
  dummyPath.Clear;
  dummyPath := FindAllFiles(edtLazPath.Text, 'fpcdefines.xml' , True);
  if not ( dummyPath.Count = 0 )then
    pathCFGLaz :=
      LowerCase(IncludeTrailingPathDelimiter(ExtractFileDir(ReplaceStr(dummyPath.Text,#13#10,''))));

  StatusBar1.Panels[0].Text := 'IDE: ['+pathIDELaz+'] CFG: ['+pathCFGLaz+']';

  {Carrega as informacoes na pagina}
  DisplayLazarusInformation;
end;

procedure TACBrForm.FormCreate(Sender: TObject); //############################
var
  i: integer;
begin
  TreeView1.Images     := acbrImages;
  TreeView1.Options    := TreeView1.Options - [tvoThemedDraw, tvoShowButtons];
  TreeView1.ScrollBars := ssAutoVertical;

  for i := 0 to Pred(TreeView1.Items.Count) do
  begin
    if TreeView1.Items[i].Level < 1 then  CheckNode(TreeView1.Items[i], True)
    { TODO : fazer readonly }
    else
      CheckNode(TreeView1.Items[i], False);
  end;

  if FileExists('acbr_install.ini') then ReadConfigFile(TreeView1,'acbr_install.ini', edtLazPath, edtACBrPath);

  checkAndDisplayEnvironment;

  NoteBookManager.PageIndex := 2;

  panelManageFiles.Visible := False;
end;//############################


procedure TACBrForm.TreeView1AdvancedCustomDrawItem(Sender: TCustomTreeView;  Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage;  var PaintImages, DefaultDraw: boolean);
begin
  with TreeView1.Canvas do
  begin
    if AnsiContainsStr(Node.Text,'.') then
    begin
      TreeView1.Canvas.Font.Style := [fsItalic , fsStrikeOut];
      TreeView1.Canvas.Font.Color := clRed;
    end
    else
    begin
      TreeView1.Canvas.Font.Style := [];
      DefaultDraw                 := True;
    end;
  end;
end;

procedure TACBrForm.btnCheckFilesClick(Sender: TObject);
begin
  CheckFiles(TreeView1 , edtACBrPath);
end;

//*********************************************
procedure TACBrForm.DisplayLazarusInformation; //(Sender: TObject);
const
  rvsProgram = LAST_DEFAULT_STYLE_NO+3;
  crlf : string = chr(13)+chr(10);
begin
  with rcvACBrInformation do
  begin
    Clear();
    Add(' ',rvsNormal);
    Add(' ',rvsNormal);
    Add(' ',rvsNormal);
    AddCenterLine('Lazarus FreePascal', rvsHeading);
    AddCenterLine('',rvsNormal);

    Add(' ',rvsNormal);
    AddCenterLine('Configuração Atual', rvsSubHeading);
    AddFromNewLine(' ',rvsNormal);
    AddCenterLine('Versão Lazarus', rvsProgram);
    AddCenterLine(envInfo(pathCFGLaz,'environmentoptions.xml','Lazarus=',''), rvsSubHeading);
    AddFromNewLine(' ',rvsNormal);
    AddCenterLine('Versão FPC', rvsProgram);
    AddCenterLine(envInfo(pathCFGLaz,'environmentoptions.xml','CompilerFilename Value=','fpc'), rvsSubHeading);
    AddFromNewLine(' ',rvsNormal);
    AddCenterLine('Plataforma', rvsProgram);
    AddCenterLine(envInfo(pathCFGLaz,'environmentoptions.xml','CompilerFilename Value=',{'x86_64-win64'}'i386-win32'), rvsSubHeading);
    AddFromNewLine(' ',rvsNormal);
    AddFromNewLine(' ',rvsNormal);
    AddBreak();
    {==========================}
    AddFromNewLine('Requisitos Primários', rvsSubHeading);
    AddFromNewLine(' ',rvsNormal);
    //*
    AddFromNewLine('   .Fortes Report ', rvsNormal);
    if packInfo(pathCFGLaz,'staticpackages.inc','frce') then
      AddBullet(5, acbrImages, False)
    else
      AddBullet(6, acbrImages, False);
    //*
    AddFromNewLine('   .LazReport ', rvsNormal);
    if packInfo(pathCFGLaz,'staticpackages.inc','lazreport') then AddBullet(5, acbrImages, False)
    else
      AddBullet(6, acbrImages, False);
    //*
    AddFromNewLine('   .PowerPDF ', rvsNormal);
    if packInfo(pathCFGLaz,'staticpackages.inc','pack_powerpdf') then AddBullet(5, acbrImages, False)
    else
      AddBullet(6, acbrImages, False);
    //*
    AddFromNewLine('   .lazreportpdfexport ', rvsNormal);
    if packInfo(pathCFGLaz,'staticpackages.inc','lazreportpdfexport') then  AddBullet(5, acbrImages, False)
    else
      AddBullet(6, acbrImages, False);
    //*
    AddBreak();
    AddFromNewLine('Nota: Sugere-se que na ausência de um destes componentes,'+ crlf+ //**
      ' se interrompa esta instalação e proceda com sua(s) instalação(ções)'+crlf+ //**
      ' por meio do ''Online Package Manager'' de seu Lazarus IDE.',rvsProgram);
    //*

    rcvACBrInformation.Format;
    rcvACBrInformation.Paint();
  end;

end;

procedure TACBrForm.edtACBrPathButtonClick(Sender: TObject);
begin
  sdd.Title := 'Selecione Diretório ACBr';
  if sdd.Execute then
    edtACBrPath.Caption := IncludeTrailingPathDelimiter(sdd.FileName);
end;

procedure TACBrForm.edtLazPathButtonClick(Sender: TObject);
begin
  sdd.Title := 'Selecione Diretório "config" do Lazarus';
  if sdd.Execute then edtLazPath.Caption := IncludeTrailingPathDelimiter(sdd.FileName);
  //*
  checkAndDisplayEnvironment;
end;

procedure TACBrForm.btnPreviousClick(Sender: TObject);
begin
  NoteBookManager.PageIndex := 1;
end;

procedure TACBrForm.acbrTabExecuteBeforeShow(ASender: TObject; ANewPage: TPage; ANewIndex: integer);
begin
  btnPrevious.Visible := ( NoteBookManager.PageIndex = 0 );
  {  modifica no botão  }
  btnNext.Caption    := 'Execute';
  btnNext.ImageIndex := 4;
  btnNext.OnClick    := @changeButtonAndExecute;
end;

procedure TACBrForm.acbrTabSelectionBeforeShow(ASender: TObject;  ANewPage: TPage; ANewIndex: integer);
begin
  panelManageFiles.Visible := True;
  btnPrevious.Visible := ( NoteBookManager.PageIndex = 0 );
  {  modifica no botão  }
  btnNext.Caption    := 'Next';
  btnNext.ImageIndex := 2;
  btnNext.OnClick    := @btnNextClick;
end;

procedure TACBrForm.btnNextClick(Sender: TObject);
begin
  if NoteBookManager.PageIndex = 2 then
    NoteBookManager.PageIndex := 1
  else
  begin
    {  Grava TreeView no arquivo .ini  }
    WriteConfigFile(TreeView1,'acbr_install.ini', edtLazPath, edtACBrPath);
    NoteBookManager.PageIndex := 0;
  end;

end;

procedure TACBrForm.TreeView1Click(Sender: TObject);
var
  P: TPoint;
  node: TTreeNode;
  ht: THitTests;
begin
  if ( TreeView1.Selected.Level < 1 ) then
    exit;
  P.Create(0,0);
  GetCursorPos(P);
  P := TreeView1.ScreenToClient(P);
  ht := TreeView1.GetHitTestInfoAt(P.X, P.Y);
  if (htOnStateIcon in ht) then
  begin
    node := TreeView1.GetNodeAt(P.X, P.Y);
    ToggleTreeViewCheckBoxes(node);
  end;

end;

procedure TACBrForm.changeButtonAndExecute(Sender: TObject);
begin
  StatusBar1.Panels[0].Text:='ativou evento';
end;

end.
