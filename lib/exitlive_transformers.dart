library dashboard.transformer;

import 'dart:async';
import 'package:barback/barback.dart';
import 'package:logging/logging.dart';
import 'package:dart_config/default_server.dart';


var log = new Logger('BrowserConfigTransformer');

/// Adds config information to an html page using hidden input fields.
/// Warning: Use safe keys and values to not trash the tag and your page.
class BrowserConfigTransformer extends Transformer {
  // These three strings make up the hidden input field, in that it is formed as follows:
  // prefix + key + separator + value + postfix, ie.
  // <input type="hidden" name="[key]" value="[value]">
  // There is no input sanitation of any kind.
  final String prefix = '<input type="hidden" name="';
  final String separator = '" value="';
  final String postfix = '">';

  // This is the configuration with which the transformer was called (from remote pubspec).
  Map<String, String> transformerConfiguration;
  String configHtml = '';

  BrowserConfigTransformer(this.transformerConfiguration);

  BrowserConfigTransformer.asPlugin(BarbackSettings settings) : this(_parseSettings(settings));

  Future<bool> isPrimary(AssetId id) {
    // TODO: Enable logging.
    log.warning('hit000000000000000000000000000000000000000000000000000000');
    // TODO: Using endsWith to determine entry points - find out whether this makes sense.
    return new Future.value(id.path.endsWith(transformerConfiguration['entry_points']));
  }

  Future apply(Transform transform) {
    return transform.primaryInput.readAsString().then((content) async {
      // Load the browser configuration from the path specified in the transformer configuration.
      await loadConfig(transformerConfiguration['config_path']).then((Map browserConfiguration) {
        browserConfiguration[transformerConfiguration['config_key']].forEach((key, value) {
          // Adds each key/value pair from the config as an html tag.
          configHtml += prefix + key + separator + value + postfix;
        });
        // TODO: Change to log.
      }, onError: (error) => print(error));

      var id = transform.primaryInput.id;

      // Create a regex to match the tag in the html to be transformed.
      RegExp configTag = new RegExp(transformerConfiguration['placeholder_regex']);
      // Make the transformation.
      String contentTransformed = content.replaceAll(configTag, configHtml);
      transform.addOutput(new Asset.fromString(id, contentTransformed));
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
