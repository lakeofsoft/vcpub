object Form1: TForm1
  Left = 178
  Top = 14
  AutoScroll = False
  Caption = 'VC 2.5 Pro - MP3/Ogg Streaming Demo'
  ClientHeight = 443
  ClientWidth = 522
  Color = clBtnFace
  Constraints.MinHeight = 470
  Constraints.MinWidth = 530
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
  object c_statusBar_main: TStatusBar
    Left = 0
    Top = 424
    Width = 522
    Height = 19
    Panels = <
      item
        Width = 60
      end
      item
        Width = 210
      end
      item
        Text = 'Copyright (c) 2002-2003 Lake of Soft, Ltd'
        Width = 50
      end>
    SimplePanel = False
  end
  object c_pageControl_main: TPageControl
    Left = 0
    Top = 0
    Width = 522
    Height = 424
    ActivePage = c_tabSheet_encoder
    Align = alClient
    TabOrder = 1
    object c_tabSheet_encoder: TTabSheet
      Caption = 'Encoding [Server]'
      object c_bevel_encodeTop: TBevel
        Left = 16
        Top = 16
        Width = 481
        Height = 2
      end
      object c_label_encodeTop: TLabel
        Left = 48
        Top = 12
        Width = 73
        Height = 13
        Caption = ' Audio &Encode '
        FocusControl = c_comboBox_inputDevice
      end
      object c_label_encoderChoose: TLabel
        Left = 28
        Top = 80
        Width = 74
        Height = 13
        Caption = 'Encoder to &Use'
        FocusControl = c_comboBox_encoder
      end
      object c_label_inputDevice: TLabel
        Left = 38
        Top = 48
        Width = 59
        Height = 13
        Caption = 'Input device'
        FocusControl = c_comboBox_inputDevice
      end
      object c_bevel_encodeSrcOptions: TBevel
        Left = 16
        Top = 304
        Width = 481
        Height = 2
      end
      object c_label_encodeSrcOptions: TLabel
        Left = 44
        Top = 300
        Width = 98
        Height = 13
        Caption = ' Destination Options '
      end
      object c_bevel_encodeOptions: TBevel
        Left = 16
        Top = 152
        Width = 481
        Height = 2
      end
      object c_label_encodeOptions: TLabel
        Left = 48
        Top = 148
        Width = 85
        Height = 13
        Caption = ' Encoder &Options '
        FocusControl = c_comboBox_avBR
      end
      object c_label_encoderDest: TLabel
        Left = 19
        Top = 112
        Width = 83
        Height = 13
        Caption = 'Audio &Destination'
        FocusControl = c_comboBox_encodedDest
      end
      object c_label_encoderMinBR: TLabel
        Left = 31
        Top = 196
        Width = 74
        Height = 13
        Caption = 'Minimum Bitrate'
      end
      object c_label_encoderMaxBR: TLabel
        Left = 28
        Top = 220
        Width = 77
        Height = 13
        Caption = 'Maximum Bitrate'
      end
      object c_label_encoderSR: TLabel
        Left = 220
        Top = 196
        Width = 69
        Height = 13
        Caption = 'Sampling &Rate'
        FocusControl = c_comboBox_samplesRate
      end
      object c_label_encoderSM: TLabel
        Left = 229
        Top = 220
        Width = 61
        Height = 13
        Caption = 'Stereo &Mode'
      end
      object c_label_encoderAvBR: TLabel
        Left = 32
        Top = 244
        Width = 73
        Height = 13
        Caption = 'Average &Bitrate'
        FocusControl = c_comboBox_avBR
      end
      object c_label_encoderVBRQ: TLabel
        Left = 48
        Top = 268
        Width = 57
        Height = 13
        Caption = 'VBR &Quality'
        FocusControl = c_comboBox_vbrQuality
      end
      object c_label_encoderMp3File: TLabel
        Left = 28
        Top = 324
        Width = 82
        Height = 13
        Caption = 'Output File Name'
        FocusControl = c_edit_destFile
      end
      object c_label_portNumber: TLabel
        Left = 52
        Top = 372
        Width = 59
        Height = 13
        Caption = 'Port Number'
        Visible = False
      end
      object c_comboBox_encoder: TComboBox
        Left = 120
        Top = 76
        Width = 285
        Height = 21
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 13
        TabOrder = 1
        OnChange = c_comboBox_encoderChange
      end
      object c_comboBox_inputDevice: TComboBox
        Left = 120
        Top = 44
        Width = 285
        Height = 21
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 13
        TabOrder = 0
        OnChange = c_comboBox_inputDeviceChange
      end
      object c_comboBox_encodedDest: TComboBox
        Left = 120
        Top = 108
        Width = 285
        Height = 21
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 13
        TabOrder = 2
        OnChange = c_comboBox_encodedDestChange
      end
      object c_button_encodeStart: TButton
        Left = 420
        Top = 44
        Width = 75
        Height = 25
        Action = a_encode_start
        Anchors = [akTop, akRight]
        TabOrder = 3
      end
      object c_button_encodeStop: TButton
        Left = 420
        Top = 76
        Width = 75
        Height = 25
        Action = a_encode_stop
        Anchors = [akTop, akRight]
        TabOrder = 4
      end
      object c_comboBox_minBR: TComboBox
        Left = 120
        Top = 192
        Width = 77
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 7
        Items.Strings = (
          '32'
          '40'
          '48'
          '56'
          '64'
          '80'
          '96'
          '112'
          '128'
          '160'
          '192'
          '224'
          '256'
          '320')
      end
      object c_checkBox_enableVBR: TCheckBox
        Left = 120
        Top = 168
        Width = 97
        Height = 17
        Caption = 'Enable &VBR'
        TabOrder = 6
        OnClick = c_checkBox_enableVBRClick
      end
      object c_comboBox_maxBR: TComboBox
        Left = 120
        Top = 216
        Width = 77
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 8
      end
      object c_comboBox_samplesRate: TComboBox
        Left = 308
        Top = 192
        Width = 101
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 12
        Items.Strings = (
          '8000'
          '11025'
          '16000'
          '22050'
          '32000'
          '44100'
          '48000')
      end
      object c_comboBox_stereoMode: TComboBox
        Left = 308
        Top = 216
        Width = 101
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 13
        OnChange = c_comboBox_stereoModeChange
        Items.Strings = (
          'Mono'
          'Stereo'
          'Joint Stereo'
          'Dual Channel')
      end
      object c_comboBox_avBR: TComboBox
        Left = 120
        Top = 240
        Width = 77
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 9
        OnChange = c_comboBox_avBRChange
        Items.Strings = (
          '<VBR>'
          '32'
          '40'
          '48'
          '56'
          '64'
          '80'
          '96'
          '112'
          '128'
          '160'
          '192'
          '224'
          '256'
          '320')
      end
      object c_checkBox_disBRS: TCheckBox
        Left = 224
        Top = 168
        Width = 277
        Height = 17
        Caption = '&Disable bit-resorvoir and insertion of padded frames'
        TabOrder = 11
      end
      object c_comboBox_vbrQuality: TComboBox
        Left = 120
        Top = 264
        Width = 77
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 10
        Items.Strings = (
          '0 (higest)'
          '1'
          '2'
          '3'
          '4'
          '5'
          '6'
          '7'
          '8'
          '9 (lowest)')
      end
      object c_edit_destFile: TEdit
        Left = 120
        Top = 320
        Width = 285
        Height = 21
        TabOrder = 18
        OnChange = c_edit_destFileChange
      end
      object c_button_destBrowse: TButton
        Left = 404
        Top = 320
        Width = 25
        Height = 21
        Caption = '...'
        TabOrder = 19
        OnClick = c_button_destBrowseClick
      end
      object c_button_playback: TButton
        Left = 436
        Top = 320
        Width = 57
        Height = 21
        Caption = '&Open...'
        TabOrder = 20
        OnClick = c_button_playbackClick
      end
      object c_button_encodeAbout: TButton
        Left = 420
        Top = 108
        Width = 75
        Height = 25
        Anchors = [akTop, akRight]
        Caption = '&About'
        TabOrder = 5
        OnClick = c_button_encodeAboutClick
      end
      object c_checkBox_copyrighted: TCheckBox
        Left = 224
        Top = 244
        Width = 97
        Height = 17
        Caption = 'Cop&yrighted'
        TabOrder = 14
      end
      object c_checkBox_CRC: TCheckBox
        Left = 364
        Top = 244
        Width = 97
        Height = 17
        Caption = '&CRC'
        TabOrder = 15
      end
      object c_checkBox_original: TCheckBox
        Left = 224
        Top = 264
        Width = 97
        Height = 17
        Caption = 'Origi&nal'
        TabOrder = 16
      end
      object c_checkBox_private: TCheckBox
        Left = 364
        Top = 264
        Width = 97
        Height = 17
        Caption = 'Pr&ivate'
        TabOrder = 17
      end
      object c_checkBox_overwriteP: TCheckBox
        Left = 120
        Top = 344
        Width = 149
        Height = 17
        Caption = 'Over&write Prompt'
        Checked = True
        State = cbChecked
        TabOrder = 21
        OnClick = c_checkBox_overwritePClick
      end
      object c_edit_portNumber: TEdit
        Left = 120
        Top = 368
        Width = 121
        Height = 21
        TabOrder = 22
        Text = '17840'
        Visible = False
      end
    end
    object c_tabSheet_decoder: TTabSheet
      Caption = 'Decoding [Client]'
      ImageIndex = 1
      object c_bevel_decodeSource: TBevel
        Left = 16
        Top = 16
        Width = 481
        Height = 2
      end
      object c_label_decodeTop: TLabel
        Left = 48
        Top = 12
        Width = 74
        Height = 13
        Caption = ' Audio Decode '
      end
      object c_label_decoderSrc: TLabel
        Left = 38
        Top = 48
        Width = 64
        Height = 13
        Caption = 'Audio Source'
      end
      object c_label_decoderChoose: TLabel
        Left = 27
        Top = 80
        Width = 75
        Height = 13
        Caption = 'Decoder to &Use'
        FocusControl = c_comboBox_decoder
      end
      object c_label_outputDevice: TLabel
        Left = 35
        Top = 116
        Width = 67
        Height = 13
        Caption = 'Output device'
      end
      object c_bevel_decodeSrcOptions: TBevel
        Left = 16
        Top = 152
        Width = 481
        Height = 2
      end
      object c_bevel_decodeOptions: TBevel
        Left = 16
        Top = 296
        Width = 481
        Height = 2
        Visible = False
      end
      object c_label_decodeSrcOptions: TLabel
        Left = 48
        Top = 148
        Width = 79
        Height = 13
        Caption = ' Source Options '
      end
      object c_label_decodeOptions: TLabel
        Left = 48
        Top = 292
        Width = 85
        Height = 13
        Caption = ' Encoder Options '
        Visible = False
      end
      object c_label_sourceFile: TLabel
        Left = 32
        Top = 180
        Width = 74
        Height = 13
        Caption = 'Input File Name'
        FocusControl = c_edit_sourceFile
      end
      object c_label_serverPort: TLabel
        Left = 12
        Top = 228
        Width = 93
        Height = 13
        Caption = 'Server Port Number'
        Visible = False
      end
      object c_label_warningOgg: TLabel
        Left = 120
        Top = 200
        Width = 349
        Height = 13
        Caption = 
          'Warning! Ogg/Vorbis decoder can properly handle .ogg files/strea' +
          'ms only.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        Visible = False
      end
      object c_comboBox_encodedSource: TComboBox
        Left = 120
        Top = 44
        Width = 285
        Height = 21
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 0
        TabOrder = 0
        OnChange = c_comboBox_encodedSourceChange
      end
      object c_comboBox_decoder: TComboBox
        Left = 120
        Top = 76
        Width = 285
        Height = 21
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 0
        TabOrder = 1
        OnChange = c_comboBox_decoderChange
      end
      object c_comboBox_outputDevice: TComboBox
        Left = 120
        Top = 108
        Width = 285
        Height = 21
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 0
        TabOrder = 2
        OnChange = c_comboBox_outputDeviceChange
      end
      object c_button_decodeStart: TButton
        Left = 420
        Top = 44
        Width = 75
        Height = 25
        Action = a_decode_start
        Anchors = [akTop, akRight]
        TabOrder = 3
      end
      object c_button_decodeStop: TButton
        Left = 420
        Top = 76
        Width = 75
        Height = 25
        Action = a_decode_stop
        Anchors = [akTop, akRight]
        TabOrder = 4
      end
      object c_button_help: TButton
        Left = 420
        Top = 108
        Width = 75
        Height = 25
        Action = a_help_show
        Anchors = [akTop, akRight]
        TabOrder = 5
      end
      object c_edit_sourceFile: TEdit
        Left = 120
        Top = 176
        Width = 285
        Height = 21
        TabOrder = 6
        OnChange = c_edit_sourceFileChange
      end
      object c_button_sourceBrowse: TButton
        Left = 404
        Top = 176
        Width = 25
        Height = 21
        Caption = '...'
        TabOrder = 7
        OnClick = c_button_sourceBrowseClick
      end
      object c_edit_serverPort: TEdit
        Left = 120
        Top = 224
        Width = 121
        Height = 21
        TabOrder = 8
        Text = '17840'
        Visible = False
      end
    end
  end
  object c_timer_update: TTimer
    OnTimer = c_timer_updateTimer
    Left = 264
    Top = 44
  end
  object c_actionList_main: TActionList
    Left = 236
    Top = 104
    object a_encode_start: TAction
      Category = 'encode'
      Caption = '&Start'
      OnExecute = a_encode_startExecute
    end
    object a_encode_stop: TAction
      Category = 'encode'
      Caption = 'S&top'
      Enabled = False
      OnExecute = a_encode_stopExecute
    end
    object a_decode_start: TAction
      Category = 'decode'
      Caption = '&Start'
      OnExecute = a_decode_startExecute
    end
    object a_decode_stop: TAction
      Category = 'decode'
      Caption = 'S&top'
      Enabled = False
      OnExecute = a_decode_stopExecute
    end
    object a_help_show: TAction
      Category = 'help'
      Caption = '&Help'
    end
  end
  object waveIn: TunavclWaveInDevice
    onDataAvailable = waveInDataAvailable
    Left = 156
    Top = 44
  end
  object c_saveDialog_dest: TSaveDialog
    DefaultExt = 'mp3'
    Filter = 
      'MP3 files (*.mp3)|*.mp3|Ogg files (*.ogg)|*.ogg|All files (*.*)|' +
      '*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Left = 376
    Top = 352
  end
  object waveOut: TunavclWaveOutDevice
    onFeedChunk = waveOutFeedChunk
    Left = 156
    Top = 108
  end
  object c_openDialog_source: TOpenDialog
    DefaultExt = 'mp3'
    Filter = 
      'Audio Files (*.wav; *.mp3; *.ogg)|*.wav;*.mp3;*.ogg|All files (*' +
      '.*)|*.*'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 448
    Top = 216
  end
end
