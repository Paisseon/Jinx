//
//  Rebind.swift
//  Jinx
//
//  Created by Lilliana on 21/03/2023.
//

import MachO

struct Rebind {
    let hook: RebindHook
    
    func rebind() -> Bool {
        for i: UInt32 in 0 ..< _dyld_image_count() {
            guard let header: UnsafePointer<mach_header> = _dyld_get_image_header(i) else {
                continue
            }
            
            let machHeader: UnsafePointer<mach_header_64> = header.withMemoryRebound(to: mach_header_64.self, capacity: 1) { $0 }
            let slide: Int = _dyld_get_image_vmaddr_slide(i)
            
            guard let table: Table = getTable(at: slide, in: machHeader) else {
                continue
            }
            
            if replace(at: slide, in: table) {
                return true
            }
        }
        
        return false
    }
    
    private func getTable(
        at slide: Int,
        in header: UnsafePointer<mach_header_64>
    ) -> Table? {
        var segCmd: UnsafeMutablePointer<segment_command_64>
        var ledCmd: UnsafeMutablePointer<segment_command_64>?
        var symCmd: UnsafeMutablePointer<symtab_command>?
        var dynCmd: UnsafeMutablePointer<dysymtab_command>?
        var dataSegs: [UnsafeMutableRawPointer] = []
        
        guard var lc: UnsafeMutableRawPointer = .init(bitPattern: UInt(bitPattern: header) + UInt(MemoryLayout<mach_header_64>.size)) else {
            return nil
        }
        
        for _ in 0 ..< header.pointee.ncmds {
            segCmd = lc.assumingMemoryBound(to: segment_command_64.self)
            
            switch segCmd.pointee.cmd {
                case UInt32(LC_SEGMENT_64):
                    if strcmp(&segCmd.pointee.segname, SEG_LINKEDIT) == 0 {
                        ledCmd = segCmd
                    } else {
                        let seg: UnsafeMutablePointer<segment_command_64> = lc.assumingMemoryBound(to: segment_command_64.self)
                        let nameOff: Int = MemoryLayout.size(ofValue: seg.pointee.cmd) + MemoryLayout.size(ofValue: seg.pointee.cmdsize)
                        let name: String = .init(cString: UnsafeRawPointer(lc).advanced(by: nameOff).assumingMemoryBound(to: Int8.self))
                        
                        if name == SEG_DATA || name == "__DATA_CONST" || name == "__AUTH_CONST" {
                            dataSegs.append(lc)
                        }
                    }
                case UInt32(LC_SYMTAB):
                    symCmd = .init(OpaquePointer(segCmd))
                case UInt32(LC_DYSYMTAB):
                    dynCmd = .init(OpaquePointer(segCmd))
                default:
                    break
            }
            
            lc += Int(segCmd.pointee.cmdsize)
        }
        
        guard let ledCmd,
              let symCmd,
              let dynCmd
        else {
            return nil
        }
        
        let ledBase: Int = slide + Int(ledCmd.pointee.vmaddr - ledCmd.pointee.fileoff)
        
        guard let sym: UnsafeMutablePointer<nlist_64> = .init(bitPattern: ledBase + Int(symCmd.pointee.symoff)),
              let str: UnsafeMutablePointer<UInt8> = .init(bitPattern: ledBase + Int(symCmd.pointee.stroff)),
              let ind: UnsafeMutablePointer<UInt32> = .init(bitPattern: ledBase + Int(dynCmd.pointee.indirectsymoff))
        else {
            return nil
        }
        
        for seg in dataSegs {
            for i: UInt32 in 0 ..< (seg.assumingMemoryBound(to: segment_command_64.self)).pointee.nsects {
                let sect: UnsafeMutablePointer<section_64> = UnsafeMutableRawPointer(seg + MemoryLayout<segment_command_64>.size)
                    .advanced(by: Int(i))
                    .assumingMemoryBound(to: section_64.self)
                
                if Int32(sect.pointee.flags) & SECTION_TYPE != S_LAZY_SYMBOL_POINTERS,
                   Int32(sect.pointee.flags) & SECTION_TYPE != S_NON_LAZY_SYMBOL_POINTERS
                {
                    continue
                }
                
                return Table(sym: sym, str: str, ind: ind, sect: sect)
            }
        }
        
        return nil
    }
    
    private func replace(
        at slide: Int,
        in table: Table
    ) -> Bool {
        let indices: UnsafeMutablePointer<UInt32> = table.ind.advanced(by: Int(table.sect.pointee.reserved1))
        
        guard let bindings: UnsafeMutablePointer<UnsafeMutableRawPointer> = .init(bitPattern: slide + Int(table.sect.pointee.addr)) else {
            return false
        }
        
        guard vm_protect(
            mach_task_self_,
            vm_address_t(slide + Int(table.sect.pointee.addr)),
            vm_size_t(table.sect.pointee.size),
            0,
            VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY
        ) == KERN_SUCCESS else {
            return false
        }
        
        for i: Int in 0 ..< Int(table.sect.pointee.size) / MemoryLayout<UnsafeMutableRawPointer>.size {
            let inSym: UnsafeMutablePointer<UInt32> = indices.advanced(by: i)
            
            guard inSym.pointee != UInt32(INDIRECT_SYMBOL_ABS),
                  inSym.pointee != INDIRECT_SYMBOL_LOCAL,
                  inSym.pointee != INDIRECT_SYMBOL_LOCAL | UInt32(INDIRECT_SYMBOL_ABS)
            else {
                continue
            }
            
            let strTabOff: UInt32 = table.sym.advanced(by: Int(inSym.pointee)).pointee.n_un.n_strx
            let symName: String = .init(cString: table.str.advanced(by: Int(strTabOff) + 1))
            
            if symName == hook.name {
                hook.orig.initialize(to: bindings.advanced(by: i).pointee)
                bindings.advanced(by: i).initialize(to: hook.replace)
                return true
            }
        }
        
        return false
    }
}
