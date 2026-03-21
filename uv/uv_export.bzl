"uv based uv lock rules"

load("//uv/private:uv_export.bzl", "uv_export_test", _uv_export = "uv_export")

def uv_export(
        name,
        pyproject_toml = None,
        requirements_txt = None,
        uv_lock = None,
        target_compatible_with = None,
        args = None,
        common_args = None,
        lock_args = None,
        export_args = None,
        data = None,
        tags = None,
        size = None,
        timeout = None,
        env = None,
        **kwargs):
    """
    Produce targets to compile a pyproject.toml file into a requirements.txt file using uv lock.

    Args:
        name: name of the primary compilation target.
        pyproject_toml: (optional, default "//:pyproject.toml") a label for the pyproject.toml file.
        requirements_txt: (optional, default "//:requirements.txt") a label for the requirements.txt file.
        uv_lock: (optional) a label for the uv.lock file. If provided, it will be used to pin versions.
        target_compatible_with: (optional) specify that a particular target is compatible only with certain
          Bazel platforms.
        args: (optional) override the default arguments passed to uv export, default arguments are:
           --format requirements.txt (Output in requirements.txt format)
           --no-header (Exclude the header comment with uv command that generated the file)
           --no-emit-workspace  (Don't emit any workspace structure in the output)
        common_args: (optional) arguments common to both export and lock, appended to the default args.
        export_args: (optional) appends to the default arguments passed to uv export. If both args and
            export_args are provided, export_args will be appended to args.
        lock_args: (optional) arguments passed only to uv lock.
        data: (optional) a list of labels of additional files to include.
        tags: (optional) tags to apply to the generated test target.
        size: (optional) size of the test target.
        timeout: (optional) timeout of the test target.
        env: (optional) a dictionary of environment variables to set.
        **kwargs: (optional) other fields passed through to all underlying rules.

    Targets produced by this macro are:
      [name]: a runnable target that will use pyproject_toml to generate requirements_txt
      [name].update: an alias for [name]
      [name]_test: a testable target that will check that requirements_txt is up to date with pyproject_toml
    """
    pyproject_toml = pyproject_toml or "//:pyproject.toml"
    requirements_txt = requirements_txt or "//:requirements.txt"
    uv_lock = uv_lock or "//:uv.lock"
    tags = tags or []
    size = size or "small"

    _uv_export(
        name = name,
        pyproject_toml = pyproject_toml,
        requirements_txt = requirements_txt,
        uv_lock = uv_lock,
        target_compatible_with = target_compatible_with,
        uv_args = args,
        common_args = common_args,
        lock_args = lock_args,
        export_args = export_args,
        data = data,
        env = env,
        **kwargs
    )

    # Also allow 'bazel run' with a "custom verb" https://bazel.build/rules/verbs-tutorial
    native.alias(
        name = name + ".update",
        actual = name,
    )

    uv_export_test(
        name = name + "_test",
        generator_label = name,
        pyproject_toml = pyproject_toml,
        requirements_txt = requirements_txt,
        uv_lock = uv_lock,
        target_compatible_with = target_compatible_with,
        uv_args = args,
        common_args = common_args,
        lock_args = lock_args,
        export_args = export_args,
        data = data,
        tags = ["requires-network"] + tags,
        size = size,
        timeout = timeout,
        env = env,
        **kwargs
    )
