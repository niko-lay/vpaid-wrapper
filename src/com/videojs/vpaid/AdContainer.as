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

public class AdContainer extends Sprite implements IVPAID {

  private var _ad:*;
  private var _creativeContent:Array;
  private var _adIsPlaying:Boolean = false;
  private var _adDuration:Number;
  private var _durationTimer:Timer;

  public function AdContainer() {

  }

  /* PROPERTIES */

  public function get adLinear():Boolean {
    return _ad.adLinear;
  }

  public function get adWidth():Number {
    return _ad.adWidth;
  }

  public function get adHeight():Number {
    return _ad.adHeight;
  }

  public function get adExpanded():Boolean {
    return _ad.adExpanded;
  }

  public function get adSkippableState():Boolean {
    return _ad.adSkippableState;
  }

  public function get adRemainingTime():Number {
    return _ad.adRemainingTime;
  }

  public function get adDuration():Number {
    return _ad.adDuration;
  }

  public function get adVolume():Number {
    return _ad.adVolume;
  }

  public function set adVolume(value:Number):void {
    _ad.adVolume = value;
  }

  public function get adCompanions():String {
    return _ad.adCompanions;
  }

  public function get adIcons():Boolean {
    return _ad.adIcons;
  }

  /* METHODS */

  public function handshakeVersion(playerVPAIDVersion:String):String {
    return _ad.handshakeVersion(playerVPAIDVersion);
  }

  public function initAd(width:Number, height:Number, viewMode:String, desiredBitrate:Number, creativeData:String = "", environmentVars:String = ""):void {
    _ad.initAd(width, height, viewMode, desiredBitrate, creativeData, environmentVars);
  }

  public function resizeAd(width:Number, height:Number, viewMode:String):void {
    _ad.resizeAd(width, height, viewMode);
  }

  public function startAd():void {
    _ad.startAd();
  }

  public function stopAd():void {
    _ad.stopAd();
  }

  public function pauseAd():void {
    _ad.pauseAd();
  }

  public function resumeAd():void {
    _ad.resumeAd();
  }

  public function expandAd():void {
    _ad.expandAd();
  }

  public function collapseAd():void {
    _ad.collapseAd();
  }

  public function skipAd():void {
    _ad.collapseAd();
  }

  /*
  override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
    _ad.addEventListener(type, listener, useCapture, priority, useWeakReference);
  }
  override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void {
    _ad.removeEventListener(type, listener, useCapture);
  }
  override public function dispatchEvent(event:Event):Boolean {
    return _ad.dispatchEvent(event);
  }
  override public function hasEventListener(type:String):Boolean {
    return _ad.hasEventListener(type);
  }
  override public function willTrigger(type:String):Boolean {
    return _ad.willTrigger(type);
  }
  */



  public function init(adAssets:Array):void {
    _creativeContent = adAssets;
    var asset:Object = _creativeContent.shift();
    loadCreative(asset);
  }

  private function loadCreative(asset:Object):void {
    var loader:Loader = new Loader();
    var loaderContext:LoaderContext = new LoaderContext();
    loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function (evt:Object):void {
      onCreativeLoaded(evt, asset);
    });
    loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,
        function (evt:SecurityErrorEvent):void {
          //throwAdError('initError: Security error '+evt.text);
        });
    loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,
        function (evt:IOErrorEvent):void {
          //throwAdError('initError: Error loading '+evt.text);
        });
    loader.load(new URLRequest(asset.path), loaderContext);
  }

  private function onCreativeLoaded(evt:Object, asset:Object):void {
    _ad = evt.target.content.getVPAID();
    _adDuration = asset.duration;

    _ad.addEventListener(VPAIDEvent.AdLoaded, function ():void {
      adLoaded();
    });

    _ad.addEventListener(VPAIDEvent.AdStopped, function ():void {
      adStopped();
    });

    _ad.addEventListener(VPAIDEvent.AdError, function ():void {
      adError();
    });

    //TODO: get rid of hardcoded bitrate
    _ad.initAd(asset.width, asset.height, "normal", 800, "", "");
  }

  protected function startDurationTimer():void {
    _durationTimer = new Timer(1000, _adDuration);
    _durationTimer.addEventListener(TimerEvent.TIMER, adDurationTick);
    _durationTimer.addEventListener(TimerEvent.TIMER_COMPLETE, adDurationComplete);
    _durationTimer.start();
  }

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

  public function adStarted():void {
    _adIsPlaying = true;
    startDurationTimer();
    dispatchEvent(new VPAIDEvent(VPAIDEvent.AdStarted));
    //_model.broadcastEventExternally(VPAIDEvent.AdPluginEventStart);

    dispatchEvent(new VPAIDEvent(VPAIDEvent.AdImpression));
    //_model.broadcastEventExternally(VPAIDEvent.AdPluginEventImpression);

  }

  public function adLoaded():void {
    addChild(_ad);
    _ad.resizeAd(stage.width, stage.height, "normal");
    _ad.startAd();
    adStarted();
  }

  private function adError():void {
    _ad.stopAd();
    dispatchEvent(new VPAIDEvent(VPAIDEvent.AdStopped));
  }

  public function adStopped():void {
    console.log('ZOMFG AD STOPPED');
    if (_adIsPlaying) {
      _adIsPlaying = false;
      _ad = null;
      dispatchEvent(new VPAIDEvent(VPAIDEvent.AdStopped));
      JSInterface.broadcast(VPAIDEvent.AdStopped);
    }
  }

  private function adDurationTick(evt:Object):void {
    //_model.broadcastEventExternally(VPAIDEvent.AdPluginEventTimeRemaining);

    ExternalInterface.call("console.log", _ad.adSkippableState)

    if (_ad.adSkippableState) {
      //_model.broadcastEventExternally(VPAIDEvent.AdPluginEventCanSkip);
    }

  }

  private function adDurationComplete(evt:Object):void {
    if (_durationTimer) {
      _durationTimer.removeEventListener(TimerEvent.TIMER, adDurationTick);
      _durationTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, adDurationComplete);
      _durationTimer = null;
    }

    adStopped();
  }
}

}