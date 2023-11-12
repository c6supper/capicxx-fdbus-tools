/* Copyright (C) 2014-2020 Bayerische Motoren Werke Aktiengesellschaft (BMW AG)
   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, You can obtain one at http://mozilla.org/MPL/2.0/. */
package org.genivi.commonapi.fdbus.generator

import org.eclipse.emf.ecore.EObject
import org.franca.core.franca.FArgument
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FField
import org.franca.core.franca.FStructType
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeDef
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FTypedElement
import org.franca.core.franca.FUnionType
import org.genivi.commonapi.fdbus.deployment.PropertyAccessor
import org.franca.core.franca.FTypeCollection
import javax.inject.Inject
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMapType
import org.franca.core.franca.FIntegerInterval

class FrancaFDBusDeploymentAccessorHelper {

    @Inject extension FrancaFDBusGeneratorExtensions

    public static Integer FDBUS_DEFAULT_MIN_LENGTH = 0
    public static Integer FDBUS_DEFAULT_MAX_LENGTH = 0
    public static Integer FDBUS_DEFAULT_LENGTH_WIDTH = 4
    public static Integer FDBUS_DEFAULT_STRING_LENGTH = 0
    public static Integer FDBUS_DEFAULT_ENUM_LENGTH_WIDTH = 1

    public static Integer FDBUS_DEFAULT_STRUCT_LENGTH_WIDTH = 0

    public static Integer FDBUS_DEFAULT_UNION_TYPE_WIDTH = 4
    public static boolean FDBUS_DEFAULT_UNION_DEFAULT_ORDER = true

    public static Integer FDBUS_DEFAULT_ENUM_WIDTH = 1

    public static PropertyAccessor.FDBusStringEncoding FDBUS_DEFAULT_STRING_ENCODING
        = PropertyAccessor.FDBusStringEncoding.utf8

    // Helper methods to get a specific deployment value
    def Integer getFDBusArrayMinLengthHelper(PropertyAccessor _accessor, EObject _obj) {
        if (_obj instanceof FAttribute) {
            var Integer minLength = _accessor.getFDBusArrayMinLength(_obj)
            if (minLength === null && _obj.type.derived !== null)
                minLength = _accessor.getFDBusArrayMinLengthHelper(_obj.type.derived)
            return minLength
        }

        if (_obj instanceof FArgument) {
            var Integer minLength = _accessor.getFDBusArrayMinLength(_obj)
            if (minLength === null && _obj.type.derived !== null)
                minLength = _accessor.getFDBusArrayMinLengthHelper(_obj.type.derived)
            return minLength
        }

        if (_obj instanceof FField) {
            var Integer minLength = _accessor.getFDBusArrayMinLength(_obj)
            return minLength
        }

        if (_obj instanceof FTypeDef) {
            if (_obj.actualType.derived !== null) {
                if (_obj.actualType.derived instanceof FArrayType) {
                    return _accessor.getFDBusArrayMinLength(_obj.actualType.derived as FArrayType)
                }
            } else {
                return FDBUS_DEFAULT_MIN_LENGTH
            }
        }
        if (_obj instanceof FArrayType)
            return _accessor.getFDBusArrayMinLength(_obj)
        return FDBUS_DEFAULT_MIN_LENGTH
    }

    def Integer getFDBusArrayMaxLengthHelper(PropertyAccessor _accessor, EObject _obj) {
        if (_obj instanceof FAttribute) {
            var Integer maxLength = _accessor.getFDBusArrayMaxLength(_obj)
            if (maxLength === null && _obj.type.derived !== null)
                maxLength = _accessor.getFDBusArrayMaxLengthHelper(_obj.type.derived)
            return maxLength
        }

        if (_obj instanceof FArgument) {
            var Integer maxLength = _accessor.getFDBusArrayMaxLength(_obj)
            if (maxLength === null && _obj.type.derived !== null)
                  maxLength = _accessor.getFDBusArrayMaxLengthHelper(_obj.type.derived)
            return maxLength
        }

        if (_obj instanceof FField) {
            var Integer maxLength = _accessor.getFDBusArrayMaxLength(_obj)
            return maxLength
        }

        if (_obj instanceof FTypeDef) {
            if (_obj.actualType.derived !== null) {
                if (_obj.actualType.derived instanceof FArrayType) {
                    return _accessor.getFDBusArrayMaxLength(_obj.actualType.derived as FArrayType)
                }
            } else {
                return FDBUS_DEFAULT_MAX_LENGTH
            }
        }
        if (_obj instanceof FArrayType)
            return _accessor.getFDBusArrayMaxLength(_obj)
        return FDBUS_DEFAULT_MAX_LENGTH
    }

    def Integer getFDBusArrayLengthWidthHelper(PropertyAccessor _accessor, EObject _obj) {
        if (_obj instanceof FAttribute) {
            var Integer lengthWidth = _accessor.getFDBusArrayLengthWidth(_obj)
            if (lengthWidth === null && _obj.type.derived !== null)
                lengthWidth = _accessor.getFDBusArrayLengthWidthHelper(_obj.type.derived)
            return lengthWidth
        }

        if (_obj instanceof FArgument) {
            var Integer lengthWidth = _accessor.getFDBusArrayLengthWidth(_obj)
            if (lengthWidth === null && _obj.type.derived !== null)
                lengthWidth = _accessor.getFDBusArrayLengthWidthHelper(_obj.type.derived)
            return lengthWidth
        }

        if (_obj instanceof FField) {
            var Integer lengthWidth = _accessor.getFDBusArrayLengthWidth(_obj)
            return lengthWidth
        }

        if (_obj instanceof FTypeDef) {
            if (_obj.actualType.derived !== null) {
                if (_obj.actualType.derived instanceof FArrayType) {
                    return _accessor.getFDBusArrayLengthWidth(_obj.actualType.derived as FArrayType)
                }
            } else {
                return FDBUS_DEFAULT_LENGTH_WIDTH
            }
        }
        if (_obj instanceof FArrayType)
            return _accessor.getFDBusArrayLengthWidth(_obj)
        return FDBUS_DEFAULT_LENGTH_WIDTH
    }

    def Integer getFDBusMapMinLengthHelper(PropertyAccessor _accessor, EObject _obj) {
        if (_obj instanceof FAttribute) {
            var Integer minLength = _accessor.getFDBusAttrMapMinLength(_obj)
            if (minLength === null && _obj.type.derived !== null)
                minLength = _accessor.getFDBusMapMinLengthHelper(_obj.type.derived)
            return minLength
        }

        if (_obj instanceof FArgument) {
            var Integer minLength = _accessor.getFDBusArgMapMinLength(_obj)
            if (minLength === null && _obj.type.derived !== null)
                minLength = _accessor.getFDBusMapMinLengthHelper(_obj.type.derived)
            return minLength
        }

        return FDBUS_DEFAULT_MIN_LENGTH
    }

    def Integer getFDBusMapMaxLengthHelper(PropertyAccessor _accessor, EObject _obj) {
        if (_obj instanceof FAttribute) {
            var Integer maxLength = _accessor.getFDBusAttrMapMaxLength(_obj)
            if (maxLength === null && _obj.type.derived !== null)
                maxLength = _accessor.getFDBusMapMaxLengthHelper(_obj.type.derived)
            return maxLength
        }

        if (_obj instanceof FArgument) {
            var Integer maxLength = _accessor.getFDBusArgMapMaxLength(_obj)
            if (maxLength === null && _obj.type.derived !== null)
                maxLength = _accessor.getFDBusMapMaxLengthHelper(_obj.type.derived)
            return maxLength
        }

        return FDBUS_DEFAULT_MAX_LENGTH
    }

