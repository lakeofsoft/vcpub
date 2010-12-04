object c_form_main: Tc_form_main
  Left = 141
  Top = 50
  Width = 544
  Height = 270
  Caption = 'VC 2.5 Pro - Voice Chat Demo'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = c_mainMenu
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object c_splitter_main: TSplitter
    Left = 0
    Top = 85
    Width = 536
    Height = 3
    Cursor = crVSplit
    Align = alTop
  end
  object c_memo_client: TMemo
    Left = 0
    Top = 0
    Width = 536
    Height = 85
    Align = alTop
    Enabled = False
    TabOrder = 0
    OnKeyPress = c_memo_clientKeyPress
  end
  object c_memo_remote: TMemo
    Left = 0
    Top = 88
    Width = 536
    Height = 113
    Align = alClient
    Color = clBtnFace
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object c_statusBar_main: TStatusBar
    Left = 0
    Top = 201
    Width = 536
    Height = 19
    Panels = <
      item
        Text = '1 800 KB'
        Width = 80
      end
      item
        Text = 'Mode: none'
        Width = 100
      end
      item
        Text = 'Copyright (c) 2002-2003 Lake of Soft, Ltd'
        Width = 50
      end>
    SimplePanel = False
  end
  object c_mainMenu: TMainMenu
    Left = 172
    Top = 108
    object mi_file: TMenuItem
      Caption = '&File'
      object mi_chat_goClient: TMenuItem
        Action = a_chat_beClient
      end
      object mi_chat_goServer: TMenuItem
        Action = a_chat_beServer
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object mi_chat_stop: TMenuItem
        Action = a_chat_stop
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object mi_file_exit: TMenuItem
        Action = c_file_exit
      end
    end
    object mi_edit: TMenuItem
      Caption = '&Edit'
      object mi_edit_audio: TMenuItem
        Caption = '&Audio Options'
        object mi_editAudio_1: TMenuItem
          Tag = 8000
          Caption = '&8 000 kHz'
          GroupIndex = 1
          RadioItem = True
          OnClick = mi_editAudio_click
        end
        object mi_editAudio_2: TMenuItem
          Tag = 11025
          Caption = '&11 025 kHz'
          GroupIndex = 1
          RadioItem = True
          OnClick = mi_editAudio_click
        end
        object mi_editAudio_3: TMenuItem
          Tag = 22050
          Caption = '&22 050 kHz'
          Checked = True
          GroupIndex = 1
          RadioItem = True
          OnClick = mi_editAudio_click
        end
        object N2: TMenuItem
          Caption = '-'
          GroupIndex = 1
        end
        object mi_esd: TMenuItem
          Caption = 'Enable Silence Detection'
          GroupIndex = 1
          OnClick = mi_esdClick
        end
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object mi_edit_clearRemote: TMenuItem
        Caption = '&Clear remote text'
        OnClick = mi_edit_clearRemoteClick
      end
    end
    object mi_help: TMenuItem
      Caption = '&Help'
      object mi_help_about: TMenuItem
        Caption = '&About'
      end
    end
  end
  object c_actionList_main: TActionList
    Left = 264
    Top = 108
    object a_chat_beClient: TAction
      Category = 'chat'
      Caption = 'Start &Client ...'
      OnExecute = a_chat_beClientExecute
    end
    object a_chat_beServer: TAction
      Category = 'chat'
      Caption = 'Start &Server'
      OnExecute = a_chat_beServerExecute
    end
    object a_chat_stop: TAction
      Category = 'chat'
      Caption = 'Stop C&hat Session'
      OnExecute = a_chat_stopExecute
    end
    object c_file_exit: TAction
      Caption = 'E&xit'
      OnExecute = c_file_exitExecute
    end
  end
  object c_timer_update: TTimer
    OnTimer = c_timer_updateTimer
    Left = 356
    Top = 108
  end
  object waveIn: TunavclWaveInDevice
    consumer = codecIn
    calcVolume = True
    pcm_samplesPerSec = 22050
    pcm_numChannels = 1
    minVolumeLevel = 300
    Left = 56
    Top = 28
  end
  object codecIn: TunavclWaveCodecDevice
    formatTag = 49
    Left = 100
    Top = 28
  end
  object ipClient: TunavclIPOutStream
    isFormatProvider = True
    port = '17850'
    onTextData = ipClientTextData
    onClientConnect = ipClientClientConnect
    Left = 144
    Top = 28
  end
  object ipServer: TunavclIPInStream
    port = '17850'
    onTextData = ipServerTextData
    onServerNewClient = ipServerServerNewClient
    Left = 244
    Top = 28
  end
  object codecOut: TunavclWaveCodecDevice
    consumer = waveOut
    inputIsPcm = False
    formatTagImmunable = False
    Left = 292
    Top = 28
  end
  object waveOut: TunavclWaveOutDevice
    Left = 344
    Top = 28
  end
end
