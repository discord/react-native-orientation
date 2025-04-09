var Orientation = require('react-native').NativeModules.Orientation;
var Platform = require('react-native').Platform;
var DeviceEventEmitter = require('react-native').DeviceEventEmitter;

var listeners = {};
var orientationDidChangeEvent = 'orientationDidChange';
var specificOrientationDidChangeEvent = 'specificOrientationDidChange';
var orientationDegreesDidChangeEvent = 'orientationDegreesDidChange';

var id = 0;
var META = '__listener_id';

function getKey(listener) {
  if (!listener.hasOwnProperty(META)) {
    if (!Object.isExtensible(listener)) {
      return 'F';
    }

    Object.defineProperty(listener, META, {
      value: 'L' + ++id,
    });
  }

  return listener[META];
};

module.exports = {
  getOrientation(cb) {
    Orientation.getOrientation((error,orientation) =>{
      cb(error, orientation);
    });
  },

  getSpecificOrientation(cb) {
    Orientation.getSpecificOrientation((error,orientation) =>{
      cb(error, orientation);
    });
  },

  ignoreAutoRotate(shouldIgnore) {
    if (Platform.OS === 'android') {
    console.log("FOO HAMZA SAYS lib ignoreAutoRotate", shouldIgnore);
    Orientation.ignoreAutoRotate(shouldIgnore);
    }
  },

  lockToPortrait() {
    console.log("FOO HAMZA SAYS lib lockToPortrait");
    Orientation.lockToPortrait();
  },

  lockToLandscape() {
    console.log("FOO HAMZA SAYS lib lockToLandscape");
    Orientation.lockToLandscape();
  },

  lockToLandscapeRight() {
    console.log("FOO HAMZA SAYS lib lockToLandscapeRight");
    Orientation.lockToLandscapeRight();
  },

  lockToLandscapeLeft() {
    console.log("FOO HAMZA SAYS lib lockToLandscapeLeft");
    Orientation.lockToLandscapeLeft();
  },

  unlockAllOrientations() {
    console.log("FOO HAMZA SAYS lib unlockAllOrientations");
    Orientation.unlockAllOrientations();
  },

  addOrientationListener(cb) {
    var key = getKey(cb);
    listeners[key] = DeviceEventEmitter.addListener(orientationDidChangeEvent,
      (body) => {
        cb(body.orientation);
      });
  },

  addOrientationDegreesChangeListener(callback) {
    var key = getKey(callback);
    listeners[key] = DeviceEventEmitter.addListener(orientationDegreesDidChangeEvent,
      (body) => {
        callback(body.orientationDegrees);
      });
  },

  removeOrientationListener(cb) {
    var key = getKey(cb);

    if (!listeners[key]) {
      return;
    }

    listeners[key].remove();
    listeners[key] = null;
  },

  addSpecificOrientationListener(cb) {
    var key = getKey(cb);

    listeners[key] = DeviceEventEmitter.addListener(specificOrientationDidChangeEvent,
      (body) => {
        cb(body.specificOrientation);
      });
  },

  removeSpecificOrientationListener(cb) {
    var key = getKey(cb);

    if (!listeners[key]) {
      return;
    }

    listeners[key].remove();
    listeners[key] = null;
  },

  getInitialOrientation() {
    return Orientation.initialOrientation;
  }
}
