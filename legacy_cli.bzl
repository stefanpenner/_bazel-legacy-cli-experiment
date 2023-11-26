
def _legacy_cli(ctx):
  tool = ctx.executable.tool

  output = ctx.actions.declare_file(ctx.label.name)

  ctx.actions.run_shell(
    inputs = [tool, ctx.file.input],
    outputs = [output],
    # given that our legacy tool reads & writes to the same file, we do some funky stuff here to make it work with bazel
    # 1. we use the sandbox to avoid poluting the workspace
    # 2. we copy the input.json into the sandboxed build directory
    # 3. we run the legacy tool
    # 4. we copy the updated output.json back out to the rules output
    command = """[[ ! -d "build" ]] && mkdir build; cp %s %s && %s && cp %s %s""" % (
      ctx.file.input.path, # input artifact-spec.json
      ctx.attr.file_name,
      tool.path, # tool to run
      ctx.attr.file_name,
      output.path # output artifact_spec
    ),

    execution_requirements = {
        "no-cache": "1",
        "no-remote": "1",
        "local": "1",
    }
  )

  return [DefaultInfo(files = depset([output]))]

legacy_cli = rule(
  implementation = _legacy_cli,
  attrs = {
    "input": attr.label(allow_single_file = True),
    "file_name": attr.string(),
    "tool": attr.label(
      executable = True,
      allow_single_file = True,
      cfg = "exec",
    ),
  },
)
