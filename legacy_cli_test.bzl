load("@bazel_skylib//lib:unittest.bzl", "asserts", "analysistest")
load("//:legacy_cli.bzl", "legacy_cli")

def _legacy_cli_test_impl(ctx):
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

  return analysistest.end(env)

legacy_cli_test = analysistest.make(_legacy_cli_test_impl)

# Macro to setup the test.
def _test_legacy_cli():
    legacy_cli(
      name = "target_subject.json",
      tool = ":tool",
      input = ":file.json",
      file_name = "build/artifact-spec.json",
      tags = ["manual"], # ensure we don't run this via :all
    )

    legacy_cli_test(name = "legacy_cli_test", target_under_test = ":target_subject.json")

def legacy_cli_test_suite(name):
    _test_legacy_cli()

    native.test_suite(
        name = name,
        tests = [
            ":legacy_cli_test",
            # ...
        ],
    )
