object Form1: TForm1
  Left = 267
  Top = 32
  AutoScroll = False
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'VC 2.5 Pro - Mixer Demo'
  ClientHeight = 413
  ClientWidth = 352
  Color = clBtnFace
  Constraints.MinHeight = 440
  Constraints.MinWidth = 360
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
  object Label5: TLabel
    Left = 24
    Top = 16
    Width = 62
    Height = 13
    Caption = 'Mixer &Device'
    FocusControl = c_comboBox_mixerIndex
  end
  object c_label_out: TLabel
    Left = 20
    Top = 56
    Width = 67
    Height = 13
    Caption = 'Playback Line'
    FocusControl = c_trackBar_outMain
  end
  object c_label_in: TLabel
    Left = 204
    Top = 56
    Width = 109
    Height = 13
    Caption = 'Recording Source Line'
    FocusControl = c_trackBar_inMain
  end
  object c_label_URL: TLabel
    Left = 115
    Top = 368
    Width = 117
    Height = 13
    Cursor = crHandPoint
    Hint = 'Click to visit VC components web page - http://lakeofsoft.com/vc'
    Caption = 'http://lakeofsoft.com/vc'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    OnClick = c_label_URLClick
  end
  object Label3: TLabel
    Left = 50
    Top = 240
    Width = 18
    Height = 13
    Caption = 'Left'
  end
  object Label4: TLabel
    Left = 50
    Top = 256
    Width = 25
    Height = 13
    Caption = 'Right'
  end
  object Bevel1: TBevel
    Left = 8
    Top = 44
    Width = 332
    Height = 2
    Anchors = [akLeft, akTop, akRight]
  end
  object Bevel2: TBevel
    Left = 8
    Top = 224
    Width = 332
    Height = 2
    Anchors = [akLeft, akTop, akRight]
  end
  object Bevel3: TBevel
    Left = 175
    Top = 52
    Width = 2
    Height = 165
  end
  object Bevel4: TBevel
    Left = 12
    Top = 316
    Width = 332
    Height = 2
    Anchors = [akLeft, akTop, akRight]
  end
  object Label1: TLabel
    Left = 96
    Top = 328
    Width = 155
    Height = 13
    Caption = 'System Mixer Control Demo'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 76
    Top = 348
    Width = 195
    Height = 13
    Caption = 'Copyright (c) 2002-2003 Lake of Soft, Ltd'
  end
  object SpeedButton1: TSpeedButton
    Left = 184
    Top = 168
    Width = 13
    Height = 13
    Caption = '-'
    Layout = blGlyphBottom
    Visible = False
    OnClick = SpeedButton1Click
  end
  object SpeedButton2: TSpeedButton
    Left = 340
    Top = 168
    Width = 13
    Height = 13
    Caption = '+'
    Layout = blGlyphBottom
    Visible = False
    OnClick = SpeedButton2Click
  end
  object c_statusBar_main: TStatusBar
    Left = 0
    Top = 394
    Width = 352
    Height = 19
    Panels = <
      item
        Width = 100
      end
      item
        Width = 50
      end>
    SimplePanel = False
  end
  object c_comboBox_mixerIndex: TComboBox
    Left = 100
    Top = 12
    Width = 209
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 0
    OnChange = c_comboBox_mixerIndexChange
  end
  object c_comboBox_outConn: TComboBox
    Left = 20
    Top = 132
    Width = 129
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 2
    OnChange = c_comboBox_outConnChange
  end
  object c_trackBar_out: TTrackBar
    Tag = 1
    Left = 13
    Top = 156
    Width = 141
    Height = 33
    Max = 100
    Orientation = trHorizontal
    Frequency = 5
    Position = 0
    SelEnd = 0
    SelStart = 0
    TabOrder = 3
    ThumbLength = 16
    TickMarks = tmTopLeft
    TickStyle = tsAuto
    OnChange = c_voumeBar_change
  end
  object c_comboBox_inConn: TComboBox
    Left = 204
    Top = 132
    Width = 129
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 6
    OnChange = c_comboBox_inConnChange
  end
  object c_trackBar_in: TTrackBar
    Tag = 3
    Left = 197
    Top = 156
    Width = 141
    Height = 33
    Max = 100
    Orientation = trHorizontal
    ParentShowHint = False
    Frequency = 5
    Position = 0
    SelEnd = 0
    SelStart = 0
    ShowHint = True
    TabOrder = 7
    ThumbLength = 16
    TickMarks = tmTopLeft
    TickStyle = tsAuto
    OnChange = c_voumeBar_change
  end
  object c_button_recStart: TButton
    Left = 92
    Top = 280
    Width = 75
    Height = 25
    Action = a_record
    TabOrder = 11
  end
  object c_button_recStop: TButton
    Left = 192
    Top = 280
    Width = 75
    Height = 25
    Action = a_stop
    TabOrder = 12
  end
  object c_progressBar_right: TProgressBar
    Left = 92
    Top = 256
    Width = 177
    Height = 13
    Min = 0
    Max = 300
    TabOrder = 9
  end
  object c_progressBar_left: TProgressBar
    Left = 92
    Top = 240
    Width = 177
    Height = 13
    Min = 0
    Max = 300
    TabOrder = 10
  end
  object c_trackBar_outMain: TTrackBar
    Left = 12
    Top = 72
    Width = 145
    Height = 33
    Max = 100
    Orientation = trHorizontal
    Frequency = 5
    Position = 0
    SelEnd = 0
    SelStart = 0
    TabOrder = 1
    TickMarks = tmTopLeft
    TickStyle = tsAuto
    OnChange = c_voumeBar_change
  end
  object c_trackBar_inMain: TTrackBar
    Tag = 2
    Left = 196
    Top = 72
    Width = 145
    Height = 33
    Max = 100
    Orientation = trHorizontal
    ParentShowHint = False
    Frequency = 5
    Position = 0
    SelEnd = 0
    SelStart = 0
    ShowHint = True
    TabOrder = 5
    TickMarks = tmTopLeft
    TickStyle = tsAuto
    OnChange = c_voumeBar_change
  end
  object c_checkBox_outMute: TCheckBox
    Left = 20
    Top = 192
    Width = 129
    Height = 17
    Caption = '&Muted'
    TabOrder = 4
    OnClick = c_checkBox_outMuteClick
  end
  object c_checkBox_inMuted: TCheckBox
    Left = 204
    Top = 192
    Width = 125
    Height = 17
    Caption = 'Mu&ted'
    Checked = True
    State = cbChecked
    TabOrder = 8
    OnClick = c_checkBox_inMutedClick
  end
  object c_checkBox_micForce: TCheckBox
    Left = 204
    Top = 112
    Width = 129
    Height = 17
    Caption = 'Force to Microphone'
    TabOrder = 14
    OnClick = c_checkBox_micForceClick
  end
  object c_actionList_main: TActionList
    Left = 40
    Top = 336
    object a_record: TAction
      Caption = 'R&ecord'
      OnExecute = a_recordExecute
    end
    object a_stop: TAction
      Caption = '&Stop'
      Enabled = False
      OnExecute = a_stopExecute
    end
  end
  object c_timer_update: TTimer
    Interval = 100
    OnTimer = c_timer_updateTimer
    Left = 12
    Top = 336
  end
end
