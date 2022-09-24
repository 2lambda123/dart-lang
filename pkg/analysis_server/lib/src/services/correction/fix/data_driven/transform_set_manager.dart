// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analysis_server/src/services/correction/fix/data_driven/transform_set.dart';
import 'package:analysis_server/src/services/correction/fix/data_driven/transform_set_parser.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/file_system/file_system.dart';

/// An object used to manage the transform sets.
class TransformSetManager {
  /// The single instance of this class.
  static final TransformSetManager instance = TransformSetManager._();

  /// The name of the data file.
  static const String dataFileName = 'fix_data.yaml';

  /// The name of the data folder.
  static const String dataFolderName = 'fix_data';

  /// Initialize a newly created transform set manager.
  TransformSetManager._();

  /// Return the transform sets associated with the [library].
  List<TransformSet> forLibrary(LibraryElement library) {
    var transformSets = <TransformSet>[];
    var analysisContext = library.session.analysisContext;
    var workspace = analysisContext.contextRoot.workspace;
    var libraryPath = library.source.fullName;
    var package = workspace.findPackageFor(libraryPath);
    if (package == null) {
      return transformSets;
    }
    var packages = package.packagesAvailableTo(libraryPath);
    for (var package in packages.packages) {
      var directory = package.libFolder;
      var file = directory.getChildAssumingFile(dataFileName);
      var transformSet = _loadTransformSet(file);
      if (transformSet != null) {
        transformSets.add(transformSet);
      }
      var folder = directory.getChildAssumingFolder(dataFolderName);
      if (folder.exists) {
        _loadTransforms(transformSets, folder);
      }
    }
    var sdkRoot = analysisContext.sdkRoot;
    if (sdkRoot != null) {
      var file = sdkRoot.getChildAssumingFile('lib/_internal/$dataFileName');
      var transformSet = _loadTransformSet(file);
      if (transformSet != null) {
        transformSets.add(transformSet);
      }
    }
    return transformSets;
  }

  /// Recursively search all the children of the specified [folder],
  /// and add the transform sets found to the [transforms].
  void _loadTransforms(List<TransformSet> transforms, Folder folder) {
    for (var resource in folder.getChildren()) {
      if (resource is File) {
        if (resource.shortName.endsWith('.yaml')) {
          var transformSet = _loadTransformSet(resource);
          if (transformSet != null) {
            transforms.add(transformSet);
          }
        }
      } else if (resource is Folder) {
        _loadTransforms(transforms, resource);
      }
    }
  }

  /// Read the [file] and parse the content. Return the transform set that was
  /// parsed, or `null` if the file doesn't exist, isn't readable, or if the
  /// content couldn't be parsed.
  TransformSet? _loadTransformSet(File file) {
    try {
      // TODO(brianwilkerson) Consider caching the transform sets.
      var content = file.readAsStringSync();
      var parser = TransformSetParser(
          ErrorReporter(
            AnalysisErrorListener.NULL_LISTENER,
            file.createSource(),
            isNonNullableByDefault: false,
          ),
          file.parent.parent.shortName);
      return parser.parse(content);
    } on FileSystemException {
      // Fall through to return `null`.
    }
    return null;
  }
}
