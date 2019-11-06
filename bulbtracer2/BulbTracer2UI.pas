(*
  BulbTracer2 for MB3D
  Copyright (C) 2016-2019 Andreas Maschke

  This is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser
  General Public License as published by the Free Software Foundation; either version 2.1 of the
  License, or (at your option) any later version.

  This software is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
  even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  Lesser General Public License for more details.
  You should have received a copy of the GNU Lesser General Public License along with this software;
  if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
  02110-1301 USA, or see the FSF site: http://www.fsf.org.
*)
unit BulbTracer2UI;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, TypeDefinitions, ComCtrls,
  Contnrs, VertexList, BulbTracer2Config, Vcl.Tabs, BulbTracerUITools,
  JvExStdCtrls, JvGroupBox, TrackBarEx, ObjectScanner2, Generics.Collections,
  SyncObjs;

type
  TParamSource = (psMain, psSingleFile, psFileSequence);

  TThreadErrorStatus = packed record
    HasError: boolean;
    ErrorMessage: string;
  end;


  TBulbTracer2Frm = class(TForm)
    SaveDialog: TSaveDialog;
    Timer1: TTimer;
    Timer2: TTimer;
    Timer3: TTimer;
    Panel1: TPanel;
    OpenDialog1: TOpenDialog;
    ImportParamsFromMainBtn: TButton;
    Button2: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    XOffsetEdit: TEdit;
    YOffsetEdit: TEdit;
    ZOffsetEdit: TEdit;
    CheckBox3: TCheckBox;
    Button6: TButton;
    ScaleEdit: TEdit;
    GroupBox2: TGroupBox;
    Button3: TButton;
    FilenameREd: TEdit;
    Label18: TLabel;
    MeshVResolutionLbl: TLabel;
    Label23: TLabel;
    MeshVResolutionEdit: TEdit;
    SurfaceSharpnessEdit: TEdit;
    SurfaceSharpnessUpDown: TUpDown;
    MeshVResolutionUpDown: TUpDown;
    CalculateColorsCBx: TCheckBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    OpenGLPreviewCBx: TCheckBox;
    MeshPreviewBtn: TButton;
    Label5: TLabel;
    MaxVerticeCountEdit: TEdit;
    GroupBox6: TGroupBox;
    Panel2: TPanel;
    Panel9: TPanel;
    Label24: TLabel;
    FrameEdit: TEdit;
    FrameUpDown: TUpDown;
    FrameTBar: TTrackBarEx;
    ProgressBar: TProgressBar;
    Button1: TButton;
    Label13: TLabel;
    CalculateBtn: TButton;
    GenCurrMeshBtn: TButton;
    CancelTypeCmb: TComboBox;
    Label19: TLabel;
    CancelBtn: TButton;
    SaveTypeCmb: TComboBox;
    Label10: TLabel;
    Panel3: TPanel;
    Image1: TImage;
    IncXOffsetBtn: TSpeedButton;
    DecXOffsetBtn: TSpeedButton;
    IncYOffsetBtn: TSpeedButton;
    DecYOffsetBtn: TSpeedButton;
    IncZOffsetBtn: TSpeedButton;
    DecZOffsetBtn: TSpeedButton;
    ScaleDownBtn: TSpeedButton;
    ScaleUpBtn: TSpeedButton;
    PreviewProgressBar: TProgressBar;
    RadioGroup2: TRadioGroup;
    CheckBox2: TCheckBox;
    Button5: TButton;
    Label6: TLabel;
    XRotateEdit: TEdit;
    YRotateEdit: TEdit;
    ZRotateEdit: TEdit;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label11: TLabel;
    EditModeCmb: TComboBox;
    procedure Button1Click(Sender: TObject);
    procedure ImportParamsFromMainBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure XOffsetEditChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure UpDown5Click(Sender: TObject; Button: TUDBtnType);
    procedure UpDown6Click(Sender: TObject; Button: TUDBtnType);
    procedure UpDown7Click(Sender: TObject; Button: TUDBtnType);
    procedure Timer3Timer(Sender: TObject);
    procedure Edit10Change(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure CalculateBtnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MeshPreviewBtnClick(Sender: TObject);
    procedure RadioGroup2Click(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure SaveTypeCmbChange(Sender: TObject);
    procedure CancelTypeCmbChange(Sender: TObject);
    procedure MeshVResolutionEditChange(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure SurfaceSharpnessUpDownClick(Sender: TObject; Button: TUDBtnType);
    procedure Button2Click(Sender: TObject);
    procedure FrameUpDownClick(Sender: TObject; Button: TUDBtnType);
    procedure FrameEditExit(Sender: TObject);
    procedure FrameTBarChange(Sender: TObject);
    procedure FrameTBarMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure IncXOffsetBtnClick(Sender: TObject);
    procedure IncYOffsetBtnClick(Sender: TObject);
    procedure IncZOffsetBtnClick(Sender: TObject);
    procedure ScaleDownBtnClick(Sender: TObject);
    procedure OpenGLPreviewCBxClick(Sender: TObject);
  private
    { Private-Deklarationen }
  //  PreviewVoxel: array of Cardinal;   //buffer to not calc everything again if shifted position
    T0: Int64;
    PVwid, PVhei, PVdep: Integer;
    VCalcThreadStats: TCalcThreadStats;
    ThreadErrorStatus: array[1..64] of TThreadErrorStatus;
    PaintedYsofar, vActiveThreads, PreviewSize: Integer;
    CalcPreview{, PrCalcedAll}: LongBool; //to verify if PreviewVoxel array is complete
    VsiLight: array of Cardinal;  //just 0..255 for color
    FThreadVertexLists, FThreadNormalsLists, FThreadColorsLists: TObjectList;
    FSavePartIdx: Integer;
    FSaveType: TMeshSaveType;
    FVertexGenConfig: TVertexGen2Config;
    FCalculating, FForceAbort: Boolean;
    FCancelType: TCancelType;
    FRefreshing: Boolean;
    FSavePartCriticalSection: TCriticalSection;
    procedure PutOutputFolder2record;
    procedure GetOutputFolderFromrecord;
    procedure MakeM3V;
    procedure SetFromM3V;
    procedure CalcImageSize;
    function StartSlicePreview(nr: Integer): LongBool;
    procedure PaintNextPreviewSlice(nr: Integer);
    procedure SetProjectName(FileName: String);
    procedure StartNewPreview;
    function  CalcPreviewSize: Integer;
    procedure CalcPreviewSizes;
    procedure UpdateSaveTypeCmb;

    function StartPLYRender: LongBool;
    procedure MergeAndSaveMesh;
    procedure UpdateVertexGenConfig;
    procedure SaveMesh;
    function  MakeMeshSequenceFilename( const BaseFilename: String ): String;
    procedure CancelPreview;
    procedure UpdateParamsRange;
    procedure UpdateFrameDisplay( const Frame: Integer );
    procedure ChangeFrame;
    procedure ShowTitle(const Caption: String);
    procedure StartCalc;
    procedure SetExportFilenameExt;
  protected
    procedure WndProc(var Message: TMessage); override;
    procedure WmThreadReady(var Msg: TMessage); message WM_ThreadReady;
  public
    { Public-Deklarationen }
    FParamSource: TParamSource;
    FSingleFrame: Boolean;
    FParamFilename: String;
    FParamSequenceBaseFilename: String;
    FParamSequenceFileExt: String;
    FParamSequencePatternLength: Integer;
    FParamSequenceFrom: Integer;
    FParamSequenceTo: Integer;
    FParamSequenceCurrFrame: Integer;
    M3Vfile: TM3Vfile;
    bUserChange, bFirstShow, Benabled: LongBool;
    OutputFolder, VProjectName: String;
    FileNumber: Integer;
    HybridCustoms: array[0..5] of TCustomFormula;
    procedure EnableControls(const Enabled: Boolean);
    procedure ImportParams(const KeepScaleAndPosition: Boolean = False);
  end;

  TFVoxelExportCalcPreviewThread = class(TThread)
  private
    FOwner: TBulbTracer2Frm;
    { Private-Deklarationen }
    Iteration3Dext: TIteration3Dext;
  public
    { Public-Deklarationen }
    MCTparas: TMCTparameter;
  protected
    procedure Execute; override;
  end;


  TPLYExportCalcThread = class(TThread)
  private
    FOwner: TBulbTracer2Frm;
    FPrepared: Boolean;
    FObjectScanner: TObjectScanner2;
  protected
    procedure Prepare;
    procedure Execute; override;
  public
    M3Vfile: TM3Vfile;
    MCTparas: TMCTparameter;
    FacesList: TFacesList;
    VertexGenConfig: TVertexGen2Config;
    destructor Destroy; override;
  end;
var
  BulbTracer2Frm: TBulbTracer2Frm;
  iVoxelVersion: Integer = 4;
  bBulbTracerFormCreated: LongBool = False;

implementation

uses CalcVoxelSliceThread, FileHandling, Math, Math3D, Calc, DivUtils, Mand,
  HeaderTrafos, CustomFormulas, ImageProcess, VectorMath, DateUtils, BulbTracer2,
  MeshPreviewUI, MeshWriter, MeshReader, MeshIOUtil, MeshSimplifier,
  Ole2;

{$R *.dfm}

procedure TBulbTracer2Frm.PutOutputFolder2record;
var i, l: Integer;
begin
    l := Min(1023, Length(OutputFolder));
    for i := 1 to l do M3Vfile.OutputFolderC[i - 1] := Ord(OutputFolder[i]);
    M3Vfile.OutputFolderC[l] := 0;
end;

procedure TBulbTracer2Frm.GetOutputFolderFromrecord;
var b: Byte;
    i: Integer;
begin
    OutputFolder := '';
    i := 0;
    repeat
      b := M3Vfile.OutputFolderC[i];
      if b > 0 then OutputFolder := OutputFolder + Chr(b);
      Inc(i);
    until (i > 1023) or (b = 0);
end;

procedure TBulbTracer2Frm.Button1Click(Sender: TObject);
begin
    Visible := False;
end;

procedure TFVoxelExportCalcPreviewThread.Execute;
var d: Double;
    CC: TVec3D;
    cLi: PCardinal;
    x, y: Integer;
    AvgDEstop: double;
begin
    AvgDEstop := 0.5 * (FOwner.CalcPreviewSize / 8.0);
    with MCTparas do
      try
      IniIt3D(@MCTparas, @Iteration3Dext);
      y := CalcRect.Top + iThreadId - 1;
      while y <= CalcRect.Bottom do
      begin
        cLi := PCardinal(Integer(pSiLight) + (y - CalcRect.Top) * SLoffset);
        mCopyAddVecWeight(@CC, @Ystart, @Vgrads[1], y);
        for x := 0 to CalcRect.Right do begin
          Iteration3Dext.CalcSIT := False;
          mCopyAddVecWeight(@Iteration3Dext.C1, @CC, @Vgrads[0], x);
          begin
            d := CalcDE(@Iteration3Dext, @MCTparas);   //in+outside: only if d between dmin and dmax
            if d < AvgDEstop then
              cLi^ := 1
            else
              cLi^ := 0;
          end;
        Inc(cLi);
          if PCalcThreadStats^.pLBcalcStop^ then Break;
        end;
        if PCalcThreadStats^.pLBcalcStop^ then Break;
        Inc(y, iThreadCount);
      end;
    finally
      PCalcThreadStats^.CTrecords[iThreadID].isActive := 0;
      PostMessage(PCalcThreadStats^.pMessageHwnd, WM_ThreadReady, 0, 0);
    end;
end;

function TBulbTracer2Frm.StartSlicePreview(nr: Integer): LongBool;
var VoxCalcThreads: array of TFVoxelExportCalcPreviewThread;
    x, ThreadCount: Integer;
    MCTparas: TMCTparameter;
    d: Double;
    alpha, beta, gamma: double;
begin
  ThreadCount := Min(Mand3DForm.UpDown3.Position, PreviewSize);
  try
    M3Vfile.VHeader.TilingOptions := 0;
    bGetMCTPverbose := False;
    MCTparas := getMCTparasFromHeader(M3Vfile.VHeader, False);
    bGetMCTPverbose := True;
    Result := MCTparas.bMCTisValid;
    if Result then
    begin
      MCTparas.pSiLight := @VsiLight[0];
      MCTparas.SLoffset := PVwid * SizeOf(Cardinal);
      MCTparas.PCalcThreadStats := @VCalcThreadStats;

      alpha := DegToRad( StrToFloatK(XRotateEdit.Text));
      beta := DegToRad( StrToFloatK(YRotateEdit.Text));
      gamma := DegToRad(StrToFloatK(ZRotateEdit.Text));

      with M3Vfile do
      begin
        if UseDefaultOrientation then BuildRotMatrix(alpha, beta, gamma, @MCTparas.VGrads);
        MCTparas.CalcRect := Rect(0, 0, PVwid - 1, PVhei - 1);
        d := 2.2 / (VHeader.dZoom * Zscale * Max(1, PVdep - 1));
        MCTparas.VGrads := NormaliseMatrixTo(d, @MCTparas.VGrads);
    //    d := (PVwid - 1) / 64;
        MCTparas.Ystart := TPVec3D(@VHeader.dXmid)^;
        mAddVecWeight(@MCTparas.Ystart, @MCTparas.Vgrads[0], PVwid * -0.5 + Xoff / d);
        mAddVecWeight(@MCTparas.Ystart, @MCTparas.Vgrads[1], PVhei * -0.5 + Yoff / d);
        mAddVecWeight(@MCTparas.Ystart, @MCTparas.Vgrads[2], nr - PVdep * 0.5 + Zoff / d);
        MCTparas.iSliceCalc := 1;
        MCTparas.DEAOmaxL := 0.75;
      end;
      MCTparas.iMandWidth := PreviewSize;
      SetLength(VoxCalcThreads, ThreadCount);
    end;
  except
    Result := False;
  end;
  if Result then
  begin
    VCalcThreadStats.ctCalcRect := MCTparas.CalcRect;
    VCalcThreadStats.pLBcalcStop := @MCalcStop;
    VCalcThreadStats.pMessageHwnd := Self.Handle;
    for x := 1 to ThreadCount do
    begin
      VCalcThreadStats.CTrecords[x].iActualYpos := -1;
      MCTparas.iThreadId := x;
      try
        VoxCalcThreads[x - 1] := TFVoxelExportCalcPreviewThread.Create(True);
        VoxCalcThreads[x - 1].FOwner := Self;
        VoxCalcThreads[x - 1].FreeOnTerminate := True;
        VoxCalcThreads[x - 1].MCTparas        := MCTparas;
        VoxCalcThreads[x - 1].Priority        := cTPrio[Mand3DForm.ComboBox2.ItemIndex];
        VCalcThreadStats.CTrecords[x].isActive := 1;
      except
        ThreadCount := x - 1;
        Break;
      end;
    end;
    for x := 0 to ThreadCount - 1 do VoxCalcThreads[x].MCTparas.iThreadCount := ThreadCount;
    VCalcThreadStats.iTotalThreadCount := ThreadCount;
    vActiveThreads := ThreadCount;
    for x := 0 to ThreadCount - 1 do VoxCalcThreads[x].Start;
    Timer2.Interval := 10;
    Timer2.Enabled := True;
  end;
end;

procedure TBulbTracer2Frm.Timer1Timer(Sender: TObject);   // proof if threads are still calculating
var
  y, it: Integer;
  Progress: Integer;
  HasError: boolean;
  ErrorMessage: string;
begin
  Application.ProcessMessages;
  Timer1.Enabled := False;
  it := 0;
  Progress := 0;
  HasError := false;
  ErrorMessage := 'An error has occured';
  with VCalcThreadStats do begin
    for y := 1 to iTotalThreadCount do begin
      Progress := Progress + CTrecords[y].iActualYpos;
      if CTrecords[y].isActive <> 0 then Inc(it);
      if ThreadErrorStatus[y].HasError then begin
        VCalcThreadStats.pLBcalcStop^ := True;
        HasError := true;
        if Trim( ThreadErrorStatus[y].ErrorMessage ) <> '' then
          ErrorMessage := Trim( ThreadErrorStatus[y].ErrorMessage );
        it := 0;
        break;
      end;
    end;
  end;
  if it = 0 then begin
    try
      if not VCalcThreadStats.pLBcalcStop^ then  begin
        MergeAndSaveMesh;
        ProgressBar.Position := ProgressBar.Max;
      end;
      Mand3DForm.EnableButtons;
      Mand3DForm.OutMessage('Finished tracing object.');
    finally
      FCalculating := False;
      EnableControls(True);

      if ( FParamSource = psFileSequence ) and ( not FSingleFrame ) then begin
        if ( not FForceAbort ) and  ( FParamSequenceCurrFrame < FParamSequenceTo ) then begin
          Inc( FParamSequenceCurrFrame );
          UpdateFrameDisplay( FParamSequenceCurrFrame );
          ImportParams( True );
          CancelPreview;
          StartCalc;
        end;
      end;
    end;
    if HasError then
      raise Exception.Create(ErrorMessage);
  end
  else begin
    ProgressBar.Position := Progress;
    Timer1.Enabled := True;
  end;
end;

procedure TBulbTracer2Frm.WmThreadReady(var Msg: TMessage);
begin
    if Msg.LParam = 0 then begin
      Dec(vActiveThreads);
      if vActiveThreads = 0 then begin
        if CalcPreview then Timer2.Interval := 1
                       else Timer1.Interval := 5;
      end;
    end;
end;

procedure TBulbTracer2Frm.MakeM3V;
begin
    with M3Vfile do  begin
      Xoff := StrToFloatK(XOffsetEdit.Text);
      Yoff := StrToFloatK(YOffsetEdit.Text);
      Zoff := StrToFloatK(ZOffsetEdit.Text);
      Xscale := StrToFloatK(ScaleEdit.Text);
      Yscale := Xscale;
      Zscale := Xscale;
      UseDefaultOrientation := CheckBox3.Checked;
      Zslices := 100;
      ObjectD := 1;

      VoxelVersion := iVoxelVersion;
      FillChar(PlaceForFuturePars, SizeOf(PlaceForFuturePars), 0);
      OutputFolder := '';
      PutOutputFolder2record;
      VHAddon.bOptions2 := (VHAddon.bOptions2 and $F9) or (0 shl 1);
    end;
end;

procedure TBulbTracer2Frm.CalcImageSize;
var d: Double;
begin
    with M3Vfile do
    begin
      d := Zslices / MaxCD(1e-40, Zscale);
      VHeader.Width := Round(Xscale * d);
      VHeader.Height := Round(Yscale * d);
    end;
end;

procedure TBulbTracer2Frm.SetFromM3V;
var b: LongBool;
    i: Integer;
begin
    with M3Vfile do
    begin
      b := bUserChange;
      bUserChange := False;
      XOffsetEdit.Text := FloatToStr(Xoff);
      ScaleEdit.Text := FloatToStr(Xscale);
      YOffsetEdit.Text := FloatToStr(Yoff);
      ZOffsetEdit.Text := FloatToStr(Zoff);
      GetOutputFolderFromrecord;
      CheckBox3.Checked := UseDefaultOrientation;
      CalcImageSize;
      // Label12.Caption := IntToStr(VHeader.Width) + ' x ' + IntToStr(VHeader.Height);
      bUserChange := b;
      VHeader.PCFAddon := @VHAddon;
      for i := 0 to 5 do VHeader.PHCustomF[i] := @HybridCustoms[i];
    end;
end;

procedure TBulbTracer2Frm.SetProjectName(FileName: String);
begin
    VProjectName := ChangeFileExtSave(ExtractFileName(FileName), '');
end;

procedure TBulbTracer2Frm.ImportParamsFromMainBtnClick(Sender: TObject);
begin
  FParamSource := psMain;
  UpdateParamsRange;
  ImportParams;
end;

procedure TBulbTracer2Frm.ImportParams(const KeepScaleAndPosition: Boolean = False);
var i: Integer;
    d: Double;
    CurrFilename: String;

    procedure LoadParamFromFile(const ParamFilename: String);
    var
      OldNoSetFocus: Boolean;
    begin
      OldNoSetFocus := Mand3DForm.NoSetFocus;
      try
        Mand3DForm.NoSetFocus := True;
        LoadParameter( Mand3DForm.MHeader, ParamFilename, True);
      finally
        Mand3DForm.NoSetFocus := OldNoSetFocus;
      end;
    end;

begin
    CancelPreview;

    with M3Vfile do
    begin
      VHeader.PCFAddon := @VHAddon;
      for i := 0 to 5 do VHeader.PHCustomF[i] := @HybridCustoms[i];
      for i := 0 to 5 do IniCustomF(@HybridCustoms[i]);

      if FParamSource = psMain then begin
        Mand3DForm.MakeHeader;
        AssignHeader(@VHeader, @Mand3DForm.MHeader);
        ShowTitle( 'Imported from Main' );
      end
      else if FParamSource = psSingleFile then begin
        LoadParamFromFile( FParamFilename );
        Mand3DForm.ParasChanged;
        Mand3DForm.ClearScreen;
        Mand3DForm.MakeHeader;
        AssignHeader(@VHeader, @Mand3DForm.MHeader);
        ShowTitle( ExtractFilename( FParamFilename ) );
      end
      else if FParamSource = psFileSequence then begin
        CurrFilename := GetSequenceFilename(
          FParamSequenceBaseFilename, FParamSequenceFileExt, FParamSequencePatternLength, FParamSequenceCurrFrame );
        LoadParamFromFile( CurrFilename );
        Mand3DForm.ParasChanged;
        Mand3DForm.ClearScreen;
        Mand3DForm.MakeHeader;
        AssignHeader(@VHeader, @Mand3DForm.MHeader);
        ShowTitle( ExtractFilename( CurrFilename ) );
      end;

      DisableTiling(@VHeader);
      VHeader.TilingOptions := 0;

      if not KeepScaleAndPosition then begin
        Xoff := 0;
        Yoff := 0;
        Zoff := 0;
        Xscale := 1;
        Yscale := 1;
        Zscale := 1;
      end;

      Zslices := 100;
      ObjectD := 1;
      OrigWidth := VHeader.Width;
      MaxIts := VHeader.Iterations;
      MinIts := MaxIts div 2;
      UseDefaultOrientation := True;
      if VHeader.bVaryDEstopOnFOV > 0 then    //calc DE @ Zmid when VaryDEstopOnFOV
        d := (1 + 0.3 / VHeader.sDEStop) * Max(0, VHeader.dFOVy * Pid180) *
             (VHeader.dZoom * VHeader.Width) / (VHeader.Height * 2.1345)
      else d := 0;
      DE := Max(0.2, VHeader.sDEstop * (1 + (VHeader.dZmid - VHeader.dZstart) * d) * Zslices / VHeader.Width);
      MinDE := DE * 0.254;
      FillChar(PlaceForFuturePars, SizeOf(PlaceForFuturePars), 0);
    end;
    SetProjectName('new');
    SetFromM3V;
    Benabled := True;
    EnableControls(True);
    StartNewPreview;
end;

procedure TBulbTracer2Frm.FormShow(Sender: TObject);
begin
    bUserChange := True;
    if bFirstShow then
    begin
      SaveDialog.InitialDir := IniDirs[12];
      bFirstShow := False;
      OutputFolder := IniDirs[12];
      PutOutputFolder2record;
      VProjectName := 'new';

      SaveTypeCmb.ItemIndex := 0;
      if(OutputFolder<>'') then begin
        FilenameREd.Text := IncludeTrailingPathDelimiter(OutputFolder)+GetDefaultMeshFilename('mb3d_mesh', TMeshSaveType(SaveTypeCmb.ItemIndex));
      end;
      CheckBox3.Checked := True;
    end;
end;

procedure TBulbTracer2Frm.FrameEditExit(Sender: TObject);
begin
  ChangeFrame;
end;

procedure TBulbTracer2Frm.FrameTBarChange(Sender: TObject);
begin
  FrameEdit.Text := IntToStr( FrameTBar.Position );
  ChangeFrame;
end;

procedure TBulbTracer2Frm.FrameTBarMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FrameTBarChange( Sender );
end;

procedure TBulbTracer2Frm.FrameUpDownClick(Sender: TObject; Button: TUDBtnType);
var
  Value: Double;
begin
  Value := StrToFloatSafe(FrameEdit.Text, 0.0) + UpDownBtnValue(Button, 1);
  if Value < FParamSequenceFrom then
    Value := FParamSequenceFrom;
  if Value > FParamSequenceTo then
    Value := FParamSequenceTo;
  FrameEdit.Text := IntToStr(Round(Value));
  ChangeFrame;
end;

procedure TBulbTracer2Frm.XOffsetEditChange(Sender: TObject);
begin
    if bUserChange then
    begin
      MakeM3V;
      CalcImageSize;
      // Label12.Caption := IntToStr(M3Vfile.VHeader.Width) + ' x ' + IntToStr(M3Vfile.VHeader.Height);
      StartNewPreview;
    end;
end;

procedure TBulbTracer2Frm.FormCreate(Sender: TObject);
var i: Integer;
begin
  FRefreshing := True;
  try
    FSavePartCriticalSection := TCriticalSection.Create;
    FParamSource := psMain;
    UpdateParamsRange;
    FThreadVertexLists := TObjectList.Create;
    FThreadNormalsLists := TObjectList.Create;
    FThreadColorsLists := TObjectList.Create;
    FVertexGenConfig := TVertexGen2Config.Create;
    bFirstShow := True;
    Benabled := False;
    for i := 0 to 5 do IniCustomF(@HybridCustoms[i]);
    bBulbTracerFormCreated := True;
    //Panel4.DoubleBuffered := True;

    FCancelType := ctCancelAndShowResult;
    CancelTypeCmb.ItemIndex := Ord(FCancelType);
  finally
    FRefreshing := False;
  end;
end;

procedure TBulbTracer2Frm.FormDestroy(Sender: TObject);
begin
  FThreadVertexLists.Free;
  FThreadNormalsLists.Free;
  FThreadColorsLists.Free;
  FVertexGenConfig.Free;
  FSavePartCriticalSection.Free;
end;

procedure TBulbTracer2Frm.CalcPreviewSizes;
var d: Double;
begin
    with M3Vfile do
    begin
      PreviewSize := CalcPreviewSize;
      d := 1 / MaxCD(MaxCD(Zscale, Yscale), Xscale);
      PVwid := Round(PreviewSize * Xscale * d);
      PVhei := Round(PreviewSize * Yscale * d);
      PVdep := Round(PreviewSize * Zscale * d);
    end;
end;

function TBulbTracer2Frm.CalcPreviewSize: Integer;
begin
  Result := 16 shl RadioGroup2.ItemIndex;
end;

procedure TBulbTracer2Frm.Button2Click(Sender: TObject);
begin
  if OpenDialog1.Execute then begin
    if GuessSequence( OpenDialog1.FileName, FParamSequenceBaseFilename, FParamSequenceFileExt,
      FParamSequencePatternLength, FParamSequenceFrom, FParamSequenceTo, FParamSequenceCurrFrame ) then begin
      FParamSource := psFileSequence;
      UpdateParamsRange;
      ImportParams;
    end
    else begin
      FParamSource := psSingleFile;
      FParamFilename := OpenDialog1.FileName;
      UpdateParamsRange;
      ImportParams;
    end;
  end;
end;

procedure TBulbTracer2Frm.Button3Click(Sender: TObject);
begin
  try
    UpdateSaveTypeCmb;
    SaveDialog.DefaultExt := GetMeshFileExt(TMeshSaveType(SaveTypeCmb.ItemIndex));
    SaveDialog.Filter := GetMeshFileFilter(TMeshSaveType(SaveTypeCmb.ItemIndex));
    SaveDialog.InitialDir := ExtractFilePath(FilenameREd.Text);
    SaveDialog.FileName := FilenameREd.Text;
    if SaveDialog.Execute(Self.Handle) then
      FilenameREd.Text := SaveDialog.FileName;
  except
    // Hide error
  end;
end;

procedure TBulbTracer2Frm.Button5Click(Sender: TObject);  //calc preview
begin
    if Button5.Caption = 'Stop' then
    begin
      MCalcStop := True;
  //    Inc(CalcVoxelPreviewIndex);
    end
    else begin
      MeshPreviewFrm.Visible := False;
      PreviewProgressBar.Position := 0;
      PreviewProgressBar.Max := 10; //CalcPreviewSize;
      MakeM3V;
      CalcPreviewSizes;
    //  Mand3DForm.bCalcTile := False;
      FileNumber := PVdep;
      SetLength(VsiLight, PreviewSize * PreviewSize);
      CalcPreview := True;
      Image1.Canvas.Brush.Color := $203040;
      Image1.Canvas.FillRect(Image1.Canvas.ClipRect);
      Image1.Picture.Bitmap.PixelFormat := pf32bit;
      M3Vfile.VHeader.sDEstop := M3Vfile.DE * PVwid / M3Vfile.VHeader.Width;
      M3Vfile.VHeader.Iterations := M3Vfile.MaxIts;
      M3Vfile.VHeader.TilingOptions := 0;
      MCalcStop := False;  //because only in DisableButtons else, to late for first filenumber
      if StartSlicePreview(FileNumber) then
      begin
        Button5.Caption := 'Stop';
      end;
    end;
end;


procedure TBulbTracer2Frm.PaintNextPreviewSlice(nr: Integer);
var x, y, y2, i, j, i2, i3, i4, im, ik: Integer;
    PSLstart, PLoffset, bmpSL, bmpOffset, bmpOffP: Integer;
    PC, PSL: PCardinal;
begin
    //PreviewProgressBar.StepIt;
    PreviewProgressBar.Position := Round(10.0 * (CalcPreviewSize - nr + 1) / CalcPreviewSize);
    PSLstart := Integer(@VsiLight[0]);
    PLoffset := PVwid * SizeOf(Cardinal);
    i := Round((165 - (nr / PVdep) * 128) * 1.5);
    i2 := Round(165 - (nr / PVdep) * 128);
    if PreviewSize > 128 then i2 := Round(255 - (nr / PVdep) * 212);
    i4 := i shr 1;
    i3 := i2 shr 1;
    i3 := i3 or (i3 shl 8) or (i3 shl 16);
    i2 := i2 or (i2 shl 8) or (i2 shl 16);
    i := i or (i shl 8) or (i shl 16);
    i4 := i4 or (i4 shl 8) or (i4 shl 16);
    ik := PreviewSize div 16; //1,2,4,8,16
    (*
    im := 5 - ik;
    if im = 3 then im := 2;   //4,2,1
    *)
    case ik of
      1: im := 16;
      2: im := 8;
      4: im := 4;
      8: im := 2;
    else
      im := 1;
    end;
    with Image1.Picture.Bitmap do
    begin
      bmpSL := Integer(ScanLine[0]);
      bmpOffset := Integer(ScanLine[1]) - bmpSL;
      bmpOffP := (((PreviewSize - PVhei) * im) shr 1) * bmpOffset + (((PreviewSize - PVwid) * im) shr 1) shl 2;
      for y := 0 to PVhei - 1 do
      begin
        PSL := PCardinal(PSLstart + y * PLoffset);
        y2 := y * im + 65 - nr div ik;
        PC := PCardinal(bmpSL + bmpOffset * y2 + bmpOffP + ((nr * im) and $FFC));   //first is background
        if PreviewSize = 16 then
        begin
          for x := 0 to PVwid - 1 do
          begin
            if PSL^ > 0 then begin
              Solid4(PC, i, i4);
              for J := 0 to 10 do
                Solid16(PCardinal(Integer(PC) + bmpOffset * J), i2, i3);
            end;
            Inc(PSL);
            Inc(PC, 16);
          end;
        end
        else if PreviewSize = 32 then
        begin
          for x := 0 to PVwid - 1 do
          begin
            if PSL^ > 0 then begin
              Solid4(PC, i, i4);
              for J := 0 to 5 do
                Solid8(PCardinal(Integer(PC) + bmpOffset * J), i2, i3);
            end;
            Inc(PSL);
            Inc(PC, 8);
          end;
        end
        else if PreviewSize = 64 then
        begin
          for x := 0 to PVwid - 1 do
          begin
            if PSL^ > 0 then begin
              Solid4(PC, i, i4);
              Solid4(PCardinal(Integer(PC) + bmpOffset), i2, i3);
              Solid4(PCardinal(Integer(PC) + bmpOffset * 2), i2, i3);
              Solid4(PCardinal(Integer(PC) + bmpOffset * 3), i2, i3);
            end;
            Inc(PSL);
            Inc(PC, 4);
          end;
        end
        else if PreviewSize = 128 then
        begin
          for x := 0 to PVwid - 1 do
          begin
            if PSL^ > 0 then
            begin
              PC^ := i;
              PCardinal(Integer(PC) + bmpOffset)^ := i2;
              Inc(PC);
              PC^ := i;
              PCardinal(Integer(PC) + bmpOffset)^ := i3;
              Inc(PC);
            end
            else Inc(PC, 2);
            Inc(PSL);
          end;
        end
        else if PreviewSize = 256 then
        begin
          for x := 0 to PVwid - 1 do
          begin
            if PSL^ > 0 then
              PC^ := i2;
            Inc(PSL);
            Inc(PC);
          end;
        end;
      end;
      Modified := True;
    end;
end;

procedure TBulbTracer2Frm.Timer2Timer(Sender: TObject);  //preview threads
var y, it: Integer;
begin
    Timer2.Enabled := False;
    it := 0;
    with VCalcThreadStats do
      for y := 1 to iTotalThreadCount do
        if CTrecords[y].isActive <> 0 then Inc(it);
    if it = 0 then //calc done
    begin
      if not VCalcThreadStats.pLBcalcStop^ then
        PaintNextPreviewSlice(FileNumber);
      Dec(FileNumber);
      if (FileNumber < 1) or VCalcThreadStats.pLBcalcStop^ or
         (not StartSlicePreview(FileNumber)) then
      begin
        Mand3DForm.EnableButtons;
      end;
    end
    else Timer2.Enabled := True;
end;

procedure TBulbTracer2Frm.UpDown5Click(Sender: TObject; Button: TUDBtnType);
var d: Double;
begin
    d := 2.2 / (M3Vfile.VHeader.dZoom * M3Vfile.Zscale * Max(1, PVdep - 1));
    if Button = btNext then d := -d;
    M3Vfile.Xoff := M3Vfile.Xoff + d;
    XOffsetEdit.Text := FloatToStrSingle(M3Vfile.Xoff);
end;

procedure TBulbTracer2Frm.UpDown6Click(Sender: TObject; Button: TUDBtnType);
var d: Double;
begin
    d := -2.2 / (M3Vfile.VHeader.dZoom * M3Vfile.Zscale * Max(1, PVdep - 1));
    if Button = btNext then d := -d;
    M3Vfile.Yoff := M3Vfile.Yoff + d;
    YOffsetEdit.Text := FloatToStrSingle(M3Vfile.Yoff);
end;

procedure TBulbTracer2Frm.UpDown7Click(Sender: TObject; Button: TUDBtnType);
var d: Double;
begin
    d := 2.2 / (M3Vfile.VHeader.dZoom * M3Vfile.Zscale * Max(1, PVdep - 1));
    if Button = btNext then d := -d;
    M3Vfile.Zoff := M3Vfile.Zoff + d;
    ZOffsetEdit.Text := FloatToStrSingle(M3Vfile.Zoff);
end;

procedure TBulbTracer2Frm.StartNewPreview;
begin
    if CheckBox2.Checked then
    begin
      MCalcStop := True;
      Timer3.Enabled := True;
    end
    else Timer3.Enabled := False;
end;


procedure TBulbTracer2Frm.Timer3Timer(Sender: TObject);
var y, it: Integer;
begin
    Timer3.Enabled := False;
    it := 0;
    with VCalcThreadStats do
      for y := 1 to iTotalThreadCount do
        if CTrecords[y].isActive <> 0 then Inc(it);
    if Button5.Enabled and (it = 0) and (Button5.Caption <> 'Stop') then //calc done
    begin
     // RadioGroup2.ItemIndex := 0;
      Button5Click(Self);
    end
    else Timer3.Enabled := True;
end;

procedure TBulbTracer2Frm.CancelBtnClick(Sender: TObject);
var
  I: Integer;
begin
// Dialog sucks
//  if FCalculating and (MessageDlg('Do you want to cancel?', mtConfirmation, mbYesNo, 0)=mrOK) then begin
    if FCalculating then begin
      try
        FForceAbort := True;
        with VCalcThreadStats do  begin
          for I := 1 to iTotalThreadCount do
            CTrecords[I].iDEAvrCount := -1;
        end;
      except
        // Hide error
      end;
    end;
//  end;
end;

procedure TBulbTracer2Frm.CancelPreview;
begin
  MCalcStop := True;
  Timer2.Enabled := False;
  Mand3DForm.EnableButtons;
end;

procedure TBulbTracer2Frm.CancelTypeCmbChange(Sender: TObject);
begin
  if (not FRefreshing) then
    FCancelType := TCancelType(CancelTypeCmb.ItemIndex);
end;

procedure TBulbTracer2Frm.RadioGroup2Click(Sender: TObject);
begin
  if CheckBox2.Checked then begin
    CancelPreview;
    Button5Click(nil);
  end;
end;

procedure TBulbTracer2Frm.Edit10Change(Sender: TObject);  //Zslices
begin
    if bUserChange then
    begin
      MakeM3V;
      CalcImageSize;
      // Label12.Caption := IntToStr(M3Vfile.VHeader.Width) + ' x ' + IntToStr(M3Vfile.VHeader.Height);
    end;                     
end;

procedure TBulbTracer2Frm.Button6Click(Sender: TObject);
begin
    bUserChange := False;
    XOffsetEdit.Text := '0';
    YOffsetEdit.Text := '0';
    ZOffsetEdit.Text := '0';
    ScaleEdit.Text := '1';
    bUserChange := True;
    XOffsetEditChange(Sender);
end;

procedure TBulbTracer2Frm.CalculateBtnClick(Sender: TObject);
var
  DoSave: boolean;
begin
  if not FCalculating then begin
    DoSave := ( ( TMeshSaveType(SaveTypeCmb.ItemIndex) <> stNoSave ) );

    if DoSave and (FilenameREd.Text = '') then begin
      Button3Click(Sender);
      if FilenameREd.Text = '' then
        Exit;
    end;

    FSingleFrame := Sender = GenCurrMeshBtn;

    if ( FParamSource = psFileSequence ) and ( Sender <> GenCurrMeshBtn ) then begin
      FParamSequenceCurrFrame := FParamSequenceFrom;
      UpdateFrameDisplay( FParamSequenceCurrFrame );
      ImportParams( True );
      CancelPreview;
    end;

    StartCalc;
  end;
end;

procedure TBulbTracer2Frm.StartCalc;
begin
  FForceAbort := False;
  FCalculating := True;
  CancelPreview;
  EnableControls(True);
  MakeM3V;
//   Mand3DForm.bCalcTile := False;
  ImageScale := 1;
  SetLength(Mand3DForm.siLight5, M3Vfile.VHeader.Width * M3Vfile.VHeader.Height);
  Mand3DForm.mSLoffset := M3Vfile.VHeader.Width * SizeOf(TsiLight5);
  Mand3DForm.MHeader.Width := M3Vfile.VHeader.Width;
  Mand3DForm.MHeader.Height := M3Vfile.VHeader.Height;
  SetImageSize;
  CalcPreview := False;
  M3Vfile.VHeader.sDEstop := M3Vfile.DE;
  M3Vfile.VHeader.Iterations := M3Vfile.MaxIts;
  UpdateVertexGenConfig;
  T0 := DateUtils.MilliSecondsBetween(Now, 0);
  StartPLYRender;
end;

function TBulbTracer2Frm.StartPLYRender: LongBool;
var
  PLYCalcThreads: array of TPLYExportCalcThread;
  x, ThreadCount: Integer;
  MCTparas: TMCTparameter;
  alpha, beta, gamma, d: Double;
begin
  ThreadCount := Min(Mand3DForm.UpDown3.Position, M3Vfile.VHeader.Height);
  try
    FSavePartIdx := 0;
    FThreadVertexLists.Clear;
    FThreadNormalsLists.Clear;
    FThreadColorsLists.Clear;
    FSaveType := TMeshSaveType( SaveTypeCmb.ItemIndex );
    M3Vfile.VHeader.TilingOptions := 0;
    bGetMCTPverbose := False;
    MCTparas := getMCTparasFromHeader(M3Vfile.VHeader, False);
    bGetMCTPverbose := True;
    Result := MCTparas.bMCTisValid;
    if Result then begin
      MCTparas.pSiLight := @Mand3DForm.siLight5[0];
      MCTparas.PCalcThreadStats := @VCalcThreadStats;
      MCTparas.CalcRect := Rect(0, 0, M3Vfile.VHeader.Width - 1, M3Vfile.VHeader.Height - 1);
      //calc VGrads to get the desired slice:

      alpha := DegToRad( StrToFloatK(XRotateEdit.Text));
      beta := DegToRad( StrToFloatK(YRotateEdit.Text));
      gamma := DegToRad(StrToFloatK(ZRotateEdit.Text));


      if M3Vfile.UseDefaultOrientation then BuildRotMatrix(alpha, beta, gamma, @MCTparas.VGrads);
      d := 2.2 / (M3Vfile.VHeader.dZoom * M3Vfile.Zscale * (M3Vfile.Zslices - 1)); //new stepwidth
      MCTparas.VGrads := NormaliseMatrixTo(d, @MCTparas.VGrads);
  //    d := (M3Vfile.VHeader.Width - 1) / 64;
      MCTparas.Ystart := TPVec3D(@M3Vfile.VHeader.dXmid)^;                                   //abs offs!
      mAddVecWeight(@MCTparas.Ystart, @MCTparas.Vgrads[0], M3Vfile.VHeader.Width * -0.5 + M3Vfile.Xoff / d);
      mAddVecWeight(@MCTparas.Ystart, @MCTparas.Vgrads[1], M3Vfile.VHeader.Height * -0.5 + M3Vfile.Yoff / d);
      mAddVecWeight(@MCTparas.Ystart, @MCTparas.Vgrads[2], M3Vfile.Zslices * -0.5 + M3Vfile.Zoff / d);
      MCTparas.iSliceCalc := M3Vfile.ObjectD;
      MCTparas.AOdither := M3Vfile.MinIts;
      MCTparas.DEAOmaxL := M3Vfile.MinDE;
      SetLength(PLYCalcThreads, ThreadCount);
    end;
  except
    Result := False;
  end;
  if Result then begin
    try
      VCalcThreadStats.ctCalcRect := MCTparas.CalcRect;
      VCalcThreadStats.pLBcalcStop := @MCalcStop;
      VCalcThreadStats.pMessageHwnd := Self.Handle;
      for x := 1 to ThreadCount do begin

        VCalcThreadStats.CTrecords[x].iActualYpos := -1;
        VCalcThreadStats.CTrecords[x].iActualXpos := 0;
        VCalcThreadStats.CTrecords[x].i64DEsteps  := 0;
        VCalcThreadStats.CTrecords[x].iDEAvrCount := 0;
        VCalcThreadStats.CTrecords[x].i64Its      := 0;
        VCalcThreadStats.CTrecords[x].iItAvrCount := 0;
        VCalcThreadStats.CTrecords[x].MaxIts      := 0;
        MCTparas.iThreadId := x;
        try
          PLYCalcThreads[x - 1] := TPLYExportCalcThread.Create(True);
          PLYCalcThreads[x - 1].FOwner := Self;
          PLYCalcThreads[x - 1].FreeOnTerminate := True;
          PLYCalcThreads[x - 1].MCTparas        := MCTparas;
          PLYCalcThreads[x - 1].Priority        := cTPrio[Mand3DForm.ComboBox2.ItemIndex];
          PLYCalcThreads[x - 1].M3Vfile         := M3Vfile;
          PLYCalcThreads[x - 1].VertexGenConfig := FVertexGenConfig;
          PLYCalcThreads[x - 1].FacesList      := TFacesList.Create;
          FThreadVertexLists.Add(PLYCalcThreads[x - 1].FacesList);
          VCalcThreadStats.CTrecords[x].isActive := 1;
        except
          ThreadCount := x - 1;
          Break;
        end;
      end;
      VCalcThreadStats.HandleType := 0;
      for x := 0 to ThreadCount - 1 do PLYCalcThreads[x].MCTparas.iThreadCount := ThreadCount;
      ProgressBar.Min := 0;
      ProgressBar.Position := 0;
      ProgressBar.Max := ThreadCount * 100;
      VCalcThreadStats.iTotalThreadCount := ThreadCount;
      VCalcThreadStats.cCalcTime         := GetTickCount;
      vActiveThreads := ThreadCount;
      PaintedYsofar := 0;
      for x := 0 to ThreadCount - 1 do PLYCalcThreads[x].Prepare;
      for x := 0 to ThreadCount - 1 do PLYCalcThreads[x].Start;
      Mand3DForm.DisableButtons;
      Label13.Caption := 'Tracing object...';
      Timer1.Interval := 200;
      Timer1.Enabled := True;
    except
      Result := False;
    end;
  end;
  if not Result then begin
    FCalculating := False;
    EnableControls(True);
    Mand3DForm.OutMessage('Error starting rendering');
  end;
end;
//################################################################################
destructor TPLYExportCalcThread.Destroy;
begin
  if Assigned( FObjectScanner ) then
    FreeAndNil( FObjectScanner );
  inherited Destroy;
end;

procedure TPLYExportCalcThread.Prepare;
var
  PHeader: TPBTraceMainHeader;
begin
  FOwner.ThreadErrorStatus[MCTparas.iThreadId].HasError := False;
  try
    CoInitialize(nil);
    FObjectScanner := TParallelScanner2.Create(VertexGenConfig, MCTparas, M3Vfile, FacesList, VertexGenConfig.SurfaceSharpness, FOwner.FSaveType = stBTracer2Data, '' );
    FObjectScanner.ThreadIdx := MCTparas.iThreadId - 1;
    if FOwner.FSaveType = stBTracer2Data then begin
      FObjectScanner.OutputFilename := FOwner.FilenameREd.Text;
      if FObjectScanner.ThreadIdx = 0 then begin
        GetMem(PHeader, SizeOf( TBTraceMainHeader ) );
        try
          PHeader^.VHeaderWidth := M3Vfile.VHeader.Width;
          PHeader^.VHeaderHeight := M3Vfile.VHeader.Height;
          PHeader^.VHeaderZoom := M3Vfile.VHeader.dZoom;
          PHeader^.VHeaderZScale := M3Vfile.Zscale;
          PHeader^.VResolution := VertexGenConfig.URange.StepCount;
          PHeader^.ThreadCount := FOwner.VCalcThreadStats.iTotalThreadCount;
          PHeader^.WithColors := Ord(VertexGenConfig.CalcColors);
          InitBTraceFile( FObjectScanner.OutputFilename, PHeader );
        finally
          FreeMem(PHeader);
        end;
      end;
    end;
    FPrepared := True;
  except
    on E: Exception do begin
      FOwner.ThreadErrorStatus[MCTparas.iThreadId].HasError := True;
      FOwner.ThreadErrorStatus[MCTparas.iThreadId].ErrorMessage := E.Message;
    end;
  end;
end;

procedure TPLYExportCalcThread.Execute;
begin
  try
    try
      if FOwner.ThreadErrorStatus[MCTparas.iThreadId].HasError then
        raise Exception.Create(FOwner.ThreadErrorStatus[MCTparas.iThreadId].ErrorMessage);
      if not FPrepared then
        raise Exception.Create('Call Prepare First');
      FObjectScanner.Scan;
    except
      on E: Exception do begin
        FOwner.ThreadErrorStatus[MCTparas.iThreadId].HasError := True;
        FOwner.ThreadErrorStatus[MCTparas.iThreadId].ErrorMessage := E.Message;
      end;
    end;
  finally
    with MCTparas do begin
      PCalcThreadStats.CTrecords[iThreadID].isActive := 0;
      PostMessage(PCalcThreadStats.pMessageHwnd, WM_ThreadReady, 0, 0);
    end;
  end;
end;

procedure TBulbTracer2Frm.SaveTypeCmbChange(Sender: TObject);
begin
  if (not FRefreshing) then begin
    SetExportFilenameExt;
  end;
end;

procedure TBulbTracer2Frm.ScaleDownBtnClick(Sender: TObject);
var d: Double;
begin
    MakeM3V;
    d := 1.1;
    if Sender <> ScaleUpBtn then d := 1 / d;
    M3Vfile.Xscale := M3Vfile.Xscale * d;
    M3Vfile.Yscale := M3Vfile.Yscale * d;
    M3Vfile.Zscale := M3Vfile.Zscale * d;
    ScaleEdit.Text := FloatToStrSingle( M3Vfile.Xscale );
end;

function TBulbTracer2Frm.MakeMeshSequenceFilename( const BaseFilename: String ): String;
var
  I: Integer;
begin
  Result := BaseFilename;
  if FParamSource = psFileSequence then begin
    for I := Length( BaseFilename ) downto 1 do begin
      if BaseFilename[I] = '.' then begin
        Result := Copy( BaseFilename, 1, I - 1 ) + '_' + Format('%.5d', [ FParamSequenceCurrFrame ] ) + Copy( BaseFilename, I, Length( BaseFilename ) - I + 1) ;
        break;
      end;
    end;
  end;
end;

procedure TBulbTracer2Frm.SaveMesh;
var
  FacesList: TFacesList;
  MaxVerticeCount: Integer;
begin
  try
    if (not FForceAbort) or (FCancelType = ctCancelAndShowResult) then begin
      if( FSaveType = stBTracer2Data ) then begin
        // trace-data is already saved at this point
        OutputDebugString(PChar('TOTAL: '+IntToStr(DateUtils.MilliSecondsBetween(Now, 0)-T0)+' ms'));
        if not FForceAbort then
          Label13.Caption := 'Elapsed time: ' + IntToStr(Round((DateUtils.MilliSecondsBetween(Now, 0)-T0)/1000.0))+' s';
      end
      else begin
        FacesList := TFacesList.MergeFacesLists( FThreadVertexLists );
        try
          FacesList.DoCenter(1.0);
          if not FForceAbort then begin
            if FSaveType = stMeshAsObj then
              TObjFileWriter.SaveToFile(MakeMeshSequenceFilename( FilenameREd.Text ), FacesList)
            else if FSaveType = stMeshAsPly then
              TPlyFileWriter.SaveToFile(MakeMeshSequenceFilename( FilenameREd.Text ), FacesList);
          end;
          FThreadVertexLists.Clear;
          OutputDebugString(PChar('TOTAL: '+IntToStr(DateUtils.MilliSecondsBetween(Now, 0)-T0)+' ms'));
          if not FForceAbort then
            Label13.Caption := 'Elapsed time: ' + IntToStr(Round((DateUtils.MilliSecondsBetween(Now, 0)-T0)/1000.0))+' s';
          if OpenGLPreviewCBx.Checked then begin
            try
              MaxVerticeCount := StrToInt(MaxVerticeCountEdit.Text);
            except
              MaxVerticeCount := -1;
            end;
            MeshPreviewFrm.UpdateMesh(FacesList, MaxVerticeCount);
          end;
        finally
          FacesList.Free;
        end;
      end;
    end;
  finally
    FThreadVertexLists.Clear;
  end;
  if not FForceAbort then
    Label13.Caption := 'Elapsed time: ' + IntToStr(Round((DateUtils.MilliSecondsBetween(Now, 0)-T0)/1000.0))+' s'
  else
    Label13.Caption := 'Operation cancelled';

  if OpenGLPreviewCBx.Checked and (  FSaveType <> stBTracer2Data )  then
    MeshPreviewBtnClick(nil);
end;

procedure TBulbTracer2Frm.MergeAndSaveMesh;
begin
  SaveMesh;
end;

procedure TBulbTracer2Frm.SurfaceSharpnessUpDownClick(Sender: TObject;
  Button: TUDBtnType);
var
  Value: Double;
begin
  Value := StrToFloatSafe(SurfaceSharpnessEdit.Text, 0.0) + UpDownBtnValue(Button, 0.05);
  if Value <= 0.1 then
    Value := 0.1
  else if Value > 2.0 then
    Value := 2.0;
  SurfaceSharpnessEdit.Text := FloatToStr(Value);
end;

procedure TBulbTracer2Frm.MeshPreviewBtnClick(Sender: TObject);
begin
  MeshPreviewFrm.Visible := True;
  BringToFront2(MeshPreviewFrm.Handle);
end;

procedure TBulbTracer2Frm.MeshVResolutionEditChange(Sender: TObject);
begin
  if not FRefreshing then
    MeshVResolutionLbl.Caption := ' x '+MeshVResolutionEdit.Text + ' x '+MeshVResolutionEdit.Text;
end;

procedure TBulbTracer2Frm.OpenGLPreviewCBxClick(Sender: TObject);
begin
  if not OpenGLPreviewCBx.Checked then
    MeshPreviewFrm.Visible := False;
end;

procedure TBulbTracer2Frm.WndProc(var Message: TMessage);
begin
  if Message.Msg = WM_Move then begin
    if MeshPreviewFrm <> nil then begin
      if FormsSticky[0] = 1 then
        MeshPreviewFrm.SetBounds(Left + Width, Top, MeshPreviewFrm.Width,
                                 MeshPreviewFrm.Height)
      else if FormsSticky[0] = 2 then
        MeshPreviewFrm.SetBounds(Left - MeshPreviewFrm.Width, Top,
                                 MeshPreviewFrm.Width, MeshPreviewFrm.Height);
    end;
  end;
  inherited WndProc(Message);
end;


procedure TBulbTracer2Frm.UpdateVertexGenConfig;
var
  VRes: Integer;
begin
  FVertexGenConfig.Clear;

  FVertexGenConfig.RemoveDuplicates := True;

  FVertexGenConfig.SurfaceSharpness := StrToFloat(SurfaceSharpnessEdit.Text);
  FVertexGenConfig.CalcColors := CalculateColorsCBx.Checked;

  VRes := StrToInt( MeshVResolutionEdit.Text );
  FVertexGenConfig.URange.StepCount := VRes;
  FVertexGenConfig.VRange.StepCount := VRes;

  FVertexGenConfig.URange.StepCount := VRes;
  FVertexGenConfig.VRange.StepCount := VRes;
end;

procedure TBulbTracer2Frm.EnableControls(const Enabled: Boolean);

  procedure EnableFields;
  begin
    Panel3.Enabled := Enabled;
    ImportParamsFromMainBtn.Enabled := Enabled;
    Button2.Enabled := Enabled;
    XOffsetEdit.Enabled := Enabled;
    YOffsetEdit.Enabled := Enabled;
    ZOffsetEdit.Enabled := Enabled;
    ScaleEdit.Enabled := Enabled;
    CheckBox3.Enabled := Enabled;
    RadioGroup2.Enabled := Enabled;
    CheckBox2.Enabled := Enabled;
    Button5.Enabled := Enabled;
    MeshVResolutionEdit.Enabled := Enabled;
    MeshVResolutionUpDown.Enabled := Enabled;
    SurfaceSharpnessEdit.Enabled := Enabled;
    SurfaceSharpnessUpDown.Enabled := Enabled;
    CalculateColorsCBx.Enabled := Enabled;
    SaveTypeCmb.Enabled := Enabled;
    Button3.Enabled := Enabled;
    FilenameREd.Enabled := Enabled;
    OpenGLPreviewCBx.Enabled := Enabled;
    MeshPreviewBtn.Enabled := Enabled;
    MaxVerticeCountEdit.Enabled := Enabled;
    FrameEdit.Enabled := Enabled;
    FrameUpDown.Enabled := Enabled;
  end;

begin
  if Enabled then begin
    ImportParamsFromMainBtn.Enabled := True;
    Button5.Enabled := Benabled;
    Button5.Caption := 'Calculate preview';
  end
  else begin
    ImportParamsFromMainBtn.Enabled := False;
    Button5.Enabled := False;
  end;
  EnableFields;
  CancelBtn.Enabled := FCalculating;
  CalculateBtn.Enabled := Benabled and (not FCalculating);
end;

procedure TBulbTracer2Frm.UpdateParamsRange;
begin
  if FParamSource = psFileSequence then begin
    FrameUpDown.Min := FParamSequenceFrom;
    FrameUpDown.Max := FParamSequenceTo;
    FrameTBar.Min := FParamSequenceFrom;
    FrameTBar.Max := FParamSequenceTo;
    UpdateFrameDisplay( FParamSequenceCurrFrame );

    FrameEdit.Enabled := True;
    FrameUpDown.Enabled := True;
    FrameTBar.Enabled := True;

    CalculateBtn.Caption := 'Generate ' + IntToStr( FParamSequenceTo - FParamSequenceFrom + 1 )+ ' Meshes';
    GenCurrMeshBtn.Visible := True;
  end
  else begin
    FrameUpDown.Min := 1;
    FrameUpDown.Max := 1;
    FrameTBar.Min := 1;
    FrameTBar.Max := 1;
    UpdateFrameDisplay( 1 );

    FrameEdit.Enabled := False;
    FrameUpDown.Enabled := False;
    FrameTBar.Enabled := False;

    CalculateBtn.Caption := 'Generate Mesh';
    GenCurrMeshBtn.Visible := False;
  end;
end;

procedure TBulbTracer2Frm.UpdateFrameDisplay( const Frame: Integer );
begin
  FrameEdit.Text := IntToStr( Frame );
  FrameTBar.Position := Frame;
end;

procedure TBulbTracer2Frm.ChangeFrame;
var
  Frame: Integer;
begin
  if FParamSource = psFileSequence then begin
    Frame := Round( StrToFloatSafe(FrameEdit.Text, FParamSequenceCurrFrame) );
    if Frame < FParamSequenceFrom then
      Frame := FParamSequenceFrom;
    if Frame > FParamSequenceTo then
      Frame := FParamSequenceTo;
    FParamSequenceCurrFrame := Frame;
    ImportParams(True);
  end;
end;


procedure TBulbTracer2Frm.ShowTitle(const Caption: String);
begin
  Self.Caption := 'Bulb Tracer 2 [ ' + Caption + ' ]';
end;

procedure TBulbTracer2Frm.IncZOffsetBtnClick(Sender: TObject);
var d: Double;
begin
  if EditModeCmb.ItemIndex = 0 then begin
    d := 2.2 / (M3Vfile.VHeader.dZoom * M3Vfile.Zscale * Max(1, PVdep - 1));
    if Sender = IncZOffsetBtn then d := -d;
    M3Vfile.Zoff := M3Vfile.Zoff + d;
    ZOffsetEdit.Text := FloatToStrSingle(M3Vfile.Zoff);
  end
  else begin
    d := 5.0;
    if Sender = IncZOffsetBtn then d := -d;
    ZRotateEdit.Text := FloatToStrSingle( StrToFloatK(ZRotateEdit.Text) + d );
  end;
end;

procedure TBulbTracer2Frm.IncXOffsetBtnClick(Sender: TObject);
var d: Double;
begin
  if EditModeCmb.ItemIndex = 0 then begin
    d := 2.2 / (M3Vfile.VHeader.dZoom * M3Vfile.Zscale * Max(1, PVdep - 1));
    if Sender = IncXOffsetBtn then d := -d;
    M3Vfile.Xoff := M3Vfile.Xoff + d;
    XOffsetEdit.Text := FloatToStrSingle(M3Vfile.Xoff);
  end
  else begin
    d := 5.0;
    if Sender = IncXOffsetBtn then d := -d;
    YRotateEdit.Text := FloatToStrSingle( StrToFloatK(YRotateEdit.Text) + d );
  end;
end;

procedure TBulbTracer2Frm.IncYOffsetBtnClick(Sender: TObject);
var d: Double;
begin
  if EditModeCmb.ItemIndex = 0 then begin
    d := -2.2 / (M3Vfile.VHeader.dZoom * M3Vfile.Zscale * Max(1, PVdep - 1));
    if Sender = DecYOffsetBtn then d := -d;
    M3Vfile.Yoff := M3Vfile.Yoff + d;
    YOffsetEdit.Text := FloatToStrSingle(M3Vfile.Yoff);
  end
  else begin
    d := 5.0;
    if Sender = DecYOffsetBtn then d := -d;
    XRotateEdit.Text := FloatToStrSingle( StrToFloatK(XRotateEdit.Text) + d );
  end;
end;

procedure TBulbTracer2Frm.SetExportFilenameExt;
var
  NewFileExt: String;
begin
  if Trim( FilenameREd.Text ) <> '' then begin
    UpdateVertexGenConfig;
    NewFileExt := GetMeshFileExt(TMeshSaveType(SaveTypeCmb.ItemIndex));

    if NewFileExt <> '' then
      NewFileExt := '.' + NewFileExt;
    FilenameREd.Text := ChangeFileExt( FilenameREd.Text, NewFileExt )
  end;
end;

procedure TBulbTracer2Frm.UpdateSaveTypeCmb;
begin
  UpdateVertexGenConfig;
end;


end.