    def Integer getFDBusMapLengthWidthHelper(PropertyAccessor _accessor, EObject _obj) {
        if (_obj instanceof FAttribute) {
            var Integer lengthWidth = _accessor.getFDBusAttrMapLengthWidth(_obj)
            if (lengthWidth === null && _obj.type.derived !== null)
                lengthWidth = _accessor.getFDBusMapLengthWidthHelper(_obj.type.derived)
            return lengthWidth
        }

        if (_obj instanceof FArgument) {
            var Integer lengthWidth = _accessor.getFDBusArgMapLengthWidth(_obj)
            if (lengthWidth === null && _obj.type.derived !== null)
                lengthWidth = _accessor.getFDBusMapLengthWidthHelper(_obj.type.derived)
            return lengthWidth
        }

        return FDBUS_DEFAULT_LENGTH_WIDTH
    }

    def Integer getFDBusUnionLengthWidthHelper(PropertyAccessor _accessor, EObject _obj) {
        if (_obj instanceof FAttribute) {
            return _accessor.getFDBusUnionLengthWidthHelper(_obj.type.derived)
        }

        if (_obj instanceof FArgument) {
            return _accessor.getFDBusUnionLengthWidthHelper(_obj.type.derived)
        }
        if (_obj instanceof FField) {
            return _accessor.getFDBusUnionLengthWidthHelper(_obj.type.derived)
        }
        if (_obj instanceof FTypeDef) {
            if (_obj.actualType.derived !== null) {
                if (_obj.actualType.derived instanceof FUnionType) {
                    return _accessor.getFDBusUnionLengthWidth(_obj.actualType.derived as FUnionType)
                }
              } else {
                return FDBUS_DEFAULT_LENGTH_WIDTH
            }
        }
        if (_obj instanceof FUnionType)
            return _accessor.getFDBusUnionLengthWidth(_obj)
        return FDBUS_DEFAULT_LENGTH_WIDTH
    }

    def Integer getFDBusUnionTypeWidthHelper(PropertyAccessor _accessor, EObject _obj) {
        if (_obj instanceof FAttribute) {
            return _accessor.getFDBusUnionTypeWidthHelper(_obj.type.derived)
        }

        if (_obj instanceof FArgument) {
            return _accessor.getFDBusUnionTypeWidthHelper(_obj.type.derived)
        }
        if (_obj instanceof FField) {
            return _accessor.getFDBusUnionTypeWidthHelper(_obj.type.derived)
        }
        if (_obj instanceof FTypeDef) {
            if (_obj.actualType.derived !== null) {
                if (_obj.actualType.derived instanceof FUnionType) {
                    return _accessor.getFDBusUnionTypeWidth(_obj.actualType.derived as FUnionType)
                }
            } else {
                return FDBUS_DEFAULT_UNION_TYPE_WIDTH
            }
        }
        if (_obj instanceof FUnionType)
            return _accessor.getFDBusUnionTypeWidth(_obj)
        return FDBUS_DEFAULT_UNION_TYPE_WIDTH
    }

    def Boolean getFDBusUnionDefaultOrderHelper(PropertyAccessor _accessor, EObject _obj) {
        if (_obj instanceof FAttribute) {
            return _accessor.getFDBusUnionDefaultOrderHelper(_obj.type.derived)
        }

        if (_obj instanceof FArgument) {
            return _accessor.getFDBusUnionDefaultOrderHelper(_obj.type.derived)
        }
        if (_obj instanceof FField) {
            return _accessor.getFDBusUnionDefaultOrderHelper(_obj.type.derived)
        }
        if (_obj instanceof FTypeDef) {
            if (_obj.actualType.derived !== null) {
                if (_obj.actualType.derived instanceof FUnionType) {
                    return _accessor.getFDBusUnionDefaultOrder(_obj.actualType.derived as FUnionType)
                }
            } else {
                return FDBUS_DEFAULT_UNION_DEFAULT_ORDER
            }
        }
        if (_obj instanceof FUnionType)
            return _accessor.getFDBusUnionDefaultOrder(_obj)
        return FDBUS_DEFAULT_UNION_DEFAULT_ORDER
    }

    def Integer getFDBusUnionMaxLengthHelper(PropertyAccessor _accessor, EObject _obj) {
        if (_obj instanceof FAttribute) {
            return _accessor.getFDBusUnionMaxLengthHelper(_obj.type.derived)
        }

        if (_obj instanceof FArgument) {
            return _accessor.getFDBusUnionMaxLengthHelper(_obj.type.derived)
        }
        if (_obj instanceof FField) {
            return _accessor.getFDBusUnionMaxLengthHelper(_obj.type.derived)
        }
        if (_obj instanceof FTypeDef) {
            if (_obj.actualType.derived !== null) {
                if (_obj.actualType.derived instanceof FUnionType) {
                    return _accessor.getFDBusUnionMaxLength(_obj.actualType.derived as FUnionType)
                }
            } else {
                return FDBUS_DEFAULT_MAX_LENGTH
            }
        }
        if (_obj instanceof FUnionType)
            return _accessor.getFDBusUnionMaxLength(_obj)
        return FDBUS_DEFAULT_MAX_LENGTH
    }

    def Integer getFDBusStructLengthWidthHelper(PropertyAccessor _accessor, EObject _obj) {
        if (_obj instanceof FAttribute) {
            return _accessor.getFDBusStructLengthWidthHelper(_obj.type.derived)
        }

        if (_obj instanceof FArgument) {
            return _accessor.getFDBusStructLengthWidthHelper(_obj.type.derived)
        }
        if (_obj instanceof FField) {
            return _accessor.getFDBusStructLengthWidthHelper(_obj.type.derived)
        }
        if (_obj instanceof FTypeDef) {
            if (_obj.actualType.derived !== null) {
                if (_obj.actualType.derived instanceof FStructType) {
                    return _accessor.getFDBusStructLengthWidth(_obj.actualType.derived as FStructType)
                }
            } else {
                return FDBUS_DEFAULT_STRUCT_LENGTH_WIDTH
            }
        }
        if (_obj instanceof FStructType)
            return _accessor.getFDBusStructLengthWidth(_obj)
        return FDBUS_DEFAULT_STRUCT_LENGTH_WIDTH
    }

    def Integer getFDBusEnumWidthHelper(PropertyAccessor _accessor, EObject _obj) {
        if (_obj !== null) {
            if (_obj instanceof FEnumerationType) {
                var Integer enumWidth = _accessor.getFDBusEnumWidth(_obj)
                var Integer enumBaseWidth = null
                if (_obj.base !== null) {
                    val itsBaseAccessor = getFDBusAccessor(_obj.base.eContainer as FTypeCollection)
                    if (itsBaseAccessor !== null)
                        enumBaseWidth = itsBaseAccessor.getFDBusEnumWidthHelper(_obj.base)
                }
                return (enumBaseWidth !== null && enumBaseWidth > enumWidth ? enumBaseWidth : enumWidth)
            }

            if (_obj instanceof FTypeDef) {
                if (_obj.actualType.derived !== null) {
                    val FType derived = _obj.actualType.derived
                    if (derived instanceof FEnumerationType) {
                        return _accessor.getFDBusEnumWidthHelper(derived)
                    }
                }
                return FDBUS_DEFAULT_ENUM_WIDTH
            }
        }
        return null
    }

    def Integer getFDBusEnumBitWidthHelper(PropertyAccessor _accessor, EObject _obj) {
        if (_obj !== null) {
            if (_obj instanceof FEnumerationType) {
                var Integer enumBitWidth = _accessor.getFDBusEnumBitWidth(_obj)
                var Integer enumBaseBitWidth = null
                if (_obj.base !== null) {
                    val itsBaseAccessor = getFDBusAccessor(_obj.base.eContainer as FTypeCollection)
                    if (itsBaseAccessor !== null)
                        enumBaseBitWidth = itsBaseAccessor.getFDBusEnumBitWidthHelper(_obj.base)
                }
                return (enumBaseBitWidth !== null && enumBaseBitWidth > enumBitWidth ? enumBaseBitWidth : enumBitWidth)
            }

            if (_obj instanceof FTypeDef) {
                if (_obj.actualType.derived !== null) {
                    val FType derived = _obj.actualType.derived
                    if (derived instanceof FEnumerationType) {
                        return _accessor.getFDBusEnumBitWidthHelper(derived)
                    }
                }
            }
        }
        return null
    }

