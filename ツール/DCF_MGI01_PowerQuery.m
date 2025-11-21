let
    // ソースファイルの読み込み
    // 注意: ファイルパスを実際のDCF_KJN.txtの場所に変更してください
    Source = Csv.Document(File.Contents("C:\Users\Yoshimasa Kumano\OneDrive - パースペクティブ株式会社\ドキュメント\GitHub\DCF2PCV\DCF_202510_中締\DCF_KJN.txt"),[Delimiter=",", Encoding=65001]),
    
    // すべての列をテキスト型に変換（先頭ゼロを保持するため）
    ToText = Table.TransformColumnTypes(Source, List.Transform(Table.ColumnNames(Source), each {_, type text})),
    
    // 入力列名の設定（必要な列のみ）
    RenamedColumns = Table.RenameColumns(ToText,{
        {"Column2", "InputCol2"}, 
        {"Column3", "InputCol3"}, 
        {"Column12", "InputCol12_DoctorNameKanji"}, 
        {"Column13", "InputCol13_DoctorNameKana"}, 
        {"Column14", "InputCol14_Gender"}, 
        {"Column15", "InputCol15_Prefecture"}, 
        {"Column16", "InputCol16_GraduationYear"}, 
        {"Column17", "InputCol17_GraduationMonth"}, 
        {"Column18", "InputCol18_SchoolCode"}, 
        {"Column19", "InputCol19_FacultyCode"}, 
        {"Column20", "InputCol20_MajorCode"}, 
        {"Column21", "InputCol21_DegreeCode"}, 
        {"Column22", "InputCol22_UniversityPrefecture"}, 
        {"Column23", "InputCol23_UniversityCode"}
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
    
    // 医師固有の列を追加
    AddedMGI01MDOCC = Table.AddColumn(AddedLUPDT, "MGI01MDOCC", each Text.From([InputCol2]) & Text.From([InputCol3]), type text),
    AddedMGI01NDOCN = Table.AddColumn(AddedMGI01MDOCC, "MGI01NDOCN", each [InputCol12_DoctorNameKanji], type text),
    AddedMGI01KDOCN = Table.AddColumn(AddedMGI01NDOCN, "MGI01KDOCN", each [InputCol13_DoctorNameKana], type text),
    AddedMGI01CSEXC = Table.AddColumn(AddedMGI01KDOCN, "MGI01CSEXC", each [InputCol14_Gender], type text),
    AddedMGI01MPREF = Table.AddColumn(AddedMGI01CSEXC, "MGI01MPREF", each [InputCol15_Prefecture], type text),
    AddedMGI01YGRAD = Table.AddColumn(AddedMGI01MPREF, "MGI01YGRAD", each [InputCol16_GraduationYear], type text),
    AddedMGI01MGRAD = Table.AddColumn(AddedMGI01YGRAD, "MGI01MGRAD", each [InputCol17_GraduationMonth], type text),
    AddedMGI01MSCHL = Table.AddColumn(AddedMGI01MGRAD, "MGI01MSCHL", each [InputCol18_SchoolCode], type text),
    AddedMGI01MFCLT = Table.AddColumn(AddedMGI01MSCHL, "MGI01MFCLT", each [InputCol19_FacultyCode], type text),
    AddedMGI01MMJOR = Table.AddColumn(AddedMGI01MFCLT, "MGI01MMJOR", each [InputCol20_MajorCode], type text),
    AddedMGI01CDEGR = Table.AddColumn(AddedMGI01MMJOR, "MGI01CDEGR", each [InputCol21_DegreeCode], type text),
    AddedMGI01MPUNI = Table.AddColumn(AddedMGI01CDEGR, "MGI01MPUNI", each [InputCol22_UniversityPrefecture], type text),
    AddedMGI01MUNI = Table.AddColumn(AddedMGI01MPUNI, "MGI01MUNI", each [InputCol23_UniversityCode], type text),
    
    // 必要な列のみを選択
    SelectedColumns = Table.SelectColumns(AddedMGI01MUNI,{
        "DIDAT", "MIUID", "DUDAT", "MUUID", "BDVER", "DMSTO", "MMSOU", "DDPPY", 
        "FJPUB", "DDDPY", "FJDEL", "LUPDT", 
        "MGI01MDOCC", "MGI01NDOCN", "MGI01KDOCN", "MGI01CSEXC", "MGI01MPREF", 
        "MGI01YGRAD", "MGI01MGRAD", "MGI01MSCHL", "MGI01MFCLT", "MGI01MMJOR", 
        "MGI01CDEGR", "MGI01MPUNI", "MGI01MUNI"
    })
in
    SelectedColumns
