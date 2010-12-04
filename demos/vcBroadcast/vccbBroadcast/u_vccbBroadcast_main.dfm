object c_form_main: Tc_form_main
  Left = 132
  Top = 33
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'VC 2.5 Pro - Broadcast Demo'
  ClientHeight = 328
  ClientWidth = 285
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object c_pageControl_main: TPageControl
    Left = 0
    Top = 0
    Width = 285
    Height = 309
    ActivePage = c_tabSheet_client
    Align = alClient
    TabOrder = 0
    object c_tabSheet_server: TTabSheet
      Caption = 'Server'
      object c_label_serverPort: TLabel
        Left = 16
        Top = 52
        Width = 60
        Height = 13
        Caption = '&Port number:'
        FocusControl = c_edit_serverPort
      end
      object c_label_serverStat: TLabel
        Left = 0
        Top = 268
        Width = 277
        Height = 13
        Align = alBottom
        Caption = 'Server:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object c_label_url: TLabel
        Left = 80
        Top = 244
        Width = 117
        Height = 13
        Cursor = crHandPoint
        Hint = 
          'Click to visit the Voice Communicator components web page - http' +
          '://lakeofsoft.com/vc'
        Caption = 'http://lakeofsoft.com/vc'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsUnderline]
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        OnClick = c_label_urlClick
      end
      object Bevel1: TBevel
        Left = 8
        Top = 120
        Width = 261
        Height = 2
      end
      object Bevel2: TBevel
        Left = 8
        Top = 16
        Width = 261
        Height = 2
      end
      object Bevel3: TBevel
        Left = 8
        Top = 168
        Width = 261
        Height = 2
      end
      object c_label_web: TLabel
        Left = 46
        Top = 228
        Width = 185
        Height = 13
        Caption = 'Visit our web page for more information:'
      end
      object Label1: TLabel
        Left = 73
        Top = 180
        Width = 130
        Height = 13
        Caption = 'Audio Broadcast Demo'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label2: TLabel
        Left = 41
        Top = 204
        Width = 195
        Height = 13
        Caption = 'Copyright (c) 2000-2003 Lake of Soft, Ltd'
      end
      object c_edit_serverPort: TEdit
        Left = 108
        Top = 48
        Width = 153
        Height = 21
        TabOrder = 0
        Text = '17830'
      end
      object c_button_serverStart: TButton
        Left = 60
        Top = 132
        Width = 73
        Height = 25
        Action = a_startServer
        TabOrder = 1
      end
      object c_button_serverStop: TButton
        Left = 144
        Top = 132
        Width = 73
        Height = 25
        Action = a_stopServer
        TabOrder = 2
      end
      object c_checkBox_serverAutoStart: TCheckBox
        Left = 16
        Top = 24
        Width = 241
        Height = 17
        Caption = 'Activate Broadcast Server on Startup'
        TabOrder = 3
      end
      object c_button_ac: TButton
        Left = 16
        Top = 80
        Width = 245
        Height = 25
        Caption = '&Audio Configuration...'
        TabOrder = 4
        OnClick = c_button_acClick
      end
    end
    object c_tabSheet_client: TTabSheet
      Caption = 'Client'
      ImageIndex = 1
      object c_label_clientPort: TLabel
        Left = 16
        Top = 124
        Width = 60
        Height = 13
        Caption = '&Port number:'
        FocusControl = c_edit_clientPort
      end
      object c_label_clientStat: TLabel
        Left = 0
        Top = 268
        Width = 277
        Height = 13
        Align = alBottom
        Caption = 'Client:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object Bevel4: TBevel
        Left = 8
        Top = 16
        Width = 261
        Height = 2
      end
      object Bevel5: TBevel
        Left = 4
        Top = 152
        Width = 261
        Height = 2
      end
      object Bevel6: TBevel
        Left = 8
        Top = 200
        Width = 261
        Height = 2
      end
      object c_edit_clientPort: TEdit
        Left = 108
        Top = 120
        Width = 153
        Height = 21
        TabOrder = 0
        Text = '17830'
      end
      object c_static_clientInfo: TStaticText
        Left = 12
        Top = 28
        Width = 249
        Height = 85
        AutoSize = False
        BorderStyle = sbsSunken
        TabOrder = 1
      end
      object c_button_clientStart: TButton
        Left = 62
        Top = 164
        Width = 73
        Height = 25
        Action = a_startClient
        TabOrder = 2
      end
      object c_button_clientStop: TButton
        Left = 142
        Top = 164
        Width = 73
        Height = 25
        Action = a_stopClient
        TabOrder = 3
      end
      object c_edit_saveWAVname: TEdit
        Left = 12
        Top = 232
        Width = 225
        Height = 21
        TabOrder = 4
        OnChange = c_edit_saveWAVnameChange
      end
      object c_button_saveWAV: TButton
        Left = 240
        Top = 232
        Width = 25
        Height = 21
        Caption = '...'
        TabOrder = 5
        OnClick = c_button_saveWAVClick
      end
      object c_checkBox_saveWAV: TCheckBox
        Left = 12
        Top = 212
        Width = 197
        Height = 17
        Caption = 'Save wave stream to file:'
        TabOrder = 6
      end
    end
  end
  object c_statusBar_main: TStatusBar
    Left = 0
    Top = 309
    Width = 285
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object c_actionList_main: TActionList
    Left = 248
    Top = 176
    object a_startServer: TAction
      Caption = '&Broadcast'
      OnExecute = a_startServerExecute
    end
    object a_stopServer: TAction
      Caption = '&Stop'
      OnExecute = a_stopServerExecute
    end
    object a_startClient: TAction
      Caption = '&Listen'
      OnExecute = a_startClientExecute
    end
    object a_stopClient: TAction
      Caption = '&Stop'
      OnExecute = a_stopClientExecute
    end
  end
  object waveIn_server: TunavclWaveInDevice
    consumer = codecIn_server
    Left = 40
    Top = 296
  end
  object waveOut_client: TunavclWaveOutDevice
    isFormatProvider = True
    Left = 232
    Top = 60
  end
  object codecIn_server: TunavclWaveCodecDevice
    consumer = c_broadcastServer
    Left = 68
    Top = 296
  end
  object c_timer_main: TTimer
    Enabled = False
    OnTimer = c_timer_mainTimer
    Left = 220
    Top = 176
  end
  object codecOut_client: TunavclWaveCodecDevice
    consumer = waveOut_client
    onDataAvailable = codecOut_clientDataAvailable
    inputIsPcm = False
    formatTagImmunable = False
    Left = 204
    Top = 60
  end
  object c_broadcastServer: TunavclIPBroadcastServer
    port = '17830'
    Left = 96
    Top = 296
  end
  object c_broadcastClient: TunavclIPBroadcastClient
    consumer = codecOut_client
    port = '17830'
    Left = 176
    Top = 60
  end
  object wavWrite: TunavclWaveRiff
    isInput = False
    Left = 124
    Top = 296
  end
  object c_sd_saveWAV: TSaveDialog
    DefaultExt = 'wav'
    Filter = 'WAV files (*.wav)|*.wav|All files (*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Left = 224
    Top = 280
  end
end
