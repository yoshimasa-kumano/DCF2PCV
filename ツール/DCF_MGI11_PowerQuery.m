let
    // ソースファイルの読み込み
    // 注意: ファイルパスを実際のDCF_SHI.txtの場所に変更してください
    // DCF_SHI.txtのデリミタと列数を確認してから使用してください
    Source = Csv.Document(File.Contents("C:\Users\Yoshimasa Kumano\OneDrive - パースペクティブ株式会社\ドキュメント\GitHub\DCF2PCV\DCF_202510_中締\DCF_SHI.txt"),[Delimiter=",", Encoding=65001]),
    
    // すべての列をテキスト型に変換（先頭ゼロを保持するため）
    ToText = Table.TransformColumnTypes(Source, List.Transform(Table.ColumnNames(Source), each {_, type text})),
    
    // 入力列名の設定（必要な列のみ）
    RenamedColumns = Table.RenameColumns(ToText,{
        {"Column2", "InputCol2"}, 
        {"Column3", "InputCol3"}, 
        {"Column13", "InputCol13_FacilityNameKanji"}, 
        {"Column14", "InputCol14_FacilityNameKana"}, 
        {"Column15", "InputCol15_FacilityShortNameKanji"}, 
        {"Column16", "InputCol16_FacilityShortNameKana"}, 
        {"Column18", "InputCol18_AddressCode"}, 
        {"Column22", "InputCol22_PostalCode"}, 
        {"Column23", "InputCol23_AddressKanji"}, 
        {"Column36", "InputCol36_ManagementEntity"}, 
        {"Column41", "InputCol41_DoctorNameKanji"}, 
        {"Column108", "InputCol108_ReexaminationDiv"}
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
    
    // 施設固有の列を追加
    AddedMGI11MPREF = Table.AddColumn(AddedLUPDT, "MGI11MPREF", each [InputCol18_AddressCode], type text),
    AddedMGI11MHSPC = Table.AddColumn(AddedMGI11MPREF, "MGI11MHSPC", each Text.From([InputCol2]) & Text.From([InputCol3]), type text),
    AddedMGI11KHSPK = Table.AddColumn(AddedMGI11MHSPC, "MGI11KHSPK", each [InputCol14_FacilityNameKana], type text),
    AddedMGI11KHSPR = Table.AddColumn(AddedMGI11KHSPK, "MGI11KHSPR", each [InputCol16_FacilityShortNameKana], type text),
    AddedMGI11JHSPN = Table.AddColumn(AddedMGI11KHSPR, "MGI11JHSPN", each [InputCol13_FacilityNameKanji], type text),
    AddedMGI11EHSPN = Table.AddColumn(AddedMGI11JHSPN, "MGI11EHSPN", each null, type text),
    AddedMGI11JHSPR = Table.AddColumn(AddedMGI11EHSPN, "MGI11JHSPR", each [InputCol15_FacilityShortNameKanji], type text),
    AddedMGI11EHSPR = Table.AddColumn(AddedMGI11JHSPR, "MGI11EHSPR", each null, type text),
    AddedMGI11LHSPK = Table.AddColumn(AddedMGI11EHSPR, "MGI11LHSPK", each null, type text),
    AddedMGI11CKEIK = Table.AddColumn(AddedMGI11LHSPK, "MGI11CKEIK", each [InputCol36_ManagementEntity], type text),
    AddedMGI11CSASK = Table.AddColumn(AddedMGI11CKEIK, "MGI11CSASK", each [InputCol108_ReexaminationDiv], type text),
    AddedMGI11JHADR = Table.AddColumn(AddedMGI11CSASK, "MGI11JHADR", each [InputCol23_AddressKanji], type text),
    AddedMGI11EHADR = Table.AddColumn(AddedMGI11JHADR, "MGI11EHADR", each null, type text),
    AddedMGI11NHSPD = Table.AddColumn(AddedMGI11EHADR, "MGI11NHSPD", each [InputCol41_DoctorNameKanji], type text),
    AddedMGI11BPTEL = Table.AddColumn(AddedMGI11NHSPD, "MGI11BPTEL", each null, type text),
    AddedMGI11AHSPB = Table.AddColumn(AddedMGI11BPTEL, "MGI11AHSPB", each null, type text),
    AddedMGI11BSYBN = Table.AddColumn(AddedMGI11AHSPB, "MGI11BSYBN", each [InputCol22_PostalCode], type text),
    AddedMGI11MSJKB = Table.AddColumn(AddedMGI11BSYBN, "MGI11MSJKB", each null, type text),
    AddedMGI11DSKOU = Table.AddColumn(AddedMGI11MSJKB, "MGI11DSKOU", each null, type text),
    AddedMGI11MHSP2 = Table.AddColumn(AddedMGI11DSKOU, "MGI11MHSP2", each null, type text),
    
    // 必要な列のみを選択（施設マッピングシートのC列の順序に従う）
    SelectedColumns = Table.SelectColumns(AddedMGI11MHSP2,{
        "DIDAT", "MIUID", "DUDAT", "MUUID", "BDVER", "DMSTO", "MMSOU", "DDPPY", 
        "FJPUB", "DDDPY", "FJDEL", "LUPDT", 
        "MGI11MPREF", "MGI11MHSPC", "MGI11KHSPK", "MGI11KHSPR", "MGI11JHSPN", "MGI11EHSPN", 
        "MGI11JHSPR", "MGI11EHSPR", "MGI11LHSPK", "MGI11CKEIK", "MGI11CSASK", "MGI11JHADR", 
        "MGI11EHADR", "MGI11NHSPD", "MGI11BPTEL", "MGI11AHSPB", "MGI11BSYBN", "MGI11MSJKB", 
        "MGI11DSKOU", "MGI11MHSP2"
    })
in
    SelectedColumns
