package com.videojs.vpaid {

import com.videojs.*;
import com.videojs.events.VPAIDEvent;
import com.videojs.util.JSInterface;
import com.videojs.util.console;

import flash.display.Loader;
import flash.display.Sprite;
import flash.utils.Timer;
import flash.events.*;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.net.URLRequest;
import flash.system.LoaderContext;

import com.videojs.structs.ExternalEventName;

import flash.external.ExternalInterface;

public class AdContainer extends Sprite {

  private var _ad:*;
  private var _adUnits:Array;
  private var _currentAdUnit:AdUnit;
  private var _adIsPlaying:Boolean = false;
  private var _durationTimer:Timer;

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
    _ad.addEventListener(VPAIDEvent.AdLoaded, function ():void {
      adLoaded();
    });
    _ad.addEventListener(VPAIDEvent.AdStarted, function ():void {
      adStarted();
    });
    _ad.addEventListener(VPAIDEvent.AdStopped, function ():void {
      adStopped();
    });
    _ad.addEventListener(VPAIDEvent.AdError, function ():void {
      adError();
    });
    // Determine VPAID version (mostly for debugging)
    var handshakeVersion:String = _ad.handshakeVersion('2.0');
    console.log('AdContainer::onAdUnitLoaded - Handshake version:', handshakeVersion);
    // Initialize ad
    _ad.initAd(_currentAdUnit.width, _currentAdUnit.height, "normal", _currentAdUnit.bitrate, "", "");
  }

  /** AD EVENT HANLDERS **/

  /**
   * Fired by the ad unit when it's content has finished loading.
   */
  private function adLoaded():void {
    // Add ad unit to stage
    addChild(_ad.displayObject);
    JSInterface.broadcast(VPAIDEvent.AdLoaded);
    // Resize to current stage values and then start
    _ad.resizeAd(stage.width, stage.height, "normal");
    _ad.startAd();
  }

  /**
   * Fired by the ad unit when it's content has started.
   */
  private function adStarted():void {
    _adIsPlaying = true;
    startDurationTimer();
    JSInterface.broadcast(VPAIDEvent.AdStarted);
    JSInterface.broadcast(VPAIDEvent.AdImpression);
  }

  /**
   * Fired by the ad unit when it's content has stopped.
   */
  public function adStopped():void {
    if (_adIsPlaying) {
      _ad = null;
      _currentAdUnit = null;
      _adIsPlaying = false;
      JSInterface.broadcast(VPAIDEvent.AdStopped);
    }
  }

  /**
   * Fired by the ad unit when it has encountered an error.
   */
  private function adError():void {
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
    adStopped();
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