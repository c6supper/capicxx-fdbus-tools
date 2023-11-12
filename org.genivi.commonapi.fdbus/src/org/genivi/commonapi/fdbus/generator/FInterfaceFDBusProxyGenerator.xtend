/* Copyright (C) 2014-2020 Bayerische Motoren Werke Aktiengesellschaft (BMW AG)
   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, You can obtain one at http://mozilla.org/MPL/2.0/. */
package org.genivi.commonapi.fdbus.generator

import java.util.List
import javax.inject.Inject
import org.eclipse.core.resources.IResource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMethod
import org.franca.core.franca.FModelElement
import org.franca.core.franca.FVersion
import org.franca.deploymodel.dsl.fDeploy.FDExtensionRoot
import org.franca.deploymodel.ext.providers.FDeployedProvider
import org.franca.deploymodel.ext.providers.ProviderUtils
import org.genivi.commonapi.core.generator.FTypeGenerator
import org.genivi.commonapi.core.generator.FrancaGeneratorExtensions
import org.genivi.commonapi.fdbus.deployment.PropertyAccessor

import static com.google.common.base.Preconditions.*
import org.genivi.commonapi.fdbus.preferences.PreferenceConstantsFDBus
import org.genivi.commonapi.fdbus.preferences.FPreferencesFDBus

class FInterfaceFDBusProxyGenerator {
    @Inject extension FrancaGeneratorExtensions
    @Inject extension FrancaFDBusGeneratorExtensions

    var boolean generateSyncCalls = true

    def generateProxy(FInterface fInterface, IFileSystemAccess fileSystemAccess, PropertyAccessor deploymentAccessor,
        List<FDExtensionRoot> providers, IResource modelid) {

        if(FPreferencesFDBus::getInstance.getPreference(PreferenceConstantsFDBus::P_GENERATE_CODE_FDBUS, "true").equals("true")) {
            generateSyncCalls = FPreferencesFDBus::getInstance.getPreference(PreferenceConstantsFDBus::P_GENERATE_SYNC_CALLS_FDBUS, "true").equals("true")
            fileSystemAccess.generateFile(fInterface.fdbusProxyHeaderPath, PreferenceConstantsFDBus.P_OUTPUT_PROXIES_FDBUS,
                fInterface.generateProxyHeader(deploymentAccessor, modelid))
            fileSystemAccess.generateFile(fInterface.fdbusProxySourcePath, PreferenceConstantsFDBus.P_OUTPUT_PROXIES_FDBUS,
                fInterface.generateProxySource(deploymentAccessor, providers, modelid))
        }
        else {
            // feature: suppress code generation
            fileSystemAccess.generateFile(fInterface.fdbusProxyHeaderPath, PreferenceConstantsFDBus.P_OUTPUT_PROXIES_FDBUS,
                PreferenceConstantsFDBus::NO_CODE)
            fileSystemAccess.generateFile(fInterface.fdbusProxySourcePath, PreferenceConstantsFDBus.P_OUTPUT_PROXIES_FDBUS,
                PreferenceConstantsFDBus::NO_CODE)
        }
    }

