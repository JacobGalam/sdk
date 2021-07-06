// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analysis_server/src/services/correction/fix.dart';
import 'package:analysis_server/src/services/linter/lint_names.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'fix_processor.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AddConst_PreferConstConstructorsBulkTest);
    defineReflectiveTests(AddConst_PreferConstConstructorsInImmutablesBulkTest);
    defineReflectiveTests(AddConst_PreferConstConstructorsInImmutablesTest);
    defineReflectiveTests(AddConst_PreferConstConstructorsTest);
  });
}

@reflectiveTest
class AddConst_PreferConstConstructorsBulkTest extends BulkFixProcessorTest {
  @override
  String get lintCode => LintNames.prefer_const_constructors;

  /// Disabled in BulkFixProcessor.
  @failingTest
  Future<void> test_noKeyword() async {
    writeTestPackageConfig(meta: true);
    await resolveTestCode(r'''
class C {
  const C([C c]);
}
var c = C(C());
''');
    // TODO (pq): results are incompatible w/ `unnecessary_const`
    await assertHasFix(r'''
class C {
  const C([C c]);
}
var c = const C(const C());
''');
  }
}

@reflectiveTest
class AddConst_PreferConstConstructorsInImmutablesBulkTest
    extends BulkFixProcessorTest {
  @override
  String get lintCode => LintNames.prefer_const_constructors_in_immutables;

  Future<void> test_multipleConstructors() async {
    writeTestPackageConfig(meta: true);
    await resolveTestCode('''
import 'package:meta/meta.dart';

@immutable
class A {
  A();
  /// Comment.
  A.a();
}
''');
    await assertHasFix('''
import 'package:meta/meta.dart';

@immutable
class A {
  const A();
  /// Comment.
  const A.a();
}
''');
  }
}

@reflectiveTest
class AddConst_PreferConstConstructorsInImmutablesTest
    extends FixProcessorLintTest {
  @override
  FixKind get kind => DartFixKind.ADD_CONST;

  @override
  String get lintCode => LintNames.prefer_const_constructors_in_immutables;

  @override
  void setUp() {
    super.setUp();
    writeTestPackageConfig(
      meta: true,
    );
  }

  Future<void> test_default() async {
    await resolveTestCode('''
import 'package:meta/meta.dart';

@immutable
class A {
  A();
}
''');
    await assertHasFix('''
import 'package:meta/meta.dart';

@immutable
class A {
  const A();
}
''');
  }

  Future<void> test_default_withComment() async {
    await resolveTestCode('''
import 'package:meta/meta.dart';

@immutable
class A {
  /// Comment.
  A();
}
''');
    await assertHasFix('''
import 'package:meta/meta.dart';

@immutable
class A {
  /// Comment.
  const A();
}
''');
  }
}

@reflectiveTest
class AddConst_PreferConstConstructorsTest extends FixProcessorLintTest {
  @override
  FixKind get kind => DartFixKind.ADD_CONST;

  @override
  String get lintCode => LintNames.prefer_const_constructors;

  Future<void> test_new() async {
    await resolveTestCode('''
class C {
  const C();
}
void f() {
  var c = new C();
  print(c);
}
''');
    // handled by REPLACE_NEW_WITH_CONST
    await assertNoFix();
  }

  Future<void> test_noKeyword() async {
    await resolveTestCode('''
class C {
  const C();
}
void f() {
  var c = C();
  print(c);
}
''');
    await assertHasFix('''
class C {
  const C();
}
void f() {
  var c = const C();
  print(c);
}
''');
  }
}
