package {

import com.vpaidwrapper.WrapperApp;
import com.vpaidwrapper.events.VPAIDWrapperEvent;
import com.vpaidwrapper.util.JSInterface;
import com.vpaidwrapper.util.console;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.external.ExternalInterface;
import flash.geom.Rectangle;
import flash.system.Security;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;
import flash.utils.ByteArray;
import flash.utils.Timer;
import flash.utils.setTimeout;

[SWF(backgroundColor="#000000", frameRate="60", width="480", height="270")]
public class VPAIDWrapper extends Sprite {

  public const VERSION:String = CONFIG::version;

  private var _app:WrapperApp;
  private var _stageSizeTimer:Timer;
  private var _ready:Boolean = false;

  /**
   * Constructor.
   */
  public function VPAIDWrapper() {
    _stageSizeTimer = new Timer(250);
    _stageSizeTimer.addEventListener(TimerEvent.TIMER, onStageSizeTimerTick);
    addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
  }

  /**
   * Main app initialization point.
   */
  private function init():void {
    console.log('VPAIDWrapper::init - initializing with ad source:', loaderInfo.parameters.src);
    // Allow JS calls from other domains
    Security.allowDomain("*");
    Security.allowInsecureDomain("*");
    setUpContextMenu();
    // Uncaught event handler
    if (loaderInfo.hasOwnProperty("uncaughtErrorEvents")) {
      // we'll want to suppress ANY uncaught debug errors in production (for the sake of ux)
      // IEventDispatcher(loaderInfo["uncaughtErrorEvents"]).addEventListener("uncaughtError", onUncaughtError);
    }
    // Wire external callbacks
    if (ExternalInterface.available) {
      registerExternalMethods();
    }
    // Initialize and add application to stage
    _app = new WrapperApp();
    _app.init(loaderInfo.parameters.src, stage.stageWidth, stage.stageHeight);
    addChild(_app);
    // Notify wrapper's container when ad unit is ready to receive commands
    _app.model.addEventListener(VPAIDWrapperEvent.READY, onReady);
    _app.model.addEventListener(VPAIDWrapperEvent.AD_DESTROYED, onAdDestroyed);
  }

  /**
   * Adds a context menu with wrapper info.
   */
  private function setUpContextMenu():void {
    var _ctxVersion:ContextMenuItem = new ContextMenuItem("VPAID Wrapper v" + VERSION, false, false);
    var _ctxAbout:ContextMenuItem = new ContextMenuItem("Copyright © 2015 OnCircle, Inc.", false, false);
    var _ctxMenu:ContextMenu = new ContextMenu();
    _ctxMenu.hideBuiltInItems();
    _ctxMenu.customItems.push(_ctxVersion, _ctxAbout);
    this.contextMenu = _ctxMenu;
  }

  /**
   * Attempts to wire callbacks for external methods.
   */
  private function registerExternalMethods():void {
    try {
      // Debug methods
      ExternalInterface.addCallback("echo", onEchoCalled);
      // VPAID methods
      ExternalInterface.addCallback("initAd", onInitAdCalled);
      ExternalInterface.addCallback("resizeAd", onResizeAdCalled);
      ExternalInterface.addCallback("startAd", onStartAdCalled);
      ExternalInterface.addCallback("stopAd", onStopAdCalled);
      ExternalInterface.addCallback("pauseAd", onPauseAdCalled);
      ExternalInterface.addCallback("resumeAd", onResumeAdCalled);
      ExternalInterface.addCallback("expandAd", onExpandAdCalled);
      ExternalInterface.addCallback("collapseAd", onCollapseAdCalled);
      ExternalInterface.addCallback("skipAd", onSkipAdCalled);
      // Property getters/setters
      ExternalInterface.addCallback("getAdLinear", onGetAdLinearCalled);
      ExternalInterface.addCallback("getAdWidth", onGetAdWidthCalled);
      ExternalInterface.addCallback("getAdHeight", onGetAdHeightCalled);
      ExternalInterface.addCallback("getAdExpanded", onGetAdExpandedCalled);
      ExternalInterface.addCallback("getAdSkippableState", onGetAdSkippableStateCalled);
      ExternalInterface.addCallback("getAdRemainingTime", onGetAdRemainingTimeCalled);
      ExternalInterface.addCallback("getAdDuration", onGetAdDurationCalled);
      ExternalInterface.addCallback("getAdVolume", onGetAdVolumeCalled);
      ExternalInterface.addCallback("setAdVolume", onSetAdVolumeCalled);
      ExternalInterface.addCallback("getAdCompanions", onGetAdCompanionsCalled);
      ExternalInterface.addCallback("getAdIcons", onGetAdIconsCalled);
      // Set custom names for callback functions if provided
      if (loaderInfo.parameters.eventFunction != undefined) {
        JSInterface.jsEventProxyName = loaderInfo.parameters.eventFunction;
      }
      if (loaderInfo.parameters.errorFunction != undefined) {
        JSInterface.jsErrorEventProxyName = loaderInfo.parameters.errorFunction;
      }
    } catch (e:SecurityError) {
      if (loaderInfo.parameters.debug != undefined && loaderInfo.parameters.debug == "true") {
        throw new SecurityError(e.message);
      }
    } catch (e:Error) {
      if (loaderInfo.parameters.debug != undefined && loaderInfo.parameters.debug == "true") {
        throw new Error(e.message);
      }
    }
  }

  /**
   * Notifies container that the VPAID wrapper has finished loading.
   */
  private function onReady(e:Event):void {
    if (loaderInfo.parameters.readyFunction != undefined) {
      try {
        ExternalInterface.call(JSInterface.cleanEIString(loaderInfo.parameters.readyFunction), ExternalInterface.objectID);
        _ready = true;
      } catch (e:Error) {
        if (loaderInfo.parameters.debug != undefined && loaderInfo.parameters.debug == "true") {
          throw new Error(e.message);
        }
      }
    }
  }

  /**
   * Fired when an ad unit is terminated.
   * @param e
   */
  private function onAdDestroyed(e:Event):void {
    _ready = false;
  }

  /**
   * Uncaught event hanlder.
   * @param e
   */
  private function onUncaughtError(e:Event):void {
    e.preventDefault();
  }

  /** STAGE EVENTS **/

  /**
   * Monitors stage state.
   * @param e
   */
  private function onStageSizeTimerTick(e:TimerEvent):void {
    if (stage.stageWidth > 0 && stage.stageHeight > 0) {
      _stageSizeTimer.stop();
      _stageSizeTimer.removeEventListener(TimerEvent.TIMER, onStageSizeTimerTick);
      init();
    }
  }

  /**
   * Wires additional events once stage is initialized.
   * @param e
   */
  private function onAddedToStage(e:Event):void {
    stage.addEventListener(MouseEvent.CLICK, onStageClick);
    stage.addEventListener(Event.RESIZE, onStageResize);
    stage.scaleMode = StageScaleMode.NO_SCALE;
    stage.align = StageAlign.TOP_LEFT;
    _stageSizeTimer.start();
  }

  /**
   * Stage size changed.
   * @param e
   */
  private function onStageResize(e:Event):void {
    if (_app != null) {
      var data:Object = {
        width: stage.stageWidth,
        height: stage.stageHeight
      };
      _app.model.dispatchEvent(new VPAIDWrapperEvent(VPAIDWrapperEvent.STAGE_RESIZE, data));
    }
  }

  /**
   * Global click event.
   * @param e
   */
  private function onStageClick(e:MouseEvent):void {
    //_app.model.broadcastEventExternally(ExternalEventName.ON_STAGE_CLICK);
  }

  /** EXTERNAL METHODS **/

  /**
   * External echo function for debug purposes.
   * @param pResponse
   * @return
   */
  private function onEchoCalled(pResponse:* = null):* {
    return pResponse;
  }

  /**
   * VPAID initAd method handler.
   * @param width
   * @param height
   * @param viewMode
   * @param desiredBitrate
   * @param creativeData
   * @param environmentVars
   */
  private function onInitAdCalled(width:Number, height:Number, viewMode:String, desiredBitrate:Number, creativeData:String="", environmentVars:String=""):void {
    if (_ready) {
      _app.model.ad.initAd(width, height, viewMode, desiredBitrate, creativeData, environmentVars);
    }
  }

  /**
   * VPAID resizeAd method handler.
   * @param width
   * @param height
   * @param viewMode
   */
  private function onResizeAdCalled(width:Number, height:Number, viewMode:String):void {
    if (_ready) {
      _app.model.ad.resizeAd(width, height, viewMode);
    }
  }

  /**
   * VPAID startAd method handler.
   */
  private function onStartAdCalled():void {
    if (_ready) {
      _app.model.ad.startAd();
    }
  }

  /**
   * VPAID stopAd method handler.
   */
  private function onStopAdCalled():void {
    if (_ready) {
      _app.model.ad.stopAd();
    }
  }

  /**
   * VPAID pauseAd method handler.
   */
  private function onPauseAdCalled():void {
    if (_ready) {
      _app.model.ad.pauseAd();
    }
  }

  /**
   * VPAID resumeAd method handler.
   */
  private function onResumeAdCalled():void {
    if (_ready) {
      _app.model.ad.resumeAd();
    }
  }

  /**
   * VPAID expandAd method handler.
   */
  private function onExpandAdCalled():void {
    if (_ready) {
      _app.model.ad.expandAd();
    }
  }

  /**
   * VPAID collapseAd method handler.
   */
  private function onCollapseAdCalled():void {
    if (_ready) {
      _app.model.ad.collapseAd();
    }
  }

  /**
   * VPAID skipAd method handler.
   */
  private function onSkipAdCalled():void {
    if (_ready) {
      _app.model.ad.skipAd();
    }
  }

  /** EXTERNAL PROPERTY GETTER/SETTERS **/

  /**
   * adLinear property getter.
   * @return
   */
  private function onGetAdLinearCalled():* {
    if (_ready) {
      return _app.model.ad.adLinear;
    }
  }

  /**
   * adWidth property getter.
   * @return
   */
  private function onGetAdWidthCalled():* {
    if (_ready) {
      return _app.model.ad.adWidth;
    }
  }

  /**
   * adHeight property getter.
   * @return
   */
  private function onGetAdHeightCalled():* {
    if (_ready) {
      return _app.model.ad.adHeight;
    }
  }

  /**
   * adExpanded property getter.
   * @return
   */
  private function onGetAdExpandedCalled():* {
    if (_ready) {
      return _app.model.ad.adExpanded;
    }
  }

  /**
   * adSkippableState property getter.
   * @return
   */
  private function onGetAdSkippableStateCalled():* {
    if (_ready) {
      return _app.model.ad.adSkippableState;
    }
  }

  /**
   * adRemainingTime property getter.
   * @return
   */
  private function onGetAdRemainingTimeCalled():* {
    if (_ready) {
      return _app.model.ad.adRemainingTime;
    }
  }

  /**
   * adDuration property getter.
   * @return
   */
  private function onGetAdDurationCalled():* {
    if (_ready) {
      return _app.model.ad.adDuration;
    }
  }

  /**
   * adVolume property getter.
   * @return
   */
  private function onGetAdVolumeCalled():* {
    if (_ready) {
      return _app.model.ad.adVolume;
    }
  }

  /**
   * adVolume property setter.
   * @param value
   */
  private function onSetAdVolumeCalled(value:Number):void {
    if (_ready) {
      _app.model.ad.adVolume = value;
    }
  }

  /**
   * adCompanions property getter.
   * @return
   */
  private function onGetAdCompanionsCalled():* {
    if (_ready) {
      return _app.model.ad.adCompanions;
    }
  }

  /**
   * adIcons property getter.
   * @return
   */
  private function onGetAdIconsCalled():* {
    if (_ready) {
      return _app.model.ad.adIcons;
    }
  }
}

}
