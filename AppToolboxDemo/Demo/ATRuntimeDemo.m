//
//  ATRuntimeDemo.m
//  AppToolboxDemo
//
//  Created by linzhiman on 2020/6/9.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "ATRuntimeDemo.h"
#import <objc/runtime.h>
#import <objc/message.h>

void myMethodIMP(id self, SEL _cmd)
{
    NSLog(@"myMethodIMP");
}

void MyEnumerationMutationHandler(id obj)
{
    NSLog(@"MyEnumerationMutationHandler %@", obj);
}

@protocol IDemoProtocol <NSObject>

- (void)demo;

@end

@protocol ITestProtocol <NSObject>

- (void)doTest;

@end

@interface ATRuntimeDemoEx : ATRuntimeDemo

@end

@implementation ATRuntimeDemoEx

@end

@interface ATRuntimeDemo ()<IDemoProtocol>
{
    int instace_a;
    int instace_b;
    int instace_c;
}

@end

@implementation ATRuntimeDemo

+ (void)classMethod1
{
    NSLog(@"classMethod1");
}

+ (void)classMethod2
{
    NSLog(@"classMethod2");
}

+ (void)classMethod3
{
    NSLog(@"classMethod3");
}

- (void)instanceMethod1
{
    NSLog(@"instanceMethod1");
}

- (void)instanceMethod2
{
    NSLog(@"instanceMethod2");
}

- (void)instanceMethod3
{
    NSLog(@"instanceMethod3");
}

- (BOOL)instanceMethod4:(int)a b:(NSString *)b
{
    NSLog(@"instanceMethod4 %d %@", a, b);
    return YES;
}

- (void)demo
{
    [self workingWithClasses];
    [self methodSwizzling];
    [self addingClasses];
    [self instantiatingClasses];
    [self workingWithInstances];
    [self obtainingClassDefinitions];
    [self workingWithInstanceVariables];
    [self associativeReferences];
    [self sendingMessages];
    [self workingWithMethods];
    [self workingWithLibraries];
    [self workingWithSelectors];
    [self workingWithProtocols];
    [self workingWithProperties];
    [self usingObjectiveCLanguageFeatures];
}

