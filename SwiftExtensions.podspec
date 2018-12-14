Pod::Spec.new do |spec|
    spec.name               = 'SwiftExtensions'
    spec.version            = '1.0.0'
    spec.license            = 'BSD'
    spec.summary            = 'Swift extensions'
    spec.homepage           = 'https://github.com/shc-vj/SwiftExtensions.git' 
    spec.source             = {
        :git => "https://github.com/shc-vj/SwiftExtensions.git"
    }
    spec.authors             = 'Paweł Czernikowski'
    spec.requires_arc       = true
    spec.platforms          = {
        :ios => '8.0',
        :osx => '10.7'
    }
    spec.swift_version = '4.0'
    spec.source_files       = 'src'
    
    spec.pod_target_xcconfig = {
    	'DEFINES_MODULE' => 'YES'
    }
    
    spec.user_target_xcconfig = {
        'CLANG_ENABLE_MODULES'                                  => 'YES',
        'CLANG_MODULES_AUTOLINK'                                => 'YES',
        'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES'
    }

end