    def Integer getFDBusEnumInvalidValueHelper(PropertyAccessor _accessor, EObject _obj) {
        if (_obj !== null) {
            if (_obj instanceof FEnumerationType) {
                var Integer invalidValue = _accessor.getFDBusEnumInvalidValue(_obj)
                if (invalidValue === null)
                    invalidValue = _accessor.getFDBusEnumInvalidValueHelper(_obj.base)
                return invalidValue
            }
            if (_obj instanceof FTypeDef) {
                if (_obj.actualType.derived !== null) {
                    val FType derived = _obj.actualType.derived
                    if (derived instanceof FEnumerationType) {
                        return _accessor.getFDBusEnumInvalidValueHelper(derived)
                    }
                }
            }
    }
        return null
    }

    def Integer getFDBusIntegerBitWidthHelper(PropertyAccessor _accessor, EObject _obj) {
         return _accessor.getFDBusIntegerBitWidth(_obj)
    }

    def Integer getFDBusIntegerInvalidValueHelper(PropertyAccessor _accessor, EObject _obj) {
        return _accessor.getFDBusIntegerInvalidValue(_obj)
    }

    def PropertyAccessor getSpecificAccessor(EObject _object) {
        var container = _object.eContainer
        while (container !== null) {
            if(container instanceof FInterface) {
                return getFDBusAccessor(container)
            }
            if(container instanceof FTypeCollection) {
                return getFDBusAccessor(container)
            }
            container = container.eContainer
        }
        return null
    }


    // Helper to check whether the deployment differs from the default deployment
    def boolean hasFDBusArrayMinLength(PropertyAccessor _accessor, EObject _object) {
        var Integer defaultMinLength = null
        // overwrites are not used for defaults
        if (!_accessor.isProperOverwrite()) {
            if (_object instanceof FTypedElement) {
                if (_object.type.derived !== null) {
                    defaultMinLength = _accessor.getFDBusArrayMinLengthHelper(_object.type.derived)
                    if (defaultMinLength === null) {
                        val newAccessor = getSpecificAccessor(_object)
                        if (newAccessor !== null)
                            defaultMinLength = newAccessor.getFDBusArrayMinLengthHelper(_object.type.derived)
                    }
                }
            }
        }
        if (defaultMinLength === null)
            defaultMinLength = FDBUS_DEFAULT_MIN_LENGTH

        var Integer minLength = _accessor.getFDBusArrayMinLengthHelper(_object)
        if(minLength !== null && minLength != defaultMinLength) {
            return true
        }
        var newAccessor = getSpecificAccessor(_object)
        if(newAccessor !== null) {
            minLength = newAccessor.getFDBusArrayMinLengthHelper(_object)
            return minLength !== null && minLength != defaultMinLength
        }
        return false
    }

    def boolean hasFDBusArrayMaxLength(PropertyAccessor _accessor, EObject _object) {
        var Integer defaultMaxLength = null
        // overwrites are not used for defaults
        if (!_accessor.isProperOverwrite()) {
            if (_object instanceof FTypedElement) {
                if (_object.type.derived !== null) {
                    defaultMaxLength = _accessor.getFDBusArrayMaxLengthHelper(_object.type.derived)
                    if (defaultMaxLength === null) {
                        val newAccessor = getSpecificAccessor(_object)
                        if(newAccessor !== null)
                            defaultMaxLength = newAccessor.getFDBusArrayMaxLengthHelper(_object.type.derived)
                    }
                }
            }
        }
        if (defaultMaxLength === null)
            defaultMaxLength = FDBUS_DEFAULT_MAX_LENGTH

        var Integer maxLength = _accessor.getFDBusArrayMaxLengthHelper(_object)
        if(maxLength !== null && maxLength != defaultMaxLength) {
            return true
        }
        var newAccessor = getSpecificAccessor(_object)
        if(newAccessor !== null) {
            maxLength = newAccessor.getFDBusArrayMaxLengthHelper(_object)
            return maxLength !== null && maxLength != defaultMaxLength
        }
        return false
    }

    def boolean hasFDBusArrayLengthWidth(PropertyAccessor _accessor, EObject _object) {
        var Integer defaultLengthWidth = null
        // overwrites are not used for defaults
        if (!_accessor.isProperOverwrite()) {
            if (_object instanceof FTypedElement) {
                if (_object.type.derived !== null) {
                    defaultLengthWidth = _accessor.getFDBusArrayLengthWidthHelper(_object.type.derived)
                    if (defaultLengthWidth === null) {
                        val newAccessor = getSpecificAccessor(_object)
                        if(newAccessor !== null)
                            defaultLengthWidth = newAccessor.getFDBusArrayLengthWidthHelper(_object.type.derived)
                    }
                }
            }
        }
        if (defaultLengthWidth === null)
            defaultLengthWidth = FDBUS_DEFAULT_LENGTH_WIDTH

        var Integer lengthWidth = _accessor.getFDBusArrayLengthWidthHelper(_object)
        if(lengthWidth !== null && lengthWidth != defaultLengthWidth) {
            return true
        }
        var newAccessor = getSpecificAccessor(_object)
        if(newAccessor !== null) {
            lengthWidth = newAccessor.getFDBusArrayLengthWidthHelper(_object)
            return lengthWidth !== null && lengthWidth != defaultLengthWidth
        }
        return false
    }

    def boolean hasFDBusByteBufferMinLength(PropertyAccessor _accessor, EObject _object) {
        var Integer defaultMinWidth = null
        // overwrites are not used for defaults
        if (!_accessor.isProperOverwrite()) {
            if (_object instanceof FTypedElement) {
                if (_object.type.derived !== null) {
                    defaultMinWidth = _accessor.getFDBusByteBufferMinLength(_object.type.derived)
                    if (defaultMinWidth === null) {
                        val newAccessor = getSpecificAccessor(_object)
                        if(newAccessor !== null)
                            defaultMinWidth = newAccessor.getFDBusByteBufferMinLength(_object.type.derived)
                    }
                }
            }
        }
        if (defaultMinWidth === null)
            defaultMinWidth = FDBUS_DEFAULT_MIN_LENGTH

        var Integer length = _accessor.getFDBusByteBufferMinLength(_object)
        if(length !== null && length != defaultMinWidth) {
            return true
        }
        var newAccessor = getSpecificAccessor(_object)
        if(newAccessor !== null) {
            length = newAccessor.getFDBusByteBufferMinLength(_object)
            return length !== null && length != defaultMinWidth
        }
        return false
    }

    def boolean hasFDBusByteBufferMaxLength(PropertyAccessor _accessor, EObject _object) {
        var Integer defaultMaxWidth = null
        // overwrites are not used for defaults
        if (!_accessor.isProperOverwrite()) {
            if (_object instanceof FTypedElement) {
                if (_object.type.derived !== null) {
                    defaultMaxWidth = _accessor.getFDBusByteBufferMaxLength(_object.type.derived)
                    if (defaultMaxWidth === null) {
                        val newAccessor = getSpecificAccessor(_object)
                        if(newAccessor !== null)
                            defaultMaxWidth = newAccessor.getFDBusByteBufferMaxLength(_object.type.derived)
                    }
                }
            }
        }
        if (defaultMaxWidth === null)
            defaultMaxWidth = FDBUS_DEFAULT_MAX_LENGTH

        var Integer length = _accessor.getFDBusByteBufferMaxLength(_object)
        if(length !== null && length != defaultMaxWidth) {
            return true
        }
        var newAccessor = getSpecificAccessor(_object)
        if(newAccessor !== null) {
            length = newAccessor.getFDBusByteBufferMaxLength(_object)
            return length !== null && length != defaultMaxWidth
        }
        return false
    }

