// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

untypedList(List list) {
  var a = /*
   subtypes={[],[()],[(), ()],[(), (), (), ...]},
   type=List<dynamic>
  */switch (list) {
    [] /*space=<[]>*/=> 0,
    [_] /*space=<[()]>*/=> 1,
    [_, _] /*space=<[(), ()]>*/=> 2,
    [_, ..., _] /*space=<[(), ...(), ()]>*/=> 3,
  };
}

sealed class A {}
class B extends A {}
class C extends A {}

typedList(List<A> list) {
  var a = /*
   subtypes={<A>[],<A>[()],<A>[(), ()],<A>[(), (), (), ...]},
   type=List<A>
  */switch (list) {
    [] /*space=<[]>*/=> 0,
    [B b] /*space=<[B]>*/=> 1,
    [C c] /*space=<[C]>*/=> 2,
    [_, _] /*space=<[(), ()]>*/=> 3,
    [B b, ..., _] /*space=<[B, ...(), ()]>*/=> 4,
    [C c, ..., _] /*space=<[C, ...(), ()]>*/=> 5,
  };
}

restWithSubpattern(List list) {
  var a = /*
   subtypes={[...]},
   type=List<dynamic>
  */switch (list) {
    [...var l] /*space=<[...List<dynamic>]>*/=> l.length,
  };
  var b = /*
   error=non-exhaustive:[...]([0:0]: [...]),
   subtypes={[...]},
   type=List<dynamic>
  */switch (list) {
    [...List<String> l] /*space=<[...List<String>]>*/=> l.length,
  };
}

exhaustive0(List list) {
  return /*
   subtypes={[...]},
   type=List<dynamic>
  */switch (list) {
    [...] /*space=<[...()]>*/=> 0,
  };
}

exhaustive1(List list) {
  return /*
   subtypes={[],[(), ...]},
   type=List<dynamic>
  */switch (list) {
    [] /*space=<[]>*/=> 0,
    [_] /*space=<[()]>*/=> 1,
    [_, ...] /*space=<[(), ...()]>*/=> 2,
  };
}

exhaustive2(List list) {
  return /*
   subtypes={[],[()],[(), (), ...]},
   type=List<dynamic>
  */switch (list) {
    [] /*space=<[]>*/=> 0,
    [_] /*space=<[()]>*/=> 1,
    [_, _] /*space=<[(), ()]>*/=> 2,
    [_, _, ...] /*space=<[(), (), ...()]>*/=> 3,
  };
}

exhaustive3(List list) {
  return /*
   subtypes={[],[()],[(), ()],[(), (), (), ...]},
   type=List<dynamic>
  */switch (list) {
    [] /*space=<[]>*/=> 0,
    [_] /*space=<[()]>*/=> 1,
    [_, _] /*space=<[(), ()]>*/=> 2,
    [_, _, _] /*space=<[(), (), ()]>*/=> 3,
    [_, _, _, ...] /*space=<[(), (), (), ...()]>*/=> 4,
  };
}

exhaustive4(List list) {
  return /*
   subtypes={[],[()],[(), ()],[(), (), ()],[(), (), (), (), ...]},
   type=List<dynamic>
  */switch (list) {
    [] /*space=<[]>*/=> 0,
    [_] /*space=<[()]>*/=> 1,
    [_, _] /*space=<[(), ()]>*/=> 2,
    [_, _, _] /*space=<[(), (), ()]>*/=> 3,
    [_, _, _, _] /*space=<[(), (), (), ()]>*/=> 4,
    [_, _, _, _, ...] /*space=<[(), (), (), (), ...()]>*/=> 5,
  };
}

