# transformers

*WIP, doesn't work*

Can be used by putting something like this into pubspec.yaml:
```dependencies:
  exitlive_transformers:
  git: git@github.com:exitlive/transformers.git
dependency_overrides:
    exitlive_transformers:
        path: ../transformers/
transformers:
- exitlive_transformers:
    entry_points: web/index.html
    config_path: path/to/config
    config_key: browser_configuration_settings```

