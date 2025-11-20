let
    // ソースファイルの読み込み
    // 注意: ファイルパスを実際のTBL_SNRYKMK.txtの場所に変更してください
    Source = Csv.Document(File.Contents("C:\Users\Yoshimasa Kumano\OneDrive - パースペクティブ株式会社\ドキュメント\GitHub\DCF2PCV\DCF_202510_中締\TBL_SNRYKMK.txt"),[Delimiter=",", Columns=8, Encoding=65001]),
    
    // 列名の設定
    RenamedColumns = Table.RenameColumns(Source,{
        {"Column1", "InputCol1"}, 
        {"Column2", "InputCol2"}, 
        {"Column3", "InputCol3"}, 
        {"Column4", "InputCol4"}, 
        {"Column5", "InputCol5"}, 
        {"Column6", "InputCol6_ShortName"}, 
        {"Column7", "InputCol7_FullName"}, 
        {"Column8", "InputCol8_Katakana"}
    }),
    
    // 現在の日時を取得（YYYYMMDDHHMMSS形式）
    CurrentDateTime = DateTime.LocalNow(),
    DateTimeString = Text.From(Date.Year(CurrentDateTime)) & 
                     Text.PadStart(Text.From(Date.Month(CurrentDateTime)), 2, "0") & 
                     Text.PadStart(Text.From(Date.Day(CurrentDateTime)), 2, "0") & 
                     Text.PadStart(Text.From(Time.Hour(CurrentDateTime)), 2, "0") & 
                     Text.PadStart(Text.From(Time.Minute(CurrentDateTime)), 2, "0") & 
                     Text.PadStart(Text.From(Time.Second(CurrentDateTime)), 2, "0"),
    
    // 出力用の列を追加
    AddedColumns = Table.AddColumn(RenamedColumns, "DIDAT", each DateTimeString, type text),
    AddedMIUID = Table.AddColumn(AddedColumns, "MIUID", each "ACU_SYS", type text),
    AddedDUDAT = Table.AddColumn(AddedMIUID, "DUDAT", each null, type text),
    AddedMUUID = Table.AddColumn(AddedDUDAT, "MUUID", each null, type text),
    AddedBDVER = Table.AddColumn(AddedMUUID, "BDVER", each null, type text),
    AddedDMSTO = Table.AddColumn(AddedBDVER, "DMSTO", each null, type text),
    AddedMMSQU = Table.AddColumn(AddedDMSTO, "MMSQU", each null, type text),
    AddedDDPPY = Table.AddColumn(AddedMMSQU, "DDPPY", each null, type text),
    AddedFJPUB = Table.AddColumn(AddedDDPPY, "FJPUB", each "0", type text),
    AddedDDDPY = Table.AddColumn(AddedFJPUB, "DDDPY", each null, type text),
    AddedFJDEL = Table.AddColumn(AddedDDDPY, "FJDEL", each "0", type text),
    AddedLUPDT = Table.AddColumn(AddedFJDEL, "LUPDT", each null, type text),
    AddedASEQN = Table.AddColumn(AddedLUPDT, "ASEQN", each null, type text),
    AddedMGI13MSZKC = Table.AddColumn(AddedASEQN, "MGI13MSZKC", each "02", type text),
    AddedMGI13MSZKK = Table.AddColumn(AddedMGI13MSZKC, "MGI13MSZKK", each null, type text),
    AddedMGI13KSZKK = Table.AddColumn(AddedMGI13MSZKK, "MGI13KSZKK", each [InputCol6_ShortName], type text),
    AddedMGI13JSZKK = Table.AddColumn(AddedMGI13KSZKK, "MGI13JSZKK", each [InputCol7_FullName], type text),
    AddedMGI13ESZKK = Table.AddColumn(AddedMGI13JSZKK, "MGI13ESZKK", each null, type text),
    
    // 必要な列のみを選択
    SelectedColumns = Table.SelectColumns(AddedMGI13ESZKK,{
        "DIDAT", "MIUID", "DUDAT", "MUUID", "BDVER", "DMSTO", "MMSQU", "DDPPY", 
        "FJPUB", "DDDPY", "FJDEL", "LUPDT", "ASEQN", 
        "MGI13MSZKC", "MGI13MSZKK", "MGI13KSZKK", "MGI13JSZKK", "MGI13ESZKK"
    }),
    
    // NULLを"NULL"文字列に変換
    ReplacedNulls = Table.ReplaceValue(SelectedColumns, null, "NULL", Replacer.ReplaceValue, Table.ColumnNames(SelectedColumns))
in
    ReplacedNulls
