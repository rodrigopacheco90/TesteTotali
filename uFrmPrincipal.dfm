object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesktopCenter
  TextHeight = 15
  object MemoResultados: TMemo
    Left = 0
    Top = 49
    Width = 624
    Height = 392
    Align = alClient
    ScrollBars = ssVertical
    TabOrder = 0
    ExplicitLeft = 200
    ExplicitTop = 20
    ExplicitWidth = 370
    ExplicitHeight = 320
  end
  object btnExecutar: TButton
    Left = 0
    Top = 0
    Width = 624
    Height = 49
    Align = alTop
    Caption = 'Executar'
    TabOrder = 1
    OnClick = btnExecutarClick
  end
end
