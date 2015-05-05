package com.vpaidwrapper.vpaid {

import flash.events.Event;
import flash.events.EventDispatcher;

public class VPAID extends EventDispatcher implements IVPAID {
  private var _ad:*;

  public function VPAID(ad:*) {
    if(ad.hasOwnProperty('getVPAID')) {
      _ad = ad.getVPAID();
    } else {
      _ad = ad;
    }
  }

  /* PROPERTIES */

  public function get displayObject():* {
    return _ad
  }

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
    // Fallback for VPAID 1.0
    if (_ad.hasOwnProperty('adDuration')) {
      return _ad.adDuration;
    } else {
      return -1;
    }
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

  /* EVENT OVERRIDES */

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
}

}