- (void)workingWithClasses
{
//    class_getName
//    Returns the name of a class.
    NSLog(@"getName %s", class_getName([self class]));
//    getName ATRuntimeDemo
    NSLog(@"getName %s", class_getName([[self class] class]));
//    getName ATRuntimeDemo
    NSLog(@"getName %s", class_getName(object_getClass([self class])));
//    getName ATRuntimeDemo
    
//    class_getSuperclass
//    Returns the superclass of a class.
//    You should usually use NSObject‘s superclass method instead of this function.
    NSLog(@"getSuperclass %s", class_getName(class_getSuperclass([self class])));
//    getSuperclass NSObject
    
//    class_isMetaClass
//    Returns a Boolean value that indicates whether a class object is a metaclass.
    NSLog(@"isMetaClass %d", class_isMetaClass([self class]));
//    isMetaClass 0
    NSLog(@"isMetaClass %d", class_isMetaClass(object_getClass([self class])));
//    isMetaClass 1
    
//    class_getInstanceSize
//    Returns the size of instances of a class.
    NSLog(@"getInstanceSize %zu", class_getInstanceSize([self class]));
//    getInstanceSize 40
    
//    class_getInstanceVariable
//    Returns the Ivar for a specified instance variable of a given class.
    Ivar ivar_instance_a = class_getInstanceVariable([self class], "instace_a");
    NSLog(@"getInstanceVariable getName %s", ivar_getName(ivar_instance_a));
//    getInstanceVariable getName instace_a
    NSLog(@"getInstanceVariable getTypeEncoding %s", ivar_getTypeEncoding(ivar_instance_a));
//    getInstanceVariable getTypeEncoding i
    NSLog(@"getInstanceVariable getOffset %td", ivar_getOffset(ivar_instance_a));
//    getInstanceVariable getOffset 8
    
//    class_getClassVariable
//    Returns the Ivar for a specified class variable of a given class.
//    ??
    
//    class_addIvar
//    Adds a new instance variable to a class.
//    This function may only be called after objc_allocateClassPair and before objc_registerClassPair. Adding an instance variable to an existing class is not supported.
//    The class must not be a metaclass. Adding an instance variable to a metaclass is not supported.
//    see addingClasses
    
//    class_copyIvarList
//    Describes the instance variables declared by a class.
//    An array of pointers of type Ivar describing the instance variables declared by the class. Any instance variables declared by superclasses are not included.
    unsigned int copyIvarList_outCount = 0;
    Ivar *copyIvarList = class_copyIvarList([self class], &copyIvarList_outCount);
    for (unsigned int index = 0; index < copyIvarList_outCount; index++) {
        NSLog(@"copyIvarList %s", ivar_getName(copyIvarList[index]));
    }
    free(copyIvarList);
//    copyIvarList instace_a
//    copyIvarList instace_b
//    copyIvarList instace_c
//    copyIvarList _propertyA
//    copyIvarList _propertyB
//    copyIvarList _propertyC
    
//    class_getIvarLayout
//    Returns a description of the Ivar layout for a given class.
    
//    class_setIvarLayout
//    Sets the Ivar layout for a given class.
    
//    class_getWeakIvarLayout
//    Returns a description of the layout of weak Ivars for a given class.
    
//    class_setWeakIvarLayout
//    Sets the layout for weak Ivars for a given class.
    
//    class_getProperty
//    Returns a property with a given name of a given class.
    objc_property_t property = class_getProperty([self class], "propertyA");
    NSLog(@"getProperty getName %s", property_getName(property));
//    getProperty getName propertyA
    NSLog(@"getProperty getAttributes %s", property_getAttributes(property));
//    getProperty getAttributes Ti,N,V_propertyA

//    class_copyPropertyList
//    Describes the properties declared by a class.
//    An array of pointers of type objc_property_t describing the properties declared by the class. Any properties declared by superclasses are not included.
    unsigned int copyAttributeList_outCount = 0;
    objc_property_attribute_t *copyAttributeList = property_copyAttributeList(property, &copyAttributeList_outCount);
    for (unsigned int index = 0; index < copyAttributeList_outCount; index++) {
        NSLog(@"copyAttributeList %s %s", copyAttributeList[index].name, copyAttributeList[index].value);
    }
    free(copyAttributeList);
//    copyAttributeList T i
//    copyAttributeList N
//    copyAttributeList V _propertyA
    
//    property_copyAttributeValue
//    Returns the value of a property attribute given the attribute name.
    NSLog(@"copyAttributeValue %s", property_copyAttributeValue(property, "V"));
//    copyAttributeValue _propertyA
    
    {{
        objc_property_t property2 = class_getProperty([self class], "propertyC");
        NSLog(@"getName %s", property_getName(property2));
//        getName propertyC
        NSLog(@"getAttributes %s", property_getAttributes(property2));
//        getAttributes T@"NSString",&,N,V_propertyC
        
        unsigned int copyAttributeList_outCount = 0;
        objc_property_attribute_t *copyAttributeList = property_copyAttributeList(property2, &copyAttributeList_outCount);
        for (unsigned int index = 0; index < copyAttributeList_outCount; index++) {
            NSLog(@"copyAttributeList %s %s", copyAttributeList[index].name, copyAttributeList[index].value);
        }
        free(copyAttributeList);
//        copyAttributeList T @"NSString"
//        copyAttributeList &
//        copyAttributeList N
//        copyAttributeList V _propertyC
    }}
    
//    class_copyPropertyList
//    Describes the properties declared by a class.
//    An array of pointers of type objc_property_t describing the properties declared by the class. Any properties declared by superclasses are not included.
    unsigned int copyPropertyList_outCount = 0;
    objc_property_t *copyPropertyList = class_copyPropertyList([self class], &copyPropertyList_outCount);
    for (unsigned int index = 0; index < copyPropertyList_outCount; index++) {
        NSLog(@"copyPropertyList %s", property_getName(copyPropertyList[index]));
    }
    free(copyPropertyList);
//    copyPropertyList propertyA
//    copyPropertyList propertyB
//    copyPropertyList propertyC
//    copyPropertyList hash
//    copyPropertyList superclass
//    copyPropertyList description
//    copyPropertyList debugDescription
    
//    class_addMethod
//    Adds a new method to a class with a given name and implementation.
//    class_addMethod will add an override of a superclass's implementation, but will not replace an existing implementation in this class. To change an existing implementation, use method_setImplementation.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    class_addMethod([self class], @selector(resolveThisMethodDynamically), (IMP)myMethodIMP, "v@:");
    [self performSelector:@selector(resolveThisMethodDynamically)];
//    myMethodIMP
    class_addMethod(object_getClass([self class]), @selector(resolveThisMethodDynamically), (IMP)myMethodIMP, "v@:");
    [ATRuntimeDemo performSelector:@selector(resolveThisMethodDynamically)];
//    myMethodIMP
#pragma clang diagnostic pop
    
//    class_getInstanceMethod
//    Returns a specified instance method for a given class.
//    Note that this function searches superclasses for implementations, whereas class_copyMethodList does not.
    Method method_instance = class_getInstanceMethod([self class], @selector(instanceMethod1));
    NSLog(@"getInstanceMethod %s", sel_getName(method_getName(method_instance)));
//    getInstanceMethod instanceMethod1
    
//    class_getClassMethod
//    Returns a pointer to the data structure describing a given class method for a given class.
//    Note that this function searches superclasses for implementations, whereas class_copyMethodList does not.
    Method method_class = class_getClassMethod([self class], @selector(classMethod1));
    NSLog(@"getClassMethod %s", sel_getName(method_getName(method_class)));
//    getClassMethod classMethod1
    
//    class_copyMethodList
//    Describes the instance methods implemented by a class.
//    To get the class methods of a class, use class_copyMethodList(object_getClass(cls), &count).
//    To get the implementations of methods that may be implemented by superclasses, use class_getInstanceMethod or class_getClassMethod.
    unsigned int copyMethodList_outCount = 0;
    Method *copyMethodList = class_copyMethodList([self class], &copyMethodList_outCount);
    for (unsigned int index = 0; index < copyMethodList_outCount; index++) {
        NSLog(@"copyMethodList %s", sel_getName(method_getName(copyMethodList[index])));
    }
    free(copyMethodList);
//    copyMethodList resolveThisMethodDynamically
//    copyMethodList demo
//    copyMethodList workingWithClasses
//    copyMethodList methodSwizzling
//    copyMethodList addingClasses
//    copyMethodList instantiatingClasses
//    copyMethodList workingWithInstances
//    copyMethodList obtainingClassDefinitions
//    copyMethodList workingWithInstanceVariables
//    copyMethodList associativeReferences
//    copyMethodList sendingMessages
//    copyMethodList workingWithMethods
//    copyMethodList workingWithLibraries
//    copyMethodList workingWithSelectors
//    copyMethodList workingWithProtocols
//    copyMethodList workingWithProperties
//    copyMethodList instanceMethod1
//    copyMethodList instanceMethod3
//    copyMethodList instanceMethod2
//    copyMethodList setPropertyC:
//    copyMethodList propertyC
//    copyMethodList instanceMethod4:b:
//    copyMethodList propertyA
//    copyMethodList setPropertyA:
//    copyMethodList propertyB
//    copyMethodList setPropertyB:
//    copyMethodList .cxx_destruct
    
//    class_replaceMethod
//    Replaces the implementation of a method for a given class.
//    This function behaves in two different ways:
//    If the method identified by name does not yet exist, it is added as if class_addMethod were called. The type encoding specified by types is used as given.
//    If the method identified by name does exist, its IMP is replaced as if method_setImplementation were called. The type encoding specified by types is ignored.
    class_replaceMethod([self class], @selector(instanceMethod3), (IMP)myMethodIMP, "v@:");
    [self instanceMethod3];
//    myMethodIMP
    class_replaceMethod(object_getClass([self class]), @selector(classMethod3), (IMP)myMethodIMP, "v@:");
    [ATRuntimeDemo classMethod3];
//    myMethodIMP
    
//    class_getMethodImplementation
//    Returns the function pointer that would be called if a particular message were sent to an instance of a class.
//    class_getMethodImplementation may be faster than method_getImplementation(class_getInstanceMethod(cls, name)).
//    The function pointer returned may be a function internal to the runtime instead of an actual method implementation. For example, if instances of the class do not respond to the selector, the function pointer returned will be part of the runtime's message forwarding machinery.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Wunused-variable"
    IMP imp_instance = class_getMethodImplementation([self class], @selector(instanceMethod3));
//    (AppToolboxDemo`myMethodIMP at ATRuntimeDemo.m:13)
    IMP imp_no = class_getMethodImplementation([self class], @selector(no));
//    (libobjc.A.dylib`_objc_msgForward)
#pragma clang diagnostic pop
    
//    class_getMethodImplementation_stret
//    Returns the function pointer that would be called if a particular message were sent to an instance of a class.
//    a data-structure return value
    
//    class_respondsToSelector
//    Returns a Boolean value that indicates whether instances of a class respond to a particular selector.
//    You should usually use NSObject's respondsToSelector: or instancesRespondToSelector: methods instead of this function.
    NSLog(@"respondsToSelector %d", class_respondsToSelector([self class], @selector(instanceMethod3)));
//    respondsToSelector 1
    
//    class_addProtocol
//    Adds a protocol to a class.
    class_addProtocol([self class], @protocol(ITestProtocol));
    
//    class_conformsToProtocol
//    Returns a Boolean value that indicates whether a class conforms to a given protocol.
//    You should usually use NSObject‘s conformsToProtocol: method instead of this function.
    NSLog(@"conformsToProtocol %d", class_conformsToProtocol([self class], @protocol(ITestProtocol)));
//    conformsToProtocol 1

//    class_copyProtocolList
//    Describes the protocols adopted by a class.
//     Any protocols adopted by superclasses or other protocols are not included.
    unsigned int copyProtocolList_outCount = 0;
    __unsafe_unretained Protocol **copyProtocolList = class_copyProtocolList([self class], &copyProtocolList_outCount);
    for (unsigned int index = 0; index < copyProtocolList_outCount; index++) {
        NSLog(@"copyProtocolList %s", protocol_getName(copyProtocolList[index]));
    }
    free(copyProtocolList);
//    copyProtocolList ITestProtocol
//    copyProtocolList IDemoProtocol
    
//    class_addProperty
//    Adds a property to a class.
    objc_property_attribute_t types = { "T", "@\"NSString\"" };
    objc_property_attribute_t ownership = { "C", "" }; // C = copy
    objc_property_attribute_t backIvar = { "V", "_privateName" };
    objc_property_attribute_t attrs[] = { types, ownership, backIvar };
    class_addProperty([self class], "name", attrs, 3);
    
    objc_property_t property_name = class_getProperty([self class], "name");
    NSLog(@"getProperty getAttributes %s", property_getAttributes(property_name));
//    getProperty getAttributes T@"NSString",C,V_privateName
    
//    class_replaceProperty
//    Replace a property of a class.
    objc_property_attribute_t ownership2 = { "&", "" }; // & = strong
    objc_property_attribute_t attrs2[] = { types, ownership2, backIvar };
    class_replaceProperty([self class], "name", attrs2, 3);
    objc_property_t property_name2 = class_getProperty([self class], "name");
    NSLog(@"property_name_attribute %s", property_getAttributes(property_name2));
//    property_name_attribute T@"NSString",&,V_privateName
    
//    class_getVersion
//    Returns the version number of a class definition.
    
//    class_setVersion
//    Sets the version number of a class definition.
    
//    objc_getFutureClass
//    Used by CoreFoundation's toll-free bridging.
    
//    objc_setFutureClass
//    Used by CoreFoundation's toll-free bridging.
}

