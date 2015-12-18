// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Converters and codecs for converting between JSON and [Info] classes.
part of dart2js_info.info;

// TODO(sigmund): add unit tests.
class JsonToAllInfoConverter extends Converter<Map, AllInfo> {
  Map<String, Info> registry;

  AllInfo convert(Map json) {
    registry = <String, Info>{};

    var result = new AllInfo();
    var elements = json['elements'];
    result.libraries.addAll(elements['library'].values.map(parseLibrary));
    result.classes.addAll(elements['class'].values.map(parseClass));
    result.functions.addAll(elements['function'].values.map(parseFunction));
    result.fields.addAll(elements['field'].values.map(parseField));
    result.typedefs.addAll(elements['typedef'].values.map(parseTypedef));

    // TODO(sigmund): remove null check on next breaking version
    var constants = elements['constant'];
    if (constants != null) {
      result.constants.addAll(constants.values.map(parseConstant));
    }

    var idMap = {};
    for (var f in result.functions) {
      idMap[f.serializedId] = f;
    }
    for (var f in result.fields) {
      idMap[f.serializedId] = f;
    }

    json['holding'].forEach((k, deps) {
      var src = idMap[k];
      assert(src != null);
      for (var dep in deps) {
        var target = idMap[dep['id']];
        assert(target != null);
        src.uses.add(new DependencyInfo(target, dep['mask']));
      }
    });

    json['dependencies']?.forEach((k, deps) {
      result.dependencies[idMap[k]] = deps.map((d) => idMap[d]).toList();
    });

    result.outputUnits.addAll(json['outputUnits'].map(parseOutputUnit));

    result.program = parseProgram(json['program']);
    // todo: version, etc
    return result;
  }

  OutputUnitInfo parseOutputUnit(Map json) {
    OutputUnitInfo result = parseId(json['id']);
    result
      ..name = json['name']
      ..size = json['size'];
    result.imports.addAll(json['imports'] ?? const []);
    return result;
  }

  LibraryInfo parseLibrary(Map json) {
    LibraryInfo result = parseId(json['id']);
    result
      ..name = json['name']
      ..uri = Uri.parse(json['canonicalUri'])
      ..outputUnit = parseId(json['outputUnit'])
      ..size = json['size'];
    for (var child in json['children'].map(parseId)) {
      if (child is FunctionInfo) {
        result.topLevelFunctions.add(child);
      } else if (child is FieldInfo) {
        result.topLevelVariables.add(child);
      } else if (child is ClassInfo) {
        result.classes.add(child);
      } else {
        assert(child is TypedefInfo);
        result.typedefs.add(child);
      }
    }
    return result;
  }

  ClassInfo parseClass(Map json) {
    ClassInfo result = parseId(json['id']);
    result
      ..name = json['name']
      ..parent = parseId(json['parent'])
      ..outputUnit = parseId(json['outputUnit'])
      ..size = json['size']
      ..isAbstract = json['modifiers']['abstract'] == true;
    assert(result is ClassInfo);
    for (var child in json['children'].map(parseId)) {
      if (child is FunctionInfo) {
        result.functions.add(child);
      } else {
        assert(child is FieldInfo);
        result.fields.add(child);
      }
    }
    return result;
  }

  FieldInfo parseField(Map json) {
    FieldInfo result = parseId(json['id']);
    return result
      ..name = json['name']
      ..parent = parseId(json['parent'])
      ..coverageId = json['coverageId']
      ..outputUnit = parseId(json['outputUnit'])
      ..size = json['size']
      ..type = json['type']
      ..inferredType = json['inferredType']
      ..code = json['code']
      ..isConst = json['const'] ?? false
      ..initializer = parseId(json['initializer'])
      ..closures = json['children'].map(parseId).toList();
  }

  ConstantInfo parseConstant(Map json) {
    ConstantInfo result = parseId(json['id']);
    return result
      ..code = json['code']
      ..size = json['size'];
  }

  TypedefInfo parseTypedef(Map json) {
    TypedefInfo result = parseId(json['id']);
    return result
      ..name = json['name']
      ..parent = parseId(json['parent'])
      ..type = json['type']
      ..size = 0;
  }

  ProgramInfo parseProgram(Map json) => new ProgramInfo()
    ..size = json['size']
    ..entrypoint = parseId(json['entrypoint']);

  FunctionInfo parseFunction(Map json) {
    FunctionInfo result = parseId(json['id']);
    return result
      ..name = json['name']
      ..parent = parseId(json['parent'])
      ..coverageId = json['coverageId']
      ..outputUnit = parseId(json['outputUnit'])
      ..size = json['size']
      ..type = json['type']
      ..returnType = json['returnType']
      ..inferredReturnType = json['inferredReturnType']
      ..parameters = json['parameters'].map(parseParameter).toList()
      ..code = json['code']
      ..sideEffects = json['sideEffects']
      ..modifiers = parseModifiers(json['modifiers'])
      ..closures = json['children'].map(parseId).toList()
      ..measurements = parseMeasurements(json['measurements']);
  }

