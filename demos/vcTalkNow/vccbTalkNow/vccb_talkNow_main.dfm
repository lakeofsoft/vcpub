object c_form_main: Tc_form_main
  Left = 216
  Top = 51
  AutoScroll = False
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'VC 2.5 Pro - Talk Now Demo'
  ClientHeight = 343
  ClientWidth = 411
  Color = clBtnFace
  Constraints.MinHeight = 370
  Constraints.MinWidth = 280
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object c_paintBox_network: TPaintBox
    Left = 0
    Top = 281
    Width = 411
    Height = 43
    Hint = 'Red - Client;  Green - Server'
    Align = alClient
    ParentShowHint = False
    ShowHint = True
    OnPaint = c_paintBox_networkPaint
  end
  object c_statusBar_main: TStatusBar
    Left = 0
    Top = 324
    Width = 411
    Height = 19
    Panels = <
      item
        Width = 100
      end
      item
        Text = 'Copyright (c) 2000-2003 Lake of Soft, Ltd'
        Width = 50
      end>
    SimplePanel = False
  end
  object c_panel_main: TPanel
    Left = 0
    Top = 0
    Width = 411
    Height = 281
    Align = alTop
    BevelOuter = bvLowered
    FullRepaint = False
    TabOrder = 1
    object Label4: TLabel
      Left = 140
      Top = 16
      Width = 64
      Height = 13
      Caption = 'Socket &Type:'
      FocusControl = c_comboBox_socketTypeServer
    end
    object Label1: TLabel
      Left = 140
      Top = 60
      Width = 22
      Height = 13
      Caption = '&Port:'
      FocusControl = c_edit_serverPort
    end
    object c_label_serverStat: TLabel
      Left = 4
      Top = 124
      Width = 402
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'Server:'
    end
    object Label5: TLabel
      Left = 140
      Top = 156
      Width = 64
      Height = 13
      Caption = 'Socket T&ype:'
      FocusControl = c_comboBox_socketTypeClient
    end
    object Label3: TLabel
      Left = 140
      Top = 200
      Width = 103
      Height = 13
      Caption = 'Server A&ddress : Port:'
      FocusControl = c_edit_serverIPclient
    end
    object c_label_clientStat: TLabel
      Left = 4
      Top = 264
      Width = 402
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'Client:'
    end
    object Bevel5: TBevel
      Left = 4
      Top = 140
      Width = 404
      Height = 2
      Anchors = [akLeft, akTop, akRight]
    end
    object c_comboBox_socketTypeServer: TComboBox
      Left = 140
      Top = 32
      Width = 133
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 3
      OnChange = c_comboBox_socketTypeServerChange
      Items.Strings = (
        'UDP'
        'TCP')
    end
    object c_edit_serverPort: TEdit
      Left = 140
      Top = 76
      Width = 133
      Height = 21
      TabOrder = 4
      Text = '17820'
    end
    object c_pb_serverIn: TProgressBar
      Left = 16
      Top = 12
      Width = 109
      Height = 9
      Min = 0
      Max = 300
      Smooth = True
      TabOrder = 5
    end
    object c_button_serverStop: TButton
      Left = 72
      Top = 44
      Width = 53
      Height = 25
      Action = server_stop
      TabOrder = 1
    end
    object c_button_serverStart: TButton
      Left = 16
      Top = 44
      Width = 53
      Height = 25
      Action = server_start
      TabOrder = 0
    end
    object c_comboBox_socketTypeClient: TComboBox
      Left = 140
      Top = 172
      Width = 133
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 9
      OnChange = c_comboBox_socketTypeClientChange
      Items.Strings = (
        'UDP'
        'TCP')
    end
    object c_button_clientStart: TButton
      Left = 8
      Top = 184
      Width = 53
      Height = 25
      Action = client_start
      TabOrder = 6
    end
    object c_button_clientStop: TButton
      Left = 64
      Top = 184
      Width = 65
      Height = 25
      Action = client_stop
      TabOrder = 7
    end
    object c_pb_clientIn: TProgressBar
      Left = 8
      Top = 152
      Width = 121
      Height = 9
      Min = 0
      Max = 300
      Smooth = True
      TabOrder = 12
    end
    object c_edit_serverPortClient: TEdit
      Left = 228
      Top = 216
      Width = 41
      Height = 21
      TabOrder = 11
      Text = '17820'
    end
    object c_edit_serverIPclient: TEdit
      Left = 140
      Top = 216
      Width = 85
      Height = 21
      TabOrder = 10
      Text = '192.168.1.1'
    end
    object c_button_configAudioSrv: TButton
      Left = 16
      Top = 76
      Width = 109
      Height = 25
      Caption = '&Audio Options..'
      TabOrder = 2
      OnClick = c_button_configAudioSrvClick
    end
    object c_button_configAudioCln: TButton
      Left = 8
      Top = 216
      Width = 121
      Height = 25
      Caption = 'A&udio Options..'
      TabOrder = 8
      OnClick = c_button_configAudioClnClick
    end
    object c_clb_server: TCheckListBox
      Left = 288
      Top = 12
      Width = 93
      Height = 109
      Enabled = False
      ItemHeight = 13
      Items.Strings = (
        'waveIn'
        'codecIn'
        'ipServer'
        'codecOut'
        'waveOut')
      TabOrder = 13
    end
    object c_clb_client: TCheckListBox
      Left = 288
      Top = 152
      Width = 93
      Height = 109
      Enabled = False
      ItemHeight = 13
      Items.Strings = (
        'waveIn'
        'codecIn'
        'ipClient'
        'codecOut'
        'waveOut')
      TabOrder = 14
    end
    object c_pb_clientOut: TProgressBar
      Left = 8
      Top = 164
      Width = 121
      Height = 9
      Min = 0
      Max = 300
      Smooth = True
      TabOrder = 15
    end
    object c_pb_serverOut: TProgressBar
      Left = 16
      Top = 24
      Width = 109
      Height = 9
      Min = 0
      Max = 300
      Smooth = True
      TabOrder = 16
    end
  end
  object ipClient: TunavclIPOutStream
    consumer = codecOut_client
    isFormatProvider = True
    onPacketEvent = ipClientPacketEvent
    onSocketEvent = ipClientSocketEvent
    onClientDisconnect = ipClientClientDisconnect
    Left = 328
    Top = 200
  end
  object ipServer: TunavclIPInStream
    consumer = codecOut_server
    onPacketEvent = ipServerPacketEvent
    onSocketEvent = ipServerSocketEvent
    Left = 324
    Top = 60
  end
  object waveOut_client: TunavclWaveOutDevice
    calcVolume = True
    Left = 340
    Top = 248
  end
  object waveOut_server: TunavclWaveOutDevice
    calcVolume = True
    Left = 340
    Top = 108
  end
  object c_actionList_main: TActionList
    Left = 196
    Top = 100
    object server_start: TAction
      Caption = '&Listen'
      OnExecute = server_startExecute
    end
    object server_stop: TAction
      Caption = '&Stop'
      Enabled = False
      OnExecute = server_stopExecute
    end
    object client_start: TAction
      Caption = '&Connect'
      OnExecute = client_startExecute
    end
    object client_stop: TAction
      Caption = '&Disconnect'
      Enabled = False
      OnExecute = client_stopExecute
    end
  end
  object c_timer_update: TTimer
    Interval = 200
    OnTimer = c_timer_updateTimer
    Left = 168
    Top = 100
  end
  object waveIn_client: TunavclWaveInDevice
    consumer = codecIn_client
    calcVolume = True
    pcm_numChannels = 1
    Left = 316
    Top = 156
  end
  object waveIn_server: TunavclWaveInDevice
    consumer = codecIn_server
    calcVolume = True
    pcm_numChannels = 1
    Left = 312
    Top = 16
  end
  object codecIn_client: TunavclWaveCodecDevice
    consumer = ipClient
    formatTag = 49
    Left = 344
    Top = 156
  end
  object codecOut_client: TunavclWaveCodecDevice
    consumer = waveOut_client
    inputIsPcm = False
    formatTagImmunable = False
    Left = 312
    Top = 248
  end
  object codecIn_server: TunavclWaveCodecDevice
    consumer = ipServer
    formatTag = 49
    Left = 340
    Top = 16
  end
  object codecOut_server: TunavclWaveCodecDevice
    consumer = waveOut_server
    inputIsPcm = False
    formatTagImmunable = False
    Left = 312
    Top = 108
  end
  object MainMenu1: TMainMenu
    AutoLineReduction = maManual
    Left = 140
    Top = 100
    object mi_file_root: TMenuItem
      Caption = '&File'
      object mi_file_listen: TMenuItem
        Action = server_start
      end
      object mi_file_stop: TMenuItem
        Action = server_stop
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object mi_file_connect: TMenuItem
        Action = client_start
      end
      object mi_file_disconnect: TMenuItem
        Action = client_stop
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object mi_file_exit: TMenuItem
        Caption = 'E&xit'
        OnClick = mi_file_exitClick
      end
    end
    object mi_options_root: TMenuItem
      Caption = 'Options'
      object mi_options_autoActivateSrv: TMenuItem
        Caption = 'Activate Server on Startup'
        OnClick = mi_options_autoActivateSrvClick
      end
      object mi_options_LLN: TMenuItem
        Caption = 'Long Latency Networks'
        OnClick = mi_options_LLNClick
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object mi_options_maxClients: TMenuItem
        Caption = 'Max. Number of Clients'
        object mi_options_maxClients_1: TMenuItem
          Tag = 1
          Caption = '1'
          Checked = True
          RadioItem = True
          OnClick = numClientsClick
        end
        object mi_options_maxClients_2: TMenuItem
          Tag = 2
          Caption = '2'
          RadioItem = True
          OnClick = numClientsClick
        end
        object mi_options_maxClients_10: TMenuItem
          Tag = 10
          Caption = '10'
          RadioItem = True
          OnClick = numClientsClick
        end
        object N4: TMenuItem
          Caption = '-'
        end
        object mi_options_maxClients_unlimited: TMenuItem
          Tag = -1
          Caption = 'Unlimited'
          RadioItem = True
          OnClick = numClientsClick
        end
      end
    end
    object mi_help_root: TMenuItem
      Caption = 'Help'
      object mi_help_about: TMenuItem
        Caption = 'About'
        OnClick = mi_help_aboutClick
      end
    end
  end
end
