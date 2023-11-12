/* Copyright (C) 2014-2020 Calvin Ke, All rights reserved
   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, You can obtain one at http://mozilla.org/MPL/2.0/. */
package org.genivi.commonapi.fdbus.generator

import java.util.HashMap
import java.util.List
import java.util.LinkedList
import javax.inject.Inject
import org.eclipse.core.resources.IResource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMethod
import org.franca.deploymodel.dsl.fDeploy.FDExtensionRoot
import org.franca.deploymodel.ext.providers.FDeployedProvider
import org.franca.deploymodel.ext.providers.ProviderUtils
import org.genivi.commonapi.core.generator.FTypeGenerator
import org.genivi.commonapi.core.generator.FrancaGeneratorExtensions
import org.genivi.commonapi.fdbus.deployment.PropertyAccessor
import org.genivi.commonapi.fdbus.preferences.PreferenceConstantsFDBus
import org.franca.core.franca.FArgument
import org.genivi.commonapi.fdbus.preferences.FPreferencesFDBus

class FInterfaceFDBusStubAdapterGenerator {
    @Inject extension FrancaGeneratorExtensions
    @Inject extension FrancaFDBusGeneratorExtensions
    @Inject extension FrancaFDBusDeploymentAccessorHelper

    def generateStubAdapter(FInterface fInterface, IFileSystemAccess fileSystemAccess, PropertyAccessor deploymentAccessor, List<FDExtensionRoot> providers, IResource modelid) {
        if(FPreferencesFDBus::getInstance.getPreference(PreferenceConstantsFDBus::P_GENERATE_CODE_FDBUS, "true").equals("true")) {
            fileSystemAccess.generateFile(fInterface.fdbusStubAdapterHeaderPath, PreferenceConstantsFDBus.P_OUTPUT_STUBS_FDBUS,
                fInterface.generateStubAdapterHeader(deploymentAccessor, modelid))
            fileSystemAccess.generateFile(fInterface.fdbusStubAdapterSourcePath, PreferenceConstantsFDBus.P_OUTPUT_STUBS_FDBUS,
                fInterface.generateStubAdapterSource(deploymentAccessor, providers, modelid))
        }
        else {
            fileSystemAccess.generateFile(fInterface.fdbusStubAdapterHeaderPath, PreferenceConstantsFDBus.P_OUTPUT_STUBS_FDBUS,
                PreferenceConstantsFDBus::NO_CODE)
            fileSystemAccess.generateFile(fInterface.fdbusStubAdapterSourcePath, PreferenceConstantsFDBus.P_OUTPUT_STUBS_FDBUS,
                PreferenceConstantsFDBus::NO_CODE)
        }
    }

