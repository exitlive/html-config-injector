library html_config_injector;

import 'dart:async';
import 'dart:convert';
import 'package:barback/barback.dart';
import 'package:dart_config/default_server.dart';


const htmlSanitizer = const HtmlEscape();

/// Adds config information to an html page using hidden input fields.
/// Warning: Use safe keys and values to not trash the tag and your page.
class BrowserConfigTransformer extends Transformer {
  // A template of the html tag into which the keys and values are inserted make up the hidden input field.
  // Inputs are html-sanitized: 'abc"def' -> 'abc&quot;def' and so on. Be mindful of this when parsing the values.
  // The "{{key}}" and "{{value}}" are matched when replacing. Be mindful of this if altering the template string.
  final String configHtmlTemplate = '<input type="hidden" name="{{key}}" value="{{value}}">';

  // This is the configuration with which the transformer was called (from remote pubspec).
  Map<String, String> transformerConfiguration;

  BrowserConfigTransformer(this.transformerConfiguration);

  BrowserConfigTransformer.asPlugin(BarbackSettings settings) : this(_parseSettings(settings));

  Future<bool> isPrimary(AssetId id) {
    if (transformerConfiguration['entry_points'].contains(id.path)) return new Future.value(true);
    return new Future.value(false);
  }

  Future apply(Transform transform) {
    return transform.primaryInput.readAsString().then((content) async {
      try {
        // Load the file with the browser configuration from the path specified in the transformer configuration.
        var browserConfiguration = await loadConfig(transformerConfiguration['config_path']);

        String configHtml = '';

        // Load the browser configuration key-value pairs from under the designated key.
        browserConfiguration[transformerConfiguration['config_key']].forEach((key, value) {
          // Sanitize (each, as per above) key and value for html.
          key = htmlSanitizer.convert(key);
          value = htmlSanitizer.convert(value);

          // Add each key-value pair from the config as an html tag into the template string specified earlier.
          configHtml += configHtmlTemplate
            .replaceFirst('{{key}}', key)
            .replaceFirst('{{value}}', value);
        });

        var id = transform.primaryInput.id;
        // String or regex, as per transformer 'regex' setting.
        var configTag;

        if (transformerConfiguration['regex'] == true) {
          // Create a regex to match the tag in the html to be transformed.
          configTag = new RegExp(transformerConfiguration['matcher']);
        }
        else if (transformerConfiguration['regex'] == null || transformerConfiguration['regex'] == false) {
          configTag = transformerConfiguration['matcher'];
        } else {
          // This error causes the transformation to be skipped to prevent user error, and is caught/displayed.
          throw('Unknown regex option \"${transformerConfiguration['regex']}\"'
              + '(use true for regex replace, false for string replace).');
        }

        // Make the transformation.
        String contentTransformed = content.replaceFirst(configTag, configHtml);
        transform.addOutput(new Asset.fromString(id, contentTransformed));
      } catch (e) {
        print(e);
      }
    });
  }
}


Map<String, String> _parseSettings(BarbackSettings settings) {
  var args = settings.configuration;

  // Create a list from a potentially single entry point.
  List<String> entryPoints = _readEntrypoints(args['entry_points']);

  // Remove the potentially non-list entry point.
  args.remove('entry_points');

  // Create a dictionary with the entry points.
  Map<String, List> entryPointMap = {'entry_points': entryPoints};

  // Add entry points back to argument list.
  args.addAll(entryPointMap);
  return args;
}


List<String> _readEntrypoints(value) {
  if (value == null) return null;
  return (value is List) ? value : [value];
}