- (void)methodSwizzling
{
    Class aClass = [self class];
    Class metaClass = object_getClass(aClass);
    
    SEL selClassMethod1 = @selector(classMethod1);
    SEL selClassMethod2 = @selector(classMethod2);
    SEL selInstanceMethod1 = @selector(instanceMethod1);
    SEL selInstanceMethod2 = @selector(instanceMethod2);
    
    Method methodClassMethod1 = class_getClassMethod(aClass, selClassMethod1);
    Method methodClassMethod2 = class_getClassMethod(aClass, selClassMethod2);
    Method methodInstanceMethod1 = class_getInstanceMethod(aClass, selInstanceMethod1);
    Method methodInstanceMethod2 = class_getInstanceMethod(aClass, selInstanceMethod2);
    
    const char * typeClassMethod1 = method_getTypeEncoding(methodClassMethod1);
    const char * typeClassMethod2 = method_getTypeEncoding(methodClassMethod2);
    const char * typeInstanceMethod1 = method_getTypeEncoding(methodInstanceMethod1);
    const char * typeInstanceMethod2 = method_getTypeEncoding(methodInstanceMethod2);
    
    IMP impClassMethod1 = method_getImplementation(methodClassMethod1);
    IMP impClassMethod2 = method_getImplementation(methodClassMethod2);
    IMP impInstanceMethod1 = method_getImplementation(methodInstanceMethod1);
    IMP impInstanceMethod2 = method_getImplementation(methodInstanceMethod2);
    
    [[self class] classMethod1];
//    classMethod1
    [[self class] classMethod2];
//    classMethod2
    
//    class_replaceMethod(aClass, selClassMethod1, impClassMethod2, typeClassMethod2);
//    class_replaceMethod(aClass, selClassMethod2, impClassMethod1, typeClassMethod1);
    
    class_replaceMethod(metaClass, selClassMethod1, impClassMethod2, typeClassMethod2);
    class_replaceMethod(metaClass, selClassMethod2, impClassMethod1, typeClassMethod1);
    
    [[self class] classMethod1];
//    classMethod2
    [[self class] classMethod2];
//    classMethod1
    
    [self instanceMethod1];
//    instanceMethod1
    [self instanceMethod2];
//    instanceMethod2
    
    class_replaceMethod(aClass, selInstanceMethod1, impInstanceMethod2, typeInstanceMethod2);
    class_replaceMethod(aClass, selInstanceMethod2, impInstanceMethod1, typeInstanceMethod1);
    
    [self instanceMethod1];
//    instanceMethod2
    [self instanceMethod2];
//    instanceMethod1
}

