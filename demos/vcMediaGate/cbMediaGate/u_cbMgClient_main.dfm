object c_form_main: Tc_form_main
  Left = 68
  Top = 56
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'VC 2.5 Pro - MediaGate Demo / Client'
  ClientHeight = 362
  ClientWidth = 446
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 24
    Width = 72
    Height = 13
    Caption = 'Server Address'
  end
  object Label2: TLabel
    Left = 16
    Top = 68
    Width = 53
    Height = 13
    Caption = 'Speak Port'
  end
  object Label3: TLabel
    Left = 16
    Top = 112
    Width = 50
    Height = 13
    Caption = 'Listen Port'
  end
  object Label4: TLabel
    Left = 148
    Top = 80
    Width = 285
    Height = 37
    AutoSize = False
    Caption = 
      'This port is used to send audio stream to Server. MediaGate "spe' +
      'ak" Server should be listening on this port.'
    WordWrap = True
  end
  object Bevel1: TBevel
    Left = 8
    Top = 12
    Width = 430
    Height = 2
  end
  object Bevel2: TBevel
    Left = 8
    Top = 172
    Width = 430
    Height = 2
  end
  object Label5: TLabel
    Left = 148
    Top = 124
    Width = 285
    Height = 37
    AutoSize = False
    Caption = 
      'This port is used to receive audio stream from Server. MediaGate' +
      ' "listen" Server should be listening on this port.'
    WordWrap = True
  end
  object Label6: TLabel
    Left = 116
    Top = 196
    Width = 274
    Height = 13
    Caption = 'Select this mode if you wish to send your stream to Server.'
  end
  object Label7: TLabel
    Left = 116
    Top = 224
    Width = 274
    Height = 13
    Caption = 'Select this mode if you wish to receive stream from Server.'
  end
  object Bevel3: TBevel
    Left = 8
    Top = 248
    Width = 430
    Height = 2
  end
  object c_label_stat: TLabel
    Left = 20
    Top = 308
    Width = 42
    Height = 14
    Caption = 'Stat: '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
  end
  object Label8: TLabel
    Left = 32
    Top = 8
    Width = 111
    Height = 13
    Caption = ' Network Configuration '
  end
  object Label9: TLabel
    Left = 24
    Top = 168
    Width = 62
    Height = 13
    Caption = ' Client Mode '
  end
  object c_edit_host: TEdit
    Left = 16
    Top = 40
    Width = 121
    Height = 21
    TabOrder = 0
    Text = '192.168.1.1'
  end
  object c_edit_speakPort: TEdit
    Left = 16
    Top = 84
    Width = 121
    Height = 21
    TabOrder = 1
    Text = '17860'
  end
  object c_rb_speak: TRadioButton
    Left = 24
    Top = 192
    Width = 69
    Height = 17
    Caption = 'Speak'
    Checked = True
    TabOrder = 2
    TabStop = True
  end
  object c_rb_listen: TRadioButton
    Left = 24
    Top = 220
    Width = 73
    Height = 17
    Caption = 'Listen'
    TabOrder = 3
  end
  object c_button_go: TButton
    Left = 20
    Top = 268
    Width = 75
    Height = 25
    Action = a_cln_start
    TabOrder = 4
  end
  object c_button_stop: TButton
    Left = 104
    Top = 268
    Width = 75
    Height = 25
    Action = a_cln_stop
    TabOrder = 5
  end
  object c_clb_debug: TCheckListBox
    Left = 308
    Top = 256
    Width = 121
    Height = 81
    ItemHeight = 13
    Items.Strings = (
      'waveIn'
      'codecIn'
      'ipClient'
      'codecOut'
      'waveOut')
    TabOrder = 6
    Visible = False
  end
  object c_edit_listenPort: TEdit
    Left = 16
    Top = 128
    Width = 121
    Height = 21
    TabOrder = 7
    Text = '17861'
  end
  object c_statusBar_main: TStatusBar
    Left = 0
    Top = 343
    Width = 446
    Height = 19
    Panels = <
      item
        Width = 100
      end
      item
        Text = ' Copyright (c) 2002-2003 Lake of Soft, Ltd'
        Width = 50
      end>
    SimplePanel = False
  end
  object c_checkBox_random: TCheckBox
    Left = 184
    Top = 272
    Width = 97
    Height = 17
    Caption = 'Random'
    TabOrder = 9
  end
  object waveIn: TunavclWaveInDevice
    consumer = codecIn
    pcm_samplesPerSec = 22050
    pcm_numChannels = 1
    Left = 160
    Top = 28
  end
  object codecIn: TunavclWaveCodecDevice
    consumer = ipClient
    formatTag = 49
    Left = 208
    Top = 28
  end
  object ipClient: TunavclIPOutStream
    consumer = codecOut
    isFormatProvider = True
    onClientDisconnect = ipClientClientDisconnect
    Left = 260
    Top = 28
  end
  object codecOut: TunavclWaveCodecDevice
    consumer = waveOut
    inputIsPcm = False
    formatTagImmunable = False
    Left = 316
    Top = 28
  end
  object waveOut: TunavclWaveOutDevice
    Left = 368
    Top = 28
  end
  object c_timer_update: TTimer
    Enabled = False
    Interval = 500
    OnTimer = c_timer_updateTimer
    Left = 396
    Top = 272
  end
  object c_actionList_main: TActionList
    Left = 228
    Top = 276
    object a_cln_start: TAction
      Caption = '&Start'
      OnExecute = a_cln_startExecute
    end
    object a_cln_stop: TAction
      Caption = 'S&top'
      OnExecute = a_cln_stopExecute
    end
  end
end
