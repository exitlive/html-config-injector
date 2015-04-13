# transformers

*WIP, doesn't work*

Can be used by putting something like this into pubspec.yaml:
```
dependencies:
  exitlive_transformers:
  git: git@github.com:exitlive/transformers.git
dependency_overrides:
    exitlive_transformers:
        path: ../transformers/
transformers:
- exitlive_transformers:
    entry_points: web/index.html
    config_path: path/to/config
    config_key: browser_configuration_settings
```
Then when you do `pub build`, you get output like this:
```
entry_points: web/index.html
config_path: path/to/config
config_key: browser_configuration_settings
```
from code like this:
```
      print('entry_points: ${config['entry_points']}');
      print('config_path: ${config['config_path']}');
      print('config_key: ${config['config_key']}');
```
Then if you have something like `BrowserConfig` inside your `web/index.html`,
say, it will be replaced in the built version (`build/web/index.html`). In this
proof-of-concept version, it will be replaced by the value of `entry_points`.

This is as far as I've come so far. :)
