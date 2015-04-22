library dashboard.transformer;

import 'dart:async';
// import 'package:exitlive_utils/config.dart';
// The barback package provides tranforming functionality.
import 'package:barback/barback.dart';
import 'package:logging/logging.dart';
// The dart_config package provides config parsing functionality.
import 'package:dart_config/default_server.dart';


var log = new Logger('BrowserConfigTransformer');

// Config config2 = new Config.fromFiles('../config/default.config.yaml', '../config/default.config.yaml');
// bool configValue2 = config2.forwardBuildToVagrant;

/// Adds config information to an html page using hidden input fields.
/// Warning: Use html-safe keys and values to not trash your page.
class BrowserConfigTransformer extends Transformer {
  // These three strings make up the hidden input field, in that it is formed as follows:
  // prefix + key + separator + value + postfix,
  // ie. <input type="hidden" name="<key>" value="<value>">
  // There is no input sanitation of any kind.
  final String prefix = '<input type="hidden" name="';
  final String separator = '" value="';
  final String postfix = '">';
  // // List entryPoints;
  // String configPath;
  // String configHeading;
  Map<String, String> config;

  // BrowserConfigTransformer([this.configPath, this.configHeading]);
  BrowserConfigTransformer(this.config);

  // // Config config = new Config.fromFiles('../config/default.config.yaml', '../config/default.config.yaml');
  // bool configValue = config.forwardBuildToVagrant;

  BrowserConfigTransformer.asPlugin(BarbackSettings settings) : this(_parseSettings(settings));

  Future<bool> isPrimary(AssetId id) {
    // print('configValue: ${configValue}');
    // print('configValue2: ${configValue2}');
    // TODO: Enable logging.
    log.finest('hit0');
    // TODO: Remove hardcoding (probably by removing endsWith and using entry points).
    return new Future.value(id.path.endsWith('/index.html'));
  }

  Future apply(Transform transform) {
    log.finest('hit');
    // print('HELLO');
    return transform.primaryInput.readAsString().then((content) {
      // Get config variables to transform into page
      loadConfig(config['config_path']).then((Map config2) {
        // TODO: Remove hardcoding.
        print('here! configs: ${config2['browser_configuration_settings']}');
      // TODO: Remove print.
      }, onError: (error) => print(error));
      // ...
      var id = transform.primaryInput.id;

      RegExp configTag = new RegExp(r"BrowserConfig");
      print(content);
      // String contentTransformed = content.replaceAll(configTag, entryPoints[0]);
      String contentTransformed = content.replaceAll(configTag, config['entry_points']);
      // print(contentTransformed);
      // TODO: Remove prints.
      // Here, a proof of concept:
      print('entry_points: ${config['entry_points']}');
      print('config_path: ${config['config_path']}');
      print('config_key: ${config['config_key']}');
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
