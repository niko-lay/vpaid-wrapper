package com.vpaidwrapper.vpaid {

import com.vpaidwrapper.*;
import com.vpaidwrapper.events.VPAIDEvent;
import com.vpaidwrapper.events.VPAIDWrapperEvent;
import com.vpaidwrapper.events.VPAIDWrapperErrorEvent;
import com.vpaidwrapper.util.JSInterface;
import com.vpaidwrapper.util.console;

import flash.display.Loader;
import flash.display.Sprite;
import flash.events.*;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.system.SecurityDomain;
import flash.system.ApplicationDomain;

import flash.external.ExternalInterface;

public class AdContainer extends EventDispatcher {

  private static var _instance:AdContainer;

  private var _ad:VPAID = null;

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
   * Returns a pointer to the displayable ad component.
   */
  public function get displayObject():* {
    if (_ad != null) {
      return _ad.displayObject;
    }
  }

  /**
   * Provides external access to the VPAID ad API.
   */
  public function get ad():VPAID {
    return _ad;
  }

  /** INITIALIZATION **/

  /**
   * Downloads and loads the given ad asset.
   * @param asset
   */
  public function loadAdUnit(src:String):void {
    var loader:Loader = new Loader();
    var loaderContext:LoaderContext = new LoaderContext();
    loaderContext.applicationDomain = ApplicationDomain.currentDomain;
    loaderContext.securityDomain = SecurityDomain.currentDomain;
    loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onAdUnitLoaded);
    loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function (evt:SecurityErrorEvent):void {
      JSInterface.broadcastError(VPAIDWrapperErrorEvent.LOAD_ERROR, evt);
    });
    loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function (evt:IOErrorEvent):void {
      JSInterface.broadcastError(VPAIDWrapperErrorEvent.LOAD_ERROR, evt);
    });
    loader.load(new URLRequest(src), loaderContext);
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
    _ad.addEventListener(VPAIDEvent.AdSkippableStateChange, adSkippableStateChange);
    _ad.addEventListener(VPAIDEvent.AdSizeChange, adSizeChange);
    _ad.addEventListener(VPAIDEvent.AdLinearChange, adLinearChange);
    _ad.addEventListener(VPAIDEvent.AdDurationChange, adDurationChange);
    _ad.addEventListener(VPAIDEvent.AdExpandedChange, adExpandedChange);
    _ad.addEventListener(VPAIDEvent.AdRemainingTimeChange, adRemainingTimeChange);
    _ad.addEventListener(VPAIDEvent.AdVolumeChange, adVolumeChange);
    _ad.addEventListener(VPAIDEvent.AdImpression, adImpression);
    _ad.addEventListener(VPAIDEvent.AdVideoStart, adVideoStart);
    _ad.addEventListener(VPAIDEvent.AdVideoFirstQuartile, adVideoFirstQuartile);
    _ad.addEventListener(VPAIDEvent.AdVideoMidpoint, adVideoMidpoint);
    _ad.addEventListener(VPAIDEvent.AdVideoThirdQuartile, adVideoThirdQuartile);
    _ad.addEventListener(VPAIDEvent.AdVideoComplete, adVideoComplete);
    _ad.addEventListener(VPAIDEvent.AdClickThru, adClickThru);
    _ad.addEventListener(VPAIDEvent.AdInteraction, adInteraction);
    _ad.addEventListener(VPAIDEvent.AdUserAcceptInvitation, adUserAcceptInvitation);
    _ad.addEventListener(VPAIDEvent.AdUserMinimize, adUserMinimize);
    _ad.addEventListener(VPAIDEvent.AdUserClose, adUserClose);
    _ad.addEventListener(VPAIDEvent.AdPaused, adPaused);
    _ad.addEventListener(VPAIDEvent.AdPlaying, adPlaying);
    _ad.addEventListener(VPAIDEvent.AdLog, adLog);
    _ad.addEventListener(VPAIDEvent.AdError, adError);
    // Determine VPAID version (mostly for debugging)
    var handshakeVersion:String = _ad.handshakeVersion('2.0');
    console.log('AdContainer::onAdUnitLoaded - VPAID Handshake version:', handshakeVersion);
    // Notify containing app that we're ready for API calls
    dispatchEvent(new VPAIDWrapperEvent(VPAIDWrapperEvent.READY));
  }

  /**
   * Resource cleanup after ad has completed or failed.
   */
  private function clearCurrentAdUnit():void {
    _ad.removeEventListener(VPAIDEvent.AdLoaded, adLoaded);
    _ad.removeEventListener(VPAIDEvent.AdStarted, adStarted);
    _ad.removeEventListener(VPAIDEvent.AdStopped, adStopped);
    _ad.removeEventListener(VPAIDEvent.AdSkipped, adSkipped);
    _ad.removeEventListener(VPAIDEvent.AdSkippableStateChange, adSkippableStateChange);
    _ad.removeEventListener(VPAIDEvent.AdSizeChange, adSizeChange);
    _ad.removeEventListener(VPAIDEvent.AdLinearChange, adLinearChange);
    _ad.removeEventListener(VPAIDEvent.AdDurationChange, adDurationChange);
    _ad.removeEventListener(VPAIDEvent.AdExpandedChange, adExpandedChange);
    _ad.removeEventListener(VPAIDEvent.AdRemainingTimeChange, adRemainingTimeChange);
    _ad.removeEventListener(VPAIDEvent.AdVolumeChange, adVolumeChange);
    _ad.removeEventListener(VPAIDEvent.AdImpression, adImpression);
    _ad.removeEventListener(VPAIDEvent.AdVideoStart, adVideoStart);
    _ad.removeEventListener(VPAIDEvent.AdVideoFirstQuartile, adVideoFirstQuartile);
    _ad.removeEventListener(VPAIDEvent.AdVideoMidpoint, adVideoMidpoint);
    _ad.removeEventListener(VPAIDEvent.AdVideoThirdQuartile, adVideoThirdQuartile);
    _ad.removeEventListener(VPAIDEvent.AdVideoComplete, adVideoComplete);
    _ad.removeEventListener(VPAIDEvent.AdClickThru, adClickThru);
    _ad.removeEventListener(VPAIDEvent.AdInteraction, adInteraction);
    _ad.removeEventListener(VPAIDEvent.AdUserAcceptInvitation, adUserAcceptInvitation);
    _ad.removeEventListener(VPAIDEvent.AdUserMinimize, adUserMinimize);
    _ad.removeEventListener(VPAIDEvent.AdUserClose, adUserClose);
    _ad.removeEventListener(VPAIDEvent.AdPaused, adPaused);
    _ad.removeEventListener(VPAIDEvent.AdPlaying, adPlaying);
    _ad.removeEventListener(VPAIDEvent.AdLog, adLog);
    _ad.removeEventListener(VPAIDEvent.AdError, adError);
    _ad = null;
  }

  /** AD EVENT HANLDERS **/

  /**
   * Fired by the ad unit when it's content has finished loading.
   * @param event
   */
  private function adLoaded(event:Object):void {
    // Add ad unit to stage
    dispatchEvent(new VPAIDWrapperEvent(VPAIDWrapperEvent.AD_LOADED));
    JSInterface.broadcast(VPAIDEvent.AdLoaded, event.data);
  }

  /**
   * Fired by the ad unit when it's content has started.
   * @param event
   */
  private function adStarted(event:Object):void {
    JSInterface.broadcast(VPAIDEvent.AdStarted, event.data);
  }

  /**
   * Fired by the ad unit when it's content has stopped.
   * @param event
   */
  public function adStopped(event:Object):void {
    if (_ad !== null) {
      clearCurrentAdUnit();
      JSInterface.broadcast(VPAIDEvent.AdStopped, event.data);
      dispatchEvent(new VPAIDWrapperEvent(VPAIDWrapperEvent.AD_DESTROYED));
    }
  }

  /**
   * Fired by the ad unit when it's content has been skipped.
   * @param event
   */
  public function adSkipped(event:Object):void {
    JSInterface.broadcast(VPAIDEvent.AdSkipped, event.data);
  }

  /**
   * Fired by the ad unit when it's skippable state has changed.
   * @param event
   */
  public function adSkippableStateChange(event:Object):void {
    JSInterface.broadcast(VPAIDEvent.AdSkippableStateChange, event.data);
  }

  /**
   * Fired by the ad unit when it size changes, usually as a response to resizeAd().
   * @param event
   */
  public function adSizeChange(event:Object):void {
    JSInterface.broadcast(VPAIDEvent.AdSizeChange, event.data);
  }

  /**
   * Fired by the ad unit when it has changed playback mode.
   * @param event
   */
  public function adLinearChange(event:Object):void {
    JSInterface.broadcast(VPAIDEvent.AdLinearChange, event.data);
  }

  /**
   * Fired by the ad unit when duration changes in response to user interaction.
   * @param event
   */
  public function adDurationChange(event:Object):void {
    JSInterface.broadcast(VPAIDEvent.AdDurationChange, event.data);
  }

  /**
   * Fired by the ad unit when its expanded state changes.
   * @param event
   */
  public function adExpandedChange(event:Object):void {
    JSInterface.broadcast(VPAIDEvent.AdExpandedChange, event.data);
  }

  /**
   * (VPAID 1.0) Fired by the ad unit when its remaining playback time has changed.
   * @param event
   */
  public function adRemainingTimeChange(event:Object):void {
    JSInterface.broadcast(VPAIDEvent.AdRemainingTimeChange, event.data);
  }

  /**
   * Fired by the ad unit when its volume changes.
   * @param event
   */
  public function adVolumeChange(event:Object):void {
    JSInterface.broadcast(VPAIDEvent.AdVolumeChange, event.data);
  }

  /**
   * Fired by the ad unit when it considers that the ad impression has occurred, which could be different from ad start.
   * @param event
   */
  public function adImpression(event:Object):void {
    JSInterface.broadcast(VPAIDEvent.AdImpression, event.data);
  }

  /**
   * Fired by the ad unit when ad video playback begins.
   * @param event
   */
  public function adVideoStart(event:Object):void {
    JSInterface.broadcast(VPAIDEvent.AdVideoStart, event.data);
  }

  /**
   * Fired by the ad unit when the first quartile of the ad video has been reached.
   * @param event
   */
  public function adVideoFirstQuartile(event:Object):void {
    JSInterface.broadcast(VPAIDEvent.AdVideoFirstQuartile, event.data);
  }

  /**
   * Fired by the ad unit when the mid-point of the ad video has been reached.
   * @param event
   */
  public function adVideoMidpoint(event:Object):void {
    JSInterface.broadcast(VPAIDEvent.AdVideoMidpoint, event.data);
  }

  /**
   * Fired by the ad unit when the third quartile of the ad video has been reached.
   * @param event
   */
  public function adVideoThirdQuartile(event:Object):void {
    JSInterface.broadcast(VPAIDEvent.AdVideoThirdQuartile, event.data);
  }

  /**
   * Fired by the ad unit when the ad video playback has completed.
   * @param event
   */
  public function adVideoComplete(event:Object):void {
    JSInterface.broadcast(VPAIDEvent.AdVideoComplete, event.data);
  }

  /**
   * Fired by the ad unit when the user clicks on the ad.
   * @param event
   */
  public function adClickThru(event:Object):void {
    JSInterface.broadcast(VPAIDEvent.AdClickThru, event.data);
  }

  /**
   * Fired by the ad unit when the user interacts with a feature in the ad.
   * @param event
   */
  public function adInteraction(event:Object):void {
    JSInterface.broadcast(VPAIDEvent.AdInteraction, event.data);
  }

  /**
   * Fired by the ad unit when the user accepts an invitation from within the ad.
   * @param event
   */
  public function adUserAcceptInvitation(event:Object):void {
    JSInterface.broadcast(VPAIDEvent.AdUserAcceptInvitation, event.data);
  }

  /**
   * Fired by the ad unit when the user minimizes the ad.
   * @param event
   */
  public function adUserMinimize(event:Object):void {
    JSInterface.broadcast(VPAIDEvent.AdUserMinimize, event.data);
  }

  /**
   * Fired by the ad unit when the user closes the ad.
   * @param event
   */
  public function adUserClose(event:Object):void {
    JSInterface.broadcast(VPAIDEvent.AdUserClose, event.data);
  }

  /**
   * Fired by the ad unit when the ad video is paused.
   * @param event
   */
  public function adPaused(event:Object):void {
    JSInterface.broadcast(VPAIDEvent.AdPaused, event.data);
  }

  /**
   * Fired by the ad unit when the ad video begins playing.
   * @param event
   */
  public function adPlaying(event:Object):void {
    JSInterface.broadcast(VPAIDEvent.AdPlaying, event.data);
  }

  /**
   * Fired by the ad unit when it wishes to log debug data.
   * @param event
   */
  public function adLog(event:Object):void {
    JSInterface.broadcast(VPAIDEvent.AdLog, event.data);
  }

  /**
   * Fired by the ad unit when it has encountered an error.
   * @param event
   */
  private function adError(event:Object):void {
    JSInterface.broadcast(VPAIDEvent.AdError, event.data);
  }
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