    def private generateProxyHeader(FInterface _interface, PropertyAccessor _accessor, IResource _modelid) '''
        «generateCommonApiFDBusLicenseHeader()»
        «FTypeGenerator::generateComments(_interface, false)»
        #ifndef «_interface.defineName.toUpperCase»_FDBUS_PROXY_HPP_
        #define «_interface.defineName.toUpperCase»_FDBUS_PROXY_HPP_

        #include <«_interface.proxyBaseHeaderPath»>
        «IF _interface.base !== null»
            #include <«_interface.base.fdbusProxyHeaderPath»>
        «ENDIF»
        «val DeploymentHeaders = _interface.getDeploymentInputIncludes(_accessor)»
        «DeploymentHeaders.map["#include <" + it + ">"].join("\n")»

        «startInternalCompilation»

        #include <CommonAPI/FDBus/Factory.hpp>
        #include <CommonAPI/FDBus/Proxy.hpp>
        #include <CommonAPI/FDBus/Types.hpp>
        «IF _interface.hasAttributes»
            #include <CommonAPI/FDBus/Attribute.hpp>
        «ENDIF»
        «IF _interface.hasBroadcasts»
            #include <CommonAPI/FDBus/Event.hpp>
            «IF _interface.hasSelectiveBroadcasts»
                #include <CommonAPI/Types.hpp>
            «ENDIF»
        «ENDIF»
        «IF !_interface.managedInterfaces.empty»
            #include <CommonAPI/FDBus/ProxyManager.hpp>
        «ENDIF»

        «endInternalCompilation»

        #include <string>

        # if defined(_MSC_VER)
        #  if _MSC_VER >= 1300
        /*
         * Diamond inheritance is used for the CommonAPI::Proxy base class.
         * The Microsoft compiler put warning (C4250) using a desired c++ feature: "Delegating to a sister class"
         * A powerful technique that arises from using virtual inheritance is to delegate a method from a class in another class
         * by using a common abstract base class. This is also called cross delegation.
         */
        #    pragma warning( disable : 4250 )
        #  endif
        # endif

        «_interface.generateVersionNamespaceBegin»
        «_interface.model.generateNamespaceBeginDeclaration»

        class «_interface.fdbusProxyClassName»
            : virtual public «_interface.proxyBaseClassName»,
              virtual public «IF _interface.base !== null»«_interface.base.getTypeCollectionName(_interface)»FDBusProxy«ELSE»CommonAPI::FDBus::Proxy«ENDIF» {
        public:
            «_interface.fdbusProxyClassName»(
                const CommonAPI::FDBus::Address &_address,
                const std::shared_ptr<CommonAPI::FDBus::ProxyConnection> &_connection);

            virtual ~«_interface.fdbusProxyClassName»();

            «FOR attribute : _interface.attributes»
                virtual «attribute.generateGetMethodDefinition»;

            «ENDFOR»
            «FOR broadcast : _interface.broadcasts»
                virtual «broadcast.generateGetMethodDefinition»;

            «ENDFOR»
            «FOR method : _interface.methods»
            «FTypeGenerator::generateComments(method, false)»
            «IF generateSyncCalls || method.isFireAndForget»
                virtual «method.generateDefinition(false)»;

            «ENDIF»
            «IF !method.isFireAndForget»
                virtual «method.generateAsyncDefinition(false)»;

            «ENDIF»
            «ENDFOR»
            «FOR managed : _interface.managedInterfaces»
                virtual CommonAPI::ProxyManager &«managed.proxyManagerGetterName»();
                
            «ENDFOR»
            virtual void getOwnVersion(uint16_t &_major, uint16_t &_minor) const;

            virtual std::future<void> getCompletionFuture();

        private:
            «FOR attribute : _interface.attributes»
                «IF attribute.supportsTypeValidation»
                    class FDBus«attribute.fdbusClassVariableName»Attribute : public «attribute.fdbusClassName(_interface, _accessor)» {
                    public:
                        template <typename... _A>
                            FDBus«attribute.fdbusClassVariableName»Attribute(«_interface.fdbusProxyClassName» &_proxy,
                                _A ... arguments) : «attribute.fdbusClassName(_interface, _accessor)»(
                                                        _proxy, arguments...) {}
                        «IF !attribute.isReadonly»
                            void setValue(const «attribute.getTypeName(_interface, true)»& requestValue,
                                          CommonAPI::CallStatus& callStatus,
                                          «attribute.getTypeName(_interface, true)»& responseValue,
                                          const CommonAPI::CallInfo *_info = nullptr) {
                                // validate input parameters
                                «IF attribute.array»
                                for (std::size_t i = 0; i < requestValue.size(); i++) {
                                    if (!requestValue[i].validate()) {
                                        callStatus = CommonAPI::CallStatus::INVALID_VALUE;
                                        return;
                                    }
                                }
                                «ELSE»
                                if (!requestValue.validate()) {
                                    callStatus = CommonAPI::CallStatus::INVALID_VALUE;
                                    return;
                                }
                                «ENDIF»
                                // call base function if ok
                                «attribute.fdbusClassName(_interface, _accessor)»::setValue(requestValue, callStatus, responseValue, _info);
                            }
                            std::future<CommonAPI::CallStatus> setValueAsync(const «attribute.getTypeName(_interface, true)»& requestValue,
                                                                             std::function<void(const CommonAPI::CallStatus &, «attribute.getTypeName(_interface, true)»)> _callback,
                                                                             const CommonAPI::CallInfo *_info) {
                                // validate input parameters
                                «IF attribute.array»
                                    for (std::size_t i = 0; i < requestValue.size(); i++) {
                                        if (!requestValue[i].validate()) {
                                            «attribute.getTypeName(_interface, true)» _returnValue;
                                            _callback(CommonAPI::CallStatus::INVALID_VALUE, _returnValue);
                                            std::promise<CommonAPI::CallStatus> promise;
                                            promise.set_value(CommonAPI::CallStatus::INVALID_VALUE);
                                            return promise.get_future();
                                        }
                                    }
                                «ELSE»
                                    if (!requestValue.validate()) {
                                        «attribute.getTypeName(_interface, true)» _returnValue;
                                        _callback(CommonAPI::CallStatus::INVALID_VALUE, _returnValue);
                                        std::promise<CommonAPI::CallStatus> promise;
                                        promise.set_value(CommonAPI::CallStatus::INVALID_VALUE);
                                        return promise.get_future();
                                    }
                                «ENDIF»
                                // call base function if ok
                                return «attribute.fdbusClassName(_interface, _accessor)»::setValueAsync(requestValue, _callback, _info);
                            }
                        «ENDIF»
                    };
                    FDBus«attribute.fdbusClassVariableName»Attribute «attribute.fdbusClassVariableName»;

                «ELSE»
                    «attribute.fdbusClassName(_interface, _accessor)» «attribute.fdbusClassVariableName»;
                «ENDIF»
            «ENDFOR»
            «FOR broadcast : _interface.broadcasts»
                «broadcast.fdbusClassName(_interface, _accessor)» «broadcast.fdbusClassVariableName»;
            «ENDFOR»
            «FOR managed : _interface.managedInterfaces»
                 CommonAPI::FDBus::ProxyManager «managed.proxyManagerMemberName»;
            «ENDFOR»

        };

        «_interface.model.generateNamespaceEndDeclaration»
        «_interface.generateVersionNamespaceEnd»

        #endif // «_interface.defineName»_FDBUS_PROXY_HPP_
    '''

