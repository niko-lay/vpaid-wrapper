package com.vpaidwrapper.vpaid {

import com.vpaidwrapper.*;
import com.vpaidwrapper.events.VPAIDEvent;
import com.vpaidwrapper.events.VPAIDWrapperEvent;
import com.vpaidwrapper.util.JSInterface;
import com.vpaidwrapper.util.console;

import flash.display.Loader;
import flash.display.Sprite;
import flash.utils.Timer;
import flash.events.*;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.net.URLRequest;
import flash.system.LoaderContext;

import flash.external.ExternalInterface;

public class AdContainer extends EventDispatcher {

  private static var _instance:AdContainer;

  private var _ad:VPAID;
  private var _adUnits:Array;
  private var _currentAdUnit:AdUnit;
  private var _adIsPlaying:Boolean = false;
  private var _durationTimer:Timer;

  /**
   * Constructor.
   * @param pLock
   */
  public function AdContainer(pLock:SingletonLock) {
    if (!pLock is SingletonLock) {
      throw new Error("Invalid Singleton access. Use AdContainer.getInstance()!");
    }
  }

  /**
   * Obtain singleton instance.
   * @return
   */
  public static function getInstance():AdContainer {
    if (_instance === null){
      _instance = new AdContainer(new SingletonLock());
    }
    return _instance;
  }

  /** PROPERTIES **/

  /**
   *
   */
  public function get displayObject():* {
    if (_ad != null) {
      return _ad.displayObject;
    }
  }

  /**
   * Provides external read access to VPAID object properties.
   * @param propertyName
   * @return
   */
  public function getAdProperty(propertyName:String):* {
    if (_ad != null && _ad.hasOwnProperty(propertyName)) {
      return _ad[propertyName];
    }
    return null;
  }

  /**
   * Provides external write access to VPAID object properties.
   * @param propertyName
   * @param value
   */
  public function setAdProperty(propertyName:String = "", value:* = null):void {
    if (_ad != null && _ad.hasOwnProperty(propertyName)) {
      _ad[propertyName] = value;
    }
  }

  /** INITIALIZATION **/

  /**
   * Main initialization point, should be called when view is ready.
   * @param adAssets
   */
  public function init(adUnits:Array):void {
    _adUnits = adUnits;
    var adUnit:AdUnit = _adUnits.shift();
    loadAdUnit(adUnit);
  }

  /**
   * Downloads and loads the given ad asset.
   * @param asset
   */
  private function loadAdUnit(adUnit:AdUnit):void {
    _currentAdUnit = adUnit;
    var loader:Loader = new Loader();
    var loaderContext:LoaderContext = new LoaderContext();
    loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onAdUnitLoaded);
    loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function (evt:SecurityErrorEvent):void {
      _currentAdUnit = null;
      //throwAdError('initError: Security error '+evt.text);
    });
    loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function (evt:IOErrorEvent):void {
      _currentAdUnit = null;
      //throwAdError('initError: Error loading '+evt.text);
    });
    loader.load(new URLRequest(_currentAdUnit.src), loaderContext);
  }

  /**
   * Ad asset loaded handler. Wires ad events and attempts to initialize ad.
   * @param evt
   * @param asset
   */
  private function onAdUnitLoaded(evt:Object):void {
    _ad = new VPAID(evt.target.content);
    // Wire ad events
    _ad.addEventListener(VPAIDEvent.AdLoaded, adLoaded);
    _ad.addEventListener(VPAIDEvent.AdStarted, adStarted);
    _ad.addEventListener(VPAIDEvent.AdStopped, adStopped);
    _ad.addEventListener(VPAIDEvent.AdSkipped, adSkipped);
    _ad.addEventListener(VPAIDEvent.AdError, adError);
    // Determine VPAID version (mostly for debugging)
    var handshakeVersion:String = _ad.handshakeVersion('2.0');
    console.log('AdContainer::onAdUnitLoaded - VPAID Handshake version:', handshakeVersion);
    // Initialize ad
    _ad.initAd(_currentAdUnit.width, _currentAdUnit.height, "normal", _currentAdUnit.bitrate);
  }

  /**
   * Resource cleanup after ad has completed or failed.
   */
  private function clearCurrentAdUnit():void {
    _ad.removeEventListener(VPAIDEvent.AdLoaded, adLoaded);
    _ad.removeEventListener(VPAIDEvent.AdStarted, adStarted);
    _ad.removeEventListener(VPAIDEvent.AdStopped, adStopped);
    _ad.removeEventListener(VPAIDEvent.AdSkipped, adSkipped);
    _ad.removeEventListener(VPAIDEvent.AdError, adError);
    _ad = null;
    _currentAdUnit = null;
    _adIsPlaying = false;
  }

  /** AD EVENT HANLDERS **/

  /**
   * Fired by the ad unit when it's content has finished loading.
   * @param event
   */
  private function adLoaded(event:Event):void {
    // Add ad unit to stage
    dispatchEvent(new VPAIDWrapperEvent(VPAIDWrapperEvent.AD_LOADED));
    JSInterface.broadcast(VPAIDEvent.AdLoaded);
    // Start ad playback
    _ad.startAd();
  }

  /**
   * Fired by the ad unit when it's content has started.
   * @param event
   */
  private function adStarted(event:Event):void {
    _adIsPlaying = true;
    //startDurationTimer();
    JSInterface.broadcast(VPAIDEvent.AdStarted);
    JSInterface.broadcast(VPAIDEvent.AdImpression);
  }

  /**
   * Fired by the ad unit when it's content has stopped.
   * @param event
   */
  public function adStopped(event:Event):void {
    if (_adIsPlaying) {
      clearCurrentAdUnit()
      JSInterface.broadcast(VPAIDEvent.AdStopped);
    }
  }

  /**
   * Fired by the ad unit when it's content has been skipped.
   * @param event
   */
  public function adSkipped(event:Event):void {
    JSInterface.broadcast(VPAIDEvent.AdSkipped);
  }

  /**
   * Fired by the ad unit when it has encountered an error.
   * @param event
   */
  private function adError(event:Event):void {
    _ad.stopAd();
    dispatchEvent(new VPAIDEvent(VPAIDEvent.AdStopped));
  }

  /** DURATION TIMER **/

  protected function startDurationTimer():void {
    var timerDuration:Number = _ad.adDuration;
    if (timerDuration < 0) {
      timerDuration = _currentAdUnit.duration;
    }
    _durationTimer = new Timer(1000, timerDuration);
    _durationTimer.addEventListener(TimerEvent.TIMER, adDurationTick);
    _durationTimer.addEventListener(TimerEvent.TIMER_COMPLETE, adDurationComplete);
    _durationTimer.start();
  }

  private function adDurationTick(evt:Object):void {
    //_model.broadcastEventExternally(VPAIDEvent.AdPluginEventTimeRemaining);

    //ExternalInterface.call("console.log", _ad.adSkippableState);

    //if (_ad.adSkippableState) {
      //_model.broadcastEventExternally(VPAIDEvent.AdPluginEventCanSkip);
    //}
  }

  private function adDurationComplete(evt:Object):void {
    if (_durationTimer) {
      _durationTimer.stop();
      _durationTimer.removeEventListener(TimerEvent.TIMER, adDurationTick);
      _durationTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, adDurationComplete);
      _durationTimer = null;
    }
    adStopped(null);
  }

  /*
  public function pausePlayingAd():void {
    _adIsPlaying = false;
    _durationTimer.stop();
    _ad.pauseAd();
  }

  public function resumePlayingAd():void {
    _adIsPlaying = true;
    _durationTimer.start();
    _ad.resumeAd();
  }
  */
}

}

/**
 * @internal This is a private class declared outside of the package
 * that is only accessible to classes inside of this file
 * file.  Because of that, no outside code is able to get a
 * reference to this class to pass to the constructor, which
 * enables us to prevent outside instantiation.
 *
 * We do this because Actionscript doesn't allow private constructors,
 * which prevents us from creating a "true" singleton.
 *
 * @private
 */
class SingletonLock {}