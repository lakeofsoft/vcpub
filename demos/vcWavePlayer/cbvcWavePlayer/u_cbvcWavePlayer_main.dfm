object c_form_main: Tc_form_main
  Left = 87
  Top = 48
  Width = 480
  Height = 270
  Caption = 'VC 2.5 Pro - WAVe Player Demo'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object c_paintBox_wave: TPaintBox
    Left = 0
    Top = 169
    Width = 472
    Height = 55
    Hint = '20 Hz (Blue = Left; Red = Right)'
    Align = alClient
    ParentShowHint = False
    ShowHint = True
    OnPaint = c_paintBox_wavePaint
  end
  object c_statusBar_main: TStatusBar
    Left = 0
    Top = 224
    Width = 472
    Height = 19
    Panels = <
      item
        Width = 50
      end
      item
        Width = 160
      end
      item
        Width = 110
      end
      item
        Text = 'Copyright (c) 2002-2003 Lake of Soft, Ltd'
        Width = 50
      end>
    ParentShowHint = False
    ShowHint = True
    SimplePanel = False
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 472
    Height = 169
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object c_label_tempo: TLabel
      Left = 0
      Top = 28
      Width = 33
      Height = 13
      Caption = 'Tempo'
    end
    object c_label_vol: TLabel
      Left = 44
      Top = 28
      Width = 18
      Height = 13
      Caption = 'Vol.'
    end
    object Bevel2: TBevel
      Left = 104
      Top = 24
      Width = 2
      Height = 123
    end
    object Bevel1: TBevel
      Left = 12
      Top = 12
      Width = 447
      Height = 2
      Anchors = [akLeft, akTop, akRight]
    end
    object Label1: TLabel
      Left = 120
      Top = 28
      Width = 74
      Height = 13
      Caption = '&Input File Name'
      FocusControl = c_edit_fileName
    end
    object Bevel3: TBevel
      Left = 8
      Top = 156
      Width = 447
      Height = 2
      Anchors = [akLeft, akTop, akRight]
    end
    object Label2: TLabel
      Left = 32
      Top = 152
      Width = 85
      Height = 13
      Cursor = crHandPoint
      Hint = 
        'Click to visit VC 2.5 components web page: http://lakeofsoft.com' +
        '/vc/'
      Caption = ' Graphics Display '
      ParentShowHint = False
      ShowHint = True
    end
    object c_label_caption: TLabel
      Left = 36
      Top = 8
      Width = 69
      Height = 13
      Cursor = crHandPoint
      Hint = 
        'Click to visit VC 2.5 components web page: http://lakeofsoft.com' +
        '/vc/'
      Caption = ' WAVe Player '
      ParentShowHint = False
      ShowHint = True
    end
    object c_trackBar_tempo: TTrackBar
      Left = 4
      Top = 40
      Width = 33
      Height = 105
      Enabled = False
      Max = 20
      Orientation = trVertical
      Frequency = 1
      Position = 10
      SelEnd = 0
      SelStart = 0
      TabOrder = 0
      TickMarks = tmBottomRight
      TickStyle = tsAuto
      OnChange = c_trackBar_tempoChange
    end
    object c_trackBar_volume: TTrackBar
      Left = 40
      Top = 40
      Width = 33
      Height = 105
      Max = 20
      Orientation = trVertical
      Frequency = 1
      Position = 10
      SelEnd = 0
      SelStart = 0
      TabOrder = 1
      TickMarks = tmBottomRight
      TickStyle = tsAuto
      OnChange = c_trackBar_volumeChange
    end
    object c_progressBar_volumeLeft: TProgressBar
      Left = 72
      Top = 47
      Width = 11
      Height = 91
      Min = 0
      Max = 300
      Orientation = pbVertical
      Smooth = True
      TabOrder = 2
    end
    object c_progressBar_volumeRight: TProgressBar
      Left = 84
      Top = 47
      Width = 11
      Height = 91
      Min = 0
      Max = 300
      Orientation = pbVertical
      Smooth = True
      TabOrder = 3
    end
    object c_edit_fileName: TEdit
      Left = 120
      Top = 44
      Width = 319
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 4
      OnChange = c_edit_fileNameChange
    end
    object c_button_browse: TButton
      Left = 438
      Top = 44
      Width = 23
      Height = 21
      Action = a_file_open
      Anchors = [akTop, akRight]
      TabOrder = 5
    end
    object c_button_start: TButton
      Left = 120
      Top = 72
      Width = 75
      Height = 25
      Action = a_playback_start
      TabOrder = 6
    end
    object c_button_stop: TButton
      Left = 204
      Top = 72
      Width = 75
      Height = 25
      Action = a_playback_stop
      TabOrder = 7
    end
    object c_checkBox_autoRewind: TCheckBox
      Left = 288
      Top = 76
      Width = 113
      Height = 17
      Caption = '&Auto Rewind'
      TabOrder = 8
      OnClick = c_checkBox_autoRewindClick
    end
    object c_trackBar_pos: TTrackBar
      Left = 112
      Top = 104
      Width = 355
      Height = 25
      Anchors = [akLeft, akTop, akRight]
      Max = 100
      Orientation = trHorizontal
      Frequency = 1
      Position = 0
      SelEnd = 0
      SelStart = 0
      TabOrder = 9
      TickMarks = tmBoth
      TickStyle = tsNone
      OnChange = c_trackBar_posChange
    end
    object c_checkBox_enableGO: TCheckBox
      Left = 120
      Top = 132
      Width = 165
      Height = 17
      Caption = 'Enable &Graphics Display'
      Checked = True
      State = cbChecked
      TabOrder = 10
    end
  end
  object resampler: TunavclWaveResampler
    consumer = waveOut
    calcVolume = True
    Left = 292
    Top = 4
  end
  object waveOut: TunavclWaveOutDevice
    onFeedChunk = waveOutFeedChunk
    Left = 340
    Top = 4
  end
  object wavRead: TunavclWaveRiff
    consumer = resampler
    isFormatProvider = True
    onDataAvailable = wavReadDataAvailable
    realTime = True
    Left = 236
    Top = 4
  end
  object c_openDialog_main: TOpenDialog
    DefaultExt = 'wav'
    Filter = 'WAVe files (*.wav)|*.wav|All files (*.*)|*.*'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 400
    Top = 28
  end
  object c_timer_update: TTimer
    Interval = 700
    OnTimer = c_timer_updateTimer
    Left = 92
    Top = 176
  end
  object c_go_update: TTimer
    Interval = 50
    OnTimer = c_go_updateTimer
    Left = 172
    Top = 176
  end
  object c_actionList_main: TActionList
    Left = 296
    Top = 176
    object a_file_open: TAction
      Caption = '...'
      OnExecute = a_file_openExecute
    end
    object a_playback_start: TAction
      Caption = '&Start'
      OnExecute = a_playback_startExecute
    end
    object a_playback_stop: TAction
      Caption = 'S&top'
      OnExecute = a_playback_stopExecute
    end
  end
end