    def private generateProxySource(FInterface _interface, PropertyAccessor _accessor, List<FDExtensionRoot> providers, IResource _modelid) '''
        «generateCommonApiFDBusLicenseHeader»
        «FTypeGenerator::generateComments(_interface, false)»
        #include <«_interface.fdbusProxyHeaderPath»>
        
        «startInternalCompilation»
        
        #include <CommonAPI/FDBus/AddressTranslator.hpp>
        
        «endInternalCompilation»
        
        «_interface.generateVersionNamespaceBegin»
        «_interface.model.generateNamespaceBeginDeclaration»
        
        std::shared_ptr<CommonAPI::FDBus::Proxy> create«_interface.fdbusProxyClassName»(
            const CommonAPI::FDBus::Address &_address,
            const std::shared_ptr<CommonAPI::FDBus::ProxyConnection> &_connection) {
            return std::make_shared< «_interface.fdbusProxyClassName»>(_address, _connection);
        }
        
        void initialize«_interface.fdbusProxyClassName»() {
            «FOR p : providers»
                «val PropertyAccessor providerAccessor = new PropertyAccessor(new FDeployedProvider(p))»
                «FOR i : ProviderUtils.getInstances(p).filter[target == _interface]»
                    CommonAPI::FDBus::AddressTranslator::get()->insert(
                        "local:«_interface.fullyQualifiedNameWithVersion»:«providerAccessor.getInstanceId(i)»",
                        «_interface.getFDBusServiceID», 0x«Integer.toHexString(providerAccessor.getFDBusInstanceID(i))», «_interface.version.major», «_interface.version.minor»);
                «ENDFOR»
            «ENDFOR»
            CommonAPI::FDBus::Factory::get()->registerProxyCreateMethod(
                "«_interface.fullyQualifiedNameWithVersion»",
                &create«_interface.fdbusProxyClassName»);
        }
        
        INITIALIZER(register«_interface.fdbusProxyClassName») {
            CommonAPI::FDBus::Factory::get()->registerInterface(initialize«_interface.fdbusProxyClassName»);
        }

        «val hasAttribute = _interface.attributes.length > 0»
        «val hasBroadcast = _interface.broadcasts.length > 0»
        «val hasManaged = _interface.managedInterfaces.length > 0»
        «_interface.fdbusProxyClassName»::«_interface.fdbusProxyClassName»(
            const CommonAPI::FDBus::Address &_address,
            const std::shared_ptr<CommonAPI::FDBus::ProxyConnection> &_connection)
                : CommonAPI::FDBus::Proxy(_address, _connection)«IF _interface.base !== null || hasAttribute || hasBroadcast || hasManaged»,«ENDIF»
                  «IF _interface.base !== null»«_interface.generateFDBusBaseInstantiations»«IF hasAttribute || hasBroadcast || hasManaged»,«ENDIF»«ENDIF»
                  «FOR attribute : _interface.attributes»
                  «attribute.generateVariableInit(_accessor, _interface)»«IF attribute != _interface.attributes.last || hasBroadcast || hasManaged»,«ENDIF»
                  «ENDFOR»
                  «FOR broadcast : _interface.broadcasts»
                  «broadcast.fdbusClassVariableName»(*this, «broadcast.getEventGroups(_accessor).head», «broadcast.getEventIdentifier(_accessor)»,«IF broadcast.selective» CommonAPI::FDBus::event_type_e::ET_SELECTIVE_EVENT«ELSE» CommonAPI::FDBus::event_type_e::ET_EVENT «ENDIF», «broadcast.getReliabilityType(_accessor)», «broadcast.getEndianess(_accessor)», «broadcast.getDeployments(_interface, _accessor)»)«IF broadcast != _interface.broadcasts.last || hasManaged»,«ENDIF»
                  «ENDFOR»
                  «FOR managed : _interface.managedInterfaces»
                  «managed.proxyManagerMemberName»(*this, "«managed.fullyQualifiedNameWithVersion»", «getFDBusServiceIDForInterface(providers, managed)»)«IF managed != _interface.managedInterfaces.last»,«ENDIF»
                  «ENDFOR»
        {
        }

        «_interface.fdbusProxyClassName»::~«_interface.fdbusProxyClassName»() {
        }
        
        «FOR attribute : _interface.attributes»
            «attribute.generateGetMethodDefinitionWithin(_interface.fdbusProxyClassName)» {
                return «attribute.fdbusClassVariableName»;
            }
        «ENDFOR»
        
        «FOR broadcast : _interface.broadcasts»
           «broadcast.generateGetMethodDefinitionWithin(_interface.fdbusProxyClassName)» {
               return «broadcast.fdbusClassVariableName»;
           }
        «ENDFOR»
        
        «FOR method : _interface.methods»
            «val timeout = method.getTimeout(_accessor)»
            «val inParams = method.generateInParams(_accessor)»
            «val outParams = method.generateOutParams(_accessor, false)»
            «FTypeGenerator::generateComments(method, false)»
            «IF generateSyncCalls || method.isFireAndForget»
            «method.generateDefinitionWithin(_interface.fdbusProxyClassName, false)» {
                «method.generateProxyHelperDeployments(_interface, false, _accessor)»
                «IF method.isFireAndForget»
                    «method.generateProxyHelperClass(_interface, _accessor)»::callMethod(
                «ELSE»
                    «IF timeout != 0»
                    static CommonAPI::CallInfo info(«timeout»);
                    «ENDIF»
                    «method.generateProxyHelperClass(_interface, _accessor)»::callMethodWithReply(
                «ENDIF»
                    *this,
                    «method.getMethodIdentifier(_accessor)»,
                    «method.isReliable(_accessor)»,
                    «method.isLittleEndian(_accessor)»,
                    «IF !method.isFireAndForget»(_info ? _info : «IF timeout != 0»&info«ELSE»&CommonAPI::FDBus::defaultCallInfo«ENDIF»),«ENDIF»
                    «IF inParams != ""»«inParams»,«ENDIF»
                    _internalCallStatus«IF method.hasError»,
                    deploy_error«ENDIF»«IF outParams != ""»,
                    «outParams»«ENDIF»);
                «method.generateOutParamsValue(_accessor)»
            }

            «ENDIF»
            «IF !method.isFireAndForget»
                «method.generateAsyncDefinitionWithin(_interface.fdbusProxyClassName, false)» {
                    «IF timeout != 0»
                        static CommonAPI::CallInfo info(«timeout»);
                    «ENDIF»
                    «method.generateProxyHelperDeployments(_interface, true, _accessor)»
                    return «method.generateProxyHelperClass(_interface, _accessor)»::callMethodAsync(
                        *this,
                        «method.getMethodIdentifier(_accessor)»,
                        «method.isReliable(_accessor)»,
                        «method.isLittleEndian(_accessor)»,
                        (_info ? _info : «IF timeout != 0»&info«ELSE»&CommonAPI::FDBus::defaultCallInfo«ENDIF»),
                        «IF inParams != ""»«inParams»,«ENDIF»
                        «method.generateCallback(_interface, _accessor)»);
                }

            «ENDIF»
        «ENDFOR»
        «FOR managed : _interface.managedInterfaces»
        CommonAPI::ProxyManager& «_interface.fdbusProxyClassName»::«managed.proxyManagerGetterName»() {
            return «managed.proxyManagerMemberName»;
        }
        
        «ENDFOR»
        void «_interface.fdbusProxyClassName»::getOwnVersion(uint16_t& ownVersionMajor, uint16_t& ownVersionMinor) const {
            «val FVersion itsVersion = _interface.version»
            «IF itsVersion !== null»
                ownVersionMajor = «_interface.version.major»;
                ownVersionMinor = «_interface.version.minor»;
            «ELSE»
                ownVersionMajor = 0;
                ownVersionMinor = 0;
            «ENDIF»
        }

        std::future<void> «_interface.fdbusProxyClassName»::getCompletionFuture() {
            return CommonAPI::FDBus::Proxy::getCompletionFuture();
        }
        
        «_interface.model.generateNamespaceEndDeclaration»
        «_interface.generateVersionNamespaceEnd»
    '''