    def boolean hasFDBusByteBufferLengthWidth(PropertyAccessor _accessor, EObject _object) {
        var Integer defaultLengthWidth = null
        // overwrites are not used for defaults
        if (!_accessor.isProperOverwrite()) {
            if (_object instanceof FTypedElement) {
                if (_object.type.derived !== null) {
                    defaultLengthWidth = _accessor.getFDBusByteBufferLengthWidth(_object.type.derived)
                    if (defaultLengthWidth === null) {
                        val newAccessor = getSpecificAccessor(_object)
                        if(newAccessor !== null)
                            defaultLengthWidth = newAccessor.getFDBusByteBufferLengthWidth(_object.type.derived)
                    }
                }
            }
        }
        if (defaultLengthWidth === null)
            defaultLengthWidth = FDBUS_DEFAULT_LENGTH_WIDTH

        var Integer length = _accessor.getFDBusByteBufferLengthWidth(_object)
        if (length !== null && length != defaultLengthWidth) {
            return true
        }
        var newAccessor = getSpecificAccessor(_object)
        if (newAccessor !== null) {
            length = newAccessor.getFDBusByteBufferMaxLength(_object)
            return length !== null && length != defaultLengthWidth
        }
        return false
    }

    def boolean isDefaultWidth(int _width) {
        return (_width == 0 || _width == 8 || _width == 16 || _width == 32 || _width == 64)
    }

    def boolean hasFDBusIntegerBitWidth(PropertyAccessor _accessor, EObject _object) {
        var Integer width = _accessor.getFDBusIntegerBitWidthHelper(_object);
        if (width !== null && !isDefaultWidth(width.intValue()))
            return true

        var newAccessor = getSpecificAccessor(_object)
        if (newAccessor !== null) {
            width = newAccessor.getFDBusIntegerBitWidthHelper(_object)
            if (width !== null && !isDefaultWidth(width.intValue()))
                return true
        }

        return false
    }

    def boolean hasFDBusIntegerInvalidValue(PropertyAccessor _accessor, EObject _object) {
        var Integer invalidValue = _accessor.getFDBusIntegerInvalidValueHelper(_object)
        if (invalidValue !== null)
            return true

        var newAccessor = getSpecificAccessor(_object)
        if (newAccessor !== null) {
            invalidValue = newAccessor.getFDBusIntegerInvalidValueHelper(_object)
            if (invalidValue !== null)
                return true
        }

        return false
    }

    def boolean hasFDBusStringLength(PropertyAccessor _accessor, EObject _object) {
        var Integer length = _accessor.getFDBusStringLength(_object)
        if(length !== null && length != FDBUS_DEFAULT_MIN_LENGTH) {
            return true
        }
        var newAccessor = getSpecificAccessor(_object)
        if(newAccessor !== null) {
            length = newAccessor.getFDBusStringLength(_object)
            return length !== null && length != FDBUS_DEFAULT_MIN_LENGTH
        }
        return false
    }

    def boolean hasFDBusStringLengthWidth(PropertyAccessor _accessor, EObject _object) {
        var Integer lengthWidth = _accessor.getFDBusStringLengthWidth(_object)
        if(lengthWidth !== null && lengthWidth != FDBUS_DEFAULT_LENGTH_WIDTH) {
            return true
        }
        var newAccessor = getSpecificAccessor(_object)
        if(newAccessor !== null) {
            lengthWidth = newAccessor.getFDBusStringLengthWidth(_object)
            return lengthWidth !== null && lengthWidth != FDBUS_DEFAULT_LENGTH_WIDTH
        }
        return false
    }


    def boolean hasFDBusStructLengthWidth(PropertyAccessor _accessor, EObject _object) {
        var Integer defaultLengthWidth = null
        // overwrites are not used for defaults
        if (!_accessor.isProperOverwrite()) {
            if (_object instanceof FTypedElement) {
                if (_object.type.derived !== null) {
                    defaultLengthWidth = _accessor.getFDBusStructLengthWidthHelper(_object.type.derived)
                    if (defaultLengthWidth === null) {
                        val newAccessor = getSpecificAccessor(_object)
                        if(newAccessor !== null)
                            defaultLengthWidth = newAccessor.getFDBusStructLengthWidthHelper(_object.type.derived)
                    }
                }
            }
        }
        if (defaultLengthWidth === null)
            defaultLengthWidth = FDBUS_DEFAULT_STRUCT_LENGTH_WIDTH

        var Integer lengthWidth = _accessor.getFDBusStructLengthWidthHelper(_object)
        if(lengthWidth !== null && lengthWidth != defaultLengthWidth) {
            return true
        }
        var newAccessor = getSpecificAccessor(_object)
        if(newAccessor !== null) {
            lengthWidth = newAccessor.getFDBusStructLengthWidthHelper(_object)
            return lengthWidth !== null && lengthWidth != defaultLengthWidth
        }
        return false
    }

    def boolean hasFDBusStringEncoding(PropertyAccessor _accessor, EObject _object) {
        var PropertyAccessor.FDBusStringEncoding encoding = _accessor.getFDBusStringEncoding(_object)
        if(encoding !== null && encoding != FDBUS_DEFAULT_STRING_ENCODING) {
            return true
        }
        var newAccessor = getSpecificAccessor(_object)
        if(newAccessor !== null) {
            encoding = newAccessor.getFDBusStringEncoding(_object)
            return encoding !== null && encoding != FDBUS_DEFAULT_STRING_ENCODING
        }
        return false
    }

    def boolean hasFDBusMapMinLength(PropertyAccessor _accessor, EObject _object) {
        var Integer defaultMinLength = null
        // overwrites are not used for defaults
        if (!_accessor.isProperOverwrite()) {
            if (_object instanceof FTypedElement) {
                if (_object.type.derived !== null) {
                    defaultMinLength = _accessor.getFDBusMapMinLengthHelper(_object.type.derived)
                    if (defaultMinLength === null) {
                        val newAccessor = getSpecificAccessor(_object)
                        if(newAccessor !== null)
                            defaultMinLength = newAccessor.getFDBusMapMinLengthHelper(_object.type.derived)
                    }
                }
            }
        }
        if (defaultMinLength === null)
            defaultMinLength = FDBUS_DEFAULT_MIN_LENGTH

        var Integer minLength = _accessor.getFDBusMapMinLengthHelper(_object)
        if(minLength !== null && minLength != defaultMinLength) {
            return true
        }
        var newAccessor = getSpecificAccessor(_object)
        if(newAccessor !== null) {
            minLength = newAccessor.getFDBusMapMinLengthHelper(_object)
            return minLength !== null && minLength != defaultMinLength
        }
        return false
    }

    def boolean hasFDBusMapMaxLength(PropertyAccessor _accessor, EObject _object) {
        var Integer defaultMaxLength = null
        // overwrites are not used for defaults
        if (!_accessor.isProperOverwrite()) {
            if (_object instanceof FTypedElement) {
                if (_object.type.derived !== null) {
                    defaultMaxLength = _accessor.getFDBusMapMaxLengthHelper(_object.type.derived)
                    if (defaultMaxLength === null) {
                        val newAccessor = getSpecificAccessor(_object)
                        if(newAccessor !== null)
                            defaultMaxLength = newAccessor.getFDBusMapMaxLengthHelper(_object.type.derived)
                    }
                }
            }
        }
        if (defaultMaxLength === null)
            defaultMaxLength = FDBUS_DEFAULT_MAX_LENGTH

        var Integer maxLength = _accessor.getFDBusMapMaxLengthHelper(_object)
        if(maxLength !== null && maxLength != defaultMaxLength) {
            return true
        }
        var newAccessor = getSpecificAccessor(_object)
        if(newAccessor !== null) {
            maxLength = newAccessor.getFDBusMapMaxLengthHelper(_object)
            return maxLength !== null && maxLength != defaultMaxLength
        }
        return false
    }