- (void)addingClasses
{
//    objc_allocateClassPair
//    Creates a new class and metaclass.
//    You can get a pointer to the new metaclass by calling object_getClass(newClass).
//    To create a new class, start by calling objc_allocateClassPair. Then set the class's attributes with functions like class_addMethod and class_addIvar. When you are done building the class, call objc_registerClassPair. The new class is now ready for use.
//    Instance methods and instance variables should be added to the class itself. Class methods should be added to the metaclass.
    Class aClass = objc_allocateClassPair([NSObject class], "MYCLASS", 0);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    class_addMethod(aClass, @selector(myClassTest), (IMP)myMethodIMP, "v@:");
    class_addMethod(object_getClass(aClass), @selector(myClassTest), (IMP)myMethodIMP, "v@:");
    class_addIvar(aClass, "name", sizeof(id), log2(sizeof(id)), @encode(id));
    
//    objc_registerClassPair
//    Registers a class that was allocated using objc_allocateClassPair.
    objc_registerClassPair(aClass);
    [aClass performSelector:@selector(myClassTest)];
//    myMethodIMP
    id myClassInstance = [[aClass alloc] init];
    [myClassInstance performSelector:@selector(myClassTest)];
//    myMethodIMP
    [myClassInstance setValue:@"1234567890" forKey:@"name"];
    NSLog(@"myClassInstance_name %@", [myClassInstance valueForKey:@"name"]);
//    myClassInstance_name 1234567890
#pragma clang diagnostic pop

//    objc_disposeClassPair
//    Destroys a class and its associated metaclass.
//    Do not call this function if instances of the cls class or any subclass exist.
    
//    objc_duplicateClass
//    Used by Foundation's Key-Value Observing.
}

- (void)instantiatingClasses
{
//    class_createInstance
//    Creates an instance of a class, allocating memory for the class in the default malloc memory zone.
    
//    objc_constructInstance
//    Creates an instance of a class at the specified location.
    
//    objc_destructInstance
//    Destroys an instance of a class without freeing memory and removes any of its associated references.
}