    def private getFDBusServiceIDForInterface(List<FDExtensionRoot> _providers, FInterface _interface) {
        for (FDExtensionRoot p : _providers) {
            for (instance : ProviderUtils.getInstances(p)) {
                if (instance.target == _interface) {
                    var id = _interface.fdbusAccessor.getFDBusServiceID(_interface)
                    if (id !== null) {
                        return "0x" + Integer.toHexString(id)
                    }
                }
            }
        }
        // If no providers are available, try to get the service id directly
        var serviceid = _interface.fdbusAccessor.getFDBusServiceID(_interface)
        if(serviceid !== null) {
            return "0x" + Integer.toHexString(serviceid)
        }
        return "UNDEFINED_SERVICE_ID"
    }

    def private fdbusClassVariableName(FModelElement fModelElement) {
        checkArgument(!fModelElement.elementName.nullOrEmpty, 'FModelElement has no name: ' + fModelElement)
        fModelElement.elementName.toFirstLower + '_'
    }

    def private fdbusClassVariableName(FBroadcast fBroadcast) {
        checkArgument(!fBroadcast.elementName.nullOrEmpty, 'FModelElement has no name: ' + fBroadcast)
        var classVariableName = fBroadcast.elementName.toFirstLower

        if (fBroadcast.selective)
            classVariableName = classVariableName + 'Selective'

        classVariableName = classVariableName + '_'

        return classVariableName
    }

