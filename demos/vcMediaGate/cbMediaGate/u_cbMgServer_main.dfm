object c_form_main: Tc_form_main
  Left = 150
  Top = 66
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'VC 2.5 Pro - MediaGate Demo / Server'
  ClientHeight = 268
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
    Left = 20
    Top = 24
    Width = 53
    Height = 13
    Caption = 'Speak Port'
  end
  object Label2: TLabel
    Left = 20
    Top = 92
    Width = 50
    Height = 13
    Caption = 'Listen Port'
  end
  object Label3: TLabel
    Left = 152
    Top = 32
    Width = 285
    Height = 37
    AutoSize = False
    Caption = 
      'This port is used to receive source audio stream. MediaGate Clie' +
      'nt in "speak" mode should connect to this port.'
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
    Top = 80
    Width = 430
    Height = 2
  end
  object Label4: TLabel
    Left = 151
    Top = 100
    Width = 285
    Height = 37
    AutoSize = False
    Caption = 
      'This port is used to send audio stream. MediaGate Clients in "li' +
      'sten" mode should connect to this port.'
    WordWrap = True
  end
  object Bevel3: TBevel
    Left = 8
    Top = 148
    Width = 430
    Height = 2
  end
  object c_label_listeners: TLabel
    Left = 20
    Top = 212
    Width = 70
    Height = 14
    Caption = 'Listeners:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
  end
  object c_label_served: TLabel
    Left = 20
    Top = 228
    Width = 56
    Height = 14
    Caption = 'Served: '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
  end
  object c_label_received: TLabel
    Left = 20
    Top = 196
    Width = 70
    Height = 14
    Caption = 'Listeners:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
  end
  object c_edit_speakPort: TEdit
    Left = 20
    Top = 40
    Width = 121
    Height = 21
    TabOrder = 0
    Text = '17860'
  end
  object c_edit_listenPort: TEdit
    Left = 20
    Top = 108
    Width = 121
    Height = 21
    TabOrder = 1
    Text = '17861'
  end
  object c_button_start: TButton
    Left = 20
    Top = 160
    Width = 75
    Height = 25
    Action = a_srv_start
    TabOrder = 2
  end
  object c_button_stop: TButton
    Left = 108
    Top = 160
    Width = 75
    Height = 25
    Action = a_srv_stop
    TabOrder = 3
  end
  object c_clb_debug: TCheckListBox
    Left = 312
    Top = 160
    Width = 121
    Height = 69
    ItemHeight = 13
    Items.Strings = (
      'speakServer'
      'not used'
      'not used'
      'listenServer')
    TabOrder = 4
    Visible = False
  end
  object c_statusBar_main: TStatusBar
    Left = 0
    Top = 249
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
  object speakServer: TunavclIPInStream
    consumer = listenServer
    Left = 212
    Top = 156
  end
  object listenServer: TunavclIPInStream
    maxClients = 3
    Left = 264
    Top = 192
  end
  object c_timer_update: TTimer
    Interval = 500
    OnTimer = c_timer_updateTimer
    Left = 376
    Top = 176
  end
  object c_actionList_main: TActionList
    Left = 144
    Top = 200
    object a_srv_start: TAction
      Caption = '&Start'
      OnExecute = a_srv_startExecute
    end
    object a_srv_stop: TAction
      Caption = 'S&top'
      Enabled = False
      OnExecute = a_srv_stopExecute
    end
  end
end