- (void)workingWithInstances
{
//    object_copy
//    Returns a copy of a given object.
    
//    object_dispose
//    Frees the memory occupied by a given object.
    
//    object_setInstanceVariable
//    Changes the value of an instance variable of a class instance.
    
//    object_getInstanceVariable
//    Obtains the value of an instance variable of a class instance.
    
//    object_getIndexedIvars
//    Returns a pointer to any extra bytes allocated with a instance given object.
    
//    not available in automatic reference counting mode
    
    self.propertyC = @"do";
    
//    object_getIvar
//    Reads the value of an instance variable in an object.
//    object_getIvar is faster than object_getInstanceVariable if the Ivar for the instance variable is already known.
    id getIvar = object_getIvar(self, class_getInstanceVariable([self class], "_propertyC"));
    NSLog(@"getIvar %@", getIvar);
//    getIvar do
    
//    id object_propertyA = object_getIvar(self, class_getInstanceVariable([self class], "_propertyA"));
//    !CRASH retain
//    id object_instance_a = object_getIvar(self, class_getInstanceVariable([self class], "instace_a"));
//    !CRASH retain
    
//    object_setIvar
//    Sets the value of an instance variable in an object.
//    object_setIvar is faster than object_setInstanceVariable if the Ivar for the instance variable is already known.
    object_setIvar(self, class_getInstanceVariable([self class], "_propertyC"), @"done");
    NSLog(@"propertyC %@", self.propertyC);
//    propertyC done
    
//    object_getClassName
//    Returns the class name of a given object.
    NSLog(@"getClassName %s", object_getClassName(self));
//    getClassName ATRuntimeDemo
    
//    object_getClass
//    Returns the class of an object.
    NSLog(@"getClass %s", class_getName(object_getClass(self)));
//    getClass ATRuntimeDemo
    
//    object_setClass
//    Sets the class of an object.
    object_setClass(self, [ATRuntimeDemoEx class]);
    NSLog(@"getClassName %s", object_getClassName(self));
//    getClassName ATRuntimeDemoEx
}