    def private generateProxyHelperDeployments(FMethod _method, FInterface _interface, boolean _isAsync,
        PropertyAccessor _accessor) '''
        «IF _method.hasError»
            CommonAPI::Deployable< «_method.errorType», «_method.getErrorDeploymentType(false)»> deploy_error(«_method.
            getErrorDeploymentRef(_interface, _accessor)»);
        «ENDIF»
        «FOR a : _method.inArgs»
            CommonAPI::Deployable< «a.getTypeName(_method, true)», «a.getDeploymentType(_interface, true)»> deploy_«a.name»(_«a.
            name», «a.getDeploymentRef(a.array, _method, _interface, _accessor.getOverwriteAccessor(a))»);
        «ENDFOR»
        «FOR a : _method.outArgs»
            CommonAPI::Deployable< «a.getTypeName(_method, true)», «a.getDeploymentType(_interface, true)»> deploy_«a.name»(«a.
            getDeploymentRef(a.array, _method, _interface, _accessor.getOverwriteAccessor(a))»);
        «ENDFOR»
    '''

    def private generateProxyHelperClass(FMethod _method, FInterface _interface, PropertyAccessor _accessor) '''
    CommonAPI::FDBus::ProxyHelper<
        CommonAPI::FDBus::SerializableArguments<
            «FOR a : _method.inArgs»
                CommonAPI::Deployable<
                    «a.getTypeName(_method, true)»,
                    «a.getDeploymentType(_interface, true)»
                >«IF a != _method.inArgs.last»,«ENDIF»
            «ENDFOR»
        >,
        CommonAPI::FDBus::SerializableArguments<
            «IF _method.hasError»
                CommonAPI::Deployable<
                    «_method.errorType»,
                    «_method.getErrorDeploymentType(false)»
                >«IF !_method.outArgs.empty»,«ENDIF»
            «ENDIF»
            «FOR a : _method.outArgs»
                CommonAPI::Deployable<
                    «a.getTypeName(_method, true)»,
                    «a.getDeploymentType(_interface, true)»
                >«IF a != _method.outArgs.last»,«ENDIF»
            «ENDFOR»
        >
    >'''

