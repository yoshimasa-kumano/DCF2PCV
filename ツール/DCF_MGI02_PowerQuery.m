let
    // ソースファイルの読み込み
    // 注意: ファイルパスを実際のDCF_KJN_SHI.txtの場所に変更してください
    Source = Csv.Document(File.Contents("C:\Users\Yoshimasa Kumano\OneDrive - パースペクティブ株式会社\ドキュメント\GitHub\DCF2PCV\DCF_202510_中締\DCF_KJN_SHI.txt"),[Delimiter=",", Encoding=65001]),
    
    // すべての列をテキスト型に変換（先頭ゼロを保持するため）
    ToText = Table.TransformColumnTypes(Source, List.Transform(Table.ColumnNames(Source), each {_, type text})),
    
    // 入力列名の設定（必要な列のみ）
    RenamedColumns = Table.RenameColumns(ToText,{
        {"Column2", "InputCol2_DoctorKey1"}, 
        {"Column3", "InputCol3_DoctorKey2"}, 
        {"Column6", "InputCol6_FacilityKey1"}, 
        {"Column7", "InputCol7_FacilityKey2"}, 
        {"Column12", "InputCol12_DepartmentCode"}, 
        {"Column13", "InputCol13_PositionCode"}, 
        {"Column14", "InputCol14_EmploymentType"}
    }, MissingField.Ignore),
    
    // 現在の日時を取得（YYYYMMDDHHMMSS形式）
    CurrentDateTime = DateTime.LocalNow(),
    DateTimeString = DateTime.ToText(CurrentDateTime,"yyyyMMddHHmmss"),
    
    // 出力用の列を追加
    AddedDIDAT = Table.AddColumn(RenamedColumns, "DIDAT", each DateTimeString, type text),
    AddedMIUID = Table.AddColumn(AddedDIDAT, "MIUID", each "ACU_SYS", type text),
    AddedDUDAT = Table.AddColumn(AddedMIUID, "DUDAT", each null, type text),
    AddedMUUID = Table.AddColumn(AddedDUDAT, "MUUID", each null, type text),
    AddedBDVER = Table.AddColumn(AddedMUUID, "BDVER", each null, type text),
    AddedDMSTO = Table.AddColumn(AddedBDVER, "DMSTO", each null, type text),
    AddedMMSOU = Table.AddColumn(AddedDMSTO, "MMSOU", each null, type text),
    AddedDDPPY = Table.AddColumn(AddedMMSOU, "DDPPY", each null, type text),
    AddedFJPUB = Table.AddColumn(AddedDDPPY, "FJPUB", each "0", type text),
    AddedDDDPY = Table.AddColumn(AddedFJPUB, "DDDPY", each null, type text),
    AddedFJDEL = Table.AddColumn(AddedDDDPY, "FJDEL", each "0", type text),
    AddedLUPDT = Table.AddColumn(AddedFJDEL, "LUPDT", each null, type text),
    
    // 医師勤務先施設固有の列を追加
    AddedMGI02MDOCC = Table.AddColumn(AddedLUPDT, "MGI02MDOCC", each Text.From([InputCol2_DoctorKey1]) & Text.From([InputCol3_DoctorKey2]), type text),
    AddedMGI02MHSPC = Table.AddColumn(AddedMGI02MDOCC, "MGI02MHSPC", each Text.From([InputCol6_FacilityKey1]) & Text.From([InputCol7_FacilityKey2]), type text),
    AddedMGI02MDEPT = Table.AddColumn(AddedMGI02MHSPC, "MGI02MDEPT", each [InputCol12_DepartmentCode], type text),
    AddedMGI02CPOST = Table.AddColumn(AddedMGI02MDEPT, "MGI02CPOST", each [InputCol13_PositionCode], type text),
    AddedMGI02CEMPT = Table.AddColumn(AddedMGI02CPOST, "MGI02CEMPT", each [InputCol14_EmploymentType], type text),
    
    // 必要な列のみを選択
    SelectedColumns = Table.SelectColumns(AddedMGI02CEMPT,{
        "DIDAT", "MIUID", "DUDAT", "MUUID", "BDVER", "DMSTO", "MMSOU", "DDPPY", 
        "FJPUB", "DDDPY", "FJDEL", "LUPDT", 
        "MGI02MDOCC", "MGI02MHSPC", "MGI02MDEPT", "MGI02CPOST", "MGI02CEMPT"
    })
in
    SelectedColumns
