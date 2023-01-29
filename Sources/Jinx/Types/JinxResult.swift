public enum JinxResult {
    case badOrig
    case badReplace
    case noBind
    case noClass
    case noData
    case noFunction
    case noHeader
    case noImage
    case noIvar
    case noLoadCmd
    case noSelector
    case noTable
    case noTableCmd
    case readMem
    case success

    // MARK: Internal

    var description: String {
        switch self {
            case .badOrig:
                return "Pointer to original function is corrupt"
            case .badReplace:
                return "Pointer to replacement function is corrupt"
            case .noBind:
                return "Binding not found in section"
            case .noClass:
                return "Class not found in process"
            case .noData:
                return "__DATA and __DATA_CONST not found in segment command"
            case .noFunction:
                return "Symbol name not found in string table"
            case .noHeader:
                return "Header not found for dyld index"
            case .noImage:
                return "Image not found in process"
            case .noIvar:
                return "Instance variable not found in class"
            case .noLoadCmd:
                return "Load command not found in image"
            case .noSelector:
                return "Selector not found in class"
            case .noTable:
                return "No table found with table command"
            case .noTableCmd:
                return "No table command found in Mach-O segments"
            case .readMem:
                return "Could not get write permission for memory"
            case .success:
                return "This was a triumph, I'm making a note here: HUGE SUCCESS"
        }
    }
}