    def private generateInParams(FMethod _method, PropertyAccessor _accessor) {
        var String inParams = ""
        for (a : _method.inArgs) {
            if(inParams != "") inParams += ", "
            inParams += "deploy_" + a.name
        }
        return inParams
    }

    def private generateOutParams(FMethod _method, PropertyAccessor _accessor, boolean _instantiate) {
        var String outParams = ""
        for (a : _method.outArgs) {
            if(outParams != "") outParams += ", "
            outParams += "deploy_" + a.name
        }
        return outParams
    }

    def private generateOutParamsValue(FMethod _method, PropertyAccessor _accessor) {
        var String outParamsValue = ""
        if (_method.hasError) {
            outParamsValue += "_error = deploy_error.getValue();\n"
        }
        for (a : _method.outArgs) {
            outParamsValue += "_" + a.name + " = deploy_" + a.name + ".getValue();\n"
        }
        return outParamsValue
    }

    def private generateCallback(FMethod _method, FInterface _interface, PropertyAccessor _accessor) {

        var String error = ""
        if (_method.hasError) {
            error = "deploy_error"
        }

        var String callback = "[_callback] (" + generateCallbackParameter(_method, _interface, _accessor) + ") {\n"
        callback += "    if (_callback)\n"
        callback += "        _callback(_internalCallStatus"
        if(_method.hasError) callback += ", _deploy_error.getValue()"
        for (a : _method.outArgs) {
            callback += ", _" + a.name
            callback += ".getValue()"
        }
        callback += ");\n"
        callback += "},\n"

        var String out = generateOutParams(_method, _accessor, true)
        if(error != "" && out != "") error += ", "
        callback += "std::make_tuple(" + error + out + ")"
        return callback
    }

    def private generateCallbackParameter(FMethod _method, FInterface _interface, PropertyAccessor _accessor) {
        var String declaration = "CommonAPI::CallStatus _internalCallStatus"
        if (_method.hasError)
            declaration += ", CommonAPI::Deployable< " + _method.errorType + ", " + _method.getErrorDeploymentType(false) +
                " > _deploy_error"
        for (a : _method.outArgs) {
            declaration += ", "
            declaration += "CommonAPI::Deployable< " + a.getTypeName(_method, true) + ", " +
                a.getDeploymentType(_interface, true) + " > _" + a.name
        }
        return declaration
    }

    def private fdbusClassName(FAttribute _attribute, FInterface _interface, PropertyAccessor _accessor) {
        var type = "CommonAPI::FDBus::"

        if (_attribute.isReadonly)
            type = type + "Readonly"

        type = type + "Attribute<" + _attribute.className
        val deployment = _attribute.getDeploymentType(_interface, true)
        if(!deployment.equals("CommonAPI::EmptyDeployment")) type += ", " + deployment
        type += ">"

        if (_attribute.isObservable)
            type = "CommonAPI::FDBus::ObservableAttribute<" + type + ">"

        return type
    }

    def private generateVariableInit(FAttribute _attribute, PropertyAccessor _accessor, FInterface _interface) {
        var init = _attribute.fdbusClassVariableName + "(*this"

        if (_attribute.isObservable) {
            init += ", " + _attribute.getNotifierEventGroups(_accessor).head + ", " +
                _attribute.getNotifierIdentifier(_accessor)
        }

        init += ", " + _attribute.getGetterIdentifier(_accessor) + ", " + _attribute.isGetterReliable(_accessor)
        if (!_attribute.isNoSubscriptions) {
            init += ", " + _attribute.getNotifierReliabilityType(_accessor)
        }
        init += ", " + _attribute.getEndianess(_accessor)

        if (!_attribute.isReadonly) {
            init += ", " + _attribute.getSetterIdentifier(_accessor) + ", " + _attribute.isSetterReliable(_accessor)
        }

        val String deployment = _attribute.getDeploymentRef(_attribute.array, null, _interface, _accessor.getOverwriteAccessor(_attribute))
        if (deployment != "")
            init += ", " + deployment

        init += ")"

        return init
    }

    def private fdbusClassName(FBroadcast _broadcast, FInterface _interface, PropertyAccessor _accessor) {
        var eventDeclaration = "CommonAPI::FDBus::"

        eventDeclaration += "Event<" + _broadcast.className
        for (a : _broadcast.outArgs) {
            eventDeclaration += ", "
            eventDeclaration += a.getDeployable(_interface, _accessor)
        }
        eventDeclaration += '>'

        return eventDeclaration
    }
}