    def private generateStubAdapterHeader(FInterface _interface, PropertyAccessor _accessor, IResource _modelid) '''
        «generateCommonApiFDBusLicenseHeader()»
        «FTypeGenerator::generateComments(_interface, false)»
        #ifndef «_interface.defineName.toUpperCase»_FDBUS_STUB_ADAPTER_HPP_
        #define «_interface.defineName.toUpperCase»_FDBUS_STUB_ADAPTER_HPP_

        #include <«_interface.stubHeaderPath»>
        «IF _interface.base !== null»
            #include <«_interface.base.fdbusStubAdapterHeaderPath»>
        «ENDIF»
        «val DeploymentHeaders = _interface.getDeploymentInputIncludes(_accessor)»
        «DeploymentHeaders.map["#include <" + it + ">"].join("\n")»

        «startInternalCompilation»

        #include <CommonAPI/FDBus/AddressTranslator.hpp>
        #include <CommonAPI/FDBus/StubAdapterHelper.hpp>
        #include <CommonAPI/FDBus/StubAdapter.hpp>
        #include <CommonAPI/FDBus/Factory.hpp>
        #include <CommonAPI/FDBus/Types.hpp>
        #include <CommonAPI/FDBus/Constants.hpp>

        «endInternalCompilation»

        «_interface.generateVersionNamespaceBegin»
        «_interface.model.generateNamespaceBeginDeclaration»

        template <typename _Stub = «_interface.stubFullClassName», typename... _Stubs>
        class «_interface.fdbusStubAdapterClassNameInternal»
            : public virtual «_interface.stubAdapterClassName»,
        «IF _interface.base === null»      public CommonAPI::FDBus::StubAdapterHelper< _Stub, _Stubs...>,
              public std::enable_shared_from_this< «_interface.fdbusStubAdapterClassNameInternal»<_Stub, _Stubs...>>
        «ELSE»      public «_interface.base.getTypeCollectionName(_interface)»FDBusStubAdapterInternal<_Stub, _Stubs...>
        «ENDIF»
        {
        public:
            typedef CommonAPI::FDBus::StubAdapterHelper< _Stub, _Stubs...> «_interface.fdbusStubAdapterHelperClassName»;

            ~«_interface.fdbusStubAdapterClassNameInternal»() {
                deactivateManagedInstances();
                «_interface.fdbusStubAdapterHelperClassName»::deinit();
            }

            «FOR attribute : _interface.attributes»
                «IF attribute.isObservable»
                    «FTypeGenerator::generateComments(attribute, false)»
                    void «attribute.stubAdapterClassFireChangedMethodName»(const «attribute.getTypeName(_interface, true)» &_value);
                    
                «ENDIF»
            «ENDFOR»
            «FOR broadcast: _interface.broadcasts»
                «FTypeGenerator::generateComments(broadcast, false)»
                «IF broadcast.selective»
                    void «broadcast.stubAdapterClassFireSelectiveMethodName»(«generateFireSelectiveSignatur(broadcast, _interface)»);
                    void «broadcast.stubAdapterClassSendSelectiveMethodName»(«generateSendSelectiveSignatur(broadcast, _interface, true)»);
                    void «broadcast.subscribeSelectiveMethodName»(const std::shared_ptr<CommonAPI::ClientId> _client, bool &_success);
                    void «broadcast.unsubscribeSelectiveMethodName»(const std::shared_ptr<CommonAPI::ClientId> _client);
                    std::shared_ptr<CommonAPI::ClientIdList> const «broadcast.stubAdapterClassSubscribersMethodName»();

                «ELSE»
                    «IF !broadcast.isErrorType(_accessor)»
                        void «broadcast.stubAdapterClassFireEventMethodName»(«broadcast.outArgs.map['const ' + getTypeName(_interface, true) + ' &_' + elementName].join(', ')»);

                    «ENDIF»
                «ENDIF»
            «ENDFOR»
            «FOR managed: _interface.managedInterfaces»
                «managed.stubRegisterManagedMethod»;
                bool «managed.stubDeregisterManagedName»(const std::string&);
                std::set<std::string>& «managed.stubManagedSetGetterName»();

            «ENDFOR»
            «IF _interface.managedInterfaces.empty»
            void deactivateManagedInstances() {}
            «ELSE»
            void deactivateManagedInstances() {
                std::set<std::string>::iterator iter;
                std::set<std::string>::iterator iterNext;
                «FOR managed : _interface.managedInterfaces»
                    iter = «managed.stubManagedSetName».begin();
                    while (iter != «managed.stubManagedSetName».end()) {
                        iterNext = std::next(iter);

                        if («managed.stubDeregisterManagedName»(*iter)) {
                            iter = iterNext;
                        }
                        else {
                            iter++;
                        }
                    }

                «ENDFOR»
            }
            «ENDIF»
            
            «IF _interface.base !== null»
                virtual void init(std::shared_ptr<CommonAPI::FDBus::StubAdapter> instance) {
                    return «_interface.fdbusStubAdapterHelperClassName»::init(instance);
                }

                virtual void deinit() {
                    return «_interface.fdbusStubAdapterHelperClassName»::deinit();
                }

                virtual bool onInterfaceMessage(const CommonAPI::FDBus::Message &_message) {
                    return «_interface.fdbusStubAdapterHelperClassName»::onInterfaceMessage(_message);
                }
                
            «ENDIF»
            CommonAPI::FDBus::GetAttributeStubDispatcher<
                «_interface.stubFullClassName»,
                CommonAPI::Version
            > get«_interface.elementName»InterfaceVersionStubDispatcher;

            «generateAttributeDispatcherDeclarations(_interface, _accessor)»
            «var dispatcherDefinitionsList = new LinkedList<String>()»
            «FOR attribute : _interface.attributes»
                «{dispatcherDefinitionsList.add(generateAttributeDispatcherDefinitions(attribute, _interface, _accessor).toString());""}»
            «ENDFOR»
            «var counterMap = new HashMap<String, Integer>()»
            «var methodNumberMap = new HashMap<FMethod, Integer>()»
            «_interface.generateMethodDispatcherDeclarations(_interface, counterMap, methodNumberMap, _accessor)»
            «{counterMap = new HashMap<String, Integer>(); ""}»
            «{methodNumberMap = new HashMap<FMethod, Integer>(); ""}»
            «FOR method : _interface.methods»
                «{dispatcherDefinitionsList.add(generateMethodDispatcherDefinitions(method, _interface, _interface, _accessor, counterMap, methodNumberMap).toString());""}»
            «ENDFOR»
            «_interface.fdbusStubAdapterClassNameInternal»(
                const CommonAPI::FDBus::Address &_address,
                const std::shared_ptr<CommonAPI::FDBus::ProxyConnection> &_connection,
                const std::shared_ptr<CommonAPI::StubBase> &_stub):
                CommonAPI::FDBus::StubAdapter(_address, _connection),
                «IF _interface.base === null»«_interface.fdbusStubAdapterHelperClassName»(
                    _address,
                    _connection,
                    std::dynamic_pointer_cast< «_interface.stubClassName»>(_stub)),
                «ENDIF»
                «IF _interface.base !== null»
                    «_interface.base.getTypeCollectionName(_interface)»FDBusStubAdapterInternal<_Stub, _Stubs...>(_address, _connection, _stub),
                «ENDIF»
                get«_interface.elementName»InterfaceVersionStubDispatcher(&«_interface.stubClassName»::lockInterfaceVersionAttribute, &«_interface.stubClassName»::getInterfaceVersion, false, true)«IF dispatcherDefinitionsList.size > 0»,«ENDIF»
                «IF dispatcherDefinitionsList.size > 0»
                    «dispatcherDefinitionsList.map[it].join(',\n')»
                «ENDIF»
            {
                «_interface.generateAttributeDispatcherTableContent»
                «_interface.generateMethodDispatcherTableContent(counterMap, methodNumberMap)»
                «_interface.generateStubAttributeTableInitializer(_accessor)»
                «IF (!_interface.attributes.filter[isObservable()].empty)»
                    std::shared_ptr<CommonAPI::FDBus::ClientId> itsClient = std::make_shared<CommonAPI::FDBus::ClientId>();

                «ENDIF»
                // Provided events/fields
                «FOR broadcast : _interface.broadcasts»
                    «IF !broadcast.isErrorType(_accessor)»
                        {
                            std::set<CommonAPI::FDBus::eventgroup_id_t> itsEventGroups;
                            «FOR eventgroup : broadcast.getEventGroups(_accessor)»
                                itsEventGroups.insert(CommonAPI::FDBus::eventgroup_id_t(«eventgroup»));
                            «ENDFOR»
                            «IF broadcast.selective»
                                CommonAPI::FDBus::StubAdapter::registerEvent(«broadcast.getEventIdentifier(_accessor)», itsEventGroups, CommonAPI::FDBus::event_type_e::ET_SELECTIVE_EVENT, «broadcast.getReliabilityType(_accessor)»);
                            «ELSE»
                                CommonAPI::FDBus::StubAdapter::registerEvent(«broadcast.getEventIdentifier(_accessor)», itsEventGroups, CommonAPI::FDBus::event_type_e::ET_EVENT, «broadcast.getReliabilityType(_accessor)»);
                            «ENDIF»
                        }
                    «ENDIF»
                «ENDFOR»
                «FOR attribute : _interface.attributes»
                    «IF attribute.observable»
                        if (_stub->hasElement(«_interface.getElementPosition(attribute)»)) {
                            std::set<CommonAPI::FDBus::eventgroup_id_t> itsEventGroups;
                            «FOR eventgroup : attribute.getNotifierEventGroups(_accessor)»
                            itsEventGroups.insert(CommonAPI::FDBus::eventgroup_id_t(«eventgroup»));
                            «ENDFOR»
                            CommonAPI::FDBus::StubAdapter::registerEvent(«attribute.getNotifierIdentifier(_accessor)», itsEventGroups, CommonAPI::FDBus::event_type_e::ET_FIELD, «attribute.getNotifierReliabilityType(_accessor)»);
                            «attribute.stubAdapterClassFireChangedMethodName»(std::dynamic_pointer_cast< «_interface.stubFullClassName»>(_stub)->«attribute.getMethodName»(itsClient));
                        }

                    «ENDIF»
                «ENDFOR»
            }

            // Register/Unregister event handlers for selective broadcasts
            void registerSelectiveEventHandlers();
            void unregisterSelectiveEventHandlers();

        «IF _interface.hasSelectiveBroadcasts || _interface.managedInterfaces.size > 0»
        private:
            «FOR broadcast: _interface.broadcasts»
                «IF broadcast.selective»
                    std::mutex «broadcast.className»Mutex_;
                    void «broadcast.className»Handler(CommonAPI::FDBus::client_id_t _client, const CommonAPI::FDBus::sec_client_t *_sec_client, const std::string &_env, bool _subscribe, const CommonAPI::FDBus::SubscriptionAcceptedHandler_t& _acceptedHandler);
                «ENDIF»
            «ENDFOR»

            «FOR managed: _interface.managedInterfaces»
                std::set<std::string> «managed.stubManagedSetName»;
            «ENDFOR»
        «ENDIF»
        };

        «FOR attribute : _interface.attributes.filter[isObservable()]»
            «FTypeGenerator::generateComments(attribute, false)»
            template <typename _Stub, typename... _Stubs>
            void «_interface.fdbusStubAdapterClassNameInternal»<_Stub, _Stubs...>::«attribute.stubAdapterClassFireChangedMethodName»(const «attribute.getTypeName(_interface, true)» &_value) {
                «attribute.generateFireChangedMethodBody(_interface, _accessor)»
            }

        «ENDFOR»
        «FOR broadcast: _interface.broadcasts»
            «FTypeGenerator::generateComments(broadcast, false)»
            «IF broadcast.selective»
                template <typename _Stub, typename... _Stubs>
                void «_interface.fdbusStubAdapterClassNameInternal»<_Stub, _Stubs...>::«broadcast.stubAdapterClassFireSelectiveMethodName»(«generateFireSelectiveSignatur(broadcast, _interface)») {
                    std::shared_ptr<CommonAPI::FDBus::ClientId> client = CommonAPI::FDBus::ClientId::getFDBusClient(_client);
                    «FOR arg: broadcast.outArgs»
                         «val String deploymentType = arg.getDeploymentType(_interface, true)»
                         «val String deployment = arg.getDeploymentRef(arg.array, broadcast, _interface, _accessor.getOverwriteAccessor(arg))»
                         «IF deploymentType != "CommonAPI::EmptyDeployment" && deploymentType != ""»
                              CommonAPI::Deployable< «arg.getTypeName(arg, true)», «deploymentType»> deployed_«arg.name»(_«arg.name», «IF deployment != ""»«deployment»«ELSE»nullptr«ENDIF»);
                         «ENDIF»
                    «ENDFOR»
                    if (client) {
                        CommonAPI::FDBus::StubEventHelper<CommonAPI::FDBus::SerializableArguments< «broadcast.outArgs.map[getDeployedTypeName(_interface, _accessor.getOverwriteAccessor(it))].join(', ')»>>
                          ::sendEvent(
                              client->getClientId(),
                              *this,
                              «broadcast.getEventIdentifier(_accessor)»,
                              «broadcast.getEndianess(_accessor)»«IF broadcast.outArgs.size > 0»,«ENDIF»
                              «broadcast.outArgs.map[getDeployedElementName(_interface, _accessor.getOverwriteAccessor(it))].join(', ')»
                          );
                   }
                }

                template <typename _Stub, typename... _Stubs>
                void «_interface.fdbusStubAdapterClassNameInternal»<_Stub, _Stubs...>::«broadcast.stubAdapterClassSendSelectiveMethodName»(«generateSendSelectiveSignatur(broadcast, _interface, false)») {
                    std::shared_ptr<CommonAPI::ClientIdList> actualReceiverList;
                    actualReceiverList = _receivers;

                    if(_receivers == NULL) {
                        std::lock_guard < std::mutex > itsLock(«broadcast.className»Mutex_);
                        if («broadcast.stubAdapterClassSubscriberListPropertyName» != NULL)
                            actualReceiverList = std::make_shared<CommonAPI::ClientIdList>(*«broadcast.stubAdapterClassSubscriberListPropertyName»);
                    }

                    if(actualReceiverList == NULL)
                        return;

                    for (auto clientIdIterator = actualReceiverList->cbegin();
                               clientIdIterator != actualReceiverList->cend();
                               clientIdIterator++) {
                        bool found(false);
                        {
                            std::lock_guard < std::mutex > itsLock(«broadcast.className»Mutex_);
                            found = («broadcast.stubAdapterClassSubscriberListPropertyName»->find(*clientIdIterator) != «broadcast.stubAdapterClassSubscriberListPropertyName»->end());
                        }
                        if(_receivers == NULL || found) {
                            «broadcast.stubAdapterClassFireSelectiveMethodName»(*clientIdIterator«IF(!broadcast.outArgs.empty)», «ENDIF»«broadcast.outArgs.map["_" + elementName].join(', ')»);
                        }
                    }
                }

                template <typename _Stub, typename... _Stubs>
                void «_interface.fdbusStubAdapterClassNameInternal»<_Stub, _Stubs...>::«broadcast.subscribeSelectiveMethodName»(const std::shared_ptr<CommonAPI::ClientId> _client, bool &_success) {
                    bool ok = «_interface.fdbusStubAdapterHelperClassName»::stub_->«broadcast.subscriptionRequestedMethodName»(_client);
                    if (ok) {
                        {
                            std::lock_guard<std::mutex> itsLock(«broadcast.className»Mutex_);
                            «broadcast.stubAdapterClassSubscriberListPropertyName»->insert(_client);
                        }
                        _success = true;
                    } else {
                        _success = false;
                    }
                }
                
                template <typename _Stub, typename... _Stubs>
                void «_interface.fdbusStubAdapterClassNameInternal»<_Stub, _Stubs...>::«broadcast.unsubscribeSelectiveMethodName»(const std::shared_ptr<CommonAPI::ClientId> _client) {
                    {
                        std::lock_guard<std::mutex> itsLock(«broadcast.className»Mutex_);
                        «broadcast.stubAdapterClassSubscriberListPropertyName»->erase(_client);
                    }
                }

                template <typename _Stub, typename... _Stubs>
                std::shared_ptr<CommonAPI::ClientIdList> const «_interface.fdbusStubAdapterClassNameInternal»<_Stub, _Stubs...>::«broadcast.stubAdapterClassSubscribersMethodName»() {
                    std::lock_guard<std::mutex> itsLock(«broadcast.className»Mutex_);
                    return std::make_shared<CommonAPI::ClientIdList>(*«broadcast.stubAdapterClassSubscriberListPropertyName»);
                }

                template <typename _Stub, typename... _Stubs>
                void «_interface.fdbusStubAdapterClassNameInternal»<_Stub, _Stubs...>::«broadcast.className»Handler(CommonAPI::FDBus::client_id_t _client, const CommonAPI::FDBus::sec_client_t *_sec_client, const std::string &_env, bool _subscribe, const CommonAPI::FDBus::SubscriptionAcceptedHandler_t& _acceptedHandler) {
                    std::shared_ptr<CommonAPI::FDBus::ClientId> clientId = std::make_shared<CommonAPI::FDBus::ClientId>(CommonAPI::FDBus::ClientId(_client, _sec_client, _env));
                    bool result = true;
                    if (_subscribe) {
                        «broadcast.subscribeSelectiveMethodName»(clientId, result);
                        if (result) {
                            _acceptedHandler(true);
                            «_interface.fdbusStubAdapterHelperClassName»::stub_->«broadcast.subscriptionChangedMethodName»(clientId, CommonAPI::SelectiveBroadcastSubscriptionEvent::SUBSCRIBED);
                        } else {
                            _acceptedHandler(false);
                        }
                    } else {
                        «broadcast.unsubscribeSelectiveMethodName»(clientId);
                        «_interface.fdbusStubAdapterHelperClassName»::stub_->«broadcast.subscriptionChangedMethodName»(clientId, CommonAPI::SelectiveBroadcastSubscriptionEvent::UNSUBSCRIBED);
                        _acceptedHandler(true);
                    }
                }

            «ELSE»
                «IF !broadcast.isErrorType(_accessor)»
                    template <typename _Stub, typename... _Stubs>
                    void «_interface.fdbusStubAdapterClassNameInternal»<_Stub, _Stubs...>::«broadcast.stubAdapterClassFireEventMethodName»(«broadcast.outArgs.map['const ' + getTypeName(_interface, true) + ' &_' + elementName].join(', ')») {
                        «FOR arg: broadcast.outArgs»
                            «val String deploymentType = arg.getDeploymentType(_interface, true)»
                            «val String deployment = arg.getDeploymentRef(arg.array, broadcast, _interface, _accessor.getOverwriteAccessor(arg))»
                            «IF deploymentType != "CommonAPI::EmptyDeployment" && deploymentType != ""»
                                CommonAPI::Deployable< «arg.getTypeName(arg, true)», «deploymentType»> deployed_«arg.name»(_«arg.name», «IF deployment != ""»«deployment»«ELSE»nullptr«ENDIF»);
                            «ENDIF»
                        «ENDFOR»
                        CommonAPI::FDBus::StubEventHelper<CommonAPI::FDBus::SerializableArguments< «broadcast.outArgs.map[getDeployedTypeName(_interface, _accessor.getOverwriteAccessor(it))].join(', ')»>>
                            ::sendEvent(
                                *this,
                                «broadcast.getEventIdentifier(_accessor)»,
                                «broadcast.getEndianess(_accessor)»«IF broadcast.outArgs.size > 0»,«ENDIF»
                                «broadcast.outArgs.map[getDeployedElementName(_interface, _accessor.getOverwriteAccessor(it))].join(', ')»
                        );
                    }

                «ENDIF»
            «ENDIF»
        «ENDFOR»

        template <typename _Stub, typename... _Stubs>
        void «_interface.fdbusStubAdapterClassNameInternal»<_Stub, _Stubs...>::registerSelectiveEventHandlers() {
            «FOR broadcast : _interface.broadcasts»
                «IF broadcast.selective»
                    «broadcast.getStubAdapterClassSubscriberListPropertyName» = std::make_shared<CommonAPI::ClientIdList>();
                    CommonAPI::FDBus::AsyncSubscriptionHandler_t «broadcast.className»SubscribeHandler =
                        std::bind(&«_interface.fdbusStubAdapterClassNameInternal»::«broadcast.className»Handler,
                        std::dynamic_pointer_cast<«_interface.fdbusStubAdapterClassNameInternal»>(this->shared_from_this()),
                        std::placeholders::_1, std::placeholders::_2, std::placeholders::_3, std::placeholders::_4, std::placeholders::_5);
                    CommonAPI::FDBus::StubAdapter::connection_->registerSubscriptionHandler(CommonAPI::FDBus::StubAdapter::getFDBusAddress(), «broadcast.getEventGroups(_accessor).head», «broadcast.className»SubscribeHandler);

                «ENDIF»
            «ENDFOR»

            «IF _interface.base !== null»
                «_interface.base.getTypeCollectionName(_interface)»FDBusStubAdapterInternal<_Stub, _Stubs...>::registerSelectiveEventHandlers();
            «ENDIF»
        }
        
        template <typename _Stub, typename... _Stubs>
        void «_interface.fdbusStubAdapterClassNameInternal»<_Stub, _Stubs...>::unregisterSelectiveEventHandlers() {
            «FOR broadcast : _interface.broadcasts»
                «IF broadcast.selective»
                    CommonAPI::FDBus::StubAdapter::connection_->unregisterSubscriptionHandler(CommonAPI::FDBus::StubAdapter::getFDBusAddress(), «broadcast.getEventGroups(_accessor).head»);
                «ENDIF»
            «ENDFOR»

            «IF _interface.base !== null»
                «_interface.base.getTypeCollectionName(_interface)»FDBusStubAdapterInternal<_Stub, _Stubs...>::unregisterSelectiveEventHandlers();
            «ENDIF»
        }

        «FOR managed : _interface.managedInterfaces»
            template <typename _Stub, typename... _Stubs>
            bool «_interface.fdbusStubAdapterClassNameInternal»<_Stub, _Stubs...>::«managed.stubRegisterManagedMethodImpl» {
                if («managed.stubManagedSetName».find(_instance) == «managed.stubManagedSetName».end()) {
                    std::string commonApiAddress = "local:«managed.fullyQualifiedNameWithVersion»:" + _instance;
                    CommonAPI::FDBus::Address itsFDBusAddress;
                    CommonAPI::FDBus::AddressTranslator::get()->translate(commonApiAddress, itsFDBusAddress);
                    std::shared_ptr<CommonAPI::FDBus::Factory> itsFactory = CommonAPI::FDBus::Factory::get();
                    auto stubAdapter = itsFactory->createStubAdapter(_stub, "«managed.fullyQualifiedNameWithVersion»", itsFDBusAddress, CommonAPI::FDBus::StubAdapter::connection_);
                    if(itsFactory->registerManagedService(stubAdapter)) {
                        «managed.stubManagedSetName».insert(_instance);
                        return true;
                    }
                }
                return false;
            }

            template <typename _Stub, typename... _Stubs>
            bool «_interface.fdbusStubAdapterClassNameInternal»<_Stub, _Stubs...>::«managed.stubDeregisterManagedName»(const std::string &_instance) {
                std::string itsAddress = "local:«managed.fullyQualifiedNameWithVersion»:" + _instance;
                if («managed.stubManagedSetName».find(_instance) != «managed.stubManagedSetName».end()) {
                    std::shared_ptr<CommonAPI::FDBus::Factory> itsFactory = CommonAPI::FDBus::Factory::get();
                    if (itsFactory->isRegisteredService(itsAddress)) {
                        itsFactory->unregisterManagedService(itsAddress);
                        «managed.stubManagedSetName».erase(_instance);
                        return true;
                    }
                }
                return false;
            }

            template <typename _Stub, typename... _Stubs>
            std::set<std::string> &«_interface.fdbusStubAdapterClassNameInternal»<_Stub, _Stubs...>::«managed.stubManagedSetGetterName»() {
                return «managed.stubManagedSetName»;
            }

        «ENDFOR»
        template <typename _Stub = «_interface.stubFullClassName», typename... _Stubs>
        class «_interface.fdbusStubAdapterClassName»
            : public «_interface.fdbusStubAdapterClassNameInternal»<_Stub, _Stubs...> {
        public:
            «_interface.fdbusStubAdapterClassName»(const CommonAPI::FDBus::Address &_address,
                                                    const std::shared_ptr<CommonAPI::FDBus::ProxyConnection> &_connection,
                                                    const std::shared_ptr<CommonAPI::StubBase> &_stub)
                : CommonAPI::FDBus::StubAdapter(_address, _connection),
                  «_interface.fdbusStubAdapterClassNameInternal»<_Stub, _Stubs...>(_address, _connection, _stub) {
            }
        };

        «_interface.model.generateNamespaceEndDeclaration»
        «_interface.generateVersionNamespaceEnd»

        #endif // «_interface.defineName»_FDBUS_STUB_ADAPTER_HPP_
        '''

