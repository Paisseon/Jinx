//
//  String.swift
//  Jinx
//
//  Created by Lilliana on 13/04/2023.
//

public extension String {
    var withRootPath: String {
        #if THEOS_PACKAGE_INSTALL_PREFIX
        "/var/jb" + self
        #else
        self
        #endif
    }
}