exhaustive5(List list) {
  return /*
   subtypes={[],[()],[(), ()],[(), (), ()],[(), (), (), ()],[(), (), (), (), (), ...]},
   type=List<dynamic>
  */switch (list) {
    [] /*space=<[]>*/=> 0,
    [_] /*space=<[()]>*/=> 1,
    [_, _] /*space=<[(), ()]>*/=> 2,
    [_, _, _] /*space=<[(), (), ()]>*/=> 3,
    [_, _, _, _] /*space=<[(), (), (), ()]>*/=> 4,
    [_, _, _, _, _] /*space=<[(), (), (), (), ()]>*/=> 5,
    [_, _, _, _, _, ...] /*space=<[(), (), (), (), (), ...()]>*/=> 6,
  };
}

exhaustive6(List list) {
  return /*
   subtypes={[],[()],[(), ()],[(), (), ()],[(), (), (), ()],[(), (), (), (), ()],[(), (), (), (), (), (), ...]},
   type=List<dynamic>
  */switch (list) {
    [] /*space=<[]>*/=> 0,
    [_] /*space=<[()]>*/=> 1,
    [_, _] /*space=<[(), ()]>*/=> 2,
    [_, _, _] /*space=<[(), (), ()]>*/=> 3,
    [_, _, _, _] /*space=<[(), (), (), ()]>*/=> 4,
    [_, _, _, _, _] /*space=<[(), (), (), (), ()]>*/=> 5,
    [_, _, _, _, _, _] /*space=<[(), (), (), (), (), ()]>*/=> 6,
    [_, _, _, _, _, _, ...] /*space=<[(), (), (), (), (), (), ...()]>*/=> 7,
  };
}

exhaustive7(List list) {
  return /*
   subtypes={[],[()],[(), ()],[(), (), ()],[(), (), (), ()],[(), (), (), (), ()],[(), (), (), (), (), ()],[(), (), (), (), (), (), (), ...]},
   type=List<dynamic>
  */switch (list) {
    [] /*space=<[]>*/=> 0,
    [_] /*space=<[()]>*/=> 1,
    [_, _] /*space=<[(), ()]>*/=> 2,
    [_, _, _] /*space=<[(), (), ()]>*/=> 3,
    [_, _, _, _] /*space=<[(), (), (), ()]>*/=> 4,
    [_, _, _, _, _] /*space=<[(), (), (), (), ()]>*/=> 5,
    [_, _, _, _, _, _] /*space=<[(), (), (), (), (), ()]>*/=> 6,
    [_, _, _, _, _, _, _] /*space=<[(), (), (), (), (), (), ()]>*/=> 7,
    [_, _, _, _, _, _, _, ...] /*space=<[(), (), (), (), (), (), (), ...()]>*/=> 8,
  };
}

exhaustive8(List list) {
  return /*
   subtypes={[],[()],[(), ()],[(), (), ()],[(), (), (), ()],[(), (), (), (), ()],[(), (), (), (), (), ()],[(), (), (), (), (), (), ()],[(), (), (), (), (), (), (), (), ...]},
   type=List<dynamic>
  */switch (list) {
    [] /*space=<[]>*/=> 0,
    [_] /*space=<[()]>*/=> 1,
    [_, _] /*space=<[(), ()]>*/=> 2,
    [_, _, _] /*space=<[(), (), ()]>*/=> 3,
    [_, _, _, _] /*space=<[(), (), (), ()]>*/=> 4,
    [_, _, _, _, _] /*space=<[(), (), (), (), ()]>*/=> 5,
    [_, _, _, _, _, _] /*space=<[(), (), (), (), (), ()]>*/=> 6,
    [_, _, _, _, _, _, _] /*space=<[(), (), (), (), (), (), ()]>*/=> 7,
    [_, _, _, _, _, _, _, _] /*space=<[(), (), (), (), (), (), (), ()]>*/=> 8,
    [_, _, _, _, _, _, _, _, ...] /*space=<[(), (), (), (), (), (), (), (), ...()]>*/=> 9,
  };
}

exhaustive2Mid(List list) {
  return /*
   subtypes={[],[()],[(), ()],[(), (), (), ...]},
   type=List<dynamic>
  */switch (list) {
    [] /*space=<[]>*/=> 0,
    [_] /*space=<[()]>*/=> 1,
    [_, _] /*space=<[(), ()]>*/=> 2,
    [_, ..., _] /*space=<[(), ...(), ()]>*/=> 3,
  };
}