    def private String generateAttributeDispatcherDeclarations(FInterface _interface, PropertyAccessor _accessor) '''
        «FOR a : _interface.attributes»
            «val typeName = a.getTypeName(_interface, true)»
            «FTypeGenerator::generateComments(a, false)»
            «val String deploymentType = a.getDeploymentType(_interface, true)»
            «val String getIdentifier = a.getGetterIdentifier(_accessor)»
            «IF getIdentifier != "0x0"»
                CommonAPI::FDBus::GetAttributeStubDispatcher<
                    «_interface.stubFullClassName»,
                    «typeName»«IF deploymentType != "CommonAPI::EmptyDeployment" && deploymentType != ""»,
                    «deploymentType»«ENDIF»
                > «a.fdbusGetStubDispatcherVariable»;

            «ENDIF»
            «IF !a.isReadonly»
                CommonAPI::FDBus::Set«IF a.observable»Observable«ENDIF»AttributeStubDispatcher<
                    «_interface.stubFullClassName»,
                    «typeName»«IF deploymentType != "CommonAPI::EmptyDeployment" && deploymentType != ""»,
                    «deploymentType»«ENDIF»
                > «a.fdbusSetStubDispatcherVariable»;

            «ENDIF»
        «ENDFOR»
    '''

    def private String generateMethodDispatcherDeclarations(FInterface _interface,
                                                            FInterface _container,
                                                            HashMap<String, Integer> _counters,
                                                            HashMap<FMethod, Integer> _methods,
                                                            PropertyAccessor _accessor) '''
        «val accessor = getFDBusAccessor(_interface)»
        «FOR method : _interface.methods»
            «FTypeGenerator::generateComments(method, false)»
            «IF !method.isFireAndForget»
                «var errorReplyTypes = new LinkedList()»
                «FOR broadcast : _interface.broadcasts»
                    «IF broadcast.isErrorType(method, _accessor)»
                        «{errorReplyTypes.add(broadcast.errorReplyTypes(method, _accessor));""}»
                        «broadcast.generateErrorReplyCallback(_interface, method, _accessor)»
                    «ENDIF»
                «ENDFOR»
                CommonAPI::FDBus::MethodWithReplyStubDispatcher<
                    «_interface.stubFullClassName»,
                    std::tuple< «method.allInTypes»>,
                    std::tuple< «method.allOutTypes»>,
                    std::tuple< «method.inArgs.getDeploymentTypes(_interface, accessor)»>,
                    std::tuple< «method.getErrorDeploymentType(true)»«method.outArgs.getDeploymentTypes(_interface, accessor)»>«IF errorReplyTypes.size > 0»,«ENDIF»
                    «errorReplyTypes.map['std::function< void (' + it + ')>'].join(',\n')»
                    «IF !(_counters.containsKey(method.fdbusStubDispatcherVariable))»
                        «{_counters.put(method.fdbusStubDispatcherVariable, 0);  _methods.put(method, 0);""}»
                > «method.fdbusStubDispatcherVariable»;
                «ELSE»
                    «{_counters.put(method.fdbusStubDispatcherVariable, _counters.get(method.fdbusStubDispatcherVariable) + 1);  _methods.put(method, _counters.get(method.fdbusStubDispatcherVariable));""}»
                > «method.fdbusStubDispatcherVariable»«Integer::toString(_counters.get(method.fdbusStubDispatcherVariable))»;
                «ENDIF»
            «ELSE»
                CommonAPI::FDBus::MethodStubDispatcher<
                    «_interface.stubFullClassName»,
                    std::tuple< «method.allInTypes»>,
                    std::tuple< «method.inArgs.getDeploymentTypes(_interface, accessor)»>
                    «IF !(_counters.containsKey(method.fdbusStubDispatcherVariable))»
                        «{_counters.put(method.fdbusStubDispatcherVariable, 0); _methods.put(method, 0);""}»
                > «method.fdbusStubDispatcherVariable»;
                «ELSE»
                    «{_counters.put(method.fdbusStubDispatcherVariable, _counters.get(method.fdbusStubDispatcherVariable) + 1);  _methods.put(method, _counters.get(method.fdbusStubDispatcherVariable));""}»
                > «method.fdbusStubDispatcherVariable»«Integer::toString(_counters.get(method.fdbusStubDispatcherVariable))»;
                «ENDIF»
            «ENDIF»

        «ENDFOR»
    '''