    def boolean hasFDBusMapLengthWidth(PropertyAccessor _accessor, EObject _object) {
        var Integer defaultLengthWidth = null
        // overwrites are not used for defaults
        if (!_accessor.isProperOverwrite()) {
            if (_object instanceof FTypedElement) {
                if (_object.type.derived !== null) {
                    defaultLengthWidth = _accessor.getFDBusMapLengthWidthHelper(_object.type.derived)
                    if (defaultLengthWidth === null) {
                        val newAccessor = getSpecificAccessor(_object)
                        if(newAccessor !== null)
                            defaultLengthWidth = newAccessor.getFDBusMapLengthWidthHelper(_object.type.derived)
                    }
                }
            }
        }
        if (defaultLengthWidth === null)
            defaultLengthWidth = FDBUS_DEFAULT_LENGTH_WIDTH

        var Integer lengthWidth = _accessor.getFDBusMapLengthWidthHelper(_object)
        if(lengthWidth !== null && lengthWidth != defaultLengthWidth) {
            return true
        }
        var newAccessor = getSpecificAccessor(_object)
        if(newAccessor !== null) {
            lengthWidth = newAccessor.getFDBusMapLengthWidthHelper(_object)
            return lengthWidth !== null && lengthWidth != defaultLengthWidth
        }
        return false
    }

    def boolean hasFDBusUnionLengthWidth(PropertyAccessor _accessor, EObject _object) {
        var Integer defaultLengthWidth = null
        // overwrites are not used for defaults
        if (!_accessor.isProperOverwrite()) {
            if (_object instanceof FTypedElement) {
                if (_object.type.derived !== null) {
                    defaultLengthWidth = _accessor.getFDBusUnionLengthWidthHelper(_object.type.derived)
                    if (defaultLengthWidth === null) {
                        val newAccessor = getSpecificAccessor(_object)
                        if(newAccessor !== null)
                            defaultLengthWidth = newAccessor.getFDBusUnionLengthWidthHelper(_object.type.derived)
                    }
                }
            }
          }
        if (defaultLengthWidth === null)
            defaultLengthWidth = FDBUS_DEFAULT_LENGTH_WIDTH

        var Integer lengthWidth = _accessor.getFDBusUnionLengthWidthHelper(_object)
        if(lengthWidth !== null && lengthWidth != defaultLengthWidth) {
            return true
        }
        val newAccessor = getSpecificAccessor(_object)
        if(newAccessor !== null) {
            lengthWidth = newAccessor.getFDBusUnionLengthWidthHelper(_object)
            return lengthWidth !== null && lengthWidth != defaultLengthWidth
        }
        return false
    }

    def boolean hasFDBusUnionTypeWidth(PropertyAccessor _accessor, EObject _object) {
        var Integer defaultTypeWidth = null
        // overwrites are not used for defaults
        if (!_accessor.isProperOverwrite()) {
            if (_object instanceof FTypedElement) {
                if (_object.type.derived !== null) {
                    defaultTypeWidth = _accessor.getFDBusUnionTypeWidthHelper(_object.type.derived)
                    if (defaultTypeWidth === null) {
                        val newAccessor = getSpecificAccessor(_object)
                        if(newAccessor !== null)
                            defaultTypeWidth = newAccessor.getFDBusUnionTypeWidthHelper(_object.type.derived)
                    }
                }
            }
        }
        if (defaultTypeWidth === null)
            defaultTypeWidth = FDBUS_DEFAULT_UNION_TYPE_WIDTH

        var Integer typeWidth = _accessor.getFDBusUnionTypeWidthHelper(_object)
        if(typeWidth !== null && typeWidth != defaultTypeWidth) {
            return true
        }
        var newAccessor = getSpecificAccessor(_object)
        if(newAccessor !== null) {
            typeWidth = newAccessor.getFDBusUnionTypeWidthHelper(_object)
            return typeWidth !== null && typeWidth != defaultTypeWidth
        }
        return false
    }

    def boolean hasFDBusUnionDefaultOrder(PropertyAccessor _accessor, EObject _object) {
        var Boolean defaultDefaultOrder = null
        // overwrites are not used for defaults
        if (!_accessor.isProperOverwrite()) {
            if (_object instanceof FTypedElement) {
                if (_object.type.derived !== null) {
                    defaultDefaultOrder = _accessor.getFDBusUnionDefaultOrderHelper(_object.type.derived)
                    if (defaultDefaultOrder === null) {
                        val newAccessor = getSpecificAccessor(_object)
                        if(newAccessor !== null)
                            defaultDefaultOrder = newAccessor.getFDBusUnionDefaultOrderHelper(_object.type.derived)
                    }
                }
            }
        }
        if (defaultDefaultOrder === null)
            defaultDefaultOrder = FDBUS_DEFAULT_UNION_DEFAULT_ORDER

        var Boolean defaultOrder = _accessor.getFDBusUnionDefaultOrderHelper(_object)
        if(defaultOrder !== null && defaultOrder != defaultDefaultOrder) {
            return true
        }
        var newAccessor = getSpecificAccessor(_object)
        if(newAccessor !== null) {
            defaultOrder = newAccessor.getFDBusUnionDefaultOrderHelper(_object)
            return defaultOrder !== null && defaultOrder != defaultDefaultOrder
        }
        return false
    }

    def boolean hasFDBusUnionMaxLength(PropertyAccessor _accessor, EObject _object) {
        var Integer defaultMaxLength = null
        // overwrites are not used for defaults
        if (!_accessor.isProperOverwrite()) {
            if (_object instanceof FTypedElement) {
                if (_object.type.derived !== null) {
                    defaultMaxLength = _accessor.getFDBusUnionMaxLengthHelper(_object.type.derived)
                    if (defaultMaxLength === null) {
                        val newAccessor = getSpecificAccessor(_object)
                        if(newAccessor !== null)
                            defaultMaxLength = newAccessor.getFDBusUnionMaxLengthHelper(_object.type.derived)
                    }
                }
            }
        }
        if (defaultMaxLength === null)
            defaultMaxLength = FDBUS_DEFAULT_MAX_LENGTH

        var Integer maxLength = _accessor.getFDBusUnionMaxLengthHelper(_object)
        if(maxLength !== null && maxLength != defaultMaxLength) {
            return true
        }
        var newAccessor = getSpecificAccessor(_object)
        if(newAccessor !== null) {
            maxLength = newAccessor.getFDBusUnionMaxLengthHelper(_object)
            return maxLength !== null && maxLength != defaultMaxLength
        }
        return false
    }

    def boolean hasFDBusEnumWidth(PropertyAccessor _accessor, EObject _object) {
        var Integer defaultEnumWidth = null
        // overwrites are not used for defaults
        if (!_accessor.isProperOverwrite()) {
            if (_object instanceof FTypedElement) {
                if (_object.type.derived !== null) {
                    defaultEnumWidth = _accessor.getFDBusEnumWidthHelper(_object.type.derived)
                    if (defaultEnumWidth === null) {
                        val newAccessor = getSpecificAccessor(_object)
                        if(newAccessor !== null)
                            defaultEnumWidth = newAccessor.getFDBusEnumWidthHelper(_object.type.derived)
                    }
                }
            }
        }
        if (defaultEnumWidth === null)
            defaultEnumWidth = FDBUS_DEFAULT_ENUM_LENGTH_WIDTH

        var Integer lengthWidth = _accessor.getFDBusEnumWidthHelper(_object)
        if(lengthWidth !== null && lengthWidth != defaultEnumWidth) {
            return true
        }
        var newAccessor = getSpecificAccessor(_object)
        if(newAccessor !== null) {
            lengthWidth = newAccessor.getFDBusEnumWidthHelper(_object)
            return lengthWidth !== null && lengthWidth != defaultEnumWidth
        }
        return false
    }

