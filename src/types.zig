// See Chapter 7 on Data Set, Data Elements and Data Element Fields
// https://dicom.nema.org/medical/dicom/current/output/html/part05.html#chapter_7
pub const DataSet = []DataElement;
// https://dicom.nema.org/medical/dicom/current/output/html/part05.html#sect_7.1
pub const DataElement = struct { tag: Tag, vr: [2]u8, vl: u16, value: u32 };
// https://dicom.nema.org/medical/dicom/current/output/html/part05.html#sect_7.2
pub const Tag = struct { group: u16, element: u16 };
