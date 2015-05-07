library dashboard.transformer;

import 'dart:async';
import 'dart:convert';
import 'package:barback/barback.dart';
import 'package:logging/logging.dart';
import 'package:dart_config/default_server.dart';


var log = new Logger('BrowserConfigTransformer');
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
  String configHtml = '';

  BrowserConfigTransformer(this.transformerConfiguration);

  BrowserConfigTransformer.asPlugin(BarbackSettings settings) : this(_parseSettings(settings));

  Future<bool> isPrimary(AssetId id) {
    // TODO: Using endsWith to determine entry points - find out whether this makes sense.
    return new Future.value(id.path.endsWith(transformerConfiguration['entry_points']));
  }

  Future apply(Transform transform) {
    return transform.primaryInput.readAsString().then((content) async {
      try {
        // Load the file with the browser configuration from the path specified in the transformer configuration.
        var browserConfiguration = await loadConfig(transformerConfiguration['config_path']);
        // Load the browser configuration key-value pairs from under the designated key.
        browserConfiguration[transformerConfiguration['config_key']].forEach((key, value) {
          // Sanitize (each, as per above) key and value for html.
          key = htmlSanitizer.convert(key);
          value = htmlSanitizer.convert(value);
          RegExp splitter = new RegExp(r"\{\{(key|value)\}\}");
          List<String> split = configHtmlTemplate.split(splitter);
          // Add each key-value pair from the config as an html tag into the template string specified earlier.
          configHtml += split[0] + key + split[1] + value + split[2];
        });

        var id = transform.primaryInput.id;
        // String or regex, as per transformer 'regex' setting.
        var configTag;

        if (transformerConfiguration['regex'] == null || transformerConfiguration['regex'] == true) {
          // Create a regex to match the tag in the html to be transformed.
          configTag = new RegExp(transformerConfiguration['placeholder']);
        }
        else if (transformerConfiguration['regex'] == false) {
          configTag = transformerConfiguration['placeholder'];
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
  // return _readEntrypoints(args['entry_points']);
  return args;
}


List<String> _readEntrypoints(value) {
  if (value == null) return null;
  return (value is List) ? value : [value];
}
