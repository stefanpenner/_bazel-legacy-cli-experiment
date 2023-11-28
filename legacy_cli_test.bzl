load("@bazel_skylib//lib:unittest.bzl", "asserts", "analysistest")
load("//:legacy_cli.bzl", "legacy_cli")

def _provider_contents_test_impl(ctx):
  env = analysistest.begin(ctx)

  target_under_test = analysistest.target_under_test(env)
  actions = analysistest.target_actions(env)
  bin_path = analysistest.target_bin_dir_path(env)

  asserts.equals(env, [
    file.basename for file in target_under_test.files.to_list()
  ], ["target_subject.json"])

  asserts.equals(env, 1, len(actions))
  run_shell = actions[0]

  command = run_shell.argv[2]

  expected_command = '''[[ ! -d "build" ]] && mkdir build; cp {input_path} {working_path} && {tool_name} && cp {working_path} {output_path}'''.format(
    input_path = "file.json",
    working_path = "build/artifact-spec.json",
    output_path = "%s/target_subject.json" % bin_path,
    tool_name = "tool",
  )

  asserts.equals(env, expected_command, command)

  # If you forget to return end(), you will get an error about an analysis
  # test needing to return an instance of AnalysisTestResultInfo.
  return analysistest.end(env)


# Create the testing rule to wrap the test logic. This must be bound to a global
# variable, not called in a macro's body, since macros get evaluated at loading
# time but the rule gets evaluated later, at analysis time. Since this is a test
# rule, its name must end with "_test".
provider_contents_test = analysistest.make(_provider_contents_test_impl)


# Macro to setup the test.
def _test_provider_contents():
    # Rule under test. Be sure to tag 'manual', as this target should not be
    # built using `:all` except as a dependency of the test.
    legacy_cli(
      name = "target_subject.json",
      tool = ":tool",
      input = ":file.json",
      file_name = "build/artifact-spec.json",
      tags = ["manual"],
    )
    # Testing rule.
    provider_contents_test(name = "provider_contents_test", target_under_test = ":target_subject.json")
    # Note the target_under_test attribute is how the test rule depends on
    # the real rule target.

# Entry point from the BUILD file; macro for running each test case's macro and
# declaring a test suite that wraps them together.
def legacy_cli_test_suite(name):
    # Call all test functions and wrap their targets in a suite.
    _test_provider_contents()
    # ...

    native.test_suite(
        name = name,
        tests = [
            ":provider_contents_test",
            # ...
        ],
    )
