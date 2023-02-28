import ObjectiveC

public protocol Groupable {
    associatedtype T
    
    var id: Int { get set }
    var orig: T { get }
    var type: T.Type { get }
    
    func hook(_ cls: AnyClass?) -> JinxResult
    func unhook(_ cls: AnyClass?) -> JinxResult
}