- (void)obtainingClassDefinitions
{
//    objc_getClassList
//    Obtains the list of registered class definitions.
//    The Objective-C runtime library automatically registers all the classes defined in your source code. You can create class definitions at runtime and register them with the objc_addClass function.
    int numClasses;
    Class *classes = NULL;
    numClasses = objc_getClassList(NULL, 0);
    if (numClasses > 0) {
        classes = (Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        for (int i = 0; i < numClasses; ++i) {
//            NSLog(@"class_list_name %s", object_getClassName(classes[i]));
        }
        free(classes);
    }
    
//    objc_copyClassList
//    Creates and returns a list of pointers to all registered class definitions.
    unsigned int copyClassList_outCount = 0;
    __unsafe_unretained Class *copyClassList = objc_copyClassList(&copyClassList_outCount);
    for (unsigned int index = 0; index < copyClassList_outCount; index++) {
//        NSLog(@"copyClassList %s", object_getClassName(copyClassList[index]));
    }
    free(copyClassList);
    
//    objc_lookUpClass
//    Returns the class definition of a specified class.
//    objc_getClass is different from this function in that if the class is not registered, objc_getClass calls the class handler callback and then checks a second time to see whether the class is registered. This function does not call the class handler callback.
    NSLog(@"lookUpClass %s", class_getName(objc_lookUpClass("ATRuntimeDemo")));
//    lookUpClass ATRuntimeDemo
    NSLog(@"lookUpClass %s", class_getName(objc_lookUpClass("ATRuntimeDemoXX")));
//    lookUpClass nil
    
//    objc_getClass
//    Returns the class definition of a specified class.
//    objc_getClass is different from objc_lookUpClass in that if the class is not registered, objc_getClass calls the class handler callback and then checks a second time to see whether the class is registered. objc_lookUpClass does not call the class handler callback.
    NSLog(@"getClass %s", class_getName(objc_getClass("ATRuntimeDemo")));
//    getClass ATRuntimeDemo
    NSLog(@"getClass %s", class_getName(objc_getClass("ATRuntimeDemoXX")));
//    getClass nil
    
//    objc_getRequiredClass
//    Returns the class definition of a specified class.
//    This function is the same as objc_getClass, but kills the process if the class is not found.
//    This function is used by ZeroLink, where failing to find a class would be a compile-time link error without ZeroLink.
    
//    objc_getMetaClass
//    Returns the metaclass definition of a specified class.
//    If the definition for the named class is not registered, this function calls the class handler callback and then checks a second time to see if the class is registered. However, every class definition must have a valid metaclass definition, and so the metaclass definition is always returned, whether it’s valid or not.
    NSLog(@"getMetaClass %s", class_getName(objc_getMetaClass("ATRuntimeDemo")));
//    getMetaClass ATRuntimeDemo
}

- (void)workingWithInstanceVariables
{
    Ivar ivar_instance_a = class_getInstanceVariable([self class], "instace_a");
//    ivar_getName
//    Returns the name of an instance variable.
    NSLog(@"getName %s", ivar_getName(ivar_instance_a));
//    getName instace_a
    
//    ivar_getTypeEncoding
//    Returns the type string of an instance variable.
    NSLog(@"getTypeEncoding %s", ivar_getTypeEncoding(ivar_instance_a));
//    getTypeEncoding i
    
//    ivar_getOffset
//    Returns the offset of an instance variable.
    NSLog(@"getOffset %td", ivar_getOffset(ivar_instance_a));
//    getOffset 8
}

- (void)associativeReferences
{
//    objc_setAssociatedObject
//    Sets an associated value for a given object using a given key and association policy.
    id associatedObject = @(9);
    objc_setAssociatedObject(self, "associatedObject", associatedObject, OBJC_ASSOCIATION_RETAIN);
    
//    objc_getAssociatedObject
//    Returns the value associated with a given object for a given key.
    id associatedObject2 = objc_getAssociatedObject(self, "associatedObject");
    NSLog(@"getAssociatedObject %@", associatedObject2);
//    getAssociatedObject 9
    
//    objc_removeAssociatedObjects
//    Removes all associations for a given object.
//    The main purpose of this function is to make it easy to return an object to a "pristine state”. You should not use this function for general removal of associations from objects, since it also removes associations that other clients may have added to the object. Typically you should use objc_setAssociatedObject with a nil value to clear an association.
    objc_removeAssociatedObjects(self);
}

- (void)sendingMessages
{
//    objc_msgSend
//    sends a message with a simple return value to an instance of a class.
    
//    objc_msgSend_stret
//    sends a message with a data-structure return value to an instance of a class.
    
//    objc_msgSendSuper
//    sends a message with a simple return value to the superclass of an instance of a class.
    
//    objc_msgSendSuper_stret
//    sends a message with a data-structure return value to the superclass of an instance of a class.
    
//    objc_msgSend(self, @selector(instanceMethod3));
//    error: too many arguments to function call, expected 0, have 2
//    enable ENABLE_STRICT_OBJC_MSGSEND or ...
    ((void (*)(id, SEL))objc_msgSend)((id)self, @selector(instanceMethod3));
//    myMethodIMP
}

- (void)workingWithMethods
{
//    method_invoke
//    Calls the implementation of a specified method.
//    Using this function to call the implementation of a method is faster than calling method_getImplementation and method_getName.
    Method method_instance = class_getInstanceMethod([self class], @selector(instanceMethod3));
    ((void (*)(id, Method))method_invoke)(self, method_instance);
//    myMethodIMP
    
//    method_invoke_stret
//    Calls the implementation of a specified method that returns a data-structure.
//    Using this function to call the implementation of a method is faster than calling method_getImplementation and method_getName.
    
//    method_getName
//    Returns the name of a method.
//    To get the method name as a C string, call sel_getName(method_getName(method)).
    NSLog(@"getName %s", sel_getName(method_getName(method_instance)));
//    getName instanceMethod3
    
//    method_getImplementation
//    Returns the implementation of a method.
     __unused IMP method_imp = method_getImplementation(method_instance);
//    (AppToolboxDemo`myMethodIMP at ATRuntimeDemo.m:14)
    
//    method_getTypeEncoding
//    Returns a string describing a method's parameter and return types.
    NSLog(@"getTypeEncoding %s", method_getTypeEncoding(method_instance));
//    getTypeEncoding v16@0:8
    
//    method_copyReturnType
//    Returns a string describing a method's return type.
    char *copyReturnType = method_copyReturnType(method_instance);
    NSLog(@"copyReturnType %s", copyReturnType);
//    copyReturnType v
    free(copyReturnType);
    
//    method_copyArgumentType
//    Returns a string describing a single parameter type of a method.
    char *copyArgumentType1 = method_copyArgumentType(method_instance, 0);
    NSLog(@"copyArgumentType %s", copyArgumentType1);
//    copyArgumentType @
    free(copyArgumentType1);
    char *copyArgumentType2 = method_copyArgumentType(method_instance, 1);
    NSLog(@"copyArgumentType %s", copyArgumentType2);
//    copyArgumentType :
    free(copyArgumentType2);
    char *copyArgumentType3 = method_copyArgumentType(method_instance, 2);
    NSLog(@"copyArgumentType %s", copyArgumentType3);
//    copyArgumentType (null)
    free(copyArgumentType3);
    
//    method_getReturnType
//    Returns by reference a string describing a method's return type.
    char getReturnType[512] = {};
    method_getReturnType(method_instance, getReturnType, 512);
    NSLog(@"getReturnType %s", getReturnType);
//    getReturnType v
    
//    method_getNumberOfArguments
//    Returns the number of arguments accepted by a method.
    NSLog(@"getNumberOfArguments %d", method_getNumberOfArguments(method_instance));
//    getNumberOfArguments 2
    
//    method_getArgumentType
//    Returns by reference a string describing a single parameter type of a method.
    char getArgumentType[512] = {};
    method_getArgumentType(method_instance, 0, getArgumentType, 512);
    NSLog(@"getArgumentType %s", getArgumentType);
//    getArgumentType @
    
//    method_getDescription
//    Returns a method description structure for a specified method.
    struct objc_method_description *method_description = method_getDescription(method_instance);
    NSLog(@"getDescription %s %s", sel_getName(method_description->name), method_description->types);
//    getDescription instanceMethod3 v16@0:8
    
//    method_setImplementation
//    Sets the implementation of a method.

//    method_exchangeImplementations
//    Exchanges the implementations of two methods.
}

- (void)workingWithLibraries
{
//    objc_copyImageNames
//    Returns the names of all the loaded Objective-C frameworks and dynamic libraries.
    
//    class_getImageName
//    Returns the name of the dynamic library a class originated from.
    
//    objc_copyClassNamesForImage
//    Returns the names of all the classes within a specified library or framework.
}

- (void)workingWithSelectors
{
//    sel_getName
//    Returns the name of the method specified by a given selector.
    
//    sel_registerName
//    Registers a method with the Objective-C runtime system, maps the method name to a selector, and returns the selector value.
//    You must register a method name with the Objective-C runtime system to obtain the method’s selector before you can add the method to a class definition. If the method name has already been registered, this function simply returns the selector.
    
//    sel_getUid
//    Registers a method name with the Objective-C runtime system.
//    The implementation of this method is identical to the implementation of sel_registerName.
    
//    sel_isEqual
//    Returns a Boolean value that indicates whether two selectors are equal.
}

- (void)workingWithProtocols
{
//    objc_getProtocol
//    Returns a specified protocol.
    Protocol *protocol = objc_getProtocol("IDemoProtocol");
    NSLog(@"getProtocol %s", protocol_getName(protocol));
//    getProtocol IDemoProtocol
    
//    objc_copyProtocolList
//    Returns an array of all the protocols known to the runtime.
    unsigned int outCount = 0;
    __unsafe_unretained Protocol **copyProtocolList = objc_copyProtocolList(&outCount);
    for (unsigned int index = 0; index < outCount; index++) {
//        NSLog(@"copyProtocolList name %s", protocol_getName(copyProtocolList[index]));
    }
    free(copyProtocolList);
    
//    objc_allocateProtocol
//    You must register the returned protocol instance with the objc_registerProtocol function before you can use it.
//    There is no dispose method associated with this function.
    Protocol *allocateProtocol = objc_allocateProtocol("IDemoProtocol2");
    NSLog(@"allocateProtocol %s", protocol_getName(allocateProtocol));
//    allocateProtocol IDemoProtocol2
    
//    protocol_addMethodDescription
//    Adds a method to a protocol.
//    To add a method to a protocol using this function, the protocol must be under construction. That is, you must add any methods to proto before you register it with the Objective-C runtime (via the objc_registerProtocol function).
    protocol_addMethodDescription(allocateProtocol, @selector(demo), "v@:", YES, YES);
    
//    protocol_addProtocol
//    Adds a registered protocol to another protocol that is under construction.
//    The protocol you want to add to (proto) must be under construction—allocated but not yet registered with the Objective-C runtime. The protocol you want to add (addition) must be registered already.
    protocol_addProtocol(allocateProtocol, @protocol(IDemoProtocol));
    
//    protocol_addProperty
//    Adds a property to a protocol that is under construction.
//    The protocol you want to add the property to must be under construction—allocated but not yet registered with the Objective-C runtime (via the objc_registerProtocol function).
    objc_property_attribute_t types = { "T", "@\"NSString\"" };
    objc_property_attribute_t ownership = { "C", "" }; // C = copy
    objc_property_attribute_t backIvar = { "V", "_privateName" };
    objc_property_attribute_t attrs[] = { types, ownership, backIvar };
    protocol_addProperty(allocateProtocol, "name", attrs, 3, YES, YES);
    
//    protocol_getName
//    Returns a the name of a protocol.
    NSLog(@"getName %s", protocol_getName(allocateProtocol));
//    getName IDemoProtocol2
    
//    protocol_isEqual
//    Returns a Boolean value that indicates whether two protocols are equal.
    NSLog(@"isEqual %d", protocol_isEqual(allocateProtocol, @protocol(IDemoProtocol)));
//    isEqual 0
    
//    protocol_copyMethodDescriptionList
//    Returns an array of method descriptions of methods meeting a given specification for a given protocol.
    struct objc_method_description *copyMethodDescriptionList = NULL;
    unsigned int copyMethodDescriptionList_outCount = 0;
    copyMethodDescriptionList = protocol_copyMethodDescriptionList(allocateProtocol, YES, YES, &copyMethodDescriptionList_outCount);
    for (unsigned int index = 0; index < copyMethodDescriptionList_outCount; index++) {
        struct objc_method_description description = copyMethodDescriptionList[index];
        NSLog(@"copyMethodDescriptionList %s %s", sel_getName(description.name), description.types);
    }
    free(copyMethodDescriptionList);
//    copyMethodDescriptionList demo v@:
    
//    protocol_getMethodDescription
//    Returns a method description structure for a specified method of a given protocol.
    struct objc_method_description getMethodDescription = protocol_getMethodDescription(allocateProtocol, @selector(demo), YES, YES);
    NSLog(@"getMethodDescription %s %s", sel_getName(getMethodDescription.name), getMethodDescription.types);
//    getMethodDescription demo v@:
    
//    protocol_copyPropertyList
//    Returns an array of the properties declared by a protocol.
//    A C array of pointers of type objc_property_t describing the properties declared by proto. Any properties declared by other protocols adopted by this protocol are not included. The array contains *outCount pointers followed by a NULL terminator. You must free the array with free().
//    If the protocol declares no properties, NULL is returned and *outCount is 0.
    unsigned int copyPropertyList_outCount = 0;
    objc_property_t *copyPropertyList = protocol_copyPropertyList(allocateProtocol, &copyPropertyList_outCount);
    for (unsigned int index = 0; index < copyPropertyList_outCount; index++) {
        objc_property_t property = copyPropertyList[index];
        NSLog(@"copyPropertyList %s", property_getName(property));
    }
    free(copyPropertyList);
//    copyPropertyList name
    
//    protocol_getProperty
//    Returns the specified property of a given protocol.
    objc_property_t getProperty = protocol_getProperty(allocateProtocol, "name", YES, YES);
    NSLog(@"getProperty %s", property_getName(getProperty));
//    getProperty name
    
//    protocol_copyProtocolList
//    Returns an array of the protocols adopted by a protocol.
    unsigned int copyProtocolList_outCount = 0;
    __unsafe_unretained Protocol **protocolCopyProtocolList = protocol_copyProtocolList(allocateProtocol, &copyProtocolList_outCount);
    for (unsigned int index = 0; index < copyProtocolList_outCount; index++) {
        Protocol *protocol = protocolCopyProtocolList[index];
        NSLog(@"copyProtocolList %s", protocol_getName(protocol));
    }
    free(protocolCopyProtocolList);
//    copyProtocolList IDemoProtocol
    
//    protocol_conformsToProtocol
//    Returns a Boolean value that indicates whether one protocol conforms to another protocol.
    NSLog(@"conformsToProtocol %d", protocol_conformsToProtocol(allocateProtocol, @protocol(IDemoProtocol)));
//    conformsToProtocol 1
    
//    objc_registerProtocol
//    Registers a newly created protocol with the Objective-C runtime.
//    When you create a new protocol using the objc_allocateProtocol, you then register it with the Objective-C runtime by calling this function. After a protocol is successfully registered, it is immutable and ready to use.
    objc_registerProtocol(allocateProtocol);
}

- (void)workingWithProperties
{
    objc_property_t property = class_getProperty([self class], "propertyA");
    
//    property_getName
//    Returns the name of a property.
    NSLog(@"getName %s", property_getName(property));
//    getName propertyA
    
//    property_getAttributes
//    Returns the attribute string of a property.
    NSLog(@"getAttributes %s", property_getAttributes(property));
//    getAttributes Ti,N,V_propertyA
    
//    property_copyAttributeValue
//    Returns the value of a property attribute given the attribute name.
    unsigned int outCount = 0;
    objc_property_attribute_t *copyAttributeList = property_copyAttributeList(property, &outCount);
    for (unsigned int index = 0; index < outCount; index++) {
        NSLog(@"copyAttributeList %s %s", copyAttributeList[index].name, copyAttributeList[index].value);
    }
    free(copyAttributeList);
//    copyAttributeList T i
//    copyAttributeList N
//    copyAttributeList V _propertyA
    
//    property_copyAttributeList
//    Returns an array of property attributes for a given property.
    NSLog(@"copyAttributeValue %s", property_copyAttributeValue(property, "V"));
//    copyAttributeValue _propertyA
}

- (void)usingObjectiveCLanguageFeatures
{
//    objc_enumerationMutation
//    Inserted by the compiler when a mutation is detected during a foreach iteration.
//    The compiler inserts this function when it detects that an object is mutated during a foreach iteration. The function is called when a mutation occurs, and the enumeration mutation handler is enacted if it is set up (via the objc_setEnumerationMutationHandler function). If the handler is not set up, a fatal error occurs.
    
//    objc_setEnumerationMutationHandler
//    !still crash
    objc_setEnumerationMutationHandler(MyEnumerationMutationHandler);
    
    NSMutableArray *array = [NSMutableArray arrayWithObjects:@1, @2, @3, nil];
    for (NSNumber *tmp in array) {
        NSLog(@"enumeration %@", tmp);
//        [array addObject:@4];
    }
//    *** Terminating app due to uncaught exception 'NSGenericException', reason: '*** Collection <__NSArrayM: 0x600000043360> was mutated while being enumerated.'
    
//    imp_implementationWithBlock
//    Creates a pointer to a function that calls the specified block when the method is called.
//    The block that implements this method. The signature of block should be method_return_type ^(id self, self, method_args …). The selector of the method is not available to block. block is copied with Block_copy().
    id block = ^(id self, id value) {
        NSLog(@"block %@", value);
    };
    IMP block_imp = imp_implementationWithBlock(block);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    class_addMethod([self class], @selector(testBlock:), block_imp, "v@:@");
    [self performSelector:@selector(testBlock:) withObject:@"123"];
//    block 123
#pragma clang diagnostic pop
    
//    imp_getBlock
//    Returns the block associated with an IMP that was created using imp_implementationWithBlock.
    id getBlock = imp_getBlock(block_imp);
    ((void(^)(id, id))getBlock)(self, @(789));
//    block 789
    
//    imp_removeBlock
//    Disassociates a block from an IMP that was created using imp_implementationWithBlock, and releases the copy of the block that was created.
    NSLog(@"removeBlock %d", imp_removeBlock(block_imp));
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
//    [self performSelector:@selector(testBlock:) withObject:@"123"];
//    !crash
#pragma clang diagnostic pop
    
//    objc_loadWeak
//    Loads the object referenced by a weak pointer and returns it.
//    This function loads the object referenced by a weak pointer and returns it after retaining and autoreleasing the object. As a result, the object stays alive long enough for the caller to use it. This function is typically used anywhere a __weak variable is used in an expression.
    
//    objc_storeWeak
//    Stores a new value in a __weak variable.
//    This function is typically used anywhere a __weak variable is the target of an assignment.
}

@end
