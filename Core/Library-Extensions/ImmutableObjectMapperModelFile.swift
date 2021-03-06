//
//  ImmutableObjectMapperModelFile.swift
//  SwiftyJSONAccelerator
//
//  Created by Alexandre Santos on 10/10/17.
//  Copyright © 2017 Karthikeya Udupa K M. All rights reserved.
//

import Foundation

struct ImmutableObjectMapperModelFile: ModelFile, DefaultModelFileComponent {
    
    /// Filename for the model.
    var fileName: String
    var type: ConstructType
    var component: ModelComponent
    var sourceJSON: JSON
    var configuration: ModelGenerationConfiguration?
    
    init() {
        self.fileName = ""
        type = ConstructType.StructType
        component = ModelComponent()
        sourceJSON = JSON([])
    }
    
    mutating func setInfo(_ fileName: String, _ configuration: ModelGenerationConfiguration) {
        self.fileName = fileName
        type = configuration.constructType
        self.configuration = configuration
    }
    
    func moduleName() -> String {
        return "ImmutableObjectMapper"
    }
    
    func baseElementName() -> String? {
        return "ImmutableMappable"
    }
    
    func mainBodyTemplateFileName() -> String {
        return "ImmutableObjectMapperTemplate"
    }
    
    mutating func generateAndAddComponentsFor(_ property: PropertyComponent) {
        switch property.propertyType {
            
        case .ValueType:
            component.declarations.append(genVariableDeclaration(property.name, property.type, false))
            component.description.append(genDescriptionForPrimitive(property.name, property.type, property.constantName))
            component.decoders.append(genDecoder(property.name, property.type, property.constantName, false))
            component.encoders.append(genEncoder(property.name, property.type, property.constantName))
            generateCommonComponentsFor(property)
        case .ValueTypeArray:
            component.description.append(genDescriptionForPrimitiveArray(property.name, property.constantName))
            component.declarations.append(genVariableDeclaration(property.name, property.type, true))
            component.decoders.append(genDecoder(property.name, property.type, property.constantName, true))
            component.encoders.append(genEncoder(property.name, property.type, property.constantName))
            generateCommonComponentsFor(property)
        case .ObjectType:
            component.description.append(genDescriptionForObject(property.name, property.constantName))
            component.declarations.append(genVariableDeclaration(property.name, property.type, false))
            component.decoders.append(genDecoder(property.name, property.type, property.constantName, false))
            component.encoders.append(genEncoder(property.name, property.type, property.constantName))
            generateCommonComponentsFor(property)
        case .ObjectTypeArray:
            component.declarations.append(genVariableDeclaration(property.name, property.type, true))
            component.description.append(genDescriptionForObjectArray(property.name, property.constantName))
            component.decoders.append(genDecoder(property.name, property.type, property.constantName, true))
            component.encoders.append(genEncoder(property.name, property.type, property.constantName))
            generateCommonComponentsFor(property)
            
        case .EmptyArray:
            component.declarations.append(genVariableDeclaration(property.name, "Any", true))
            component.description.append(genDescriptionForPrimitiveArray(property.name, property.constantName))
            component.decoders.append(genDecoder(property.name, "Any", property.constantName, true))
            component.encoders.append(genEncoder(property.name, "Any", property.constantName))
            generateCommonComponentsFor(property)
        case .NullType: break
            // Currently we do not deal with null values.
            
        }
    }
    
    fileprivate mutating func generateCommonComponentsFor(_ property: PropertyComponent) {
        component.stringConstants.append(genStringConstant(property.constantName, property.key))
        component.initialisers.append(genInitializerForVariable(property.name, property.constantName))
    }
    
    // MARK: - Customised methods for ObjectMapper
    // MARK: - Initialisers
    func genInitializerForVariable(_ name: String, _ constantName: String) -> String {
        return "self.\(name) = try? map.value(\(constantName))"
    }
    
}
