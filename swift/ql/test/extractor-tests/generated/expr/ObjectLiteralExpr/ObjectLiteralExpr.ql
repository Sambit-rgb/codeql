// generated by codegen/codegen.py
import codeql.swift.elements
import TestUtils

from ObjectLiteralExpr x, int getKind
where
  toBeTested(x) and
  not x.isUnknown() and
  getKind = x.getKind()
select x, "getKind:", getKind