    def boolean hasFDBusEnumBitWidth(PropertyAccessor _accessor, EObject _object) {
        var Integer width = _accessor.getFDBusEnumBitWidthHelper(_object);
        if (width !== null && !isDefaultWidth(width.intValue()))
            return true

        var newAccessor = getSpecificAccessor(_object)
        if (newAccessor !== null) {
            width = newAccessor.getFDBusEnumBitWidthHelper(_object)
            if (width !== null && !isDefaultWidth(width.intValue()))
                return true
        }

        return false
    }

    def boolean hasFDBusEnumInvalidValue(PropertyAccessor _accessor, EObject _object) {
        var Integer invalidValue = _accessor.getFDBusEnumInvalidValueHelper(_object)
        if (invalidValue !== null)
            return true

        var newAccessor = getSpecificAccessor(_object)
        if (newAccessor !== null) {
            invalidValue = newAccessor.getFDBusEnumInvalidValueHelper(_object)
            if (invalidValue !== null)
                return true
        }

        return false
    }

    def dispatch boolean hasDeployment(PropertyAccessor _accessor, FTypedElement _element) {
        if (_accessor === null)
            return false
        if (_accessor.hasFDBusArrayMinLength(_element) ||
            _accessor.hasFDBusArrayMaxLength(_element) ||
            _accessor.hasFDBusArrayLengthWidth(_element) ||
            _accessor.hasFDBusMapMinLength(_element) ||
            _accessor.hasFDBusMapMaxLength(_element) ||
            _accessor.hasFDBusMapLengthWidth(_element) ||
            _accessor.hasFDBusByteBufferMinLength(_element) ||
            _accessor.hasFDBusByteBufferMaxLength(_element) ||
            _accessor.hasFDBusByteBufferLengthWidth(_element) ||
            _accessor.hasFDBusStringLength(_element) ||
            _accessor.hasFDBusStringLengthWidth(_element) ||
            _accessor.hasFDBusStringEncoding(_element) ||
            _accessor.hasFDBusStructLengthWidth(_element) ||
            _accessor.hasFDBusUnionLengthWidth(_element) ||
            _accessor.hasFDBusUnionTypeWidth(_element) ||
            _accessor.hasFDBusUnionDefaultOrder(_element) ||
            _accessor.hasFDBusUnionMaxLength(_element) ||
            _accessor.hasFDBusEnumWidth(_element) ||
            _accessor.hasFDBusEnumBitWidth(_element) ||
            _accessor.hasFDBusEnumInvalidValue(_element) ||
            _accessor.hasFDBusIntegerBitWidth(_element) ||
            _accessor.hasFDBusIntegerInvalidValue(_element)) {
                return true
        }
        return _accessor.hasDeployment(_element.type)
    }

    def dispatch boolean hasDeployment(PropertyAccessor _accessor, FArrayType _array) {
        if (_accessor.hasFDBusArrayMinLength(_array) ||
            _accessor.hasFDBusArrayMaxLength(_array) ||
            _accessor.hasFDBusArrayLengthWidth(_array)) {
            return true
        }
        var PropertyAccessor overwriteAccessor = _accessor.getOverwriteAccessor(_array);
        if (overwriteAccessor.hasDeployment(_array.elementType)) {
            return true
        }

        return false
    }

    def dispatch boolean hasDeployment(PropertyAccessor _accessor, FMapType _map) {
        if (_accessor.hasFDBusMapMinLength(_map) ||
            _accessor.hasFDBusMapMaxLength(_map) ||
            _accessor.hasFDBusMapLengthWidth(_map)) {
            return true
        }

        if (_accessor.hasDeployment(_map.keyType) ||
            _accessor.hasDeployment(_map.valueType)) {
            return true
        }

        return false
    }

    def dispatch boolean hasDeployment(PropertyAccessor _accessor, FEnumerationType _enum) {
        if (_accessor.hasFDBusEnumWidth(_enum) ||
            _accessor.hasFDBusEnumBitWidth(_enum) ||
            _accessor.hasFDBusEnumInvalidValue(_enum))
            return true

        if (_enum.base !== null) {
            val itsBaseAccessor = getFDBusAccessor(_enum.base.eContainer as FTypeCollection)
            if (itsBaseAccessor !== null)
                return itsBaseAccessor.hasDeployment(_enum.base)
        }

        return false 
    }

    def dispatch boolean hasDeployment(PropertyAccessor _accessor, FStructType _struct) {
        if (_accessor.hasFDBusStructLengthWidth(_struct))
            return true
        for (element : _struct.elements) {
            var PropertyAccessor overwriteAccessor = _accessor.getOverwriteAccessor(element);
            if (overwriteAccessor.hasDeployment(element)) {
                return true
            }
        }

        if (_struct.base !== null) {
            return hasDeployment(_accessor, _struct.base);
        }

        return false
    }

    def dispatch boolean hasDeployment(PropertyAccessor _accessor, FUnionType _union) {
        if (_accessor.hasFDBusUnionDefaultOrder(_union) ||
            _accessor.hasFDBusUnionLengthWidth(_union) ||
            _accessor.hasFDBusUnionTypeWidth(_union) ||
            _accessor.hasFDBusUnionMaxLength(_union)) {
            return true
        }

        for (element : _union.elements) {
            var PropertyAccessor overwriteAccessor = _accessor.getOverwriteAccessor(element);
            if (overwriteAccessor.hasDeployment(element)) {
                return true
            }
        }

        return false
    }

    def dispatch boolean hasDeployment(PropertyAccessor _accessor, FTypeDef _typeDef) {
        return _accessor.hasDeployment(_typeDef.actualType)
    }
    def dispatch boolean hasDeployment(PropertyAccessor _accessor, FIntegerInterval _type) {
        return false
    }
    def dispatch boolean hasDeployment(PropertyAccessor _accessor, FBasicTypeId _type) {
        return false
    }

    def dispatch boolean hasDeployment(PropertyAccessor _accessor, FType _type) {
        return false;
    }

    def dispatch boolean hasDeployment(PropertyAccessor _accessor, FTypeRef _type) {
        if (_type.derived !== null)
            return _accessor.hasDeployment(_type.derived)
        if (_type.interval !== null)
            return _accessor.hasDeployment(_type.interval)
        if (_type.predefined !== null)
            return _accessor.hasDeployment(_type.predefined)

        return false
    }

    def boolean isFull(FBasicTypeId _type, Integer _width) {
        if (_type === null)
            return false

        if (_type == FBasicTypeId.INT8 || _type == FBasicTypeId.INT8)
            return _width == 8

        if (_type == FBasicTypeId.INT16 || _type == FBasicTypeId.INT16)
            return _width == 16

        if (_type == FBasicTypeId.INT32 || _type == FBasicTypeId.INT32)
            return _width == 32

        if (_type == FBasicTypeId.INT64 || _type == FBasicTypeId.INT64)
            return _width == 64

        return false
    }

