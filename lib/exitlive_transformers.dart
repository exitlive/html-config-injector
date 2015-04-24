library dashboard.transformer;

import 'dart:async';
import 'package:barback/barback.dart';
import 'package:logging/logging.dart';
import 'package:dart_config/default_server.dart';


var log = new Logger('BrowserConfigTransformer');

/// Adds config information to an html page using hidden input fields.
/// Warning: Use html-safe keys and values to not trash your page.
class BrowserConfigTransformer extends Transformer {
  // These three strings make up the hidden input field, in that it is formed as follows:
  // prefix + key + separator + value + postfix, ie.
  // <input type="hidden" name="[key]" value="[value]">
  // There is no input sanitation of any kind.
  final String prefix = '<input type="hidden" name="';
  final String separator = '" value="';
  final String postfix = '">';

  Map<String, String> config;
  String configHtml = '';

  BrowserConfigTransformer(this.config);

  BrowserConfigTransformer.asPlugin(BarbackSettings settings) : this(_parseSettings(settings));

  Future<bool> isPrimary(AssetId id) {
    // TODO: Enable logging.
    log.warning('hit000000000000000000000000000000000000000000000000000000');
    // TODO: Using endsWith to determine entry points - find out whether this makes sense.
    return new Future.value(id.path.endsWith(config['entry_points']));
  }

  Future apply(Transform transform) {
    return transform.primaryInput.readAsString().then((content) async {
      // Get config variables to transform into page
      await loadConfig(config['config_path']).then((Map config2) {
        // TODO: Remove hardcoding.
        config2['browser_configuration_settings'].forEach((key, value) {
          // Adds each key/value pair from the config as a (hopefully) valid html field.
          configHtml += prefix + key + separator + value + postfix;
        });
        // TODO: Change to log.
      }, onError: (error) => print(error));

      var id = transform.primaryInput.id;

      RegExp configTag = new RegExp(r"BrowserConfig");
      // TODO: Fix this.
      // print(config['placeholder_regex']);
      // RegExp configTag = new RegExp(config['placeholder_regex']);
      String contentTransformed = content.replaceAll(configTag, configHtml);
      // TODO: Remove prints.
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
