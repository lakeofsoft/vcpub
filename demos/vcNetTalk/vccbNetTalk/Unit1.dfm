object c_form_main: Tc_form_main
  Left = 205
  Top = 27
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'vccbNetTalk, version 1.0'
  ClientHeight = 415
  ClientWidth = 538
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
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object c_statusBar_main: TStatusBar
    Left = 0
    Top = 396
    Width = 538
    Height = 19
    Panels = <
      item
        Text = 'mem'
        Width = 150
      end
      item
        Text = '  Copyright (c) 2001-2002 Lake of Soft, Ltd'
        Width = 50
      end>
    SimplePanel = False
  end
  object c_pageControl_main: TPageControl
    Left = 0
    Top = 0
    Width = 538
    Height = 396
    ActivePage = c_tabSheet_server
    Align = alClient
    TabOrder = 1
    object c_tabSheet_server: TTabSheet
      Caption = 'Server'
      object c_groupBox_server: TGroupBox
        Left = 0
        Top = 0
        Width = 530
        Height = 368
        Align = alClient
        TabOrder = 0
        object Label1: TLabel
          Left = 144
          Top = 20
          Width = 57
          Height = 13
          Caption = 'Port number'
        end
        object Bevel1: TBevel
          Left = 321
          Top = 16
          Width = 2
          Height = 257
        end
        object c_label_statusSrv: TLabel
          Left = 2
          Top = 353
          Width = 526
          Height = 13
          Align = alBottom
          AutoSize = False
          Color = clGray
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentColor = False
          ParentFont = False
        end
        object Bevel4: TBevel
          Left = 8
          Top = 108
          Width = 301
          Height = 2
        end
        object Label5: TLabel
          Left = 20
          Top = 116
          Width = 85
          Height = 13
          Caption = 'Streaming Format:'
        end
        object Label6: TLabel
          Left = 20
          Top = 20
          Width = 57
          Height = 13
          Caption = 'Socket type'
        end
        object Bevel5: TBevel
          Left = 8
          Top = 228
          Width = 301
          Height = 2
        end
        object c_edit_serverPort: TEdit
          Left = 144
          Top = 36
          Width = 133
          Height = 21
          TabOrder = 0
          Text = '17810'
        end
        object c_button_startServer: TButton
          Left = 444
          Top = 36
          Width = 75
          Height = 25
          Action = a_srvStart
          TabOrder = 1
        end
        object c_button_stopServer: TButton
          Left = 444
          Top = 68
          Width = 75
          Height = 25
          Action = a_srvStop
          TabOrder = 2
        end
        object c_checkListBox_server: TCheckListBox
          Left = 336
          Top = 36
          Width = 101
          Height = 129
          ItemHeight = 13
          Items.Strings = (
            'waveIn'
            'riffIn'
            'resampler'
            'mixer'
            'codecIn'
            'ipServer'
            'codecOut'
            'waveOut')
          TabOrder = 3
        end
        object c_edit_waveNameServer: TEdit
          Left = 20
          Top = 196
          Width = 241
          Height = 21
          TabOrder = 4
        end
        object c_checkBox_mixWaveServer: TCheckBox
          Left = 20
          Top = 176
          Width = 225
          Height = 17
          Caption = 'Mix recording with WAVe file:'
          TabOrder = 5
        end
        object c_button_chooseWaveServer: TButton
          Left = 264
          Top = 196
          Width = 25
          Height = 21
          Caption = '...'
          TabOrder = 6
          OnClick = c_button_chooseWaveServerClick
        end
        object c_checkBox_useWaveInServer: TCheckBox
          Left = 20
          Top = 154
          Width = 225
          Height = 17
          Caption = 'Use waveIn device for recording'
          TabOrder = 7
        end
        object c_button_formatChooseServer: TButton
          Left = 264
          Top = 131
          Width = 29
          Height = 19
          Caption = '>>'
          TabOrder = 8
          OnClick = c_button_formatChooseServerClick
        end
        object c_static_formatInfoServer: TStaticText
          Left = 20
          Top = 132
          Width = 241
          Height = 17
          AutoSize = False
          BorderStyle = sbsSunken
          ShowAccelChar = False
          TabOrder = 9
        end
        object c_staticText_deviceInfoServer: TStaticText
          Left = 336
          Top = 172
          Width = 185
          Height = 93
          AutoSize = False
          BorderStyle = sbsSingle
          TabOrder = 10
        end
        object c_checkBox_autoStartServer: TCheckBox
          Left = 20
          Top = 68
          Width = 257
          Height = 17
          Caption = '&Auto start server on startup'
          TabOrder = 11
        end
        object c_comboBox_socketTypeServer: TComboBox
          Left = 20
          Top = 36
          Width = 101
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 12
          OnChange = c_comboBox_socketTypeServerChange
          Items.Strings = (
            'UDP'
            'TCP')
        end
        object c_pb_volumeOutServer: TProgressBar
          Left = 20
          Top = 256
          Width = 269
          Height = 9
          Min = 0
          Max = 300
          TabOrder = 13
        end
        object c_pb_volumeInServer: TProgressBar
          Left = 20
          Top = 244
          Width = 269
          Height = 9
          Min = 0
          Max = 300
          TabOrder = 14
        end
      end
    end
    object c_tabSheet_client: TTabSheet
      Caption = 'Client'
      ImageIndex = 1
      object c_groupBox_client: TGroupBox
        Left = 0
        Top = 0
        Width = 530
        Height = 368
        Align = alClient
        TabOrder = 0
        object Label2: TLabel
          Left = 20
          Top = 64
          Width = 151
          Height = 13
          Caption = 'Server host (IP or DNS address)'
        end
        object Label3: TLabel
          Left = 144
          Top = 20
          Width = 90
          Height = 13
          Caption = 'Server port number'
        end
        object Bevel2: TBevel
          Left = 321
          Top = 16
          Width = 2
          Height = 256
        end
        object c_label_statusClient: TLabel
          Left = 2
          Top = 353
          Width = 526
          Height = 13
          Align = alBottom
          AutoSize = False
          Color = clGray
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentColor = False
          ParentFont = False
        end
        object Bevel3: TBevel
          Left = 8
          Top = 108
          Width = 301
          Height = 2
        end
        object Label4: TLabel
          Left = 20
          Top = 116
          Width = 85
          Height = 13
          Caption = 'Streaming Format:'
        end
        object Label7: TLabel
          Left = 20
          Top = 20
          Width = 89
          Height = 13
          Caption = 'Server socket type'
        end
        object Bevel6: TBevel
          Left = 8
          Top = 228
          Width = 301
          Height = 2
        end
        object c_edit_clientSrvHost: TEdit
          Left = 20
          Top = 80
          Width = 257
          Height = 21
          TabOrder = 0
          Text = '127.0.0.1'
        end
        object c_button_startClient: TButton
          Left = 444
          Top = 36
          Width = 75
          Height = 25
          Action = a_clientStart
          TabOrder = 1
        end
        object c_button_stopClient: TButton
          Left = 444
          Top = 68
          Width = 75
          Height = 25
          Action = a_clientStop
          TabOrder = 2
        end
        object c_edit_clientSrvPort: TEdit
          Left = 144
          Top = 36
          Width = 133
          Height = 21
          TabOrder = 3
          Text = '17810'
        end
        object c_checkListBox_client: TCheckListBox
          Left = 336
          Top = 36
          Width = 101
          Height = 129
          ItemHeight = 13
          Items.Strings = (
            'waveIn'
            'riffIn'
            'resampler'
            'mixer'
            'codecIn'
            'ipClient'
            'codecOut'
            'waveOut')
          TabOrder = 4
        end
        object c_checkBox_mixWaveClient: TCheckBox
          Left = 20
          Top = 176
          Width = 241
          Height = 17
          Caption = 'Mix recording with WAVe file:'
          TabOrder = 5
        end
        object c_edit_waveNameClient: TEdit
          Left = 20
          Top = 196
          Width = 241
          Height = 21
          TabOrder = 6
        end
        object c_button_chooseWaveClient: TButton
          Left = 264
          Top = 196
          Width = 25
          Height = 21
          Caption = '...'
          TabOrder = 7
          OnClick = c_button_chooseWaveClientClick
        end
        object c_checkBox_useWaveInClient: TCheckBox
          Left = 20
          Top = 154
          Width = 225
          Height = 17
          Caption = 'Use waveIn device for recording'
          TabOrder = 8
        end
        object c_static_formatInfoClient: TStaticText
          Left = 20
          Top = 132
          Width = 241
          Height = 17
          AutoSize = False
          BorderStyle = sbsSunken
          ShowAccelChar = False
          TabOrder = 9
        end
        object c_button_formatChooseClient: TButton
          Left = 264
          Top = 131
          Width = 29
          Height = 19
          Caption = '>>'
          TabOrder = 10
          OnClick = c_button_formatChooseClientClick
        end
        object c_staticText_deviceInfoClient: TStaticText
          Left = 336
          Top = 172
          Width = 185
          Height = 93
          AutoSize = False
          BorderStyle = sbsSingle
          TabOrder = 11
        end
        object c_comboBox_socketTypeClient: TComboBox
          Left = 20
          Top = 36
          Width = 101
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 12
          OnChange = c_comboBox_socketTypeClientChange
          Items.Strings = (
            'UDP'
            'TCP')
        end
        object c_pb_volumeOutClient: TProgressBar
          Left = 20
          Top = 256
          Width = 269
          Height = 9
          Min = 0
          Max = 300
          TabOrder = 13
        end
        object c_pb_volumeInClient: TProgressBar
          Left = 20
          Top = 244
          Width = 269
          Height = 9
          Min = 0
          Max = 300
          TabOrder = 14
        end
      end
    end
  end
  object c_openDialog_wave: TOpenDialog
    Filter = 'WAV files (*.wav)|*.wav|All files (*.*)|*.*'
    Options = [ofReadOnly, ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 184
    Top = 88
  end
  object c_actionList_main: TActionList
    Left = 160
    Top = 88
    object a_srvStart: TAction
      Caption = '&Start'
      OnExecute = a_srvStartExecute
    end
    object a_srvStop: TAction
      Caption = 'S&top'
      Enabled = False
      OnExecute = a_srvStopExecute
    end
    object a_clientStart: TAction
      Caption = '&Connect'
      OnExecute = a_clientStartExecute
    end
    object a_clientStop: TAction
      Caption = 'C&lose'
      Enabled = False
      OnExecute = a_clientStopExecute
    end
  end
  object c_timer_update: TTimer
    Enabled = False
    Interval = 300
    OnTimer = c_timer_updateTimer
    Left = 264
    Top = 88
  end
  object riff_client: TunavclWaveRiff
    consumer = resampler_client
    isFormatProvider = True
    realTime = True
    loop = True
    Left = 16
    Top = 332
  end
  object resampler_client: TunavclWaveResampler
    consumer = mixer_client
    autoActivate = False
    realTime = True
    Left = 44
    Top = 332
  end
  object waveIn_client: TunavclWaveInDevice
    consumer = mixer_client
    isFormatProvider = False
    autoActivate = False
    Left = 44
    Top = 304
  end
  object mixer_client: TunavclWaveMixer
    consumer = codecIn_client
    calcVolume = True
    addSilence = True
    realTime = True
    Left = 72
    Top = 312
  end
  object codecIn_client: TunavclWaveCodecDevice
    consumer = ipClient
    autoActivate = False
    Left = 100
    Top = 312
  end
  object ipClient: TunavclIPOutStream
    consumer = codecOut_client
    isFormatProvider = True
    onClientDisconnect = ipClientClientDisconnect
    Left = 132
    Top = 312
  end
  object codecOut_client: TunavclWaveCodecDevice
    consumer = waveOut_client
    inputIsPcm = False
    formatTagImmunable = False
    Left = 164
    Top = 312
  end
  object waveOut_client: TunavclWaveOutDevice
    calcVolume = True
    Left = 192
    Top = 312
  end
  object riff_server: TunavclWaveRiff
    consumer = resampler_server
    isFormatProvider = True
    realTime = True
    loop = True
    Left = 292
    Top = 328
  end
  object resampler_server: TunavclWaveResampler
    consumer = mixer_server
    autoActivate = False
    realTime = True
    Left = 320
    Top = 328
  end
  object waveIn_server: TunavclWaveInDevice
    consumer = mixer_server
    isFormatProvider = False
    autoActivate = False
    Left = 320
    Top = 300
  end
  object mixer_server: TunavclWaveMixer
    consumer = codecIn_server
    calcVolume = True
    addSilence = True
    realTime = True
    Left = 348
    Top = 312
  end
  object codecIn_server: TunavclWaveCodecDevice
    consumer = ipServer
    autoActivate = False
    Left = 376
    Top = 312
  end
  object ipServer: TunavclIPInStream
    consumer = codecOut_server
    Left = 408
    Top = 312
  end
  object codecOut_server: TunavclWaveCodecDevice
    consumer = waveOut_server
    inputIsPcm = False
    formatTagImmunable = False
    Left = 440
    Top = 312
  end
  object waveOut_server: TunavclWaveOutDevice
    calcVolume = True
    Left = 468
    Top = 312
  end
end
