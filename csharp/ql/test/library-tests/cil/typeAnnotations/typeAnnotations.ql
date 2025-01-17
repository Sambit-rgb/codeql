import cil
import semmle.code.csharp.commons.QualifiedName
import semmle.code.cil.Type

private string elementType(Element e, string toString) {
  exists(string namespace, string type, string name |
    toString = getQualifiedName(namespace, type, name)
  |
    e.(Method).hasFullyQualifiedName(namespace, type, name) and result = "method"
    or
    e.(Property).hasFullyQualifiedName(namespace, type, name) and result = "property"
  )
  or
  e =
    any(Parameter p |
      exists(string qualifier, string name |
        p.getDeclaringElement().hasFullyQualifiedName(qualifier, name)
      |
        toString = "Parameter " + p.getIndex() + " of " + getQualifiedName(qualifier, name)
      )
    ) and
  result = "parameter"
  or
  e =
    any(LocalVariable v |
      exists(string namespace, string type, string name |
        v.getImplementation().getMethod().hasFullyQualifiedName(namespace, type, name)
      |
        toString =
          "Local variable " + v.getIndex() + " of method " + getQualifiedName(namespace, type, name)
      )
    ) and
  result = "local"
  or
  exists(string qualifier, string name |
    e.(FunctionPointerType).hasFullyQualifiedName(qualifier, name)
  |
    toString = getQualifiedName(qualifier, name)
  ) and
  result = "fnptr"
  or
  not e instanceof Method and
  not e instanceof Property and
  not e instanceof Parameter and
  not e instanceof LocalVariable and
  not e instanceof FunctionPointerType and
  result = "other" and
  toString = e.toString()
}

private predicate exclude(string s) {
  s in [
      "Parameter 0 of Interop.libobjc.NSOperatingSystemVersion_objc_msgSend_stret",
      "Parameter 1 of Interop.procfs.TryParseStatusFile",
      "Parameter 1 of Interop.procfs.TryReadFile",
      "Parameter 1 of Interop.procfs.TryReadStatusFile",
      "Parameter 1 of System.CLRConfig.GetBoolValue",
      "Parameter 1 of System.CLRConfig.GetConfigBoolValue",
      "Parameter 1 of System.Runtime.InteropServices.ObjectiveC.ObjectiveCMarshal.CreateReferenceTrackingHandleInternal",
      "Parameter 2 of System.Runtime.InteropServices.ObjectiveC.ObjectiveCMarshal.CreateReferenceTrackingHandleInternal",
      "Parameter 2 of Interop.OSReleaseFile.<GetPrettyName>g__TryGetFieldValue|1_0",
      "Parameter 2 of System.Runtime.InteropServices.ObjectiveC.ObjectiveCMarshal.InvokeUnhandledExceptionPropagation",
      "Parameter 3 of System.IO.FileSystem.<TryCloneFile>g__TryCloneFile|5_0",
      "Parameter 3 of System.IO.FileSystem.TryCloneFile",
      "Parameter 6 of Microsoft.Win32.SafeHandles.SafeFileHandle.OpenNoFollowSymlink",
      "Local variable 1 of method Interop.libobjc.NSOperatingSystemVersion_objc_msgSend_stret",
      "Local variable 1 of method System.Diagnostics.Tracing.XplatEventLogger.LogEventSource",
      "Local variable 2 of method System.Runtime.InteropServices.ObjectiveC.ObjectiveCMarshal.CreateReferenceTrackingHandleInternal",
      "Local variable 3 of method System.Diagnostics.Tracing.XplatEventLogger.LogEventSource",
      "Local variable 4 of method System.CLRConfig.GetConfigBoolValue",
      "Local variable 4 of method System.Runtime.InteropServices.ObjectiveC.ObjectiveCMarshal.CreateReferenceTrackingHandleInternal",
      "Local variable 5 of method Interop.OSReleaseFile.<GetPrettyName>g__TryGetFieldValue|1_0",
      "Local variable 5 of method System.Diagnostics.Tracing.XplatEventLogger.LogEventSource",
      "Local variable 13 of method Interop.procfs.TryParseStatusFile",
      "Parameter 0 of System.Diagnostics.Tracing.XplatEventLogger.AppendByteArrayAsHexString",
      "Parameter 1 of System.Diagnostics.Tracing.XplatEventLogger.MinimalJsonserializer"
    ]
}

from Element e, int i, string toString, string type
where
  cil_type_annotation(e, i) and
  type = elementType(e, toString) and
  not exclude(toString) and
  (
    not e instanceof Parameter
    or
    not exists(Type t |
      t = e.(Parameter).getDeclaringElement().(Method).getDeclaringType() and
      t.hasFullyQualifiedName("System", "Environment")
    ) // There are OS specific methods in this class
  )
select toString, type, i
