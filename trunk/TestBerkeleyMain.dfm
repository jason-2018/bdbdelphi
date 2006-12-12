object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 398
  ClientWidth = 486
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
  object CreateDB: TButton
    Left = 64
    Top = 24
    Width = 75
    Height = 25
    Caption = 'CreateDB'
    TabOrder = 0
    OnClick = CreateDBClick
  end
  object FreeDB: TButton
    Left = 168
    Top = 24
    Width = 75
    Height = 25
    Caption = 'FreeDB'
    Enabled = False
    TabOrder = 1
    OnClick = FreeDBClick
  end
  object OpenDB: TButton
    Left = 64
    Top = 64
    Width = 75
    Height = 25
    Caption = 'OpenDB'
    Enabled = False
    TabOrder = 2
    OnClick = OpenDBClick
  end
  object CloseDB: TButton
    Left = 168
    Top = 64
    Width = 75
    Height = 25
    Caption = 'CloseDB'
    Enabled = False
    TabOrder = 3
    OnClick = CloseDBClick
  end
  object Populate: TButton
    Left = 120
    Top = 104
    Width = 75
    Height = 25
    Caption = 'Populate'
    TabOrder = 4
    OnClick = PopulateClick
  end
  object Memo1: TMemo
    Left = 8
    Top = 192
    Width = 369
    Height = 185
    Lines.Strings = (
      'Memo1')
    TabOrder = 5
  end
  object List: TButton
    Left = 16
    Top = 152
    Width = 75
    Height = 25
    Caption = 'List'
    TabOrder = 6
    OnClick = ListClick
  end
  object ListCursor: TButton
    Left = 107
    Top = 152
    Width = 75
    Height = 25
    Caption = 'ListCursor'
    TabOrder = 7
    OnClick = ListCursorClick
  end
  object First: TButton
    Left = 400
    Top = 221
    Width = 75
    Height = 25
    Caption = 'First'
    TabOrder = 8
    OnClick = FirstClick
  end
  object Last: TButton
    Left = 400
    Top = 256
    Width = 75
    Height = 25
    Caption = 'Last'
    TabOrder = 9
    OnClick = LastClick
  end
  object Next: TButton
    Left = 400
    Top = 288
    Width = 75
    Height = 25
    Caption = 'Next'
    TabOrder = 10
    OnClick = NextClick
  end
  object Prev: TButton
    Left = 400
    Top = 319
    Width = 75
    Height = 25
    Caption = 'Prev'
    TabOrder = 11
    OnClick = PrevClick
  end
  object GetCursor: TButton
    Left = 400
    Top = 190
    Width = 75
    Height = 25
    Caption = 'GetCursor'
    TabOrder = 12
    OnClick = GetCursorClick
  end
  object CloseCursor: TButton
    Left = 400
    Top = 352
    Width = 75
    Height = 25
    Caption = 'CloseCursor'
    TabOrder = 13
    OnClick = CloseCursorClick
  end
  object Stat: TButton
    Left = 384
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Stat'
    TabOrder = 14
    OnClick = StatClick
  end
end