    def private generateAttributeDispatcherDefinitions(FAttribute _attribute, FInterface _interface, PropertyAccessor _accessor) '''
        «val String getIdentifier = _attribute.getGetterIdentifier(_accessor)»
        «IF getIdentifier != "0x0"»
        «_attribute.fdbusGetStubDispatcherVariable»(
            &«_interface.stubFullClassName»::«_attribute.stubClassLockMethodName»,
            &«_interface.stubFullClassName»::«_attribute.stubClassGetMethodName»,
            «_attribute.getEndianess(_accessor)»,
            _stub->hasElement(«_interface.getElementPosition(_attribute)»)«IF _accessor.getOverwriteAccessor(_attribute).hasDeployment(_attribute)», «_attribute.getDeploymentRef(_attribute.array, null, _interface, _accessor.getOverwriteAccessor(_attribute))»«ENDIF»)«IF !_attribute.isReadonly»,«ENDIF»
        «ENDIF»
        «IF !_attribute.isReadonly»
            «_attribute.fdbusSetStubDispatcherVariable»(
                &«_interface.stubFullClassName»::«_attribute.stubClassLockMethodName»,
                &«_interface.stubFullClassName»::«_attribute.stubClassGetMethodName»,
                &«_interface.stubRemoteEventClassName»::«_attribute.stubRemoteEventClassSetMethodName»,
                &«_interface.stubRemoteEventClassName»::«_attribute.stubRemoteEventClassChangedMethodName»,
                «IF _attribute.observable»&«_interface.stubAdapterClassName»::«_attribute.stubAdapterClassFireChangedMethodName»,«ENDIF»
                «_attribute.getEndianess(_accessor)»,
                _stub->hasElement(«_interface.getElementPosition(_attribute)»)«IF _accessor.getOverwriteAccessor(_attribute).hasDeployment(_attribute)»,
                «_attribute.getDeploymentRef(_attribute.array, null, _interface, _accessor.getOverwriteAccessor(_attribute))»«ENDIF»)
        «ENDIF»
    '''

