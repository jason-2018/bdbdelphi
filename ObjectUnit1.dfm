object Form1: TForm1
  Left = 452
  Top = 397
  Caption = 'Form1'
  ClientHeight = 386
  ClientWidth = 583
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 240
    Top = 32
    Width = 36
    Height = 13
    Caption = 'Prenom'
  end
  object Label2: TLabel
    Left = 240
    Top = 56
    Width = 22
    Height = 13
    Caption = 'Nom'
  end
  object Label3: TLabel
    Left = 240
    Top = 80
    Width = 44
    Height = 13
    Caption = 'Addresse'
  end
  object Label4: TLabel
    Left = 240
    Top = 104
    Width = 14
    Height = 13
    Caption = 'CP'
  end
  object Label5: TLabel
    Left = 400
    Top = 104
    Width = 27
    Height = 13
    Caption = 'Town'
  end
  object Button1: TButton
    Left = 312
    Top = 152
    Width = 75
    Height = 25
    Caption = 'Add'
    TabOrder = 0
    OnClick = Button1Click
  end
  object ForName: TEdit
    Left = 288
    Top = 29
    Width = 249
    Height = 21
    TabOrder = 1
  end
  object SurName: TEdit
    Left = 288
    Top = 53
    Width = 249
    Height = 21
    TabOrder = 2
  end
  object Adress: TEdit
    Left = 288
    Top = 77
    Width = 249
    Height = 21
    TabOrder = 3
  end
  object CP: TEdit
    Left = 288
    Top = 101
    Width = 81
    Height = 21
    TabOrder = 4
  end
  object Town: TEdit
    Left = 448
    Top = 101
    Width = 121
    Height = 21
    TabOrder = 5
  end
  object Button4: TButton
    Left = 232
    Top = 192
    Width = 75
    Height = 25
    Caption = 'Premier'
    TabOrder = 6
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 320
    Top = 192
    Width = 75
    Height = 25
    Caption = 'Prec.'
    TabOrder = 7
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 408
    Top = 192
    Width = 75
    Height = 25
    Caption = 'Suiv.'
    TabOrder = 8
    OnClick = Button6Click
  end
  object Button7: TButton
    Left = 496
    Top = 192
    Width = 75
    Height = 25
    Caption = 'Dernier'
    TabOrder = 9
    OnClick = Button7Click
  end
  object DBGrid1: TDBGrid
    Left = 16
    Top = 256
    Width = 320
    Height = 120
    DataSource = DataSource1
    TabOrder = 10
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
  end
  object Edit1: TEdit
    Left = 48
    Top = 32
    Width = 121
    Height = 21
    TabOrder = 11
    Text = 'Edit1'
  end
  object Env: TBerkeleyEnv
    Active = False
    HomeDir = 'D:\Preventech\Berkeley DB\build_win32\Data'
    LogDir = 'D:\Preventech\Berkeley DB\build_win32\Data'
    TmpDir = 'Data'
    BaseName = 'dbo'
    EnvFlags = [INIT_MPOOL]
    CacheSize = 20000
    PageSize = 4096
    Left = 80
    Top = 64
  end
  object Person: TBerkeleyDB
    Active = False
    Environment = Env
    FileName = 'Test.dbo'
    DBFlags = [DBCREATE]
    AccessRecno = True
    Left = 80
    Top = 104
  end
  object DBODataSet1: TDBODataSet
    ObjectView = False
    ObjectDB = Person
    Left = 16
    Top = 152
  end
  object DataSource1: TDataSource
    DataSet = DBODataSet1
    Left = 16
    Top = 184
  end
end
