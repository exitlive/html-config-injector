# Dart HTML Config Injector

*Transforms html to add configuration data as hidden input fields*

## Usage

### 1. Create file with browser configuration settings

The path of the yaml file with the browser configuration you want to be embed
can be anywhere in the project. The only restriction is that all configuration
settings have to be second level key/value pairs under a single top level
entry.

#### Example configuration file with browser configurations

`config/default.config.yaml`
```
# Something unrelated
forward_build_to_vagrant: true

# to-be embedded configs
browser_configuration_settings:
    hello: world
```

### 2. Configure the transformer in your `pubspec.yaml`

The transformer takes the following five (5) configuration parameters, the
first four (4) of which are required:

1. `entry_points`: Which files to transform (required, takes a yaml list).

2. `config_path`: Path of file with the browser configurations to be embedded
into html (required).

3. `config_key`: The key under which the aforementioned configs are located
(required).

4. `matcher`: String or regex (see below) used to find configuration
placeholders to replace in the transformation (required).

5. `regex`: Whether to use regex or not (optional, default: false).

#### Example `pubspec.yaml`
```
dependencies:
  [...]
  html_config_injector: any
transformers:
[...]
- html_config_injector:
    entry_points:
        - web/index.html
        - web/other.html
    config_path: config/default.config.yaml
    config_key: browser_configuration_settings
    matcher: BrowserConfig
    regex: false
```

### 3. Modify html

Place the placeholder you have defined earlier into your html.

#### Example html template

Continuing with the example above, our placeholder is `BrowserConfig`:

`web/index.html`

```
<!DOCTYPE html>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>A Website</title>
<p>Some content.</p>
BrowserConfig
```

### 4. Build

Run `pub build` on your application.

### Example results

If everything worked, the transformed files will be in the `build` directory.
Continuing with the example above:

`build/web/index.html`

```
<!DOCTYPE html>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>A Website</title>
<p>Some content.</p>
<input type="hidden" name="hello" value="world">
```

## Known bugs

None at the moment.
