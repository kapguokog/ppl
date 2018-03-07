object fmPPLMonitor: TfmPPLMonitor
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = #1048#1079#1091#1095#1077#1085#1080#1077' PPL + TMonitor'
  ClientHeight = 400
  ClientWidth = 800
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object info: TMemo
    Left = 405
    Top = 0
    Width = 395
    Height = 400
    Align = alRight
    TabOrder = 0
  end
  object bbRunTask: TButton
    Left = 8
    Top = 8
    Width = 200
    Height = 25
    Caption = #1042#1099#1087#1086#1083#1085#1080#1090#1100' '#1086#1090#1076#1077#1083#1100#1085#1086#1081' '#1079#1072#1076#1072#1095#1077#1081
    TabOrder = 1
    OnClick = bbRunTaskClick
  end
  object bbCreateTask: TButton
    Left = 8
    Top = 70
    Width = 200
    Height = 25
    Caption = #1057#1086#1079#1076#1072#1090#1100' '#1079#1072#1076#1072#1095#1080
    TabOrder = 4
    OnClick = bbCreateTaskClick
  end
  object bbStartTask: TButton
    Left = 215
    Top = 70
    Width = 180
    Height = 25
    Caption = #1047#1072#1087#1091#1089#1090#1080#1090#1100' '#1079#1072#1076#1072#1095#1080
    TabOrder = 5
    OnClick = bbStartTaskClick
  end
  object rgWaitMode: TRadioGroup
    Left = 8
    Top = 35
    Width = 387
    Height = 35
    Caption = #1056#1077#1078#1080#1084' '#1086#1078#1080#1076#1072#1085#1080#1103
    Columns = 3
    ItemIndex = 0
    Items.Strings = (
      #1074#1089#1077
      #1083#1102#1073#1072#1103
      #1076#1074#1077)
    TabOrder = 3
  end
  object bbAnonymThread: TButton
    Left = 8
    Top = 190
    Width = 200
    Height = 25
    Caption = #1040#1085#1086#1085#1080#1084#1085#1099#1081' '#1087#1086#1090#1086#1082
    TabOrder = 12
    OnClick = bbAnonymThreadClick
  end
  object bbCreateCanceled: TButton
    Left = 8
    Top = 95
    Width = 200
    Height = 25
    Caption = #1057#1086#1079#1076#1072#1090#1100' '#1079#1072#1076#1072#1095#1091' '#1076#1083#1103' '#1086#1090#1084#1077#1085#1099
    TabOrder = 6
    OnClick = bbCreateCanceledClick
  end
  object bbCancelTask: TButton
    Left = 214
    Top = 95
    Width = 181
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1080#1090#1100' '#1079#1072#1076#1072#1095#1091
    TabOrder = 7
    OnClick = bbCancelTaskClick
  end
  object ckException: TCheckBox
    Left = 214
    Top = 12
    Width = 181
    Height = 17
    Caption = #1057#1075#1077#1085#1077#1088#1080#1088#1086#1074#1072#1090#1100' '#1080#1089#1082#1083#1102#1095#1077#1085#1080#1077
    TabOrder = 2
  end
  object bbParallel: TButton
    Left = 8
    Top = 155
    Width = 200
    Height = 25
    Caption = #1055#1072#1088#1072#1083#1083#1077#1083#1100#1085#1099#1081' '#1094#1080#1082#1083
    TabOrder = 10
    OnClick = bbParallelClick
  end
  object bbParallelCancel: TButton
    Left = 214
    Top = 155
    Width = 181
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1080#1090#1100' '#1094#1080#1082#1083
    TabOrder = 11
    OnClick = bbParallelCancelClick
  end
  object btnCreateFutures: TButton
    Left = 8
    Top = 120
    Width = 200
    Height = 25
    Caption = #1057#1086#1079#1076#1072#1090#1100' '#1079#1072#1076#1072#1095#1080' '#1092#1100#1102#1095#1077#1088#1089#1099
    TabOrder = 8
    OnClick = btnCreateFuturesClick
  end
  object bbStartFuture: TButton
    Left = 214
    Top = 120
    Width = 181
    Height = 25
    Caption = #1047#1072#1087#1091#1089#1090#1080#1090#1100' '#1079#1072#1076#1072#1095#1080
    TabOrder = 9
    OnClick = bbStartFutureClick
  end
end
