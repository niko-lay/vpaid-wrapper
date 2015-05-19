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
      ExternalInterface.addCallback("echo", onEchoCalled);
      ExternalInterface.addCallback("initAd", onInitAdCalled);
      ExternalInterface.addCallback("startAd", onStartAdCalled);
      ExternalInterface.addCallback("stopAd", onStopAdCalled);
      ExternalInterface.addCallback("resizeAd", onResizeAdCalled);
      ExternalInterface.addCallback("getProperty", onGetPropertyCalled);
      ExternalInterface.addCallback("setProperty", onSetPropertyCalled);
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
      } catch (e:Error) {
        if (loaderInfo.parameters.debug != undefined && loaderInfo.parameters.debug == "true") {
          throw new Error(e.message);
        }
      }
    }
    _ready = true;
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
   * @param bitrate
   */
  private function onInitAdCalled(width:Number, height:Number, viewMode:String, bitrate:Number):void {
    if (_ready) {
      _app.model.ad.initAd(width, height, viewMode, bitrate);
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
   * External read access to VPAID object properties.
   * @param pPropertyName
   * @return
   */
  private function onGetPropertyCalled(pPropertyName:String = ""):* {
    if (_ready) {
      return _app.model.getAdProperty(pPropertyName);
    }
    return null;
  }

  /**
   * External write access to VPAID object properties.
   * @param pPropertyName
   * @param pValue
   */
  private function onSetPropertyCalled(pPropertyName:String = "", pValue:* = null):void {
    if (_ready) {
      _app.model.setAdProperty(pPropertyName, pValue);
    }
  }
}

}
