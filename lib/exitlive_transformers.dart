library dashboard.transformer;

import 'dart:async';
import 'package:exitlive_utils/config.dart';
import 'package:barback/barback.dart';
import 'package:logging/logging.dart';


var log = new Logger('BrowserConfigTransformer');

// Config config2 = new Config.fromFiles('../config/default.config.yaml', '../config/default.config.yaml');
// bool configValue2 = config2.forwardBuildToVagrant;


class BrowserConfigTransformer extends Transformer {
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
    log.finest('hit0');
    return new Future.value(id.path.endsWith('/index.html'));
  }

  Future apply(Transform transform) {
    log.finest('hit');
    // print('HELLO');
    return transform.primaryInput.readAsString().then((content) {
      var id = transform.primaryInput.id;

      RegExp configTag = new RegExp(r"BrowserConfig");
      print(content);
      // String contentTransformed = content.replaceAll(configTag, entryPoints[0]);
      String contentTransformed = content.replaceAll(configTag, config['entry_points']);
      // print(contentTransformed);
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