    def boolean hasSpecificDeployment(PropertyAccessor _accessor, FTypedElement _element) {
        val PropertyAccessor itsBaseAccessor =
        if (_accessor.isProperOverwrite() )
            _accessor.parent
        else
            null

        val itsSpecificArrayMinLength = _accessor.getFDBusArrayMinLengthHelper(_element)
        var itsArrayMinLength = FDBUS_DEFAULT_MIN_LENGTH
        if (itsBaseAccessor !== null) {
            itsArrayMinLength = _accessor.getFDBusArrayMinLengthHelper(_element)
        }
        if (itsSpecificArrayMinLength !== null
            && itsSpecificArrayMinLength != itsArrayMinLength
            && itsSpecificArrayMinLength != FDBUS_DEFAULT_MIN_LENGTH) {
            return true
        }

        val itsSpecificArrayMaxLength = _accessor.getFDBusArrayMaxLengthHelper(_element)
        var itsArrayMaxLength = FDBUS_DEFAULT_MAX_LENGTH
        if (itsBaseAccessor !== null) {
            itsArrayMaxLength = _accessor.getFDBusArrayMaxLengthHelper(_element)
        }
        if (itsSpecificArrayMaxLength !== null
            && itsSpecificArrayMaxLength != itsArrayMaxLength
            && itsSpecificArrayMaxLength != FDBUS_DEFAULT_MAX_LENGTH) {
            return true
        }

        val itsSpecificArrayLengthWidth = _accessor.getFDBusArrayLengthWidthHelper(_element)
        var itsArrayLengthWidth = FDBUS_DEFAULT_LENGTH_WIDTH
        if (itsBaseAccessor !== null) {
            itsArrayLengthWidth = _accessor.getFDBusArrayLengthWidthHelper(_element)
        }
        if (itsSpecificArrayLengthWidth !== null
            && itsSpecificArrayLengthWidth != itsArrayLengthWidth
            && itsSpecificArrayLengthWidth != FDBUS_DEFAULT_LENGTH_WIDTH) {
            return true
        }
        val itsSpecificMapMinLength = _accessor.getFDBusMapMinLengthHelper(_element)
        var itsMapMinLength = FDBUS_DEFAULT_MIN_LENGTH
        if (itsBaseAccessor !== null) {
            itsMapMinLength = _accessor.getFDBusMapMinLengthHelper(_element)
        }
        if (itsSpecificMapMinLength !== null
            && itsSpecificMapMinLength != itsMapMinLength
            && itsSpecificMapMinLength != FDBUS_DEFAULT_MIN_LENGTH) {
            return true
        }

        val itsSpecificMapMaxLength = _accessor.getFDBusMapMaxLengthHelper(_element)
        var itsMapMaxLength = FDBUS_DEFAULT_MAX_LENGTH
        if (itsBaseAccessor !== null) {
            itsMapMaxLength = _accessor.getFDBusMapMaxLengthHelper(_element)
        }
        if (itsSpecificMapMaxLength !== null
            && itsSpecificMapMaxLength != itsMapMaxLength
            && itsSpecificMapMaxLength != FDBUS_DEFAULT_MAX_LENGTH) {
            return true
        }

        val itsSpecificMapLengthWidth = _accessor.getFDBusMapLengthWidthHelper(_element)
        var itsMapLengthWidth = FDBUS_DEFAULT_LENGTH_WIDTH
        if (itsBaseAccessor !== null) {
            itsMapLengthWidth = itsBaseAccessor.getFDBusMapLengthWidthHelper(_element)
        }
        if (itsSpecificMapLengthWidth !== null
            && itsSpecificMapLengthWidth != itsMapLengthWidth
            && itsSpecificMapLengthWidth != FDBUS_DEFAULT_LENGTH_WIDTH) {
            return true
        }

        val itsSpecificByteBufferMinLength = _accessor.getFDBusByteBufferMinLength(_element)
        var itsByteBufferMinLength = FDBUS_DEFAULT_MIN_LENGTH
        if (itsBaseAccessor !== null) {
            itsByteBufferMinLength = _accessor.getFDBusByteBufferMinLength(_element)
        }
        if (itsSpecificByteBufferMinLength !== null
            && itsSpecificByteBufferMinLength != itsByteBufferMinLength
            && itsSpecificByteBufferMinLength != FDBUS_DEFAULT_MIN_LENGTH) {
            return true
        }

        val itsSpecificByteBufferMaxLength = _accessor.getFDBusByteBufferMaxLength(_element)
        var itsByteBufferMaxLength = FDBUS_DEFAULT_MAX_LENGTH
        if (itsBaseAccessor !== null) {
            itsByteBufferMaxLength = _accessor.getFDBusByteBufferMaxLength(_element)
        }
        if (itsSpecificByteBufferMaxLength !== null
            && itsSpecificByteBufferMaxLength != itsByteBufferMaxLength 
            && itsSpecificByteBufferMaxLength != FDBUS_DEFAULT_MAX_LENGTH) {
            return true
        }

        val itsSpecificByteBufferLengthWidth = _accessor.getFDBusByteBufferLengthWidth(_element)
        var itsByteBufferLengthWidth = FDBUS_DEFAULT_LENGTH_WIDTH
        if (itsBaseAccessor !== null) {
            itsByteBufferLengthWidth = itsBaseAccessor.getFDBusByteBufferLengthWidth(_element)
        }
        if (itsSpecificByteBufferLengthWidth !== null
            && itsSpecificByteBufferLengthWidth != itsByteBufferLengthWidth
            && itsSpecificByteBufferLengthWidth != FDBUS_DEFAULT_LENGTH_WIDTH) {
            return true
        }

        val itsSpecificStringLength = _accessor.getFDBusStringLength(_element)
        var Integer itsStringLength = FDBUS_DEFAULT_STRING_LENGTH
        if (itsBaseAccessor !== null) {
            itsStringLength = itsBaseAccessor.getFDBusStringLength(_element)
        }
        if (itsSpecificStringLength !== null
            && itsSpecificStringLength != itsStringLength
            && itsSpecificStringLength != FDBUS_DEFAULT_STRING_LENGTH) {
            return true
        }

        val itsSpecificStringLengthWidth = _accessor.getFDBusStringLengthWidth(_element)
        var itsStringLengthWidth = FDBUS_DEFAULT_LENGTH_WIDTH
        if (itsBaseAccessor !== null) {
            itsStringLengthWidth = itsBaseAccessor.getFDBusStringLengthWidth(_element)
        }
        if (itsSpecificStringLengthWidth !== null
            && itsSpecificStringLengthWidth != itsStringLengthWidth 
            && itsSpecificStringLengthWidth != FDBUS_DEFAULT_LENGTH_WIDTH) {
            return true
        }

        val itsSpecificStringEncoding = _accessor.getFDBusStringEncoding(_element)
        var itsStringEncoding = FDBUS_DEFAULT_STRING_ENCODING
        if (itsBaseAccessor !== null) {
            itsStringEncoding = itsBaseAccessor.getFDBusStringEncoding(_element)
        }
        if (itsSpecificStringEncoding !== null
            && itsSpecificStringEncoding != itsStringEncoding
            && itsSpecificStringEncoding != FDBUS_DEFAULT_STRING_ENCODING) {
            return true
        }

        val itsSpecificStructLengthWidth = _accessor.getFDBusStructLengthWidthHelper(_element)
        var itsStructLengthWidth = FDBUS_DEFAULT_STRUCT_LENGTH_WIDTH
        if (itsBaseAccessor !== null) {
            itsStructLengthWidth = itsBaseAccessor.getFDBusStructLengthWidthHelper(_element)
        }
        if (itsSpecificStructLengthWidth !== null
            && itsSpecificStructLengthWidth != itsStructLengthWidth
            && itsSpecificStructLengthWidth != FDBUS_DEFAULT_STRUCT_LENGTH_WIDTH) {
            return true
        }

        val itsSpecificUnionLengthWidth = _accessor.getFDBusUnionLengthWidthHelper(_element)
        var itsUnionLengthWidth = FDBUS_DEFAULT_LENGTH_WIDTH
        if (itsBaseAccessor !== null) {
            itsUnionLengthWidth = itsBaseAccessor.getFDBusUnionLengthWidthHelper(_element)
        }
        if (itsSpecificUnionLengthWidth !== null
            && itsSpecificUnionLengthWidth != itsUnionLengthWidth
            && itsSpecificUnionLengthWidth != FDBUS_DEFAULT_LENGTH_WIDTH) {
            return true
        }

        val itsSpecificUnionTypeWidth = _accessor.getFDBusUnionTypeWidthHelper(_element)
        var itsUnionTypeWidth = FDBUS_DEFAULT_UNION_TYPE_WIDTH
        if (itsBaseAccessor !== null) {
            itsUnionTypeWidth = itsBaseAccessor.getFDBusUnionTypeWidthHelper(_element)
        }
        if (itsSpecificUnionTypeWidth !== null
            && itsSpecificUnionTypeWidth != itsUnionTypeWidth
            && itsSpecificUnionTypeWidth != FDBUS_DEFAULT_UNION_TYPE_WIDTH) {
            return true
        }

        val itsSpecificUnionDefaultOrder = _accessor.getFDBusUnionDefaultOrderHelper(_element)
        var Boolean itsUnionDefaultOrder = FDBUS_DEFAULT_UNION_DEFAULT_ORDER
        if (itsBaseAccessor !== null) {
            itsUnionDefaultOrder = itsBaseAccessor.getFDBusUnionDefaultOrderHelper(_element)
        }
        if (itsSpecificUnionDefaultOrder !== null
            && itsSpecificUnionDefaultOrder != itsUnionDefaultOrder
            && itsSpecificUnionDefaultOrder != FDBUS_DEFAULT_UNION_DEFAULT_ORDER) {
            return true
        }

        val itsSpecificUnionMaxLength = _accessor.getFDBusUnionMaxLengthHelper(_element)
        var itsUnionMaxLength = FDBUS_DEFAULT_MAX_LENGTH
        if (itsBaseAccessor !== null) {
            itsUnionMaxLength = itsBaseAccessor.getFDBusUnionMaxLengthHelper(_element)
        }
        if (itsSpecificUnionMaxLength !== null
            && itsSpecificUnionMaxLength != itsUnionMaxLength
            && itsSpecificUnionMaxLength != FDBUS_DEFAULT_MAX_LENGTH) {
            return true
        }

        val itsSpecificEnumWidth = _accessor.getFDBusEnumWidthHelper(_element)
        var itsEnumWidth = FDBUS_DEFAULT_ENUM_WIDTH
        if (itsBaseAccessor !== null) {
            itsEnumWidth = itsBaseAccessor.getFDBusEnumWidthHelper(_element)
        }
        if (itsSpecificEnumWidth !== null
            && itsSpecificEnumWidth != itsEnumWidth
            && itsSpecificEnumWidth != FDBUS_DEFAULT_ENUM_WIDTH) {
            return true
        }

        val itsSpecificEnumBitWidth = _accessor.getFDBusEnumBitWidthHelper(_element)
        var Integer itsEnumBitWidth = null
        if (itsEnumWidth !== null) {
            itsEnumBitWidth = (itsEnumWidth << 3)
        }
        if (itsBaseAccessor !== null) {
            itsEnumBitWidth = itsBaseAccessor.getFDBusEnumBitWidthHelper(_element)
        }
        if (itsSpecificEnumBitWidth !== null
            && itsSpecificEnumBitWidth != itsEnumBitWidth
            && itsSpecificEnumBitWidth != (itsEnumWidth << 3)) {
            return true;
        }

        val itsSpecificEnumInvalidValue = _accessor.getFDBusEnumInvalidValueHelper(_element)
        var Integer itsEnumInvalidValue = null
        if (itsBaseAccessor !== null) {
            itsEnumInvalidValue = itsBaseAccessor.getFDBusEnumInvalidValueHelper(_element)
        }
        if (itsSpecificEnumInvalidValue !== null
            && itsSpecificEnumInvalidValue != itsEnumInvalidValue) {
            return true;
        }

        val itsSpecificIntegerBitWidth = _accessor.getFDBusIntegerBitWidthHelper(_element)
        var Integer itsIntegerBitWidth = null
        if (itsBaseAccessor !== null) {
            itsIntegerBitWidth = itsBaseAccessor.getFDBusIntegerBitWidthHelper(_element)
        }
        if (itsSpecificIntegerBitWidth !== null
            && itsSpecificIntegerBitWidth != itsIntegerBitWidth) {
            return !isFull(_element.type.predefined, itsSpecificIntegerBitWidth)
        }

        val itsSpecificIntegerInvalidValue = _accessor.getFDBusIntegerInvalidValueHelper(_element)
        var Integer itsIntegerInvalidValue = null
        if (itsBaseAccessor !== null) {
            itsIntegerInvalidValue = itsBaseAccessor.getFDBusIntegerInvalidValueHelper(_element)
        }
        if (itsSpecificIntegerInvalidValue !== null
            && itsSpecificIntegerInvalidValue != itsIntegerInvalidValue) {
            return true;
        }

        // also check for overwrites
        if (_accessor.isProperOverwrite()) {
            return true
        }

        return false
    }
    
