# transformers

*WIP, doesn't work*

*Example `pubspec.yaml`*
```
dependencies:
  [...]
  exitlive_transformers:
      git: git@github.com:exitlive/transformers.git
dependency_overrides:
    [...]
    exitlive_transformers:
        path: ../transformers/
transformers:
[...]
- exitlive_transformers:
    entry_points: web/index.html
    config_path: config/default.config.yaml
    config_key: browser_configuration_settings
    placeholder_regex: r"BrowserConfig"
```
*Explanation of configuration variables*

`entry_points`: Which files to transform (matches path name endings).
`config_path`: Path of file with the configurations to be embedded into html.
`config_key`: The key under which the aforementioned configurations are located
(currently ignored, uses `browser_configuration_settings`).

`placeholder_regex`: Regex used to find configuration placeholders to replace
in the transformation (currently ignored, uses `u"BrowserConfig"`).

*Functionality*

On building, the placeholder in your template, f.ex. `BrowserConfig` is
replaced by f.ex. `<input type="hidden" name="hello" value="world" >` in the
built version.

*Known bugs*

Many, but it works, provided one uses the same values as in the example. :)
