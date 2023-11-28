def _legacy_cli(ctx):
  output = ctx.actions.declare_file(ctx.label.name)

  ctx.actions.run_shell(
    inputs = [ctx.executable.tool, ctx.file.input],
    outputs = [output],

    # given that our legacy tool reads & writes to the same file, we do some funky stuff here to make it work with bazel
    #
    # 1. we use the sandbox to avoid poluting the workspace
    # 2. we copy the input.json into the sandboxed build directory
    # 3. we run the legacy tool
    # 4. we copy the updated output.json back out to the rules output
    #
    # Note: this is a prototype, to demonstrate the possibility not a production ready solution.
    # If this were to be used:
    # * the mkdir stuff should be generalized.
    # * this could be generalized to more then one set of input / output / working file mappings
    # * proper shell settings to ensure the script errors correctly etc.
    command = """[[ ! -d "build" ]] && mkdir build; cp {input_path} {working_path} && {executable_path} && cp {working_path} {output_path}""".format(
      input_path = ctx.file.input.path,
      working_path = ctx.attr.file_name,
      executable_path = ctx.executable.tool.path,
      output_path = output.path
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
    "input": attr.label(allow_single_file = True, mandatory = True),
    "file_name": attr.string(mandatory = True),
    "tool": attr.label(
      mandatory = True,
      executable = True,
      allow_single_file = True,
      cfg = "exec",
    ),
  },
)