    def private generateMethodDispatcherDefinitions(FMethod _method, FInterface _interface, FInterface _thisInterface,
                                                    PropertyAccessor _accessor,
                                                    HashMap<String, Integer> counterMap,
                                                    HashMap<FMethod, Integer> methodnumberMap) '''
        «IF !_method.isFireAndForget»
            «var errorReplyTypes = new LinkedList()»
            «var errorReplyCallbacks = new LinkedList()»
            «FOR broadcast : _interface.broadcasts»
                «IF broadcast.isErrorType(_method, _accessor)»
                    «{errorReplyTypes.add(broadcast.errorReplyTypes(_method, _accessor));""}»
                    «{errorReplyCallbacks.add('std::bind(&' + _interface.fdbusStubAdapterClassNameInternal + '<_Stub, _Stubs...>::' +
                        broadcast.errorReplyCallbackName(_accessor) + ', this, ' + broadcast.errorReplyCallbackBindArgs(_accessor) + ')'
                    );""}»
                «ENDIF»
            «ENDFOR»
            «IF !(counterMap.containsKey(_method.fdbusStubDispatcherVariable))»
                «{counterMap.put(_method.fdbusStubDispatcherVariable, 0);  methodnumberMap.put(_method, 0);""}»
                «_method.fdbusStubDispatcherVariable»(
                    &«_interface.stubClassName + "::" + _method.elementName»,
                    «_method.isLittleEndian(_accessor)»,
                    _stub->hasElement(«_interface.getElementPosition(_method)»),
                    «_method.getDeployments(_interface, _accessor, true, false)»,
                    «_method.getDeployments(_interface, _accessor, false, true)»«IF errorReplyCallbacks.size > 0»,«'\n' + errorReplyCallbacks.map[it].join(',\n')»«ENDIF»)
            «ELSE»
                «{counterMap.put(_method.fdbusStubDispatcherVariable, counterMap.get(_method.fdbusStubDispatcherVariable) + 1);  methodnumberMap.put(_method, counterMap.get(_method.fdbusStubDispatcherVariable));""}»
                «_method.fdbusStubDispatcherVariable»«Integer::toString(counterMap.get(_method.fdbusStubDispatcherVariable))»(
                    &«_interface.stubClassName + "::" + _method.elementName»,
                    «_method.isLittleEndian(_accessor)»,
                    _stub->hasElement(«_interface.getElementPosition(_method)»),
                    «_method.getDeployments(_interface, _accessor, true, false)»,
                    «_method.getDeployments(_interface, _accessor, false, true)»«IF errorReplyCallbacks.size > 0»,«'\n' + errorReplyCallbacks.map[it].join(',\n')»«ENDIF»)
            «ENDIF»
            
        «ELSE»
            «IF !(counterMap.containsKey(_method.fdbusStubDispatcherVariable))»
                «{counterMap.put(_method.fdbusStubDispatcherVariable, 0); methodnumberMap.put(_method, 0);""}»
                «_method.fdbusStubDispatcherVariable»(
                    &«_interface.stubClassName + "::" + _method.elementName»,
                    «_method.isLittleEndian(_accessor)»,
                    _stub->hasElement(«_interface.getElementPosition(_method)»),
                    «_method.getDeployments(_interface, _accessor, true, false)»)
            «ELSE»
                «{counterMap.put(_method.fdbusStubDispatcherVariable, counterMap.get(_method.fdbusStubDispatcherVariable) + 1);  methodnumberMap.put(_method, counterMap.get(_method.fdbusStubDispatcherVariable));""}»
                «_method.fdbusStubDispatcherVariable»«Integer::toString(counterMap.get(_method.fdbusStubDispatcherVariable))»(
                    &«_interface.stubClassName + "::" + _method.elementName»,
                    «_method.isLittleEndian(_accessor)»,
                    _stub->hasElement(«_interface.getElementPosition(_method)»),
                    «_method.getDeployments(_interface, _accessor, true, false)»)
            «ENDIF»
            
        «ENDIF»
    '''

