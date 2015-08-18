# Dart2js Info

This package contains libraries and tools you can use to process `.info.json`
files, which are produced when running dart2js with `--dump-info`.

The `.info.json` files contain data about each element included in
the output of your program. The data includes information such as:

  * the size that each function adds to the `.dart.js` output,
  * dependencies between functions,
  * how the code is clustered when using deferred libraries, and
  * the declared and inferred type of each function argument.

All of this information can help you understand why some piece of code is
included in your compiled application, and how far was dart2js able to
understand your code. This data can help you make changes to improve the quality
and size of your framework or app.

This package focuses on gathering libraries and tools that summarize all of that
information. Bear in mind that even with all these tools, it is not trivial to
isolate code-size issues. We just hope that these tools make things a bit
earier.

## Status

[![Build Status](https://travis-ci.org/dart-lang/dart2js_info.svg)](https://travis-ci.org/dart-lang/dart2js_info)

Currently, most tools available here can be used to analyze code-size and
attibution of code-size to different parts of your app. With time, we hope to
add more data to the `.info.json` files, and include better tools to help
understand the results of type inference.

This package is still in flux and we might make breaking changes at any time.
Our current goal is not to provide a stable API, we mainly want to expose the
functionality and iterate on it.  We recommend that you pin a specific version
of this package and update when needed.

## Info API

[AllInfo][AllInfo] exposes a Dart representation of the `.info.json` files.
You can parse the information using `AllInfo.parseFromJson`. For example:

```dart
import 'dart:convert';
import 'dart:io';

import 'package:dart2js_info/info.dart';

main(args) {
  var infoPath = args[0];
  var json = JSON.decode(new File(infoPath).readAsStringSync());
  var info = AllInfo.parseFromJson(json);
  ...
```

## Available tools

The following tools are a available today:

  * [`code_deps.dart`][code_deps]: simple tool that can answer queries about the
    dependency between functions and fields in your program. Currently it only
    supports the `some_path` query, which shows a dependency path from one
    function to another.

  * [`library_size_split`][lib_split]: a tool that shows how much code was
    attributed to each library. This tool is configurable so it can group data
    in many ways (e.g. to tally together all libraries that belong to a package,
    or all libraries that match certain name pattern).

  * [`function_size_analysis`][function_analysis]: a tool that shows how much
    code was attributed to each function. This tool also uses depedency
    information to compute dominance and reachability data. This information can
    sometimes help determine how much savings could come if the function was not
    included in the program.

  * [`coverage_log_server`][coverage] and [`live_code_size_analysis`][live]:
    dart2js has an experimental feature to gather coverage data of your
    application. The `coverage_log_server` can record this data, and
    `live_code_size_analysis` can correlate that with the `.info.json`, so you
    determine why code that is not used is being included in your app.

Next we describe in detail how to use each of these tools.

### Code deps tool

This command-line tool can be used to query for code dependencies. Currently
this tool only supports the `some_path` query, which gives you the shortest path
for how one function depends on another.

Run this tool as follows:
```bash
pub global activate dart2js_info # only needed once
pub global run dart2js_info:code_deps out.js.info.json some_path main foo
```

The arguments to the query are regular expressions that can be used to
select a single element in your program. If your regular expression is too
general and has more than one match, this tool will pick
the first match and ignore the rest. Regular expressions are matched against
a fully qualified element name, which includes the library and class name
(if any) that contains it. A typical qualified name is of this form:

    libraryName::ClassName.elementName

If the name of a function your are looking for is unique enough, it might be
sufficient to just write that name as your regular expression.

### Library size split tool

This command-line tool shows the size distribution of generated code among
libraries. It can be run as follows:

```bash
pub global activate dart2js_info # only needed once
pub global run dart2js_info:library_size_split out.js.info.json
```


Libraries can be grouped using regular expressions. You can
specify what regular expressions to use by providing a `grouping.yaml` file:

```bash
pub global run dart2js_info:library_size_split out.js.info.json grouping.yaml
```

The format of the `grouping.yaml` file is as follows:

```yaml
groups:
- { regexp: "package:(foo)/*.dart", name: "group name 1", cluster: 2}
- { regexp: "dart:.*",              name: "group name 2", cluster: 3}
```

The file should include a single key `groups` containing a list of group
specifications.  Each group is specified by a map of 3 entries:

  * `regexp` (required): a regexp used to match entries that belong to the
  group.

  * `name` (optional): the name given to this group in the output table. If
  omitted, the name is derived from the regexp as the match's group(1) or
  group(0) if no group was defined. When names are omitted the group
  specification implicitly defines several groups, one per observed name.

  * `cluster` (optional): a clustering index for how data is shown in a table.
  Groups with higher cluster indices are shown later in the table after a
  dividing line. If missing, the cluster index defaults to 0.

Here is an example configuration, with comments about what each entry does:

```yaml
groups:
# This group shows the total size of all libraries together, it is shown in
# cluster #3, which happens to be the last cluster in this example:
- name: "Total (excludes preambles, statics & consts)"
  regexp: ".*"
  cluster: 3

# This group shows the total size for all libraries that were loaded from
# file:// urls:
- { name: "Loose files", regexp: "file://.*", cluster: 2}

# This group shows the total size of all code loaded from packages:
- { name: "All packages", regexp: "package:.*", cluster: 2}

# This group shows the total size of all code loaded from core libraries:
- { name: "Core libs", regexp: "dart:.*", cluster: 2}

# This group shows the total size of all libraries in a single package. Here
# we omitted the `name` entry, instead we extract it from the regexp
# directly.  In this case, the name will be the package-name portion of the
# package-url (determined by group(1) of the regexp).
- { regexp: "package:([^/]*)", cluster: 1}

# The next two groups match the entire library url as the name of the group.
- regexp: "package:.*"
- regexp: "dart:.*"

# If your code lives under /my/project/dir, this will match any file loaded
from a file:// url, and we use as a name the relative path to it.
- regexp: "file:///my/project/dir/(.*)"
```

### Function size analysis tool

This command-line tool presents how much each function contributes to the total
code of your application.  We use dependency information to compute dominance
and reachability data as well.

When you run:
```bash
pub global activate dart2js_info # only needed once
pub global run dart2js_info:function_size_analysis out.js.info.json
```

the tool produces a table output with lots of entries. Here is an example entry
with the corresponding table header:
```
 --- Results per element (field or function) ---
    element size     dominated size     reachable size Element identifier
    ...
     275   0.01%     283426  13.97%    1506543  74.28% some.library.name::ClassName.myMethodName
```

Such entry means that the function `myMethodName` uses 275 bytes, which is 0.01%
of the application. That function however calls other functions, which
transitively can include up to 74.28% of the application size. Of all those
reachable functions, some of them are reachable from other parts of the program,
but a subset are dominated by `myMethodName`, that is, other parts of the
program starting from `main` would first go through `myMethodName` before
reaching those functions. In this example, that subset is 13.97% of the
application size. This means that if you somehow can remove your dependency on
`myMethodName`, you will save at least that 13.97%, and possibly some more from
the reachable size, but how much of that we are not certain.

### Coverage tools

Coverage information requires a bit more setup and work to get them running. The
steps are as follows:

  * Compile an app with dart2js using `--dump-info` and defining the
    Dart environment `traceCalls=post`:

```
DART_VM_OPTIONS="-DtraceCalls=post" dart2js --dump-info main.dart
```

  Because coverage/tracing data is currently experimental, the feature is
  not exposed as a flag in dart2js, but you can enable it using the Dart
  environment flag. The flag only works dart2js version 1.13.0-dev.0.0 or newer.

  * Launch the coverage server tool to serve up the JS code of your app:

```bash
pub global run dart2js_info:coverage_log_server main.dart.js
```

  * (optional) If you have a complex application setup, you may need to serve an
    html file or integrate your application server to proxy to the log server
    any GET request for the .dart.js file and /coverage POST requests that send
    coverage data.

  * Load your app and use it to excersize the entire code.

  * Shut down the coverage server (Ctrl-C). This will emit a file named
    `mail.dart.js.coverage.json`

  * Finally, run the live code analysis tool given it both the info and
    converage json files:

```bash
pub global run dart2js_info:live_code_size_analysis main.dart.info.json main.dart.coverage.json
```

## Code location, features and bugs

This package is developed in [github][repo].  Please file feature requests and
bugs at the [issue tracker][tracker].

[repo]: https://github.com/dart-lang/dart2js_info/
[tracker]: https://github.com/dart-lang/dart2js_info/issues
[code_deps]: https://github.com/dart-lang/dart2js_info/blob/master/bin/code_deps.dart
[lib_split]: https://github.com/dart-lang/dart2js_info/blob/master/bin/library_size_split.dart
[coverage]: https://github.com/dart-lang/dart2js_info/blob/master/bin/coverage_log_server.dart
[live]: https://github.com/dart-lang/dart2js_info/blob/master/bin/live_code_size_analysis.dart
[function_analysis]: https://github.com/dart-lang/dart2js_info/blob/master/bin/function_size_analysis.dart
[AllInfo]: http://dart-lang.github.io/dart2js_info/doc/api/dart2js_info.info/AllInfo-class.html
