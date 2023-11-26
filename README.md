# legacy-cli (Exploration)

NOTE: A better approach to this may exists, but I wasn't able to find one. If someone does, please let me know!

This repo explores an approach which enables legacy-cli use with bazel.
A legacy-cli is one that doesn't confirm to a explicit and parametizable inputs & outputs.

Rather then:

```sh
tool inputfile > outputfile
```

It behaves on implicit inputs and outputs in the CWD.

```sh
tool
// implicitly reads inputFile
// and then maybe even writes back to inputFile
```

This repo plays with the idea of a rule which wraps such a tool, and provides a
mechanism to pass the inputFile in as a bazel input, and pass the inputFile
back out as a bazel output.

All while running in the expected CWD.

This rule could be extended to operate on N input and output files, which a mapping between them.
This rule needs some testing, especially on different platforms as I don't fully understand the bazel sandboxing primitive.

## Installation
just have bazel installed 

## Usage
```
bazel build :build/file.json
```

## Contributing
PRs welcome