   def private getDeployedTypeName(FArgument _arg, FInterface _interface, PropertyAccessor _accessor)'''
            «val String deploymentType = _arg.getDeploymentType(_interface, true)»
            «IF deploymentType != "CommonAPI::EmptyDeployment" && deploymentType != ""» CommonAPI::Deployable< «_arg.getTypeName(_interface, true)», «deploymentType» > «ELSE» «_arg.getTypeName(_interface, true)»«ENDIF»
   '''

   def private  getDeployedElementName(FArgument _arg, FInterface _interface, PropertyAccessor _accessor)'''
    «val String deploymentType = _arg.getDeploymentType(_interface, true)»
    «IF deploymentType != "CommonAPI::EmptyDeployment" && deploymentType != ""» deployed_«_arg.name» «ELSE»_«_arg.name»«ENDIF»
   '''
    def private String getInterfaceHierarchy(FInterface fInterface) {
        if (fInterface.base === null) {
            fInterface.stubFullClassName
        } else {
            fInterface.stubFullClassName + ", " + fInterface.base.interfaceHierarchy
        }
    }
    
    def private generateStubAdapterSource(FInterface _interface, PropertyAccessor _accessor, List<FDExtensionRoot> providers, IResource _modelid) '''
        «generateCommonApiFDBusLicenseHeader()»
        #include <«_interface.fdbusStubAdapterHeaderPath»>
        #include <«_interface.headerPath»>

        «startInternalCompilation»

        #include <CommonAPI/FDBus/AddressTranslator.hpp>

        «endInternalCompilation»

        «_interface.generateVersionNamespaceBegin»
        «_interface.model.generateNamespaceBeginDeclaration»

        std::shared_ptr<CommonAPI::FDBus::StubAdapter> create«_interface.fdbusStubAdapterClassName»(
                           const CommonAPI::FDBus::Address &_address,
                           const std::shared_ptr<CommonAPI::FDBus::ProxyConnection> &_connection,
                           const std::shared_ptr<CommonAPI::StubBase> &_stub) {
            return std::make_shared< «_interface.fdbusStubAdapterClassName»<«_interface.interfaceHierarchy»>>(_address, _connection, _stub);
        }

        void initialize«_interface.fdbusStubAdapterClassName»() {
            «FOR p : providers»
                «val PropertyAccessor providerAccessor = new PropertyAccessor(new FDeployedProvider(p))»
                «FOR i : ProviderUtils.getInstances(p).filter[target == _interface]»
                    CommonAPI::FDBus::AddressTranslator::get()->insert(
                        "local:«_interface.fullyQualifiedNameWithVersion»:«providerAccessor.getInstanceId(i)»",
                         «_interface.getFDBusServiceID», 0x«Integer.toHexString(
                            providerAccessor.getFDBusInstanceID(i))», «_interface.version.major», «_interface.version.minor»);
                «ENDFOR»
            «ENDFOR»
            CommonAPI::FDBus::Factory::get()->registerStubAdapterCreateMethod(
                "«_interface.fullyQualifiedNameWithVersion»",
                &create«_interface.fdbusStubAdapterClassName»);
        }

        INITIALIZER(register«_interface.fdbusStubAdapterClassName») {
            CommonAPI::FDBus::Factory::get()->registerInterface(initialize«_interface.fdbusStubAdapterClassName»);
        }
        
        «_interface.model.generateNamespaceEndDeclaration»
        «_interface.generateVersionNamespaceEnd»
    '''