  ParameterInfo parseParameter(Map json) =>
      new ParameterInfo(json['name'], json['type'], json['declaredType']);

  Measurements parseMeasurements(Map json) {
    if (json == null) return null;
    var uri = json['sourceFile'];
    var res = new Measurements(uri == null ? null : Uri.parse(uri));
    for (var key in json.keys) {
      var value = json[key];
      if (value == null) continue;
      if (key == 'entries') {
        value.forEach((metricName, entries) {
          var metric = new Metric.fromName(metricName);
          for (var i = 0; i < entries.length; i += 2) {
            res.record(metric, entries[i], entries[i + 1]);
          }
        });
      } else {
        res.counters[new Metric.fromName(key)] = value;
      }
    }
    return res;
  }

  FunctionModifiers parseModifiers(Map<String, bool> json) {
    return new FunctionModifiers(
        isStatic: json['static'] == true,
        isConst: json['const'] == true,
        isFactory: json['factory'] == true,
        isExternal: json['external'] == true);
  }

  Info parseId(String serializedId) => registry.putIfAbsent(serializedId, () {
        if (serializedId == null) {
          return null;
        } else if (serializedId.startsWith('function/')) {
          return new FunctionInfo._(serializedId);
        } else if (serializedId.startsWith('library/')) {
          return new LibraryInfo._(serializedId);
        } else if (serializedId.startsWith('class/')) {
          return new ClassInfo._(serializedId);
        } else if (serializedId.startsWith('field/')) {
          return new FieldInfo._(serializedId);
        } else if (serializedId.startsWith('constant/')) {
          return new ConstantInfo._(serializedId);
        } else if (serializedId.startsWith('typedef/')) {
          return new TypedefInfo._(serializedId);
        } else if (serializedId.startsWith('outputUnit/')) {
          return new OutputUnitInfo._(serializedId);
        }
        assert(false);
      });
}