exhaustive2End(List list) {
  return /*
   subtypes={[],[()],[(), ()],[(), (), ()],[(), (), (), (), ...]},
   type=List<dynamic>
  */switch (list) {
    [] /*space=<[]>*/=> 0,
    [_] /*space=<[()]>*/=> 1,
    [_, _] /*space=<[(), ()]>*/=> 2,
    [..., _, _] /*space=<[...(), (), ()]>*/=> 3,
  };
}

exhaustiveRestWithExtraElement(List list) {
  return /*
   subtypes={[],[()],[(), ()],[(), (), ()],[(), (), (), (), ...]},
   type=List<dynamic>
  */switch (list) {
    [] /*space=<[]>*/=> 0,
    [_] /*space=<[()]>*/=> 1,
    [_, _] /*space=<[(), ()]>*/=> 2,
    [_, _, _] /*space=<[(), (), ()]>*/=> 3,
    [_, _, _, _, ...] /*space=<[(), (), (), (), ...()]>*/=> 4,
  };
}

nonExhaustiveNoRest(List list) {
  return /*
   error=non-exhaustive:[(), (), (), ...],
   subtypes={[],[()],[(), ()],[(), (), (), ...]},
   type=List<dynamic>
  */switch (list) {
    [] /*space=<[]>*/=> 0,
    [_] /*space=<[()]>*/=> 1,
    [_, _] /*space=<[(), ()]>*/=> 2,
    [_, _, _] /*space=<[(), (), ()]>*/=> 3,
  };
}

nonExhaustiveTyped(List list) {
  return /*
   error=non-exhaustive:[(), ()],
   subtypes={[],[()],[(), ()],[(), (), (), ...]},
   type=List<dynamic>
  */switch (list) {
    [] /*space=<[]>*/=> 0,
    [_] /*space=<[()]>*/=> 1,
    <int>[_, _] /*space=<int>[(), ()]*/=> 2,
    [_, _, _] /*space=<[(), (), ()]>*/=> 3,
    [_, _, _, ...] /*space=<[(), (), (), ...()]>*/=> 7,
  };
}

nonExhaustiveRestrictedHeadElement(List list) {
  return /*
   error=non-exhaustive:[(), ()]([0]: Object, [1]: Object),
   subtypes={[],[()],[(), ()],[(), (), (), ...]},
   type=List<dynamic>
  */switch (list) {
    [] /*space=<[]>*/=> 0,
    [_] /*space=<[()]>*/=> 1,
    [_, 1] /*space=<[(), 1]>*/=> 2,
    [_, _, _] /*space=<[(), (), ()]>*/=> 3,
    [_, _, _, ...] /*space=<[(), (), (), ...()]>*/=> 8,
  };
}

nonExhaustiveRestrictedTailElement(List list) {
  return /*
   error=non-exhaustive:[(), (), (), ()]([0]: Object, [1:-2]: [...], [-1]: Object, [-2]: Object),
   subtypes={[],[()],[(), ()],[(), (), ()],[(), (), (), ()],[(), (), (), (), (), ...]},
   type=List<dynamic>
  */switch (list) {
    [] /*space=<[]>*/=> 0,
    [_] /*space=<[()]>*/=> 1,
    [_, _] /*space=<[(), ()]>*/=> 2,
    [_, _, _] /*space=<[(), (), ()]>*/=> 3,
    [_, ..., 1, _] /*space=<[(), ...(), (), 1]>*/=> 8,
  };
}

nonExhaustiveRestrictedRest(List list) {
  return /*
   error=non-exhaustive:[(), (), (), ...]([0]: Object, [1]: Object, [2]: Object, [3:0]: [...]),
   subtypes={[],[()],[(), ()],[(), (), (), ...]},
   type=List<dynamic>
  */switch (list) {
    [] /*space=<[]>*/=> 0,
    [_] /*space=<[()]>*/=> 1,
    [_, _] /*space=<[(), ()]>*/=> 2,
    [_, _, _] /*space=<[(), (), ()]>*/=> 3,
    [_, _, _, ...List<int> rest] /*space=<[(), (), (), ...List<int>]>*/=> 8,
  };
}