    def private String generateAttributeDispatcherTableContent(FInterface _interface) '''
        «val accessor = getFDBusAccessor(_interface)»
        «FOR attribute : _interface.attributes»
            «FTypeGenerator::generateComments(attribute, false)»
            «val String getIdentifier = attribute.getGetterIdentifier(accessor)»
            «IF getIdentifier != "0x0"»
                «dispatcherTableEntry(_interface, getIdentifier, attribute.fdbusGetStubDispatcherVariable)»
            «ENDIF»
            «IF !attribute.isReadonly»
                «dispatcherTableEntry(_interface, attribute.getSetterIdentifier(accessor), attribute.fdbusSetStubDispatcherVariable)»
            «ENDIF»
        «ENDFOR»
    '''
    
    def private String generateMethodDispatcherTableContent(FInterface _interface, HashMap<String, Integer> _counters, HashMap<FMethod, Integer> _methods) '''
        «val accessor = getFDBusAccessor(_interface)»
        «FOR method : _interface.methods»«FTypeGenerator::generateComments(method, false)»
        «IF _methods.get(method)==0»
            «dispatcherTableEntry(_interface, method.getMethodIdentifier(accessor), method.fdbusStubDispatcherVariable)»
        «ELSE»
            «dispatcherTableEntry(_interface, method.getMethodIdentifier(accessor), method.fdbusStubDispatcherVariable+_methods.get(method))»
        «ENDIF»
        «ENDFOR»
    '''

