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
  private var _adAssets:Array;
  private var _adIsPlaying:Boolean = false;
  private var _adDuration:Number;
  private var _durationTimer:Timer;

  /** INITIALIZATION **/

  /**
   * Main initialization point, should be called when view is ready.
   * @param adAssets
   */
  public function init(adAssets:Array):void {
    _adAssets = adAssets;
    var asset:Object = _adAssets.shift();
    loadAdAsset(asset);
  }

  /**
   * Downloads and loads the given ad asset.
   * @param asset
   */
  private function loadAdAsset(asset:Object):void {
    var loader:Loader = new Loader();
    var loaderContext:LoaderContext = new LoaderContext();
    loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function (evt:Object):void {
      onAdAssetLoaded(evt, asset);
    });
    loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function (evt:SecurityErrorEvent):void {
      //throwAdError('initError: Security error '+evt.text);
    });
    loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function (evt:IOErrorEvent):void {
      //throwAdError('initError: Error loading '+evt.text);
    });
    loader.load(new URLRequest(asset.path), loaderContext);
  }

  /**
   * Ad asset loaded handler. Wires ad events and attempts to initialize ad.
   * @param evt
   * @param asset
   */
  private function onAdAssetLoaded(evt:Object, asset:Object):void {
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
    // Initialize ad
    _ad.initAd(asset.width, asset.height, "normal", asset.bitrate, "", "");
  }

  /** AD EVENT HANLDERS **/

  /**
   * Fired by the ad unit when it's content has finished loading.
   */
  private function adLoaded():void {
    // Add ad unit to stage
    addChild(_ad.displayObject);
    // Resize to current stage values and then start
    _ad.resizeAd(stage.width, stage.height, "normal");
    _ad.startAd();
  }

  /**
   * Fired by the ad unit when it's content has started.
   */
  private function adStarted():void {
    _adIsPlaying = true;
    _adDuration = _ad.adDuration();
    startDurationTimer();
    JSInterface.broadcast(VPAIDEvent.AdStarted);
    JSInterface.broadcast(VPAIDEvent.AdImpression);
  }

  /**
   * Fired by the ad unit when it's content has stopped.
   */
  public function adStopped():void {
    if (_adIsPlaying) {
      _adIsPlaying = false;
      _ad = null;
      dispatchEvent(new VPAIDEvent(VPAIDEvent.AdStopped));
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
    _durationTimer = new Timer(1000, _adDuration);
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