nonExhaustiveRestrictedRestWithTail(List list) {
  return /*
   error=non-exhaustive:[(), (), (), ()]([0]: Object, [1:-2]: [...], [-1]: Object, [-2]: Object),
   subtypes={[],[()],[(), ()],[(), (), ()],[(), (), (), ()],[(), (), (), (), (), ...]},
   type=List<dynamic>
  */switch (list) {
    [] /*space=<[]>*/=> 0,
    [_] /*space=<[()]>*/=> 1,
    [_, _] /*space=<[(), ()]>*/=> 2,
    [_, _, _] /*space=<[(), (), ()]>*/=> 3,
    [_, ...List<int> rest, _, _] /*space=<[(), ...List<int>, (), ()]>*/=> 8,
  };
}

nonExhaustiveMissingCount(List list) {
  return /*
   error=non-exhaustive:[(), ()],
   subtypes={[],[()],[(), ()],[(), (), (), ...]},
   type=List<dynamic>
  */switch (list) {
    [] /*space=<[]>*/=> 0,
    [_] /*space=<[()]>*/=> 1,
    [_, _, _] /*space=<[(), (), ()]>*/=> 3,
    [_, _, _, ...] /*space=<[(), (), (), ...()]>*/=> 9,
  };
}

unreachableAfterRestOnly(List list) {
  return /*
   subtypes={[],[(), ...]},
   type=List<dynamic>
  */switch (list) {
    [...] /*space=<[...()]>*/=> 0,
    [_] /*
     error=unreachable,
     space=<[()]>
    */=> 1,
  };
}

unreachableAfterRest(List list) {
  return /*
   subtypes={[],[(), ...]},
   type=List<dynamic>
  */switch (list) {
    [_, ...] /*space=<[(), ...()]>*/=> 0,
    [_] /*
     error=unreachable,
     space=<[()]>
    */=> 1,
    [...] /*space=<[...()]>*/=> 2,
  };
}

nonExhaustiveAfterRest(List list) {
  return /*
   error=non-exhaustive:[],
   subtypes={[],[(), ...]},
   type=List<dynamic>
  */switch (list) {
    [_, ...] /*space=<[(), ...()]>*/=> 0,
    [_] /*
     error=unreachable,
     space=<[()]>
    */=> 1,
  };
}

exhaustiveSealed(List<A> list) {
  return /*
   subtypes={<A>[],<A>[()],<A>[(), (), ...]},
   type=List<A>
  */switch (list) {
    [] /*space=<[]>*/=> 0,
    [B()] /*space=<[B]>*/=> 1,
    [C()] /*space=<[C]>*/=> 2,
    [_, _, ...] /*space=<[(), (), ...()]>*/=> 3,
  };
}

nonExhaustiveSealed(List<A> list) {
  return /*
   error=non-exhaustive:<A>[()]([0]: C),
   subtypes={<A>[],<A>[()],<A>[(), (), ...]},
   type=List<A>
  */switch (list) {
    [] /*space=<[]>*/=> 0,
    [B()] /*space=<[B]>*/=> 1,
    [_, _, ...] /*space=<[(), (), ...()]>*/=> 3,
  };
}

reachableRest(List<A> list) {
  return /*
   subtypes={<A>[],<A>[()],<A>[(), (), ...]},
   type=List<A>
  */switch (list) {
    [] /*space=<[]>*/=> 0,
    [B(), ...] /*space=<[B, ...()]>*/=> 1,
    [..., B()] /*space=<[...(), B]>*/=> 2,
    [C(), ...] /*space=<[C, ...()]>*/=> 3,
    [..., C()] /*space=<[...(), C]>*/=> 4,
  };
}