    def dispatcherTableEntry(FInterface fInterface, String identifierAsHexString, String memberFunctionName) '''
        «fInterface.fdbusStubAdapterHelperClassName»::addStubDispatcher( { «identifierAsHexString» }, &«memberFunctionName» );
    '''

    def private fdbusStubAdapterHeaderFile(FInterface fInterface) {
        fInterface.elementName + "FDBusStubAdapter.hpp"
    }

    def private fdbusStubAdapterHeaderPath(FInterface fInterface) {
        fInterface.versionPathPrefix + fInterface.model.directoryPath + '/' + fInterface.fdbusStubAdapterHeaderFile
    }

    def private fdbusStubAdapterSourceFile(FInterface fInterface) {
        fInterface.elementName + "FDBusStubAdapter.cpp"
    }

    def private fdbusStubAdapterSourcePath(FInterface fInterface) {
        fInterface.versionPathPrefix + fInterface.model.directoryPath + '/' + fInterface.fdbusStubAdapterSourceFile
    }

    def private fdbusStubAdapterClassName(FInterface fInterface) {
        fInterface.elementName + 'FDBusStubAdapter'
    }

    def private fdbusStubAdapterClassNameInternal(FInterface fInterface) {
        fInterface.fdbusStubAdapterClassName + 'Internal'
    }

    def private fdbusStubAdapterHelperClassName(FInterface fInterface) {
        fInterface.elementName + 'FDBusStubAdapterHelper'
    }

    def private getAllInTypes(FMethod fMethod) {
        fMethod.inArgs.map[getTypeName(fMethod, true)].join(', ')
    }

    def private getAllOutTypes(FMethod fMethod) {
        var types = fMethod.outArgs.map[getTypeName(fMethod, true)].join(', ')

        if (fMethod.hasError) {
            if (!fMethod.outArgs.empty)
                types = ', ' + types
            types = fMethod.getErrorNameReference(fMethod.eContainer) + types
        }

        return types
    }

    def private fdbusStubDispatcherVariable(FMethod fMethod) {
        fMethod.elementName.toFirstLower + 'StubDispatcher'
    }

    def private fdbusGetStubDispatcherVariable(FAttribute fAttribute) {
        fAttribute.getMethodName + 'StubDispatcher'
    }

    def private fdbusSetStubDispatcherVariable(FAttribute fAttribute) {
        fAttribute.setMethodName + 'StubDispatcher'
    }

    def private generateFireChangedMethodBody(FAttribute _attribute, FInterface _interface, PropertyAccessor _accessor) '''
        «val String deploymentType = _attribute.getDeploymentType(_interface, true)»
        «val String deployment = _attribute.getDeploymentRef(_attribute.array, null, _interface, _accessor.getOverwriteAccessor(_attribute))»
        «IF deploymentType != "CommonAPI::EmptyDeployment" && deploymentType != ""»
            CommonAPI::Deployable< «_attribute.getTypeName(_interface, true)», «deploymentType»> deployedValue(_value, «IF deployment != ""»«deployment»«ELSE»nullptr«ENDIF»);
        «ENDIF»
        CommonAPI::FDBus::StubEventHelper<
            CommonAPI::FDBus::SerializableArguments<
                «IF deploymentType != "CommonAPI::EmptyDeployment" && deploymentType != ""»
                    CommonAPI::Deployable<
                        «_attribute.getTypeName(_interface, true)»,
                        «deploymentType»
                    >
                «ELSE»
                    «_attribute.getTypeName(_interface, true)»
                «ENDIF»
                >
        >::sendEvent(
            *this,
            «_attribute.getNotifierIdentifier(_accessor)»,
            «_attribute.getEndianess(_accessor)»,
            «IF deploymentType != "CommonAPI::EmptyDeployment" && deploymentType != ""»deployedValue«ELSE»_value«ENDIF»
        );
    '''

    def private generateStubAttributeTableInitializer(FInterface _interface, PropertyAccessor _accessor) '''
    '''

    def private generateErrorReplyCallback(FBroadcast _broadcast, FInterface _interface, FMethod _method, PropertyAccessor _accessor) '''
            
        void «_broadcast.errorReplyCallbackName(_accessor)»(«_broadcast.generateErrorReplyCallbackSignature(_method, _accessor)») {
            «IF _broadcast.errorArgs(_accessor).size > 1»
                auto args = std::make_tuple(
                    «_broadcast.errorArgs(_accessor).map[it.getDeployable(_interface, _accessor) + '(' + '_' + it.elementName + ', ' + getDeploymentRef(it.array, _broadcast, _interface, _accessor) + ')'].join(",\n")  + ");"»
            «ELSE»
                auto args = std::make_tuple();
            «ENDIF»
            (void)args;
            //sayHelloStubDispatcher.sendErrorReplyMessage(_call, «_broadcast.errorName(_accessor)», args);
        }
    '''
}