    def boolean hasNonArrayDeployment(PropertyAccessor _accessor,
                                      FTypedElement _attribute) {
        if (_attribute.type.derived !== null
            && _attribute.type.derived instanceof FMapType) {
            if (hasFDBusMapMinLength(_accessor, _attribute)) {
                return true
            }
            if (hasFDBusMapMaxLength (_accessor, _attribute)) {
                return true
            }
            if (hasFDBusMapLengthWidth (_accessor, _attribute)) {
                return true
            }
        }

        if (_attribute.type.predefined !== null
            && _attribute.type.predefined == FBasicTypeId.BYTE_BUFFER) {
            if (hasFDBusByteBufferMinLength(_accessor, _attribute)) {
                return true
            }
            if (hasFDBusByteBufferMaxLength(_accessor, _attribute)) {
                return true
            }
            if (hasFDBusByteBufferLengthWidth(_accessor, _attribute)) {
                return true
            }
        }

        if (_attribute.type.predefined !== null
            && _attribute.type.predefined == FBasicTypeId.STRING) {
            if (hasFDBusStringLength (_accessor, _attribute)) {
                return true
            }
            if (hasFDBusStringLengthWidth (_accessor, _attribute)) {
                return true
            }
            if (hasFDBusStringEncoding (_accessor, _attribute)) {
                return true
            }
        }

        if (_attribute.type.derived !== null
            && _attribute.type.derived instanceof FStructType) {
            if (hasFDBusStructLengthWidth (_accessor, _attribute)) {
                return true
            }
            val struct = _attribute.type.derived as FStructType
            if (_accessor.isProperOverwrite()) {
                for (element : struct.elements) {
                    if (_accessor.hasSpecificDeployment(element)) {
                        return true
                    }
                }
            }
        }

        if (_attribute.type.derived !== null
            && _attribute.type.derived instanceof FUnionType) {
            if (hasFDBusUnionLengthWidth (_accessor, _attribute)) {
                return true
            }
            if (hasFDBusUnionTypeWidth (_accessor, _attribute)) {
                return true
            }
            if (hasFDBusUnionDefaultOrder (_accessor, _attribute)) {
                return true
            }
            if (hasFDBusUnionMaxLength (_accessor, _attribute)) {
                return true
            }
            val union = _attribute.type.derived as FUnionType
            if (_accessor.isProperOverwrite()) {
                for (element : union.elements) {
                    if (_accessor.hasSpecificDeployment(element)) {
                        return true
                    }
                }
            }
        }

        if (_attribute.type.derived !== null
            && _attribute.type.derived instanceof FEnumerationType) {
            if (hasFDBusEnumWidth(_accessor, _attribute)) {
                return true
            }
            if (hasFDBusEnumBitWidth(_accessor, _attribute)) {
                return true
            }
            if (hasFDBusEnumInvalidValue (_accessor, _attribute)) {
                return true
            }
        }

        if (_attribute.type.predefined !== null
            && (_attribute.type.predefined == FBasicTypeId.INT8
                || _attribute.type.predefined == FBasicTypeId.INT16
                || _attribute.type.predefined == FBasicTypeId.INT32
                || _attribute.type.predefined == FBasicTypeId.INT64
                || _attribute.type.predefined == FBasicTypeId.UINT8
                || _attribute.type.predefined == FBasicTypeId.UINT16
                || _attribute.type.predefined == FBasicTypeId.UINT32
                || _attribute.type.predefined == FBasicTypeId.UINT64)) {
            if (hasFDBusIntegerBitWidth (_accessor, _attribute)) {
                return true
            }
            if (hasFDBusIntegerInvalidValue (_accessor, _attribute)) {
                return true
            }
        }

        return false
    }
}