class AllInfoToJsonConverter extends Converter<AllInfo, Map>
    implements InfoVisitor<Map> {
  Map convert(AllInfo info) => info.accept(this);

  Map _visitList(List<Info> infos) {
    var map = <String, Map>{};
    for (var info in infos) {
      map['${info.id}'] = info.accept(this);
    }
    return map;
  }

  Map _visitAllInfoElements(AllInfo info) {
    var jsonLibraries = _visitList(info.libraries);
    var jsonClasses = _visitList(info.classes);
    var jsonFunctions = _visitList(info.functions);
    var jsonTypedefs = _visitList(info.typedefs);
    var jsonFields = _visitList(info.fields);
    var jsonConstants = _visitList(info.constants);
    return {
      'library': jsonLibraries,
      'class': jsonClasses,
      'function': jsonFunctions,
      'typedef': jsonTypedefs,
      'field': jsonFields,
      'constant': jsonConstants
    };
  }

  Map _visitDependencyInfo(DependencyInfo info) =>
      {'id': info.target.serializedId, 'mask': info.mask};

  Map _visitAllInfoHolding(AllInfo allInfo) {
    var map = <String, List>{};
    void helper(CodeInfo info) {
      if (info.uses.isEmpty) return;
      map[info.serializedId] =
          info.uses.map((u) => _visitDependencyInfo(u)).toList();
    }
    allInfo.functions.forEach(helper);
    allInfo.fields.forEach(helper);
    return map;
  }

  Map _visitAllInfoDependencies(AllInfo allInfo) {
    var map = <String, List>{};
    allInfo.dependencies.forEach((k, v) {
      map[k.serializedId] = v.map((i) => i.serializedId).toList();
    });
    return map;
  }

  Map visitAll(AllInfo info) {
    var elements = _visitAllInfoElements(info);
    var jsonHolding = _visitAllInfoHolding(info);
    var jsonDependencies = _visitAllInfoDependencies(info);
    return {
      'elements': elements,
      'holding': jsonHolding,
      'dependencies': jsonDependencies,
      'outputUnits': info.outputUnits.map((u) => u.accept(this)).toList(),
      'dump_version': info.version,
      'deferredFiles': info.deferredFiles,
      'dump_minor_version': '${info.minorVersion}',
      'program': info.program.accept(this)
    };
  }

  Map visitProgram(ProgramInfo info) {
    return {
      'entrypoint': info.entrypoint.serializedId,
      'size': info.size,
      'dart2jsVersion': info.dart2jsVersion,
      'compilationMoment': '${info.compilationMoment}',
      'compilationDuration': '${info.compilationDuration}',
      'toJsonDuration': info.toJsonDuration,
      'dumpInfoDuration': '${info.dumpInfoDuration}',
      'noSuchMethodEnabled': info.noSuchMethodEnabled,
      'minified': info.minified,
    };
  }

  Map _visitBasicInfo(BasicInfo info) {
    var res = {
      'id': info.serializedId,
      'kind': kindToString(info.kind),
      'name': info.name,
      'size': info.size,
    };
    // TODO(sigmund): Omit this also when outputUnit.id == 0 (most code is in
    // the main output unit by default).
    if (info.outputUnit != null) res['outputUnit'] =
        info.outputUnit.serializedId;
    if (info.coverageId != null) res['coverageId'] = info.coverageId;
    if (info.parent != null) res['parent'] = info.parent.serializedId;
    return res;
  }

  Map visitLibrary(LibraryInfo info) {
    return _visitBasicInfo(info)
      ..addAll({
        'children': []
          ..addAll(info.topLevelFunctions.map((f) => f.serializedId))
          ..addAll(info.topLevelVariables.map((v) => v.serializedId))
          ..addAll(info.classes.map((c) => c.serializedId))
          ..addAll(info.typedefs.map((t) => t.serializedId)),
        'canonicalUri': '${info.uri}',
      });
  }

  Map visitClass(ClassInfo info) {
    return _visitBasicInfo(info)
      ..addAll({
        // TODO(sigmund): change format, include only when abstract is true.
        'modifiers': {'abstract': info.isAbstract},
        'children': []
          ..addAll(info.fields.map((f) => f.serializedId))
          ..addAll(info.functions.map((m) => m.serializedId))
      });
  }

  Map visitField(FieldInfo info) {
    var result = _visitBasicInfo(info)
      ..addAll({
        'children': info.closures.map((i) => i.serializedId).toList(),
        'inferredType': info.inferredType,
        'code': info.code,
        'type': info.type,
      });
    if (info.isConst) {
      result['const'] = true;
      if (info.initializer != null) result['initializer'] =
          info.initializer.serializedId;
    }
    return result;
  }

  Map visitConstant(ConstantInfo info) =>
      _visitBasicInfo(info)..addAll({'code': info.code});

  // TODO(sigmund): exclude false values (requires bumping the format version):
  //     var res = <String, bool>{};
  //     if (isStatic) res['static'] = true;
  //     if (isConst) res['const'] = true;
  //     if (isFactory) res['factory'] = true;
  //     if (isExternal) res['external'] = true;
  //     return res;
  Map _visitFunctionModifiers(FunctionModifiers mods) => {
        'static': mods.isStatic,
        'const': mods.isConst,
        'factory': mods.isFactory,
        'external': mods.isExternal,
      };

  Map _visitParameterInfo(ParameterInfo info) =>
      {'name': info.name, 'type': info.type, 'declaredType': info.declaredType};

  String _visitMetric(Metric metric) => metric.name;

  Map _visitMeasurements(Measurements measurements) {
    if (measurements == null) return null;
    var jsonEntries = <String, List<Map>>{};
    measurements.entries.forEach((metric, values) {
      jsonEntries[_visitMetric(metric)] =
          values.expand((e) => [e.begin, e.end]).toList();
    });
    var json = {'entries': jsonEntries};
    // TODO(sigmund): encode uri as an offset of the URIs available in the parts
    // of the library info.
    if (measurements.uri != null) json['sourceFile'] = '${measurements.uri}';
    if (measurements.counters[Metric.functions] != null) {
      json[_visitMetric(Metric.functions)] =
          measurements.counters[Metric.functions];
    }
    if (measurements.counters[Metric.reachableFunctions] != null) {
      json[_visitMetric(Metric.reachableFunctions)] =
          measurements.counters[Metric.reachableFunctions];
    }
    return json;
  }

  Map visitFunction(FunctionInfo info) {
    return _visitBasicInfo(info)
      ..addAll({
        'children': info.closures.map((i) => i.serializedId).toList(),
        'modifiers': _visitFunctionModifiers(info.modifiers),
        'returnType': info.returnType,
        'inferredReturnType': info.inferredReturnType,
        'parameters':
            info.parameters.map((p) => _visitParameterInfo(p)).toList(),
        'sideEffects': info.sideEffects,
        'inlinedCount': info.inlinedCount,
        'code': info.code,
        'type': info.type,
        'measurements': _visitMeasurements(info.measurements),
        // Note: version 3.2 of dump-info serializes `uses` in a section called
        // `holding` at the top-level.
      });
  }

  visitTypedef(TypedefInfo info) => _visitBasicInfo(info)..['type'] = info.type;

  visitOutput(OutputUnitInfo info) =>
      _visitBasicInfo(info)..['imports'] = info.imports;
}

class AllInfoJsonCodec extends Codec<AllInfo, Map> {
  final Converter<AllInfo, Map> encoder = new AllInfoToJsonConverter();
  final Converter<Map, AllInfo> decoder = new JsonToAllInfoConverter();
}
